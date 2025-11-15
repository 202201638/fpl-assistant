import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/fpl_provider.dart';
import '../models/team.dart';

class LeagueTableScreen extends StatelessWidget {
  const LeagueTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'Premier League Table',
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
          if (provider.isLoading && provider.teams.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
              ),
            );
          }

          if (provider.error != null && provider.teams.isEmpty) {
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
                    'Error loading data',
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
                // Current Gameweek Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF37003C),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.currentGameweek != null 
                          ? 'Gameweek ${provider.currentGameweek!.id}'
                          : 'Current Season',
                        style: const TextStyle(
                          color: Color(0xFF00FF87),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (provider.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF2A0A2E),
                  child: const Row(
                    children: [
                      SizedBox(width: 30), // Position
                      SizedBox(width: 40), // Logo
                      Expanded(child: Text('Club', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500))),
                      SizedBox(width: 30, child: Text('P', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text('W', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text('D', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                      SizedBox(width: 30, child: Text('L', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                      SizedBox(width: 40, child: Text('GD', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                      SizedBox(width: 40, child: Text('Pts', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center)),
                    ],
                  ),
                ),

                // League Table
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.leagueTable.length,
                    itemBuilder: (context, index) {
                      final team = provider.leagueTable[index];
                      return _buildTeamRow(context, team, provider);
                    },
                  ),
                ),

                // Legend
                _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, Team team, FPLProvider provider) {
    final teamColors = team.teamColors;
    final primaryColor = Color(int.parse('0xFF${teamColors['primary']!.substring(1)}'));
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: Material(
        color: _getPositionColor(team.position),
        child: InkWell(
          onTap: () {
            // Could navigate to team details
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Position
                Container(
                  width: 30,
                  child: Text(
                    '${team.position}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Team Logo
                Container(
                  width: 40,
                  height: 30,
                  margin: const EdgeInsets.only(right: 12),
                  child: CachedNetworkImage(
                    imageUrl: provider.getTeamLogoUrl(team.id),
                    placeholder: (context, url) => Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        team.shortName.substring(0, 2),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Team Name
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Played
                SizedBox(
                  width: 30,
                  child: Text(
                    '${team.played}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Won
                SizedBox(
                  width: 30,
                  child: Text(
                    '${team.win}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Draw
                SizedBox(
                  width: 30,
                  child: Text(
                    '${team.draw}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Lost
                SizedBox(
                  width: 30,
                  child: Text(
                    '${team.loss}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Goal Difference
                SizedBox(
                  width: 40,
                  child: Text(
                    '${team.goalDifference >= 0 ? '+' : ''}${team.goalDifference}',
                    style: TextStyle(
                      color: team.goalDifference >= 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Points
                SizedBox(
                  width: 40,
                  child: Text(
                    '${team.points}',
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
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 4) {
      return const Color(0xFF1E88E5).withOpacity(0.1); // Champions League - Blue
    } else if (position <= 6) {
      return const Color(0xFFFF9800).withOpacity(0.1); // Europa League - Orange
    } else if (position >= 18) {
      return const Color(0xFFE53935).withOpacity(0.1); // Relegation - Red
    }
    return Colors.transparent;
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2A0A2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Table Key',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendItem(const Color(0xFF1E88E5), 'Champions League'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFFF9800), 'Europa League'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFE53935), 'Relegation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
