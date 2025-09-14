import 'package:flutter/material.dart';
import '../presentation/market_prices/market_prices.dart';
import '../presentation/voice_assistant/voice_assistant.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/weather_dashboard/weather_dashboard.dart';
import '../presentation/dashboard_home/dashboard_home.dart';
import '../presentation/community_forum/community_forum_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String marketPrices = '/market-prices';
  static const String voiceAssistant = '/voice-assistant';
  static const String login = '/login-screen';
  static const String profileSettings = '/profile-settings';
  static const String weatherDashboard = '/weather-dashboard';
  static const String dashboardHome = '/dashboard-home';
  static const String communityForum = '/community-forum'; // new route added

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    marketPrices: (context) => const MarketPrices(),
    voiceAssistant: (context) => const VoiceAssistant(),
    login: (context) => const LoginScreen(),
    profileSettings: (context) => const ProfileSettings(),
    weatherDashboard: (context) => const WeatherDashboard(),
    dashboardHome: (context) => const DashboardHome(),
    communityForum: (context) => const CommunityForumScreen(), // added here
    // TODO: Add your other routes here
  };
}
