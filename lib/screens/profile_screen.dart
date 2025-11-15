import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fplIdController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fplIdController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // TODO: Load saved user data from SharedPreferences
    // For now, using mock data
    _fplIdController.text = '';
    _teamNameController.text = '';
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Save to SharedPreferences and validate FPL ID
        await Future.delayed(const Duration(seconds: 1)); // Mock API call
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully!'),
              backgroundColor: Color(0xFF00FF87),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              const SizedBox(height: 30),
              
              // FPL ID Section
              _buildFPLIdSection(),
              
              const SizedBox(height: 20),
              
              // Team Name Section
              _buildTeamNameSection(),
              
              const SizedBox(height: 30),
              
              // Statistics Section
              _buildStatisticsSection(),
              
              const SizedBox(height: 30),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Color(0xFF37003C),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Welcome Text
          const Text(
            'Welcome to FPL Assistant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Connect your FPL account to get started',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFPLIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FPL Team ID',
          style: TextStyle(
            color: Color(0xFF00FF87),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Enter your Fantasy Premier League team ID to sync your data',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _fplIdController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g., 1234567',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(
              Icons.sports_soccer,
              color: Color(0xFF00FF87),
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.help_outline,
                color: Color(0xFF00FF87),
              ),
              onPressed: () => _showFPLIdHelp(),
            ),
            filled: true,
            fillColor: const Color(0xFF2A0A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00FF87),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your FPL Team ID';
            }
            if (value.length < 6) {
              return 'FPL Team ID must be at least 6 digits';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTeamNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Team Name (Optional)',
          style: TextStyle(
            color: Color(0xFF00FF87),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextFormField(
          controller: _teamNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your team name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: const Icon(
              Icons.flag,
              color: Color(0xFF00FF87),
            ),
            filled: true,
            fillColor: const Color(0xFF2A0A2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00FF87),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              color: Color(0xFF00FF87),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Overall Rank', '--'),
              _buildStatItem('Total Points', '--'),
              _buildStatItem('GW Rank', '--'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF87).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF00FF87),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connect your FPL account to see your live statistics',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FF87),
          foregroundColor: const Color(0xFF37003C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
                'Save Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showFPLIdHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A0A2E),
        title: const Text(
          'How to find your FPL Team ID',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Go to fantasy.premierleague.com\n'
              '2. Log in to your account\n'
              '3. Go to "Points" or "My Team"\n'
              '4. Look at the URL in your browser\n'
              '5. Your Team ID is the number after "entry/"\n\n'
              'Example: fantasy.premierleague.com/entry/1234567/\n'
              'Your Team ID would be: 1234567',
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
              'Got it!',
              style: TextStyle(color: Color(0xFF00FF87)),
            ),
          ),
        ],
      ),
    );
  }
}
