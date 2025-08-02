import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shoporbit/models/user_model.dart';
import 'package:shoporbit/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadCurrentUser();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    File? imageFile,
    List<String>? addresses,
    bool? isBlocked,
    bool? isApproved,
  }) async {
    if (_currentUser == null) {
      throw Exception('No logged-in user to update');
    }

    String? profileImageUrl = _currentUser!.profileImage;

    // 1. Upload new profile image if provided
    if (imageFile != null) {
      final ref = _storage
          .ref()
          .child('profile_pictures')
          .child('${_currentUser!.id}.jpg');

      await ref.putFile(imageFile);
      profileImageUrl = await ref.getDownloadURL();
    }

    // 2. Prepare updated data
    final updatedData = <String, dynamic>{
      'name': name,
      'email': email,
      // If you want to allow update email in Auth as well, you might want to update FirebaseAuth user.email
      'profileImage': profileImageUrl,
      'updatedAt': Timestamp.now(),
      // Optional updates
      if (addresses != null) 'addresses': addresses,
      if (isBlocked != null) 'isBlocked': isBlocked,
      if (isApproved != null) 'isApproved': isApproved,
    };

    // 3. Update Firestore user document
    await _firestore
        .collection('users')
        .doc(_currentUser!.id)
        .update(updatedData);

    // 4. Optionally, update Firebase Auth email address if changed
    final user = _auth.currentUser;
    if (user != null && user.email != email) {
      await user.updateEmail(email);
    }

    // 5. Update local user model and notify listeners
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: name,
      email: email,
      role: _currentUser!.role,
      profileImage: profileImageUrl,
      addresses: addresses ?? _currentUser!.addresses,
      isBlocked: isBlocked ?? _currentUser!.isBlocked,
      isApproved: isApproved ?? _currentUser!.isApproved,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

