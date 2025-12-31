import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _isInitialized = false;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();
  
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }
  
  FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      rethrow;
    }
  }

  // Authentication
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return auth.authStateChanges();
  }

  // Starred Matches
  Future<void> saveStarredMatch(int matchId, String homeTeam, String awayTeam) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('starred_matches')
          .doc(matchId.toString())
          .set({
        'matchId': matchId,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'starredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving starred match: $e');
      rethrow;
    }
  }

  Future<void> removeStarredMatch(int matchId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('starred_matches')
          .doc(matchId.toString())
          .delete();
    } catch (e) {
      print('Error removing starred match: $e');
      rethrow;
    }
  }

  Stream<List<int>> getStarredMatches() {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .doc(userId)
        .collection('starred_matches')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['matchId'] as int).toList();
    });
  }

  // User Preferences
  Future<void> saveUserPreferences({
    required String userId,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving user preferences: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return doc.data()?['preferences'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }

  // User Profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    try {
      await firestore.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'preferences': {},
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Favorite Teams
  Future<void> addFavoriteTeam(String userId, int teamId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_teams')
          .doc(teamId.toString())
          .set({
        'teamId': teamId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding favorite team: $e');
      rethrow;
    }
  }

  Future<void> removeFavoriteTeam(String userId, int teamId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_teams')
          .doc(teamId.toString())
          .delete();
    } catch (e) {
      print('Error removing favorite team: $e');
      rethrow;
    }
  }

  Stream<List<int>> getFavoriteTeams(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_teams')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['teamId'] as int).toList();
    });
  }

  // Match Notes
  Future<void> saveMatchNote({
    required String userId,
    required int matchId,
    required String note,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('match_notes')
          .doc(matchId.toString())
          .set({
        'matchId': matchId,
        'note': note,
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving match note: $e');
      rethrow;
    }
  }

  Future<String?> getMatchNote(String userId, int matchId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('match_notes')
          .doc(matchId.toString())
          .get();
      return doc.data()?['note'] as String?;
    } catch (e) {
      print('Error getting match note: $e');
      return null;
    }
  }

  Future<void> deleteMatchNote(String userId, int matchId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('match_notes')
          .doc(matchId.toString())
          .delete();
    } catch (e) {
      print('Error deleting match note: $e');
      rethrow;
    }
  }

  // Sync Data
  Future<void> syncUserData(String userId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'lastSync': FieldValue.serverTimestamp(),
        'syncData': data,
      });
    } catch (e) {
      print('Error syncing user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSyncData(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return doc.data()?['syncData'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting sync data: $e');
      return null;
    }
  }
}
