import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/fixture.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../providers/fpl_provider.dart';
import '../providers/starred_matches_provider.dart';

class MatchDetailsScreen extends StatelessWidget {
  final Fixture fixture;
  final Team homeTeam;
  final Team awayTeam;
  final FPLProvider provider;

  const MatchDetailsScreen({
    super.key,
    required this.fixture,
    required this.homeTeam,
    required this.awayTeam,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${homeTeam.shortName} vs ${awayTeam.shortName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<StarredMatchesProvider>(
            builder: (context, starredProvider, _) {
              final isStarred = starredProvider.isMatchStarred(fixture.id);
              return IconButton(
                icon: Icon(
                  isStarred ? Icons.star : Icons.star_outline,
                  color: isStarred ? const Color(0xFF00FF87) : Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  if (!isStarred && !starredProvider.notificationsEnabled) {
                    // Ask for notification permission
                    _showNotificationPermissionDialog(context, starredProvider);
                  } else {
                    await starredProvider.toggleStarMatch(
                      fixture,
                      homeTeam.name,
                      awayTeam.name,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Match Header with Score
            _buildMatchHeader(),
            const SizedBox(height: 20),
            
            // Match Stats (if available)
            if (fixture.started && fixture.stats.isNotEmpty)
              _buildMatchStats(),
            
            const SizedBox(height: 20),
            
            // Team Lineups
            _buildLineupSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    final homeColors = homeTeam.teamColors;
    final awayColors = awayTeam.teamColors;
    final homePrimaryColor = Color(int.parse('0xFF${homeColors['primary']!.substring(1)}'));
    final awayPrimaryColor = Color(int.parse('0xFF${awayColors['primary']!.substring(1)}'));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A0A2E),
            const Color(0xFF1A0A1E),
          ],
        ),
      ),
      child: Column(
        children: [
          // Teams and Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Team
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: provider.getTeamLogoUrl(homeTeam.id),
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: homePrimaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          color: homePrimaryColor,
                          size: 30,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: homePrimaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          homeTeam.shortName.substring(0, 2),
                          style: TextStyle(
                            color: homePrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      homeTeam.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Score
              Column(
                children: [
                  if (fixture.started)
                    Text(
                      '${fixture.teamHScore}',
                      style: const TextStyle(
                        color: Color(0xFF00FF87),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: fixture.finished
                          ? Colors.green.withOpacity(0.2)
                          : fixture.started
                              ? const Color(0xFF00FF87).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fixture.status,
                      style: TextStyle(
                        color: fixture.finished
                            ? Colors.green
                            : fixture.started
                                ? const Color(0xFF00FF87)
                                : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Away Team
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: provider.getTeamLogoUrl(awayTeam.id),
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: awayPrimaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sports_soccer,
                          color: awayPrimaryColor,
                          size: 30,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: awayPrimaryColor.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          awayTeam.shortName.substring(0, 2),
                          style: TextStyle(
                            color: awayPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      awayTeam.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (fixture.started)
            Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${fixture.teamAScore}',
                      style: const TextStyle(
                        color: Color(0xFF00FF87),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...fixture.stats.map((stat) => _buildStatRow(stat)).toList(),
        ],
      ),
    );
  }

  Widget _buildStatRow(FixtureStat stat) {
    final homeValue = stat.h.isNotEmpty ? stat.h.first.value : 0;
    final awayValue = stat.a.isNotEmpty ? stat.a.first.value : 0;
    
    String statLabel = stat.identifier.replaceAll('_', ' ').toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            statLabel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$homeValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: homeValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF87),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: awayValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  '$awayValue',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineupSection() {
    // Get players for each team
    final homePlayers = _getTeamPlayers(homeTeam.id);
    final awayPlayers = _getTeamPlayers(awayTeam.id);

    return Column(
      children: [
        // Home Team Lineup
        _buildTeamLineup(homeTeam, homePlayers, true),
        const SizedBox(height: 20),
        
        // Away Team Lineup
        _buildTeamLineup(awayTeam, awayPlayers, false),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTeamLineup(Team team, List<Player> players, bool isHome) {
    final teamColors = team.teamColors;
    final primaryColor = Color(int.parse('0xFF${teamColors['primary']!.substring(1)}'));

    // Group players by position
    final goalkeepers = players.where((p) => p.elementType == 1).toList();
    final defenders = players.where((p) => p.elementType == 2).toList();
    final midfielders = players.where((p) => p.elementType == 3).toList();
    final forwards = players.where((p) => p.elementType == 4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Team Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: provider.getTeamLogoUrl(team.id),
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  '${team.name} (${players.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Lineup by Position
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (goalkeepers.isNotEmpty) ...[
                  _buildPositionGroup('GOALKEEPERS', goalkeepers),
                  const SizedBox(height: 12),
                ],
                if (defenders.isNotEmpty) ...[
                  _buildPositionGroup('DEFENDERS', defenders),
                  const SizedBox(height: 12),
                ],
                if (midfielders.isNotEmpty) ...[
                  _buildPositionGroup('MIDFIELDERS', midfielders),
                  const SizedBox(height: 12),
                ],
                if (forwards.isNotEmpty) ...[
                  _buildPositionGroup('FORWARDS', forwards),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionGroup(String position, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          position,
          style: const TextStyle(
            color: Color(0xFF00FF87),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...players.map((player) => _buildPlayerCard(player)).toList(),
      ],
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Player Avatar (placeholder)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.webName.isNotEmpty 
                    ? player.webName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF00FF87),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  player.positionName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Icon
          if (player.statusIcon.isNotEmpty)
            Text(
              player.statusIcon,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  List<Player> _getTeamPlayers(int teamId) {
    return provider.getPlayersByTeamId(teamId);
  }

  void _showNotificationPermissionDialog(
    BuildContext context,
    StarredMatchesProvider starredProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'Enable Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Get notified when this match starts, ends, or has important updates.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Not Now',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await starredProvider.enableNotifications();
              if (context.mounted) {
                await starredProvider.toggleStarMatch(
                  fixture,
                  homeTeam.name,
                  awayTeam.name,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Match starred! You\'ll get notifications.'),
                    backgroundColor: Color(0xFF00FF87),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FF87),
              foregroundColor: const Color(0xFF37003C),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}
