import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../secure_storage.dart';

class ProfileImageProvider extends ChangeNotifier {
  File? _image;
  String? _currentUser;
  String? _remoteImageUrl;
  String? _currentEmail;
  bool _initialized = false;

  File? get image => _image;
  String? get remoteImageUrl => _remoteImageUrl;
  bool get initialized => _initialized;

  final ImagePicker _picker = ImagePicker();

  /// Initialize profile image provider
  Future<void> initialize() async {
    try {
      final username = await SecureStorage.read('user_name');
      final email = await SecureStorage.read('user_email');
      _currentEmail = email;

      if (username != null && username.isNotEmpty) {
        await loadImageForUser(username);
      } else {
        _clearLocal();
      }
    } catch (e) {
      debugPrint("❌ Error initializing profile image: $e");
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Fetch remote agent image by email
  Future<void> fetchRemoteProfileImage(String email) async {
    try {
      final token = await SecureStorage.getToken();

      // Try direct email filter (adjust if your API uses a different param name)
      Uri uri = Uri.https('akarat.com', '/api/agents', {
        'email': email,
        'per_page': '1', // keep it small
      });

      http.Response response = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      Map<String, dynamic>? dataMap;
      List<dynamic> list = [];

      if (response.statusCode == 200) {
        dataMap = json.decode(response.body) as Map<String, dynamic>;
        final d = dataMap['data'];
        if (d is Map && d['data'] is List) list = d['data'];
        if (d is List) list = d;
      }

      // Fallback: use search if 'email' filter not supported / empty result
      if (list.isEmpty) {
        uri = Uri.https('akarat.com', '/api/agents', {
          'search': email,
          'per_page': '1',
        });
        response = await http.get(uri, headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        });
        if (response.statusCode == 200) {
          dataMap = json.decode(response.body) as Map<String, dynamic>;
          final d = dataMap['data'];
          if (d is Map && d['data'] is List) list = d['data'];
          if (d is List) list = d;
        }
      }

      String? url;
      if (list.isNotEmpty) {
        final a = list.first as Map<String, dynamic>;
        url = (a['image'] ?? a['agent_image'])?.toString();
      }

      if (url != null && url.isNotEmpty) {
        // Force HTTPS (devices may block http)
        if (url.startsWith('http://')) {
          url = url.replaceFirst('http://', 'https://');
        }
        // Cache-buster to avoid stale CDN images on device
        final sep = url.contains('?') ? '&' : '?';
        _remoteImageUrl = '$url${sep}v=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        _remoteImageUrl = null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching remote profile image: $e");
      _remoteImageUrl = null;
    }
  }


  /// Load image for current user (local takes priority)
  Future<void> loadImageForUser(String username) async {
    try {
      _currentUser = username.trim().toLowerCase();

      // 1) Try remote first so it works across devices
      if (_currentEmail != null && _currentEmail!.isNotEmpty) {
        await fetchRemoteProfileImage(_currentEmail!);
      }

      // 2) If remote is not available, use local base64 (device-local fallback)
      if (_remoteImageUrl == null) {
        final base64String = await SecureStorage.read('profile_image_base64_$_currentUser');
        if (base64String != null && base64String.isNotEmpty) {
          final bytes = base64Decode(base64String);
          final tempDir = await getTemporaryDirectory();
          final tempPath = '${tempDir.path}/profile_$_currentUser.png';
          _image = await File(tempPath).writeAsBytes(bytes);
        } else {
          _image = null;
        }
      } else {
        _image = null; // show network image in the UI
      }

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error loading profile image for $_currentUser: $e");
    }
  }



  /// Pick & save a new local profile image
  /// Pick & save a new local profile image
  /// Pick & save a new local profile image
  Future<void> pickImage() async {
    try {
      _currentUser = await SecureStorage.read('user_name');
      if (_currentUser == null || _currentUser!.isEmpty) return;

      final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      _image = File(picked.path);
      _remoteImageUrl = null;

      // Save local base64 (so current device shows immediately)
      final bytes = await _image!.readAsBytes();
      final base64String = base64Encode(bytes);
      await SecureStorage.write('profile_image_base64_$_currentUser', base64String);
      notifyListeners();

      // ⬇️ Make it available on all devices
      await uploadPickedImageToServer(_image!);

    } catch (e) {
      debugPrint("❌ Error picking/saving profile image: $e");
    }
  }



  Future<void> uploadPickedImageToServer(File file) async {
    final token = await SecureStorage.getToken();
    final uri = Uri.https('akarat.com', '/api/agent/profile-image'); // <-- change to your real endpoint
    final req = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      })
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    // If your API needs extra fields, uncomment/adjust:
    // if (_currentEmail != null) req.fields['email'] = _currentEmail!;
    // req.fields['agent_id'] = '...';

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode == 200 || res.statusCode == 201) {
      final map = json.decode(body) as Map<String, dynamic>;
      final url = (map['image_url'] ?? map['url'])?.toString();
      if (url != null && url.isNotEmpty) {
        final httpsUrl = url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;
        // cache-bust so device doesn’t show stale image
        final sep = httpsUrl.contains('?') ? '&' : '?';
        _remoteImageUrl = '$httpsUrl${sep}v=${DateTime.now().millisecondsSinceEpoch}';
        _image = null; // prefer server image across devices
        notifyListeners();
      }
    } else {
      debugPrint('❌ Upload failed: ${res.statusCode} $body');
    }
  }



  /// Delete the profile image
  Future<void> deleteImage() async {
    try {
      if (_currentUser == null || _currentUser!.isEmpty) return;

      await SecureStorage.delete('profile_image_base64_$_currentUser');
      _image = null;

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/profile_$_currentUser.png';
      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      // If no local, fall back to remote
      if (_currentEmail != null && _currentEmail!.isNotEmpty) {
        await fetchRemoteProfileImage(_currentEmail!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error deleting profile image: $e");
    }
  }

  /// Clear all on logout
  Future<void> clear() async {
    if (_currentUser != null && _currentUser!.isNotEmpty) {
      await SecureStorage.delete('profile_image_base64_$_currentUser');
    }
    _clearLocal();
    notifyListeners();
  }

  void _clearLocal() {
    _currentUser = null;
    _currentEmail = null;
    _image = null;
    _remoteImageUrl = null;
  }

  /// Refresh image
  Future<void> refreshImage() async {
    if (_currentUser != null && _currentUser!.isNotEmpty) {
      await loadImageForUser(_currentUser!);
    }
  }
}
