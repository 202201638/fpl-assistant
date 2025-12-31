import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_team.dart';
import '../models/player.dart';
import '../services/fpl_api_service.dart';

class TeamPlanScreen extends StatefulWidget {
  const TeamPlanScreen({super.key});

  @override
  State<TeamPlanScreen> createState() => _TeamPlanScreenState();
}

class _TeamPlanScreenState extends State<TeamPlanScreen> {
  final FPLApiService _apiService = FPLApiService.instance;
  final TextEditingController _fplIdController = TextEditingController();
  
  UserTeamData? _teamData;
  List<Player> _allPlayers = [];
  Map<int, Player> _playerMap = {};
  bool _isLoading = false;
  String? _error;
  String? _savedFplId;

  @override
  void initState() {
    super.initState();
    _loadSavedFplId();
  }

  @override
  void dispose() {
    _fplIdController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedFplId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('fpl_team_id');
    if (savedId != null && savedId.isNotEmpty) {
      setState(() {
        _savedFplId = savedId;
        _fplIdController.text = savedId;
      });
      _loadTeamData(savedId);
    }
  }

  Future<void> _saveFplId(String fplId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fpl_team_id', fplId);
    setState(() {
      _savedFplId = fplId;
    });
  }

  Future<void> _loadTeamData(String fplIdStr) async {
    final fplId = int.tryParse(fplIdStr);
    if (fplId == null) {
      setState(() {
        _error = 'Please enter a valid FPL ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load players first to map picks to player data
      if (_allPlayers.isEmpty) {
        _allPlayers = await _apiService.getPlayers();
        _playerMap = {for (var p in _allPlayers) p.id: p};
      }

      // Load user team data
      final teamData = await _apiService.getUserTeamData(fplId);
      
      // Save the FPL ID
      await _saveFplId(fplIdStr);

      setState(() {
        _teamData = teamData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Player? _getPlayer(int playerId) {
    return _playerMap[playerId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'My Team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_teamData != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => _loadTeamData(_fplIdController.text),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_savedFplId == null && _teamData == null) {
      return _buildFplIdInput();
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_teamData == null) {
      return _buildFplIdInput();
    }

    return _buildTeamView();
  }

  Widget _buildFplIdInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A0A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 60,
                  color: Color(0xFF00FF87),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter Your FPL ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find your FPL ID on the Fantasy Premier League website in your team\'s URL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _fplIdController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'e.g., 1234567',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: const Color(0xFF37003C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FF87), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _loadTeamData(_fplIdController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: const Color(0xFF37003C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF37003C)),
                            ),
                          )
                        : const Text(
                            'Load My Team',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _savedFplId = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: const Color(0xFF37003C),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Team Header with stats
          _buildTeamHeader(),
          
          // Football pitch with formation
          _buildFootballPitch(),
          
          // Bench
          _buildBench(),
          
          // Stats and Chips
          _buildStatsAndChips(),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    final data = _teamData!;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00FF87).withOpacity(0.2),
            const Color(0xFF2A0A2E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            data.entry.teamName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.entry.fullName,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('GW ${data.currentGameweek}', '${data.gameweekPoints} pts'),
              _buildStatColumn('Total', '${data.totalPoints} pts'),
              _buildStatColumn('Rank', _formatRank(data.overallRank)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00FF87),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatRank(int rank) {
    if (rank >= 1000000) {
      return '${(rank / 1000000).toStringAsFixed(1)}M';
    } else if (rank >= 1000) {
      return '${(rank / 1000).toStringAsFixed(0)}K';
    }
    return rank.toString();
  }

  Widget _buildFootballPitch() {
    final picks = _teamData!.startingXI;
    
    // Group players by position
    final gks = picks.where((p) {
      final player = _getPlayer(p.playerId);
      return player?.elementType == 1;
    }).toList();
    
    final defs = picks.where((p) {
      final player = _getPlayer(p.playerId);
      return player?.elementType == 2;
    }).toList();
    
    final mids = picks.where((p) {
      final player = _getPlayer(p.playerId);
      return player?.elementType == 3;
    }).toList();
    
    final fwds = picks.where((p) {
      final player = _getPlayer(p.playerId);
      return player?.elementType == 4;
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E7D32), // Dark green
            Color(0xFF388E3C), // Medium green
            Color(0xFF43A047), // Light green
            Color(0xFF388E3C),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Pitch markings
          CustomPaint(
            size: const Size(double.infinity, 480),
            painter: PitchPainter(),
          ),
          // Players
          SizedBox(
            height: 480,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Forwards
                _buildPlayerRow(fwds),
                // Midfielders
                _buildPlayerRow(mids),
                // Defenders
                _buildPlayerRow(defs),
                // Goalkeeper
                _buildPlayerRow(gks),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow(List<UserPick> picks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: picks.map((pick) => _buildPlayerCard(pick)).toList(),
      ),
    );
  }

  Widget _buildPlayerCard(UserPick pick) {
    final player = _getPlayer(pick.playerId);
    if (player == null) return const SizedBox();

    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player image with captain/vice badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: pick.isCaptain
                        ? Colors.amber
                        : pick.isViceCaptain
                            ? Colors.grey
                            : Colors.white.withOpacity(0.3),
                    width: pick.isCaptain || pick.isViceCaptain ? 3 : 1,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _apiService.getPlayerPhotoUrl(player.code),
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF37003C),
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF37003C),
                      child: const Icon(Icons.person, color: Colors.white54),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Captain badge
              if (pick.isCaptain)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'C',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Vice captain badge
              if (pick.isViceCaptain)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'V',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Player name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF37003C).withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player.webName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${player.totalPoints}',
              style: const TextStyle(
                color: Color(0xFF37003C),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBench() {
    final bench = _teamData!.bench;
    
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bench',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: bench.map((pick) => _buildBenchPlayer(pick)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchPlayer(UserPick pick) {
    final player = _getPlayer(pick.playerId);
    if (player == null) return const SizedBox();

    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: _apiService.getPlayerPhotoUrl(player.code),
                placeholder: (context, url) => Container(
                  color: const Color(0xFF37003C),
                  child: const Icon(Icons.person, color: Colors.white54, size: 20),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF37003C),
                  child: const Icon(Icons.person, color: Colors.white54, size: 20),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            player.webName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          Text(
            '${player.totalPoints} pts',
            style: const TextStyle(
              color: Color(0xFF00FF87),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsAndChips() {
    final data = _teamData!;
    
    return Column(
      children: [
        // Budget and Transfers
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A0A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoTile(
                    icon: Icons.account_balance_wallet,
                    label: 'In Bank',
                    value: '£${data.bank.toStringAsFixed(1)}m',
                  ),
                  _buildInfoTile(
                    icon: Icons.trending_up,
                    label: 'Squad Value',
                    value: '£${data.squadValue.toStringAsFixed(1)}m',
                  ),
                  _buildInfoTile(
                    icon: Icons.swap_horiz,
                    label: 'Free Transfers',
                    value: '${data.freeTransfers}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Chips
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A0A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.chips.map((chip) => _buildChipBadge(chip)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF00FF87), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildChipBadge(UserChips chip) {
    final isUsed = chip.isUsed;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUsed
            ? Colors.grey.withOpacity(0.3)
            : const Color(0xFF00FF87).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUsed ? Colors.grey : const Color(0xFF00FF87),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chip.icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            chip.displayName,
            style: TextStyle(
              color: isUsed ? Colors.grey : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: isUsed ? TextDecoration.lineThrough : null,
            ),
          ),
          if (isUsed) ...[
            const SizedBox(width: 4),
            Text(
              'GW${chip.gameweekUsed}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Custom painter for football pitch markings
class PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Top penalty box
    final topBoxRect = Rect.fromLTWH(
      size.width * 0.2,
      0,
      size.width * 0.6,
      size.height * 0.15,
    );
    canvas.drawRect(topBoxRect, paint);

    // Top goal box
    final topGoalRect = Rect.fromLTWH(
      size.width * 0.35,
      0,
      size.width * 0.3,
      size.height * 0.06,
    );
    canvas.drawRect(topGoalRect, paint);

    // Bottom penalty box
    final bottomBoxRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.6,
      size.height * 0.15,
    );
    canvas.drawRect(bottomBoxRect, paint);

    // Bottom goal box
    final bottomGoalRect = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.94,
      size.width * 0.3,
      size.height * 0.06,
    );
    canvas.drawRect(bottomGoalRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
