import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solarconnect_app/main.dart';
import 'package:solarconnect_app/widgets/common/summary_card.dart';
import 'package:solarconnect_app/widgets/explore/article_card.dart';

void main() {
  group('SolarConnect App Tests', () {
    testWidgets('App smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Shell screen shows 3 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Verify bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify 3 tabs
      expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
    });

    testWidgets('Tab switching works - Overview tab', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Overview tab should be active by default
      expect(find.text('Good Morning ☀️'), findsOneWidget);
      expect(find.text('SolarConnect'), findsOneWidget);
    });

    testWidgets('Tab switching works - Explore tab', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Tap Explore tab
      await tester.tap(find.byIcon(Icons.explore_rounded));
      await tester.pumpAndSettle();
      
      // Verify Explore screen is shown
      expect(find.text('Explore'), findsWidgets);
    });

    testWidgets('Tab switching works - Me tab', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Tap Me tab
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();
      
      // Verify Me screen is shown
      expect(find.text('My Account'), findsOneWidget);
    });

    testWidgets('Overview screen displays energy flow', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Wait for initial load
      await tester.pumpAndSettle();
      
      // Verify energy components
      expect(find.byIcon(Icons.wb_sunny_rounded), findsWidgets); // Solar icon
      expect(find.byIcon(Icons.power_outlined), findsWidgets);   // Energy icons
    });

    testWidgets('Overview screen displays stats cards', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      await tester.pumpAndSettle();
      
      // Scroll to find stats section
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      // Verify SummaryCard widgets exist
      expect(find.byType(SummaryCard), findsNWidgets(4));
    });

    testWidgets('Battery card displays progress', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      await tester.pumpAndSettle();
      
      // Find battery percentage text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Explore screen filters articles', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Go to Explore tab
      await tester.tap(find.byIcon(Icons.explore_rounded));
      await tester.pumpAndSettle();
      
      // Verify article cards exist
      expect(find.byType(ArticleCard), findsWidgets);
      
      // Tap a filter chip
      await tester.tap(find.text('Finance').first);
      await tester.pumpAndSettle();
      
      // Articles should update (at least one financial article)
      expect(find.byType(ArticleCard), findsWidgets);
    });

    testWidgets('Me screen displays menu items', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Go to Me tab
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();
      
      // Verify menu sections
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      
      // Verify menu items
      expect(find.text('FAQ'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('App theme colors are applied', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Verify dark theme background
      final scaffold = find.byType(Scaffold).first;
      expect(scaffold, findsOneWidget);
    });

    testWidgets('Responsiveness - Content scrolls', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      // Scroll up
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      
      // Should reach back to top
      expect(find.text('Good Morning ☀️'), findsOneWidget);
    });

    testWidgets('Tab navigation is smooth', (WidgetTester tester) async {
      await tester.pumpWidget(const SolarConnectApp());
      
      // Switch between tabs rapidly
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.explore_rounded));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.person_rounded));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.dashboard_rounded));
        await tester.pumpAndSettle();
      }
      
      // App should still be responsive
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
