import 'package:flutter/material.dart';
import '../models/player.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int selectedPosition = 0; // 0=All, 1=GKP, 2=DEF, 3=MID, 4=FWD
  int selectedTeam = 0; // 0=All teams
  String sortBy = 'total_points';
  String searchQuery = '';
  bool showPlayerList = false;
  Player? selectedPlayerToReplace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'Transfers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to next gameweek or confirm transfers
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF87),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'NEXT',
                style: TextStyle(
                  color: Color(0xFF37003C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Transfer Stats Header
          _buildTransferStats(),
          
          // Team Formation or Player List
          Expanded(
            child: showPlayerList 
                ? _buildPlayerList()
                : _buildTeamFormation(),
          ),
          
          // Bottom Action Buttons
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildTransferStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2A0A2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Transfers', '0 / 3'),
          _buildStatItem('Cost', '0 pts'),
          _buildStatItem('Bank', '0.0'),
          _buildStatItem('xPts', '50.4'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: label == 'Bank' ? const Color(0xFF00FF87) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamFormation() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Football pitch background
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Goalkeeper
                Expanded(
                  flex: 1,
                  child: _buildFormationRow([1], 'GKP'),
                ),
                // Defenders
                Expanded(
                  flex: 2,
                  child: _buildFormationRow([2, 3, 4, 5], 'DEF'),
                ),
                // Midfielders
                Expanded(
                  flex: 2,
                  child: _buildFormationRow([6, 7, 8], 'MID'),
                ),
                // Forwards
                Expanded(
                  flex: 2,
                  child: _buildFormationRow([9, 10, 11], 'FWD'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormationRow(List<int> playerNumbers, String position) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: playerNumbers.map((number) => 
          Flexible(
            child: _buildPlayerCard(number, position),
          )
        ).toList(),
      ),
    );
  }

  Widget _buildPlayerCard(int playerNumber, String position) {
    // Mock player data - in real app, get from provider
    final playerName = _getMockPlayerName(playerNumber);
    final teamCode = _getMockTeamCode(playerNumber);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          showPlayerList = true;
          selectedPosition = _getPositionType(position);
        });
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Player Jersey
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTeamColor(teamCode),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      playerNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Info icon
                  const Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Player name
            Container(
              constraints: const BoxConstraints(maxWidth: 70),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                playerName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    return Column(
      children: [
        // Filters
        _buildFilters(),
        
        // Player List
        Expanded(
          child: Container(
            color: const Color(0xFF00FF87),
            child: Column(
              children: [
                // List Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF00CC6A),
                  child: Row(
                    children: const [
                      Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('%', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('£', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 1, child: Text('xPts', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                
                // Player Items
                Expanded(
                  child: ListView.builder(
                    itemCount: 10, // Mock data
                    itemBuilder: (context, index) => _buildPlayerListItem(index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF00B8D4),
      child: Column(
        children: [
          // Position and Club filters
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Position', ['All', 'GKP', 'DEF', 'MID', 'FWD']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('Club', ['All', 'ARS', 'CHE', 'LIV', 'MCI']),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sort by and Search
          Row(
            children: [
              Expanded(
                child: _buildDropdown('Sort By', ['Points', 'Price', 'Form', 'Selected %']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: (value) {
          // Handle filter change
        },
      ),
    );
  }

  Widget _buildPlayerListItem(int index) {
    // Mock player data
    final players = [
      {'name': 'Salah', 'team': 'LIV', 'percent': '70.8%', 'price': '£14.9', 'points': '102', 'xpts': '5.7'},
      {'name': 'M.Salah', 'team': 'LIV', 'percent': '23.9%', 'price': '£14.2', 'points': '54', 'xpts': '5.5'},
      {'name': 'Isak', 'team': 'NEW', 'percent': '4.6%', 'price': '£10.4', 'points': '10', 'xpts': '0'},
    ];
    
    if (index >= players.length) return const SizedBox.shrink();
    
    final player = players[index];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Team jersey icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getTeamColorByCode(player['team']!),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          
          // Player info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  player['team']!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(child: Text(player['percent']!)),
          Expanded(child: Text(player['price']!)),
          Expanded(child: Text(player['points']!)),
          Expanded(child: Text(player['xpts']!)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF2A0A2E),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('Wildcard', const Color(0xFF00FF87))),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton('Free Hit', const Color(0xFF00FF87))),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton('Triple Captain', const Color(0xFF00FF87))),
          const SizedBox(width: 8),
          Expanded(child: _buildActionButton('Bench Boost', const Color(0xFF00FF87))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Handle chip activation
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xFF37003C),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Helper methods
  String _getMockPlayerName(int number) {
    final names = {
      1: 'Dubravka', 2: 'Keane', 3: 'Senesi', 4: 'Calfiori', 5: 'Van de Ven',
      6: 'Guéhi', 7: 'M.Salah', 8: 'Semenyo', 9: 'Grealish', 10: 'Mateta', 11: 'Haaland'
    };
    return names[number] ?? 'Player $number';
  }

  int _getMockTeamCode(int number) {
    final codes = {
      1: 4, 2: 11, 3: 91, 4: 3, 5: 21, 6: 31, 7: 14, 8: 91, 9: 11, 10: 31, 11: 11
    };
    return codes[number] ?? 1;
  }

  Color _getTeamColor(int teamCode) {
    final colors = {
      3: const Color(0xFFEF0107), // Arsenal
      4: const Color(0xFF241F20), // Newcastle
      11: const Color(0xFF6CABDD), // Man City
      14: const Color(0xFFC8102E), // Liverpool
      21: const Color(0xFF132257), // Tottenham
      31: const Color(0xFF1B458F), // Crystal Palace
      91: const Color(0xFFDA020E), // Bournemouth
    };
    return colors[teamCode] ?? const Color(0xFF37003C);
  }

  Color _getTeamColorByCode(String teamCode) {
    final colors = {
      'ARS': const Color(0xFFEF0107),
      'NEW': const Color(0xFF241F20),
      'MCI': const Color(0xFF6CABDD),
      'LIV': const Color(0xFFC8102E),
      'TOT': const Color(0xFF132257),
      'CRY': const Color(0xFF1B458F),
      'BOU': const Color(0xFFDA020E),
    };
    return colors[teamCode] ?? const Color(0xFF37003C);
  }

  int _getPositionType(String position) {
    switch (position) {
      case 'GKP': return 1;
      case 'DEF': return 2;
      case 'MID': return 3;
      case 'FWD': return 4;
      default: return 0;
    }
  }
}
