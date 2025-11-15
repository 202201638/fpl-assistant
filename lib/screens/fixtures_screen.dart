import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/fpl_provider.dart';
import '../models/fixture.dart';
import '../models/team.dart';

class FixturesScreen extends StatelessWidget {
  const FixturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'Fixtures & Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<FPLProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.fixtures.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              ),
            );
          }

          if (provider.error != null && provider.fixtures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading fixtures',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF87),
                      foregroundColor: const Color(0xFF37003C),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: const Color(0xFF00FF87),
            backgroundColor: const Color(0xFF37003C),
            child: Column(
              children: [
                // Gameweek Selector
                _buildGameweekSelector(provider),
                
                // Fixtures List
                Expanded(
                  child: provider.selectedGameweekFixtures.isEmpty
                      ? const Center(
                          child: Text(
                            'No fixtures available',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: provider.selectedGameweekFixtures.length,
                          itemBuilder: (context, index) {
                            final fixture = provider.selectedGameweekFixtures[index];
                            return _buildFixtureCard(context, fixture, provider);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameweekSelector(FPLProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF2A0A2E),
      child: Row(
        children: [
          // Previous Gameweek Button
          IconButton(
            onPressed: provider.selectedGameweek > 1
                ? () => provider.selectGameweek(provider.selectedGameweek - 1)
                : null,
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          
          // Current Gameweek Display
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gameweek ${provider.selectedGameweek}',
                    style: const TextStyle(
                      color: Color(0xFF00FF87),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (provider.currentGameweek?.id == provider.selectedGameweek)
                    const Text(
                      'Current',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Next Gameweek Button
          IconButton(
            onPressed: provider.selectedGameweek < 38
                ? () => provider.selectGameweek(provider.selectedGameweek + 1)
                : null,
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFixtureCard(BuildContext context, Fixture fixture, FPLProvider provider) {
    final homeTeam = provider.getTeamById(fixture.teamH);
    final awayTeam = provider.getTeamById(fixture.teamA);
    
    if (homeTeam == null || awayTeam == null) {
      return const SizedBox.shrink();
    }

    final kickoffTime = DateTime.tryParse(fixture.kickoffTime);
    final difficultyRating = fixture.getDifficultyRating(fixture.teamH, provider.teams);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Could show fixture details
            _showFixtureDetails(context, fixture, homeTeam, awayTeam);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Match Status and Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMatchStatus(fixture),
                    if (kickoffTime != null && !fixture.started)
                      Text(
                        DateFormat('HH:mm').format(kickoffTime),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    _buildDifficultyRating(difficultyRating),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Teams and Score
                Row(
                  children: [
                    // Home Team
                    Expanded(
                      child: _buildTeamSection(homeTeam, provider, true),
                    ),
                    
                    // Score or VS
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: fixture.started
                          ? Text(
                              '${fixture.teamHScore} - ${fixture.teamAScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              'VS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                    
                    // Away Team
                    Expanded(
                      child: _buildTeamSection(awayTeam, provider, false),
                    ),
                  ],
                ),
                
                // Match Stats (if available)
                if (fixture.started && fixture.stats.isNotEmpty)
                  _buildMatchStats(fixture),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(Team team, FPLProvider provider, bool isHome) {
    final teamColors = team.teamColors;
    final primaryColor = Color(int.parse('0xFF${teamColors['primary']!.substring(1)}'));

    return Column(
      children: [
        // Team Logo
        CachedNetworkImage(
          imageUrl: provider.getTeamLogoUrl(team.id),
          placeholder: (context, url) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sports_soccer,
              color: primaryColor,
              size: 20,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              team.shortName.substring(0, 2),
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        
        const SizedBox(height: 8),
        
        // Team Name
        Text(
          team.shortName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMatchStatus(Fixture fixture) {
    Color statusColor;
    String statusText;

    if (fixture.finished) {
      statusColor = Colors.green;
      statusText = 'FT';
    } else if (fixture.started) {
      statusColor = const Color(0xFF00FF87);
      statusText = 'LIVE';
    } else {
      statusColor = Colors.white70;
      statusText = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDifficultyRating(int difficulty) {
    Color difficultyColor;
    String difficultyText;

    switch (difficulty) {
      case 1:
        difficultyColor = Colors.green;
        difficultyText = 'Easy';
        break;
      case 3:
        difficultyColor = Colors.red;
        difficultyText = 'Hard';
        break;
      default:
        difficultyColor = Colors.orange;
        difficultyText = 'Medium';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: difficultyColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficultyText,
        style: TextStyle(
          color: difficultyColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMatchStats(Fixture fixture) {
    // Find possession and shots stats
    final possessionStat = fixture.stats.firstWhere(
      (stat) => stat.identifier == 'possession',
      orElse: () => FixtureStat(identifier: '', a: [], h: []),
    );
    
    final shotsStat = fixture.stats.firstWhere(
      (stat) => stat.identifier == 'total_shots',
      orElse: () => FixtureStat(identifier: '', a: [], h: []),
    );

    if (possessionStat.identifier.isEmpty && shotsStat.identifier.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (possessionStat.identifier.isNotEmpty)
            _buildStatRow(
              'Possession',
              possessionStat.h.isNotEmpty ? '${possessionStat.h.first.value}%' : '0%',
              possessionStat.a.isNotEmpty ? '${possessionStat.a.first.value}%' : '0%',
            ),
          if (shotsStat.identifier.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildStatRow(
              'Shots',
              shotsStat.h.isNotEmpty ? '${shotsStat.h.first.value}' : '0',
              shotsStat.a.isNotEmpty ? '${shotsStat.a.first.value}' : '0',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          homeValue,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          awayValue,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFixtureDetails(BuildContext context, Fixture fixture, Team homeTeam, Team awayTeam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A0A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${homeTeam.name} vs ${awayTeam.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (fixture.started)
              Text(
                'Score: ${fixture.teamHScore} - ${fixture.teamAScore}',
                style: const TextStyle(
                  color: Color(0xFF00FF87),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Status: ${fixture.status}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                foregroundColor: const Color(0xFF37003C),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
