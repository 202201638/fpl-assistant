class Team {
  final int id;
  final String name;
  final String shortName;
  final int code;
  final int draw;
  final int form;
  final int loss;
  final int played;
  final int points;
  final int position;
  final int strength;
  final String strengthAttackAway;
  final String strengthAttackHome;
  final String strengthDefenceAway;
  final String strengthDefenceHome;
  final String strengthOverallAway;
  final String strengthOverallHome;
  final bool unavailable;
  final int win;
  final int pulse;
  final int goalsFor;
  final int goalsAgainst;

  Team({
    required this.id,
    required this.name,
    required this.shortName,
    required this.code,
    required this.draw,
    required this.form,
    required this.loss,
    required this.played,
    required this.points,
    required this.position,
    required this.strength,
    required this.strengthAttackAway,
    required this.strengthAttackHome,
    required this.strengthDefenceAway,
    required this.strengthDefenceHome,
    required this.strengthOverallAway,
    required this.strengthOverallHome,
    required this.unavailable,
    required this.win,
    required this.pulse,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      shortName: _toString(json['short_name']),
      code: _toInt(json['code']),
      draw: _toInt(json['draw']),
      form: _toInt(json['form']),
      loss: _toInt(json['loss']),
      played: _toInt(json['played']),
      points: _toInt(json['points']),
      position: _toInt(json['position']),
      strength: _toInt(json['strength']),
      strengthAttackAway: _toString(json['strength_attack_away']),
      strengthAttackHome: _toString(json['strength_attack_home']),
      strengthDefenceAway: _toString(json['strength_defence_away']),
      strengthDefenceHome: _toString(json['strength_defence_home']),
      strengthOverallAway: _toString(json['strength_overall_away']),
      strengthOverallHome: _toString(json['strength_overall_home']),
      unavailable: _toBool(json['unavailable']),
      win: _toInt(json['win']),
      pulse: _toInt(json['pulse']),
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

  // Calculate goal difference
  int get goalDifference => goalsFor - goalsAgainst;

  // Team colors for UI styling
  Map<String, String> get teamColors {
    switch (shortName.toUpperCase()) {
      case 'ARS':
        return {'primary': '#EF0107', 'secondary': '#FFFFFF'};
      case 'AVL':
        return {'primary': '#95BFE5', 'secondary': '#670E36'};
      case 'BOU':
        return {'primary': '#DA020E', 'secondary': '#000000'};
      case 'BRE':
        return {'primary': '#E62333', 'secondary': '#000000'};
      case 'BHA':
        return {'primary': '#0057B8', 'secondary': '#FFCD00'};
      case 'CHE':
        return {'primary': '#034694', 'secondary': '#FFFFFF'};
      case 'CRY':
        return {'primary': '#1B458F', 'secondary': '#A7A5A6'};
      case 'EVE':
        return {'primary': '#003399', 'secondary': '#FFFFFF'};
      case 'FUL':
        return {'primary': '#000000', 'secondary': '#FFFFFF'};
      case 'IPS':
        return {'primary': '#4C9FE7', 'secondary': '#FFFFFF'};
      case 'LEI':
        return {'primary': '#003090', 'secondary': '#FDBE11'};
      case 'LIV':
        return {'primary': '#C8102E', 'secondary': '#FFFFFF'};
      case 'MCI':
        return {'primary': '#6CABDD', 'secondary': '#FFFFFF'};
      case 'MUN':
        return {'primary': '#FFF200', 'secondary': '#DA020E'};
      case 'NEW':
        return {'primary': '#241F20', 'secondary': '#FFFFFF'};
      case 'NFO':
        return {'primary': '#DD0000', 'secondary': '#FFFFFF'};
      case 'SOU':
        return {'primary': '#D71920', 'secondary': '#FFFFFF'};
      case 'TOT':
        return {'primary': '#132257', 'secondary': '#FFFFFF'};
      case 'WHU':
        return {'primary': '#7A263A', 'secondary': '#F3D459'};
      case 'WOL':
        return {'primary': '#FDB913', 'secondary': '#231F20'};
      default:
        return {'primary': '#38003C', 'secondary': '#FFFFFF'};
    }
  }
}
