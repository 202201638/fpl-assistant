import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/gameweek.dart';
import '../models/player.dart';
import '../services/fpl_api_service.dart';
import '../services/football_data_api_service.dart';

class FPLProvider extends ChangeNotifier {
  final FPLApiService _apiService = FPLApiService.instance;
  final FootballDataApiService _footballDataService = FootballDataApiService.instance;

  List<Team> _teams = [];
  List<Fixture> _fixtures = [];
  List<Gameweek> _gameweeks = [];
  List<Player> _players = [];
  Gameweek? _currentGameweek;
  int _selectedGameweek = 1;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Team> get teams => _teams;
  List<Fixture> get fixtures => _fixtures;
  List<Gameweek> get gameweeks => _gameweeks;
  List<Player> get players => _players;
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
      // Load FPL teams for logos and basic info
      final fplTeams = await _apiService.getTeams();
      
      // Load external API teams for real stats
      try {
        final externalTeams = await _footballDataService.getLeagueStandings();
        
        // Merge: use FPL logos but external API stats
        _teams = fplTeams.map((fplTeam) {
          // Find matching external team using both full name and short name
          final externalTeam = externalTeams.firstWhere(
            (ext) => _teamsMatch(fplTeam.name, ext.name) || _teamsMatch(fplTeam.shortName, ext.name),
            orElse: () => fplTeam,
          );
          
          // If we found a match, use external stats
          if (externalTeam != fplTeam) {
            return Team(
              id: fplTeam.id,
              name: fplTeam.name,
              shortName: fplTeam.shortName,
              code: fplTeam.code, // Keep FPL code for logo
              draw: externalTeam.draw,
              form: fplTeam.form,
              loss: externalTeam.loss,
              played: externalTeam.played,
              points: externalTeam.points,
              position: externalTeam.position,
              strength: fplTeam.strength,
              strengthAttackAway: fplTeam.strengthAttackAway,
              strengthAttackHome: fplTeam.strengthAttackHome,
              strengthDefenceAway: fplTeam.strengthDefenceAway,
              strengthDefenceHome: fplTeam.strengthDefenceHome,
              strengthOverallAway: fplTeam.strengthOverallAway,
              strengthOverallHome: fplTeam.strengthOverallHome,
              unavailable: fplTeam.unavailable,
              win: externalTeam.win,
              pulse: fplTeam.pulse,
              goalsFor: externalTeam.goalsFor,
              goalsAgainst: externalTeam.goalsAgainst,
            );
          }
          return fplTeam;
        }).toList();
      } catch (e) {
        // If external API fails, just use FPL teams
        print('External API failed, using FPL teams only: $e');
        _teams = fplTeams;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load teams: $e');
      rethrow;
    }
  }

  /// Check if two team names match
  bool _teamsMatch(String name1, String name2) {
    // Normalize names: lowercase and remove FC/AFC suffixes and special characters
    String normalize(String name) {
      return name
          .toLowerCase()
          .replaceAll(' fc', '')
          .replaceAll(' afc', '')
          .replaceAll('&', 'and')
          .replaceAll("'", '') // Remove apostrophes (e.g., "Nott'm" -> "Nottm")
          .replaceAll(RegExp(r'\s+'), '')
          .trim();
    }
    
    final n1 = normalize(name1);
    final n2 = normalize(name2);
    
    // Exact match after normalization
    if (n1 == n2) return true;
    
    // Check if one contains the other (for partial matches)
    if (n1.contains(n2) || n2.contains(n1)) return true;
    
    // Special cases mapping - maps normalized names to possible variations
    final specialCases = {
      'brightonhovealbion': ['brighton', 'brightonandhovalbion'],
      'manchestercity': ['mancity', 'manchestercity', 'manci'],
      'manchesterunited': ['manutd', 'manchesterunited', 'manu'],
      'tottenhamhotspur': ['spurs', 'tottenham', 'tottenhamhotspur'],
      'wolverhamptonwanderers': ['wolves', 'wolverhampton', 'wolverhamptonwanderers'],
      'nottinghamforest': ['nottm', 'nottingham', 'nottinghamforest', 'nottmforest'],
      'westhamunited': ['westham', 'westhamunited'],
      'afcbournemouth': ['bournemouth', 'afcbournemouth'],
      'leedsunited': ['leeds', 'leedsunited'],
    };
    
    // Check special cases bidirectionally
    for (final entry in specialCases.entries) {
      if (n1 == entry.key && entry.value.contains(n2)) return true;
      if (n2 == entry.key && entry.value.contains(n1)) return true;
      // Also check if both are in the same variation list
      if (entry.value.contains(n1) && entry.value.contains(n2)) return true;
    }
    
    return false;
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

  List<Player> getPlayersByTeamId(int teamId) {
    return _players.where((player) => player.teamCode == teamId).toList();
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
