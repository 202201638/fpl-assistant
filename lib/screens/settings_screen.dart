import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoRefreshEnabled = true;
  String _refreshInterval = '5 minutes';
  String _defaultView = 'League Table';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'Settings',
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
          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Push Notifications',
              'Get notified about gameweek deadlines and updates',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
              Icons.notifications,
            ),
          ]),

          const SizedBox(height: 20),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme throughout the app',
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
              Icons.dark_mode,
            ),
          ]),

          const SizedBox(height: 20),

          // Data & Sync Section
          _buildSectionHeader('Data & Sync'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Auto Refresh',
              'Automatically refresh data when app opens',
              _autoRefreshEnabled,
              (value) => setState(() => _autoRefreshEnabled = value),
              Icons.refresh,
            ),
            _buildDropdownTile(
              'Refresh Interval',
              'How often to check for new data',
              _refreshInterval,
              ['1 minute', '5 minutes', '15 minutes', '30 minutes'],
              (value) => setState(() => _refreshInterval = value!),
              Icons.schedule,
            ),
            _buildDropdownTile(
              'Default View',
              'Screen to show when app opens',
              _defaultView,
              ['League Table', 'Fixtures', 'Transfers'],
              (value) => setState(() => _defaultView = value!),
              Icons.home,
            ),
          ]),

          const SizedBox(height: 20),

          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsCard([
            _buildActionTile(
              'Profile',
              'Manage your FPL account connection',
              Icons.person,
              () => _navigateToProfile(),
            ),
            _buildActionTile(
              'Clear Cache',
              'Clear stored data and images',
              Icons.cleaning_services,
              () => _showClearCacheDialog(),
            ),
          ]),

          const SizedBox(height: 20),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingsCard([
            _buildActionTile(
              'App Version',
              'v1.0.0',
              Icons.info,
              null,
            ),
            _buildActionTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () => _showPrivacyPolicy(),
            ),
            _buildActionTile(
              'Terms of Service',
              'Read our terms of service',
              Icons.description,
              () => _showTermsOfService(),
            ),
            _buildActionTile(
              'Rate App',
              'Rate us on the app store',
              Icons.star,
              () => _rateApp(),
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF00FF87),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF00FF87),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00FF87),
        activeTrackColor: const Color(0xFF00FF87).withOpacity(0.3),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF00FF87),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: const Color(0xFF2A0A2E),
        style: const TextStyle(color: Colors.white),
        underline: Container(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF00FF87),
        ),
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(
            option,
            style: const TextStyle(fontSize: 14),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF00FF87),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            )
          : null,
      onTap: onTap,
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'Clear Cache',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will clear all stored data and images. The app will need to reload data from the internet.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    // TODO: Implement cache clearing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Color(0xFF00FF87),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            'FPL Assistant Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data.\n\n'
            '• We only collect data necessary for app functionality\n'
            '• Your FPL data is fetched directly from official APIs\n'
            '• We do not store personal information on our servers\n'
            '• All data is stored locally on your device\n\n'
            'For questions, contact us at support@fplassistant.com',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'Terms of Service',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Text(
            'FPL Assistant Terms of Service\n\n'
            'By using this app, you agree to:\n\n'
            '• Use the app for personal, non-commercial purposes\n'
            '• Not attempt to reverse engineer or modify the app\n'
            '• Respect the Fantasy Premier League terms of service\n'
            '• Understand that we are not affiliated with the Premier League\n\n'
            'The app is provided "as is" without warranties.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
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

  void _rateApp() {
    // TODO: Implement app store rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! This would open the app store.'),
        backgroundColor: Color(0xFF00FF87),
      ),
    );
  }
}

