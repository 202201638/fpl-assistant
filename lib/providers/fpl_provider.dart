import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/gameweek.dart';
import '../services/fpl_api_service.dart';

class FPLProvider extends ChangeNotifier {
  final FPLApiService _apiService = FPLApiService.instance;

  List<Team> _teams = [];
  List<Fixture> _fixtures = [];
  List<Gameweek> _gameweeks = [];
  Gameweek? _currentGameweek;
  int _selectedGameweek = 1;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Team> get teams => _teams;
  List<Fixture> get fixtures => _fixtures;
  List<Gameweek> get gameweeks => _gameweeks;
  Gameweek? get currentGameweek => _currentGameweek;
  int get selectedGameweek => _selectedGameweek;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get league table sorted by position
  List<Team> get leagueTable {
    final sortedTeams = List<Team>.from(_teams);
    sortedTeams.sort((a, b) => a.position.compareTo(b.position));
    return sortedTeams;
  }

  // Get fixtures for selected gameweek
  List<Fixture> get selectedGameweekFixtures {
    return _fixtures.where((fixture) => fixture.event == _selectedGameweek).toList();
  }

  Future<void> loadInitialData() async {
    _setLoading(true);
    _setError(null);

    try {
      // Load teams and gameweeks
      await Future.wait([
        loadTeams(),
        loadGameweeks(),
      ]);

      // Load current gameweek and its fixtures
      await loadCurrentGameweek();
      if (_currentGameweek != null) {
        _selectedGameweek = _currentGameweek!.id;
        await loadFixtures(_selectedGameweek);
      }
    } catch (e) {
      String errorMessage = 'Failed to load data';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid data format received from server.';
      } else {
        errorMessage = 'Error loading data: ${e.toString()}';
      }
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTeams() async {
    try {
      _teams = await _apiService.getTeams();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load teams: $e');
      rethrow;
    }
  }

  Future<void> loadGameweeks() async {
    try {
      _gameweeks = await _apiService.getGameweeks();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load gameweeks: $e');
      rethrow;
    }
  }

  Future<void> loadCurrentGameweek() async {
    try {
      _currentGameweek = await _apiService.getCurrentGameweek();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load current gameweek: $e');
      rethrow;
    }
  }

  Future<void> loadFixtures(int gameweek) async {
    _setLoading(true);
    try {
      final newFixtures = await _apiService.getFixtures(gameweek: gameweek);
      
      // Update fixtures list, replacing existing fixtures for this gameweek
      _fixtures.removeWhere((fixture) => fixture.event == gameweek);
      _fixtures.addAll(newFixtures);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load fixtures: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectGameweek(int gameweek) {
    if (_selectedGameweek != gameweek) {
      _selectedGameweek = gameweek;
      notifyListeners();
      
      // Load fixtures for the selected gameweek if not already loaded
      final hasFixtures = _fixtures.any((fixture) => fixture.event == gameweek);
      if (!hasFixtures) {
        loadFixtures(gameweek);
      }
    }
  }

  Team? getTeamById(int teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  String getTeamLogoUrl(int teamId) {
    final team = getTeamById(teamId);
    if (team != null) {
      return _apiService.getTeamLogoUrl(team.code);
    }
    return '';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadInitialData();
  }
}
