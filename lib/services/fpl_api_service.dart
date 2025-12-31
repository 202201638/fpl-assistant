import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/gameweek.dart';
import '../models/player.dart';
import '../models/user_team.dart';

class FPLApiService {
  static const String baseUrl = 'https://fantasy.premierleague.com/api';
  
  static FPLApiService? _instance;
  static FPLApiService get instance => _instance ??= FPLApiService._();
  
  FPLApiService._();

  Future<Map<String, dynamic>> getBootstrapStatic() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/bootstrap-static/'),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else {
          throw Exception('Failed to load bootstrap data: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Error fetching bootstrap data after $maxRetries attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('Failed to fetch data after $maxRetries attempts');
  }

  Future<List<Team>> getTeams() async {
    try {
      final data = await getBootstrapStatic();
      final teamsJson = data['teams'] as List<dynamic>;
      
      return teamsJson.map((teamJson) => Team.fromJson(teamJson)).toList()
        ..sort((a, b) => a.position.compareTo(b.position));
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }

  Future<List<Gameweek>> getGameweeks() async {
    try {
      final data = await getBootstrapStatic();
      final gameweeksJson = data['events'] as List<dynamic>;
      
      return gameweeksJson.map((gwJson) => Gameweek.fromJson(gwJson)).toList();
    } catch (e) {
      throw Exception('Error fetching gameweeks: $e');
    }
  }

  Future<Gameweek?> getCurrentGameweek() async {
    try {
      final gameweeks = await getGameweeks();
      return gameweeks.firstWhere(
        (gw) => gw.isCurrent,
        orElse: () => gameweeks.firstWhere(
          (gw) => gw.isNext,
          orElse: () => gameweeks.first,
        ),
      );
    } catch (e) {
      throw Exception('Error fetching current gameweek: $e');
    }
  }

  Future<List<Fixture>> getFixtures({int? gameweek}) async {
    try {
      String url = '$baseUrl/fixtures/';
      if (gameweek != null) {
        url += '?event=$gameweek';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final fixturesJson = json.decode(response.body) as List<dynamic>;
        return fixturesJson.map((fixtureJson) => Fixture.fromJson(fixtureJson)).toList();
      } else {
        throw Exception('Failed to load fixtures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fixtures: $e');
    }
  }

  Future<List<Fixture>> getCurrentGameweekFixtures() async {
    try {
      final currentGW = await getCurrentGameweek();
      if (currentGW != null) {
        return await getFixtures(gameweek: currentGW.id);
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching current gameweek fixtures: $e');
    }
  }

  // Get team logo URL - using team code for official badges
  String getTeamLogoUrl(int teamCode) {
    return 'https://resources.premierleague.com/premierleague/badges/t$teamCode.png';
  }

  // Fallback team logo URL
  String getFallbackTeamLogoUrl(String teamShortName) {
    return 'https://logos-world.net/wp-content/uploads/2020/06/${teamShortName.toLowerCase()}-logo.png';
  }

  // Get player photo URL
  String getPlayerPhotoUrl(int playerId) {
    return 'https://resources.premierleague.com/premierleague/photos/players/110x140/p$playerId.png';
  }

  // Get player photo URL (small)
  String getPlayerPhotoSmallUrl(int playerId) {
    return 'https://resources.premierleague.com/premierleague/photos/players/40x40/p$playerId.png';
  }

  // Get all players from bootstrap data
  Future<List<Player>> getPlayers() async {
    try {
      final data = await getBootstrapStatic();
      final playersJson = data['elements'] as List<dynamic>;
      return playersJson.map((json) => Player.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching players: $e');
    }
  }

  // Get user's FPL team entry (basic info)
  Future<UserTeam> getUserTeam(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entry/$teamId/'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserTeam.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Team not found. Please check your FPL ID.');
      } else {
        throw Exception('Failed to load team data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user team: $e');
    }
  }

  // Get user's team history
  Future<Map<String, dynamic>> getUserHistory(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entry/$teamId/history/'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load team history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user history: $e');
    }
  }

  // Get user's picks for a specific gameweek
  Future<Map<String, dynamic>> getUserPicks(int teamId, int gameweek) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entry/$teamId/event/$gameweek/picks/'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load picks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user picks: $e');
    }
  }

  // Get user's transfers
  Future<List<Map<String, dynamic>>> getUserTransfers(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/entry/$teamId/transfers/'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load transfers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user transfers: $e');
    }
  }

  // Get complete user team data for the plan screen
  Future<UserTeamData> getUserTeamData(int teamId) async {
    try {
      // Get current gameweek first
      final currentGW = await getCurrentGameweek();
      final gameweekId = currentGW?.id ?? 1;

      // Fetch all user data in parallel
      final results = await Future.wait([
        getUserTeam(teamId),
        getUserHistory(teamId),
        getUserPicks(teamId, gameweekId),
      ]);

      final userTeam = results[0] as UserTeam;
      final historyData = results[1] as Map<String, dynamic>;
      final picksData = results[2] as Map<String, dynamic>;

      // Parse history
      final historyJson = historyData['current'] as List<dynamic>? ?? [];
      final history = historyJson
          .map((json) => UserGameweekHistory.fromJson(json))
          .toList();

      // Parse chips
      final chipsJson = historyData['chips'] as List<dynamic>? ?? [];
      final chips = chipsJson
          .map((json) => UserChips.fromJson(json))
          .toList();

      // Add default chips if not present
      final chipNames = ['wildcard', 'freehit', 'bboost', '3xc'];
      for (var chipName in chipNames) {
        if (!chips.any((c) => c.chipName == chipName)) {
          chips.add(UserChips(chipName: chipName));
        }
      }

      // Parse picks
      final picksJson = picksData['picks'] as List<dynamic>? ?? [];
      final picks = picksJson
          .map((json) => UserPick.fromJson(json))
          .toList();

      // Get entry history for current event to get bank and value
      final entryHistory = picksData['entry_history'] as Map<String, dynamic>?;
      final bank = (entryHistory?['bank'] as num? ?? 0) / 10;
      final squadValue = (entryHistory?['value'] as num? ?? 0) / 10;

      // Calculate free transfers based on transfers data
      int freeTransfers = 1;
      if (entryHistory != null) {
        final eventTransfers = entryHistory['event_transfers'] as int? ?? 0;
        // If no transfers made, add 1 (max 2)
        if (eventTransfers == 0 && history.length > 1) {
          freeTransfers = 2; // Could have banked a transfer
        }
      }

      return UserTeamData(
        entry: userTeam,
        history: history,
        chips: chips,
        picks: picks,
        freeTransfers: freeTransfers,
        bank: bank,
        squadValue: squadValue,
        currentGameweek: gameweekId,
      );
    } catch (e) {
      throw Exception('Error fetching complete team data: $e');
    }
  }
}
