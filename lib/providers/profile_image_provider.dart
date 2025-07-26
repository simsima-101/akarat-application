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
      final response = await http.get(
        Uri.parse('https://akarat.com/api/agents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final agents = data['data']['data'] as List<dynamic>;
        final agent = agents.firstWhere(
              (a) => a['email'] != null && a['email'].toString().toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );

        _remoteImageUrl = (agent != null && agent['image'] != null) ? agent['image'] : null;
      }
    } catch (e) {
      debugPrint("❌ Error fetching remote profile image: $e");
    }
  }

  /// Load image for current user (local takes priority)
  Future<void> loadImageForUser(String username) async {
    try {
      _currentUser = username.trim().toLowerCase();

      final base64String = await SecureStorage.read('profile_image_base64_$_currentUser');
      if (base64String != null && base64String.isNotEmpty) {
        final bytes = base64Decode(base64String);
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/profile_$_currentUser.png';
        _image = await File(tempPath).writeAsBytes(bytes);
        _remoteImageUrl = null; // Local overrides remote
      } else {
        _image = null;
        if (_currentEmail != null && _currentEmail!.isNotEmpty) {
          await fetchRemoteProfileImage(_currentEmail!);
        }
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

      // 1. Use the picked image file directly for UI
      _image = File(picked.path);
      _remoteImageUrl = null; // Local takes priority

      // 2. Save in base64 for persistence
      final bytes = await _image!.readAsBytes();
      final base64String = base64Encode(bytes);
      await SecureStorage.write('profile_image_base64_$_currentUser', base64String);

      // 3. Notify UI to refresh
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error picking/saving profile image: $e");
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
