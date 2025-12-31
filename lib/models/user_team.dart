/// Model representing a user's FPL team entry
class UserTeam {
  final int id;
  final String playerFirstName;
  final String playerLastName;
  final String teamName;
  final int startedEvent;
  final int favouriteTeam;
  final double lastDeadlineBank;
  final double lastDeadlineTotalTransfers;
  final double lastDeadlineValue;

  UserTeam({
    required this.id,
    required this.playerFirstName,
    required this.playerLastName,
    required this.teamName,
    required this.startedEvent,
    required this.favouriteTeam,
    required this.lastDeadlineBank,
    required this.lastDeadlineTotalTransfers,
    required this.lastDeadlineValue,
  });

  factory UserTeam.fromJson(Map<String, dynamic> json) {
    return UserTeam(
      id: _toInt(json['id']),
      playerFirstName: _toString(json['player_first_name']),
      playerLastName: _toString(json['player_last_name']),
      teamName: _toString(json['name']),
      startedEvent: _toInt(json['started_event']),
      favouriteTeam: _toInt(json['favourite_team']),
      lastDeadlineBank: _toDouble(json['last_deadline_bank']) / 10,
      lastDeadlineTotalTransfers: _toDouble(json['last_deadline_total_transfers']),
      lastDeadlineValue: _toDouble(json['last_deadline_value']) / 10,
    );
  }

  String get fullName => '$playerFirstName $playerLastName';
  double get squadValue => lastDeadlineValue;
  double get bank => lastDeadlineBank;

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
    return value?.toString() ?? '';
  }
}

/// Model representing user's gameweek history entry
class UserGameweekHistory {
  final int event;
  final int points;
  final int totalPoints;
  final int rank;
  final int overallRank;
  final double bank;
  final double teamValue;
  final int eventTransfers;
  final int eventTransfersCost;
  final int pointsOnBench;

  UserGameweekHistory({
    required this.event,
    required this.points,
    required this.totalPoints,
    required this.rank,
    required this.overallRank,
    required this.bank,
    required this.teamValue,
    required this.eventTransfers,
    required this.eventTransfersCost,
    required this.pointsOnBench,
  });

  factory UserGameweekHistory.fromJson(Map<String, dynamic> json) {
    return UserGameweekHistory(
      event: _toInt(json['event']),
      points: _toInt(json['points']),
      totalPoints: _toInt(json['total_points']),
      rank: _toInt(json['rank']),
      overallRank: _toInt(json['overall_rank']),
      bank: _toDouble(json['bank']) / 10,
      teamValue: _toDouble(json['value']) / 10,
      eventTransfers: _toInt(json['event_transfers']),
      eventTransfersCost: _toInt(json['event_transfers_cost']),
      pointsOnBench: _toInt(json['points_on_bench']),
    );
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
}

/// Model representing chips available to the user
class UserChips {
  final String chipName;
  final int? gameweekUsed;

  UserChips({
    required this.chipName,
    this.gameweekUsed,
  });

  factory UserChips.fromJson(Map<String, dynamic> json) {
    return UserChips(
      chipName: json['name']?.toString() ?? '',
      gameweekUsed: json['event'] as int?,
    );
  }

  bool get isUsed => gameweekUsed != null;

  String get displayName {
    switch (chipName) {
      case 'wildcard':
        return 'Wildcard';
      case 'freehit':
        return 'Free Hit';
      case 'bboost':
        return 'Bench Boost';
      case '3xc':
        return 'Triple Captain';
      default:
        return chipName;
    }
  }

  String get icon {
    switch (chipName) {
      case 'wildcard':
        return '🃏';
      case 'freehit':
        return '⚡';
      case 'bboost':
        return '📈';
      case '3xc':
        return '👑';
      default:
        return '🎯';
    }
  }
}

/// Model representing a player pick in the user's team
class UserPick {
  final int playerId;
  final int position;
  final double sellingPrice;
  final int multiplier;
  final bool isCaptain;
  final bool isViceCaptain;

  UserPick({
    required this.playerId,
    required this.position,
    required this.sellingPrice,
    required this.multiplier,
    required this.isCaptain,
    required this.isViceCaptain,
  });

  factory UserPick.fromJson(Map<String, dynamic> json) {
    return UserPick(
      playerId: _toInt(json['element']),
      position: _toInt(json['position']),
      sellingPrice: _toDouble(json['selling_price']) / 10,
      multiplier: _toInt(json['multiplier']),
      isCaptain: _toBool(json['is_captain']),
      isViceCaptain: _toBool(json['is_vice_captain']),
    );
  }

  bool get isOnBench => position > 11;
  bool get isInStartingXI => position <= 11;

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

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    return false;
  }
}

/// Model representing user's transfer information
class UserTransfers {
  final int freeTransfers;
  final int cost;
  final String status;
  final int limit;

  UserTransfers({
    required this.freeTransfers,
    required this.cost,
    required this.status,
    required this.limit,
  });

  factory UserTransfers.fromJson(Map<String, dynamic> json) {
    return UserTransfers(
      freeTransfers: json['limit'] as int? ?? 1,
      cost: json['cost'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      limit: json['limit'] as int? ?? 1,
    );
  }
}

/// Complete model representing user's team data for planning screen
class UserTeamData {
  final UserTeam entry;
  final List<UserGameweekHistory> history;
  final List<UserChips> chips;
  final List<UserPick> picks;
  final int freeTransfers;
  final double bank;
  final double squadValue;
  final int currentGameweek;

  UserTeamData({
    required this.entry,
    required this.history,
    required this.chips,
    required this.picks,
    required this.freeTransfers,
    required this.bank,
    required this.squadValue,
    required this.currentGameweek,
  });

  double get totalValue => squadValue + bank;
  
  List<UserChips> get availableChips => chips.where((c) => !c.isUsed).toList();
  List<UserChips> get usedChips => chips.where((c) => c.isUsed).toList();
  
  UserGameweekHistory? get latestHistory => history.isNotEmpty ? history.last : null;
  int get totalPoints => latestHistory?.totalPoints ?? 0;
  int get overallRank => latestHistory?.overallRank ?? 0;
  int get gameweekPoints => latestHistory?.points ?? 0;
  int get gameweekRank => latestHistory?.rank ?? 0;
  
  List<UserPick> get startingXI => picks.where((p) => p.isInStartingXI).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
  
  List<UserPick> get bench => picks.where((p) => p.isOnBench).toList()
    ..sort((a, b) => a.position.compareTo(b.position));
  
  UserPick? get captain => picks.firstWhere(
    (p) => p.isCaptain,
    orElse: () => picks.first,
  );
  
  UserPick? get viceCaptain => picks.firstWhere(
    (p) => p.isViceCaptain,
    orElse: () => picks.first,
  );
}
