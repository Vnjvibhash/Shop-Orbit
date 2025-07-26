import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoporbit/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await getCurrentUserData();
      }
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userData = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          addresses: [],
          isBlocked: false,
          isApproved: role == 'user' ? true : false, // Auto-approve users, sellers need approval
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData.toJson());

        return userData;
      }
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? profileImage,
    List<String>? addresses,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return;

      final updateData = {
        'name': name,
        'updatedAt': Timestamp.now(),
      };

      if (profileImage != null) {
        updateData['profileImage'] = profileImage;
      }

      if (addresses != null) {
        updateData['addresses'] = addresses;
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}