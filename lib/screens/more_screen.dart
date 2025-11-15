import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _buildSectionCard(
            'Account',
            [
              _buildMenuItem(
                'Profile',
                'Manage your FPL account and team ID',
                Icons.person,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ),
              ),
              _buildMenuItem(
                'Settings',
                'App preferences and notifications',
                Icons.settings,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tools Section
          _buildSectionCard(
            'Tools',
            [
              _buildMenuItem(
                'Player Comparison',
                'Compare player statistics',
                Icons.compare_arrows,
                () => _showComingSoon(context, 'Player Comparison'),
              ),
              _buildMenuItem(
                'Price Changes',
                'Track player price movements',
                Icons.trending_up,
                () => _showComingSoon(context, 'Price Changes'),
              ),
              _buildMenuItem(
                'Fixture Difficulty',
                'Analyze upcoming fixtures',
                Icons.calendar_today,
                () => _showComingSoon(context, 'Fixture Difficulty'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Information Section
          _buildSectionCard(
            'Information',
            [
              _buildMenuItem(
                'Rules & Scoring',
                'FPL rules and point system',
                Icons.rule,
                () => _showRulesDialog(context),
              ),
              _buildMenuItem(
                'Help & Support',
                'Get help using the app',
                Icons.help,
                () => _showHelpDialog(context),
              ),
              _buildMenuItem(
                'About',
                'App version and credits',
                Icons.info,
                () => _showAboutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF00FF87),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A0A2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF00FF87).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00FF87),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: Text(
          feature,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'This feature is coming soon! We\'re working hard to bring you the best FPL experience.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it!',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'FPL Rules & Scoring',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scoring System:',
                style: TextStyle(
                  color: Color(0xFF00FF87),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Playing 60+ minutes: 2 points\n'
                '• Playing 1-59 minutes: 1 point\n'
                '• Goal (GK/DEF): 6 points\n'
                '• Goal (MID): 5 points\n'
                '• Goal (FWD): 4 points\n'
                '• Assist: 3 points\n'
                '• Clean sheet (GK/DEF): 4 points\n'
                '• Clean sheet (MID): 1 point\n'
                '• Save (GK): 1 point per 3 saves\n'
                '• Penalty save: 5 points\n'
                '• Yellow card: -1 point\n'
                '• Red card: -3 points\n'
                '• Own goal: -2 points\n'
                '• Penalty miss: -2 points\n'
                '• 2+ goals conceded (GK/DEF): -1 point',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Getting Started:\n'
              '1. Go to Profile and enter your FPL Team ID\n'
              '2. Browse league tables and fixtures\n'
              '3. Use the transfers screen to plan changes\n\n'
              'Need Help?\n'
              '• Check the FPL official website for rules\n'
              '• Contact us at support@fplassistant.com\n'
              '• Follow us on social media for updates',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'About FPL Assistant',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Color(0xFF00FF87),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'FPL Assistant is an unofficial companion app for Fantasy Premier League managers. '
              'Get live updates, track your team performance, and make informed decisions.\n\n'
              'This app is not affiliated with the Premier League or Fantasy Premier League.\n\n'
              'Made with ❤️ for FPL managers worldwide.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }
}
