import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/get_transactions.dart';
import '../screens/authentication/users/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  String _selectedGender = 'Gender';
  String message = '';
  final List<String> genderItems = [
    'Male',
    'Female',
  ];

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? get selectedGender => _selectedGender;

  AuthProvider() {
    // Check if the user is already authenticated when the app starts up
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  void updateSelectedGender(String newGender) {
    _selectedGender = newGender;
    notifyListeners();
  }

  //ari ma butang ang mga na register nga data
  Future<UserCredential?> registerUser(
    String email,
    String password,
    String username,
    String displayName,
    String phoneNumber,
    String birthdate,
    String? sex,
    String address,
  ) async {
    UserCredential? userCredential = await _authService.registerUser(
      email,
      password,
      username,
      displayName,
      phoneNumber,
      birthdate,
      sex!,
      address,
    );
    if (userCredential != null) {
      message = 'Verification email sent to ${userCredential.user!.email}';
    }
    notifyListeners();
    return userCredential;
  }

  Future<UserCredential?> signInWithEmailOrUsernameAndPassword(
      String emailOrUsername, String password) async {
    try {
      // Check if emailOrUsername matches an email or a username
      final emailRegex =
          RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$');
      if (emailRegex.hasMatch(emailOrUsername)) {
        // Sign in with email
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailOrUsername,
          password: password,
        );
        _isAuthenticated = true;
        notifyListeners();
        return userCredential;
      } else {
        // Fetch user with matching username
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .get();
        if (snapshot.size == 0) {
          return null;
        }
        String email =
            (snapshot.docs[0].data() as Map<String, dynamic>)['email'];

        // Sign in with retrieved email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _isAuthenticated = true;
        notifyListeners();
        return userCredential;
      }
    } catch (e) {
      //print(e);
      return null;
    }
  }

  Future<bool> checkEmailVerified() async {
    bool isEmailVerified = await _authService.checkEmailVerified();
    if (!isEmailVerified) {
      message = 'Please verify your email address';
    }
    notifyListeners();
    return isEmailVerified;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
