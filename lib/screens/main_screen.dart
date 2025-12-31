import 'package:flutter/material.dart';
import 'league_table_screen.dart';
import 'fixtures_screen.dart';
import 'transfers_screen.dart';
import 'team_plan_screen.dart';
import 'more_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LeagueTableScreen(),
    const FixturesScreen(),
    const TeamPlanScreen(),
    const TransfersScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF37003C),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF37003C),
          selectedItemColor: const Color(0xFF00FF87),
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.table_chart, 0),
              label: 'Table',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.sports_soccer, 1),
              label: 'Fixtures',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.people, 2),
              label: 'My Team',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.swap_horiz, 3),
              label: 'Transfers',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.more_horiz, 4),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected 
          ? const Color(0xFF00FF87).withOpacity(0.2)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected 
          ? const Color(0xFF00FF87)
          : Colors.white54,
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37003C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37003C),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              title == 'Transfers' ? Icons.swap_horiz : Icons.more_horiz,
              size: 80,
              color: const Color(0xFF00FF87).withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              '$title Screen',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
