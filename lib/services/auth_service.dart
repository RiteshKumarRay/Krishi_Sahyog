import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Sign up with phone number and password
  static Future<Map<String, dynamic>> signUpWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
    required String name,
    required String userType, // 'farmer', 'advisor', 'admin'
    String? location,
  }) async {
    try {
      // Create a custom email from phone number for Firebase Auth
      String email = '$phoneNumber@krishisahyog.app';

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Store additional user data in Firestore
        await _storeUserData(
          userId: user.uid,
          phoneNumber: phoneNumber,
          name: name,
          userType: userType,
          location: location,
          email: email,
        );

        return {
          'success': true,
          'user': user,
          'message': 'Account created successfully'
        };
      }

      return {'success': false, 'message': 'Failed to create account'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code)
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred'
      };
    }
  }

  // Sign in with phone number and password
  static Future<Map<String, dynamic>> signInWithPhoneAndPassword({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      String email = '$phoneNumber@krishisahyog.app';

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        return {
          'success': true,
          'user': user,
          'userData': userData.data(),
          'message': 'Login successful'
        };
      }

      return {'success': false, 'message': 'Login failed'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code)
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed. Please try again.'
      };
    }
  }

  // Store user data in Firestore
  static Future<void> _storeUserData({
    required String userId,
    required String phoneNumber,
    required String name,
    required String userType,
    required String email,
    String? location,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'userId': userId,
      'phoneNumber': phoneNumber,
      'name': name,
      'userType': userType, // 'farmer', 'advisor', 'admin'
      'location': location ?? '',
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'cropInterests': [], // For farmers to specify crop types
      'expertise': [], // For advisors to specify areas of expertise
    });
  }

  // Update user data
  static Future<bool> updateUserData({
    required String userId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...?updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  static Future<bool> resetPassword(String phoneNumber) async {
    try {
      String email = '$phoneNumber@krishisahyog.app';
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Error message helper
  static String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'इस फोन नंबर से पहले से खाता मौजूद है';
      case 'invalid-email':
        return 'गलत फोन नंबर प्रारूप';
      case 'weak-password':
        return 'कमजोर पासवर्ड। कम से कम 6 अक्षर का उपयोग करें';
      case 'user-not-found':
        return 'यह फोन नंबर पंजीकृत नहीं है';
      case 'wrong-password':
        return 'गलत पासवर्ड';
      default:
        return 'कुछ गलत हुआ। कृपया पुनः प्रयास करें';
    }
  }
}
