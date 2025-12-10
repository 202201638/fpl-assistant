import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;

  Future<void> initialize() async {
    try {
      await _firebaseService.initialize();
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        _isAuthenticated = true;
        _userId = user.uid;
        _userEmail = user.email;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.signUpWithEmail(email, password);
      if (userCredential != null) {
        _userId = userCredential.user?.uid;
        _userEmail = userCredential.user?.email;
        _isAuthenticated = true;

        // Create user profile
        await _firebaseService.createUserProfile(
          userId: _userId!,
          email: email,
          displayName: displayName,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Sign up failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseService.signInWithEmail(email, password);
      if (userCredential != null) {
        _userId = userCredential.user?.uid;
        _userEmail = userCredential.user?.email;
        _isAuthenticated = true;

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Sign in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _error = null;
    } catch (e) {
      _error = 'Sign out failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
