import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/fixture.dart';
import '../models/gameweek.dart';

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
}
