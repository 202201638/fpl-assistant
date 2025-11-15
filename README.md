# FPL Assistant

A comprehensive Flutter app for Fantasy Premier League enthusiasts, providing real-time league tables, fixtures, results, and match statistics.

## Features

### 🏆 League Table Screen
- **Current Premier League Table**: Display teams sorted by position with complete statistics
- **Team Statistics**: Shows played matches, wins, draws, losses, goals for/against, goal difference, and points
- **Official Team Badges**: Integration with official EPL club logos and team colors
- **Position Indicators**: Visual indicators for Champions League, Europa League, and Relegation positions
- **Real-time Updates**: Pull-to-refresh functionality for latest standings

### ⚽ Fixtures & Results Screen
- **Current Gameweek Fixtures**: List all matches for the selected gameweek
- **Match Status**: Live match indicators, finished results, and upcoming fixtures
- **Team Logos**: Official team badges displayed for each fixture
- **Gameweek Navigation**: Easy navigation between different gameweeks
- **Match Statistics**: Basic in-game stats for live and finished matches (possession, shots)
- **Fixture Difficulty**: Color-coded difficulty ratings for each match
- **Kickoff Times**: Display match start times for upcoming fixtures

### 🎯 Bottom Navigation
- **Intuitive Navigation**: Four-tab bottom navigation matching the wireframe design
- **Active Tab Highlighting**: Visual feedback for the currently selected tab
- **Consistent Design**: Maintains FPL brand colors and styling throughout

## Technical Implementation

### 🏗️ Architecture
- **Provider State Management**: Efficient state management using the Provider package
- **Modular Design**: Clean separation of concerns with dedicated models, services, and screens
- **Responsive UI**: Adaptive layouts that work across different screen sizes

### 🌐 API Integration
- **Fantasy Premier League API**: Direct integration with official FPL endpoints
- **Bootstrap Static Data**: Team information, gameweeks, and league metadata
- **Fixtures API**: Real-time fixture data with match statistics
- **Image Caching**: Efficient loading and caching of team logos using cached_network_image

### 🎨 Design & Styling
- **Official FPL Branding**: Authentic Premier League color scheme (#37003C primary, #00FF87 accent)
- **Team Colors**: Dynamic team-specific color schemes for enhanced visual appeal
- **Material Design**: Modern Flutter Material Design components
- **Custom Theming**: Comprehensive theme system with consistent styling

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # API requests
  provider: ^6.1.1          # State management
  cached_network_image: ^3.3.0  # Image caching
  intl: ^0.19.0             # Date formatting
```

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fpl_assistant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## API Endpoints Used

- **Bootstrap Static**: `https://fantasy.premierleague.com/api/bootstrap-static/`
  - Team data, gameweeks, and league information
  
- **Fixtures**: `https://fantasy.premierleague.com/api/fixtures/?event={gameweek}`
  - Match fixtures, results, and statistics

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   └── theme/
│       └── app_theme.dart
├── models/
│   ├── team.dart
│   ├── fixture.dart
│   └── gameweek.dart
├── providers/
│   └── fpl_provider.dart
├── screens/
│   ├── main_screen.dart
│   ├── league_table_screen.dart
│   └── fixtures_screen.dart
├── services/
│   └── fpl_api_service.dart
└── main.dart
```

## Features Roadmap

- [ ] **Transfers Screen**: Player transfer market and recommendations
- [ ] **More Screen**: Settings, about, and additional features
- [ ] **Player Details**: Individual player statistics and performance
- [ ] **Team Analysis**: Detailed team performance analytics
- [ ] **Push Notifications**: Live match updates and gameweek reminders
- [ ] **Offline Support**: Cached data for offline viewing

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Fantasy Premier League**: For providing the comprehensive API
- **Premier League**: For the official team badges and branding
- **Flutter Community**: For the excellent packages and resources
