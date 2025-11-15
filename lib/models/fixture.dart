class Fixture {
  final int id;
  final int code;
  final int teamH;
  final int teamA;
  final int teamHScore;
  final int teamAScore;
  final int event;
  final bool finished;
  final String kickoffTime;
  final bool started;
  final List<FixtureStat> stats;

  Fixture({
    required this.id,
    required this.code,
    required this.teamH,
    required this.teamA,
    required this.teamHScore,
    required this.teamAScore,
    required this.event,
    required this.finished,
    required this.kickoffTime,
    required this.started,
    required this.stats,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: _toInt(json['id']),
      code: _toInt(json['code']),
      teamH: _toInt(json['team_h']),
      teamA: _toInt(json['team_a']),
      teamHScore: _toInt(json['team_h_score']),
      teamAScore: _toInt(json['team_a_score']),
      event: _toInt(json['event']),
      finished: _toBool(json['finished']),
      kickoffTime: _toString(json['kickoff_time']),
      started: _toBool(json['started']),
      stats: (json['stats'] as List<dynamic>?)
              ?.map((stat) => FixtureStat.fromJson(stat))
              .toList() ??
          [],
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
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

  String get status {
    if (finished) return 'FT';
    if (started) return 'LIVE';
    return 'Upcoming';
  }

  String get result {
    if (!started) return '';
    return '$teamHScore - $teamAScore';
  }

  // Difficulty rating based on team strength
  int getDifficultyRating(int teamId, List<dynamic> teams) {
    final opponent = teamId == teamH ? teamA : teamH;
    
    try {
      final opponentTeam = teams.firstWhere((team) => team.id == opponent);
      final strength = opponentTeam.strength ?? 3;
      if (strength >= 4) return 3; // High difficulty
      if (strength <= 2) return 1; // Low difficulty
      return 2; // Medium difficulty
    } catch (e) {
      return 2; // Medium difficulty as default if team not found
    }
  }
}

class FixtureStat {
  final String identifier;
  final List<StatValue> a;
  final List<StatValue> h;

  FixtureStat({
    required this.identifier,
    required this.a,
    required this.h,
  });

  factory FixtureStat.fromJson(Map<String, dynamic> json) {
    return FixtureStat(
      identifier: _toString(json['identifier']),
      a: (json['a'] as List<dynamic>?)
              ?.map((stat) => StatValue.fromJson(stat))
              .toList() ??
          [],
      h: (json['h'] as List<dynamic>?)
              ?.map((stat) => StatValue.fromJson(stat))
              .toList() ??
          [],
    );
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value?.toString() ?? '';
  }
}

class StatValue {
  final int value;
  final int element;

  StatValue({
    required this.value,
    required this.element,
  });

  factory StatValue.fromJson(Map<String, dynamic> json) {
    return StatValue(
      value: _toInt(json['value']),
      element: _toInt(json['element']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
