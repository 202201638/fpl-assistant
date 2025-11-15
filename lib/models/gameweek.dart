class Gameweek {
  final int id;
  final String name;
  final String deadlineTime;
  final bool finished;
  final bool dataChecked;
  final bool highestScoringEntry;
  final int deadlineTimeEpoch;
  final String deadlineTimeGameOffset;
  final bool highestScore;
  final bool isPrevious;
  final bool isCurrent;
  final bool isNext;
  final int cupRanksCount;
  final String h2hKoMatchesCreated;
  final bool rankedCount;
  final int chipPlays;
  final int mostSelected;
  final int mostTransferredIn;
  final int topElement;
  final Map<String, int> topElementInfo;
  final int transfersMade;
  final int mostCaptained;
  final int mostViceCaptained;

  Gameweek({
    required this.id,
    required this.name,
    required this.deadlineTime,
    required this.finished,
    required this.dataChecked,
    required this.highestScoringEntry,
    required this.deadlineTimeEpoch,
    required this.deadlineTimeGameOffset,
    required this.highestScore,
    required this.isPrevious,
    required this.isCurrent,
    required this.isNext,
    required this.cupRanksCount,
    required this.h2hKoMatchesCreated,
    required this.rankedCount,
    required this.chipPlays,
    required this.mostSelected,
    required this.mostTransferredIn,
    required this.topElement,
    required this.topElementInfo,
    required this.transfersMade,
    required this.mostCaptained,
    required this.mostViceCaptained,
  });

  factory Gameweek.fromJson(Map<String, dynamic> json) {
    return Gameweek(
      id: _toInt(json['id']),
      name: _toString(json['name']),
      deadlineTime: _toString(json['deadline_time']),
      finished: _toBool(json['finished']),
      dataChecked: _toBool(json['data_checked']),
      highestScoringEntry: _toBool(json['highest_scoring_entry']),
      deadlineTimeEpoch: _toInt(json['deadline_time_epoch']),
      deadlineTimeGameOffset: _toString(json['deadline_time_game_offset']),
      highestScore: _toBool(json['highest_score']),
      isPrevious: _toBool(json['is_previous']),
      isCurrent: _toBool(json['is_current']),
      isNext: _toBool(json['is_next']),
      cupRanksCount: _toInt(json['cup_ranks_count']),
      h2hKoMatchesCreated: _toString(json['h2h_ko_matches_created']),
      rankedCount: _toBool(json['ranked_count']),
      chipPlays: _toInt(json['chip_plays']),
      mostSelected: _toInt(json['most_selected']),
      mostTransferredIn: _toInt(json['most_transferred_in']),
      topElement: _toInt(json['top_element']),
      topElementInfo: _toIntMap(json['top_element_info']),
      transfersMade: _toInt(json['transfers_made']),
      mostCaptained: _toInt(json['most_captained']),
      mostViceCaptained: _toInt(json['most_vice_captained']),
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

  static Map<String, int> _toIntMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(key, _toInt(val)));
    }
    return {};
  }
}
