class Player {
  final int id;
  final int code; // Player code for photos
  final String firstName;
  final String secondName;
  final String webName;
  final int teamCode;
  final int elementType; // 1=GK, 2=DEF, 3=MID, 4=FWD
  final double nowCost;
  final int totalPoints;
  final String status;
  final int chanceOfPlayingThisRound;
  final int chanceOfPlayingNextRound;
  final String news;
  final double selectedByPercent;
  final int transfersIn;
  final int transfersOut;
  final double form;
  final int pointsPerGame;
  final bool inDreamteam;

  Player({
    required this.id,
    required this.code,
    required this.firstName,
    required this.secondName,
    required this.webName,
    required this.teamCode,
    required this.elementType,
    required this.nowCost,
    required this.totalPoints,
    required this.status,
    required this.chanceOfPlayingThisRound,
    required this.chanceOfPlayingNextRound,
    required this.news,
    required this.selectedByPercent,
    required this.transfersIn,
    required this.transfersOut,
    required this.form,
    required this.pointsPerGame,
    required this.inDreamteam,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: _toInt(json['id']),
      code: _toInt(json['code']),
      firstName: _toString(json['first_name']),
      secondName: _toString(json['second_name']),
      webName: _toString(json['web_name']),
      teamCode: _toInt(json['team_code']),
      elementType: _toInt(json['element_type']),
      nowCost: _toDouble(json['now_cost']) / 10, // API returns in tenths
      totalPoints: _toInt(json['total_points']),
      status: _toString(json['status']),
      chanceOfPlayingThisRound: _toInt(json['chance_of_playing_this_round']),
      chanceOfPlayingNextRound: _toInt(json['chance_of_playing_next_round']),
      news: _toString(json['news']),
      selectedByPercent: _toDouble(json['selected_by_percent']),
      transfersIn: _toInt(json['transfers_in']),
      transfersOut: _toInt(json['transfers_out']),
      form: _toDouble(json['form']),
      pointsPerGame: _toInt(json['points_per_game']),
      inDreamteam: _toBool(json['in_dreamteam']),
    );
  }

  String get displayName => webName.isNotEmpty ? webName : '$firstName $secondName';
  
  String get positionName {
    switch (elementType) {
      case 1: return 'GKP';
      case 2: return 'DEF';
      case 3: return 'MID';
      case 4: return 'FWD';
      default: return 'UNK';
    }
  }

  String get statusIcon {
    switch (status) {
      case 'i': return '🤕'; // Injured
      case 'd': return '❓'; // Doubtful
      case 's': return '🚫'; // Suspended
      case 'u': return '❌'; // Unavailable
      default: return '';
    }
  }

  bool get isAvailable => status == 'a';

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

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    return value?.toString() ?? '';
  }
}
