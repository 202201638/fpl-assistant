import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';

/// Service to fetch real Premier League standings from football-data.org API
/// This provides actual match statistics (goals, wins, draws, losses)
class FootballDataApiService {
  static const String baseUrl = 'https://api.football-data.org/v4';
  // Free tier API key - replace with your own from football-data.org
  static const String apiKey = 'e483ca92ff5445fcaaaa56071449353b';
  
  static FootballDataApiService? _instance;
  static FootballDataApiService get instance => _instance ??= FootballDataApiService._();
  
  FootballDataApiService._();

  /// Fetch Premier League standings with real match data
  Future<List<Team>> getLeagueStandings() async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Premier League competition ID is 'PL'
        final response = await http.get(
          Uri.parse('$baseUrl/competitions/PL/standings'),
          headers: {
            'X-Auth-Token': apiKey,
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('DEBUG API Response: $data');
          
          final standings = data['standings'] as List<dynamic>;
          
          if (standings.isNotEmpty) {
            final tableData = standings[0]['table'] as List<dynamic>;
            print('DEBUG Table Data: $tableData');
            return tableData.map((teamData) => _parseTeamFromStanding(teamData)).toList();
          }
          return [];
        } else if (response.statusCode == 429) {
          // Rate limited, wait and retry
          await Future.delayed(Duration(seconds: retryCount * 5));
          retryCount++;
          continue;
        } else {
          throw Exception('Failed to load standings: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Error fetching standings after $maxRetries attempts: $e');
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    throw Exception('Failed to fetch standings after $maxRetries attempts');
  }

  /// Parse team data from football-data.org standings response
  Team _parseTeamFromStanding(Map<String, dynamic> data) {
    final team = data['team'] as Map<String, dynamic>;
    
    // Extract wins, draws, losses from the data
    // football-data.org API v4 uses: won, draw, lost (not draws/losses)
    int wins = _toInt(data['won'] ?? 0);
    int draws = _toInt(data['draw'] ?? 0);  // Note: 'draw' not 'draws'
    int losses = _toInt(data['lost'] ?? 0); // Note: 'lost' not 'losses'
    
    print('Team: ${team['name']}, W:$wins D:$draws L:$losses, Full data: $data');
    
    return Team(
      id: _toInt(team['id']),
      name: _toString(team['name']),
      shortName: _toString(team['tla']), // Three letter abbreviation
      code: FootballDataApiService._getTeamCode(_toString(team['name'])), // Get correct team code for FPL logo
      draw: draws,
      form: 0, // Not available in this API
      loss: losses,
      played: _toInt(data['playedGames']),
      points: _toInt(data['points']),
      position: _toInt(data['position']),
      strength: 0, // Not available in this API
      strengthAttackAway: '0',
      strengthAttackHome: '0',
      strengthDefenceAway: '0',
      strengthDefenceHome: '0',
      strengthOverallAway: '0',
      strengthOverallHome: '0',
      unavailable: false,
      win: wins,
      pulse: 0,
      goalsFor: _toInt(data['goalsFor']),
      goalsAgainst: _toInt(data['goalsAgainst']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value?.toString() ?? '';
  }

  /// Map team names from football-data.org to FPL team codes
  static int _getTeamCode(String teamName) {
    // Remove " FC" suffix if present to normalize team names from API
    String normalizedName = teamName.replaceAll(' FC', '').replaceAll(' AFC', '');
    
    final nameMap = {
      'Arsenal': 1,
      'Aston Villa': 2,
      'AFC Bournemouth': 3,
      'Bournemouth': 3,
      'Brentford': 4,
      'Brighton & Hove Albion': 5,
      'Brighton and Hove Albion': 5,
      'Chelsea': 6,
      'Crystal Palace': 7,
      'Everton': 8,
      'Fulham': 9,
      'Ipswich Town': 10,
      'Leicester City': 11,
      'Leeds United': 11, // Fallback if needed
      'Liverpool': 12,
      'Manchester City': 13,
      'Manchester United': 14,
      'Newcastle United': 15,
      'Nottingham Forest': 16,
      'Nottingham': 16,
      'Southampton': 17,
      'Tottenham Hotspur': 18,
      'Tottenham': 18,
      'West Ham United': 19,
      'Wolverhampton Wanderers': 20,
      'Wolverhampton': 20,
    };
    return nameMap[normalizedName] ?? 0;
  }
}
