// lib/providers/profile_image_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../secure_storage.dart';
import '../services/api_service.dart';

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

  /// Initialize: load user info
  Future<void> initialize() async {
    try {
      final username = await SecureStorage.getUserName();
      final email = await SecureStorage.getUserEmail();

      _currentEmail = email?.trim().isNotEmpty == true ? email : null;
      _currentUser = username?.trim().isNotEmpty == true ? username!.trim().toLowerCase() : null;

      if (_currentUser != null) {
        await loadImageForUser(_currentUser!);
      } else {
        _clearLocal();
      }
    } catch (e) {
      debugPrint("Error initializing profile image: $e");
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Fetch profile image from backend (agent image)
  Future<void> fetchRemoteProfileImage(String email) async {
    try {
      final token = await SecureStorage.getToken();
      final baseHost = ApiService.baseUrl.replaceFirst(RegExp(r'^https?://'), '');

      final uri = Uri.https(baseHost, '/agents', {
        'email': email,
        'per_page': '1',
      });

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      List<dynamic> agents = [];

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'];
        if (data is Map && data['data'] is List) agents = data['data'] as List;
        if (data is List) agents = data;
      }

      // Fallback: search by email
      if (agents.isEmpty) {
        final searchUri = Uri.https(baseHost, '/agents', {
          'search': email,
          'per_page': '1',
        });
        final resp = await http.get(searchUri, headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        }).timeout(const Duration(seconds: 15));

        if (resp.statusCode == 200) {
          final json = jsonDecode(resp.body);
          final data = json['data'];
          if (data is Map && data['data'] is List) agents = data['data'];
          if (data is List) agents = data;
        }
      }

      String? url;
      if (agents.isNotEmpty) {
        final agent = agents.first as Map<String, dynamic>;
        url = (agent['image'] ?? agent['agent_image'] ?? agent['profile_image'])?.toString();
      }

      if (url != null && url.isNotEmpty) {
        if (url.startsWith('http://')) url = url.replaceFirst('http://', 'https://');
        final sep = url.contains('?') ? '&' : '?';
        _remoteImageUrl = '$url${sep}ts=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        _remoteImageUrl = null;
      }
    } catch (e) {
      debugPrint("Error fetching remote image: $e");
      _remoteImageUrl = null;
    }
  }

  /// Load image: remote → local cache → nothing
  Future<void> loadImageForUser(String username) async {
    _currentUser = username.trim().toLowerCase();

    // 1. Try remote first (best: works across devices)
    if (_currentEmail != null && _currentEmail!.isNotEmpty) {
      await fetchRemoteProfileImage(_currentEmail!);
    }

    // 2. Local fallback (optional: you can remove this block entirely if you want server-only)
    if (_remoteImageUrl == null) {
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/profile_image_cache.png';
      final localFile = File(localPath);

      if (await localFile.exists()) {
        _image = localFile;
      } else {
        _image = null;
      }
    } else {
      _image = null; // show network image
    }

    notifyListeners();
  }

  /// Pick new image
  Future<void> pickImage() async {
    try {
      final username = await SecureStorage.getUserName();
      if (username == null || username.isEmpty) return;

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      _image = file;
      _remoteImageUrl = null;

      // Cache locally for instant display
      final tempDir = await getTemporaryDirectory();
      final cachePath = '${tempDir.path}/profile_image_cache.png';
      await file.copy(cachePath);

      notifyListeners();

      // Upload to server
      await uploadPickedImageToServer(file);
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  /// Upload to backend
  Future<void> uploadPickedImageToServer(File file) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) return;

      final uri = Uri.parse('${ApiService.baseUrl}/agent/profile-image');

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(body);
        final url = (json['image_url'] ?? json['url'] ?? json['image'])?.toString();
        if (url != null && url.isNotEmpty) {
          final cleanUrl = url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;
          final sep = cleanUrl.contains('?') ? '&' : '?';
          _remoteImageUrl = '$cleanUrl${sep}ts=${DateTime.now().millisecondsSinceEpoch}';
          _image = null;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
  }

  /// Delete image
  Future<void> deleteImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheFile = File('${tempDir.path}/profile_image_cache.png');
      if (await cacheFile.exists()) await cacheFile.delete();

      _image = null;
      _remoteImageUrl = null;

      if (_currentEmail != null) {
        await fetchRemoteProfileImage(_currentEmail!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting image: $e");
    }
  }

  /// Clear on logout
  Future<void> clear() async {
    final tempDir = await getTemporaryDirectory();
    final cacheFile = File('${tempDir.path}/profile_image_cache.png');
    if (await cacheFile.exists()) await cacheFile.delete();

    _clearLocal();
    notifyListeners();
  }

  void _clearLocal() {
    _currentUser = null;
    _currentEmail = null;
    _image = null;
    _remoteImageUrl = null;
  }

  Future<void> refreshImage() async {
    if (_currentUser != null) {
      await loadImageForUser(_currentUser!);
    }
  }
}