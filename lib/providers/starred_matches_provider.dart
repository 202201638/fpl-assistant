import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fixture.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';

class StarredMatchesProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final FirebaseService _firebaseService = FirebaseService();
  late SharedPreferences _prefs;
  Set<int> _starredMatchIds = {};
  bool _notificationsEnabled = false;
  bool _useFirebase = false;

  Set<int> get starredMatchIds => _starredMatchIds;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get useFirebase => _useFirebase;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _starredMatchIds = Set.from(_prefs.getStringList('starred_matches') ?? [])
        .map((id) => int.parse(id))
        .toSet();
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? false;
    
    if (_notificationsEnabled) {
      await _notificationService.initialize();
    }
    notifyListeners();
  }

  Future<void> enableNotifications() async {
    final hasPermission = await _notificationService.requestNotificationPermission();
    if (hasPermission) {
      await _notificationService.initialize();
      _notificationsEnabled = true;
      await _prefs.setBool('notifications_enabled', true);
      notifyListeners();
    }
  }

  Future<void> disableNotifications() async {
    _notificationsEnabled = false;
    await _prefs.setBool('notifications_enabled', false);
    notifyListeners();
  }

  Future<void> enableFirebaseSync() async {
    try {
      await _firebaseService.initialize();
      _useFirebase = true;
      await _prefs.setBool('firebase_sync_enabled', true);
      notifyListeners();
    } catch (e) {
      print('Error enabling Firebase sync: $e');
    }
  }

  Future<void> disableFirebaseSync() async {
    _useFirebase = false;
    await _prefs.setBool('firebase_sync_enabled', false);
    notifyListeners();
  }

  Future<void> toggleStarMatch(
    Fixture fixture,
    String homeTeamName,
    String awayTeamName,
  ) async {
    if (_starredMatchIds.contains(fixture.id)) {
      await unstarMatch(fixture.id);
    } else {
      await starMatch(fixture, homeTeamName, awayTeamName);
    }
  }

  Future<void> starMatch(
    Fixture fixture,
    String homeTeamName,
    String awayTeamName,
  ) async {
    _starredMatchIds.add(fixture.id);
    await _saveStarredMatches();

    // Sync to Firebase if user is authenticated
    if (_useFirebase) {
      try {
        await _firebaseService.saveStarredMatch(
          fixture.id,
          homeTeamName,
          awayTeamName,
        );
      } catch (e) {
        print('Error syncing to Firebase: $e');
      }
    }

    // Send notification if enabled
    if (_notificationsEnabled) {
      await _notificationService.showMatchNotification(
        matchId: fixture.id,
        homeTeam: homeTeamName,
        awayTeam: awayTeamName,
        title: 'Match Starred',
        body: '$homeTeamName vs $awayTeamName',
      );
    }

    notifyListeners();
  }

  Future<void> unstarMatch(int matchId) async {
    _starredMatchIds.remove(matchId);
    await _saveStarredMatches();
    
    // Cancel notification
    await _notificationService.cancelNotification(matchId);
    
    notifyListeners();
  }

  bool isMatchStarred(int matchId) {
    return _starredMatchIds.contains(matchId);
  }

  Future<void> _saveStarredMatches() async {
    await _prefs.setStringList(
      'starred_matches',
      _starredMatchIds.map((id) => id.toString()).toList(),
    );
  }
}
