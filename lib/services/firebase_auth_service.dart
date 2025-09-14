import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Google Sign-In with Firestore storage
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google साइन इन रद्द किया गया',
        };
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        await _createOrUpdateUserInFirestore(user, userCredential.additionalUserInfo?.isNewUser ?? false);

        // Get user data from Firestore
        final userData = await getUserDataFromFirestore(user.uid);

        return {
          'success': true,
          'user': user,
          'userData': userData,
          'isNewUser': userCredential.additionalUserInfo?.isNewUser ?? false,
          'message': 'सफलतापूर्वक लॉगिन हो गए',
        };
      }

      return {
        'success': false,
        'message': 'Google साइन इन असफल',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Google साइन इन में त्रुटि: $e',
      };
    }
  }

  // Create or update user data in Firestore
  static Future<void> _createOrUpdateUserInFirestore(User user, bool isNewUser) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    if (isNewUser) {
      // Create new user document
      await userRef.set({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'photoURL': user.photoURL ?? '',
        'userType': 'farmer', // Default to farmer, can be updated later
        'location': '',
        'cropInterests': [],
        'experience': '',
        'languagePreference': 'hi', // Hindi by default
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profileCompleted': false,
        // Agricultural specific fields
        'farmSize': '',
        'primaryCrops': [],
        'farmingType': '', // organic, conventional, mixed
        'soilType': '',
        'irrigationType': '',
        'expertiseAreas': [], // For advisors
      });
    } else {
      // Update existing user's last login
      await userRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'photoURL': user.photoURL ?? '',
        'name': user.displayName ?? 'User',
      });
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserDataFromFirestore(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    required String uid,
    String? userType,
    String? location,
    List<String>? cropInterests,
    String? experience,
    String? farmSize,
    List<String>? primaryCrops,
    String? farmingType,
    String? soilType,
    String? irrigationType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
        'profileCompleted': true,
      };

      if (userType != null) updateData['userType'] = userType;
      if (location != null) updateData['location'] = location;
      if (cropInterests != null) updateData['cropInterests'] = cropInterests;
      if (experience != null) updateData['experience'] = experience;
      if (farmSize != null) updateData['farmSize'] = farmSize;
      if (primaryCrops != null) updateData['primaryCrops'] = primaryCrops;
      if (farmingType != null) updateData['farmingType'] = farmingType;
      if (soilType != null) updateData['soilType'] = soilType;
      if (irrigationType != null) updateData['irrigationType'] = irrigationType;
      if (additionalData != null) updateData.addAll(additionalData);

      await _firestore.collection('users').doc(uid).update(updateData);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Delete account
  static Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  // Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}
