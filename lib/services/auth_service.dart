import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory AuthService() => _instance;

  AuthService._internal();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      // Create user with email and password
      UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user!.updateDisplayName(name);
      
      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': email,
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (_auth.currentUser == null) return null;
    
    final doc = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
        
    return doc.data();
  }

  // Update user profile
  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (_auth.currentUser == null) return;
    
    final userRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
    
    if (name != null) {
      await userRef.update({'name': name});
      await _auth.currentUser!.updateDisplayName(name);
    }
    
    if (photoUrl != null) {
      await userRef.update({'photoUrl': photoUrl});
      await _auth.currentUser!.updatePhotoURL(photoUrl);
    }
  }
}
