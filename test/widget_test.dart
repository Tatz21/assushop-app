import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ansu_sales_app/main.dart';
import 'package:ansu_sales_app/core/widgets/ansu_vistar_logo.dart';
import 'package:ansu_sales_app/screens/collection/collection_entry_screen.dart';
import 'package:ansu_sales_app/screens/ledger/party_ledger_screen.dart';
import 'package:ansu_sales_app/screens/login/login_screen.dart';
import 'package:ansu_sales_app/screens/main_navigation_shell.dart';
import 'package:ansu_sales_app/screens/market/district_wise_screen.dart';
import 'package:ansu_sales_app/screens/market/market_hierarchy_screen.dart';
import 'package:ansu_sales_app/screens/outlets/outlet_detail_screen.dart';
import 'package:ansu_sales_app/screens/outlets/outlet_list_screen.dart';
import 'package:ansu_sales_app/screens/reports/reports_screen.dart';
import 'package:ansu_sales_app/screens/splash/splash_screen.dart';
import 'package:ansu_sales_app/state/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  Widget createTestWidget(Widget child, [AppState? state]) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => state ?? AppState(),
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('Splash Screen renders complete ANSU VISTAR design reference',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const SplashScreen(autoNavigate: false)));
    await tester.pump();

    // Verify Brand Logo Elements
    expect(find.byType(AnsuVistarLogo), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('U'), findsOneWidget);
    expect(find.text('VISTAR'), findsOneWidget);
    expect(find.text('Connecting Every Market.'), findsOneWidget);

    // Verify Bottom Leaf Footer
    expect(find.text('Healthy People'), findsOneWidget);
    expect(find.text('Healthier India'), findsOneWidget);
  });

  testWidgets('App renders Dashboard with correct branding and KPIs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const AnsuSalesApp(enableSplash: false));
    await tester.pump();

    // Verify Dashboard is rendered with Rohit Sharma
    expect(find.byType(MainNavigationShell), findsOneWidget);
    expect(find.text('Rohit Sharma'), findsOneWidget);
    expect(find.textContaining('Sales Executive'), findsOneWidget);
    expect(find.text('Today\'s Collection'), findsOneWidget);
    expect(find.text('Outlets Visited'), findsOneWidget);
    expect(find.text('Pending Outlets'), findsOneWidget);
    expect(find.text('Monthly Target'), findsOneWidget);

    // Verify Quick Actions exist
    expect(find.text('Outlet List'), findsOneWidget);
    expect(find.text('Territory Map'), findsOneWidget);
    expect(find.text('Party Ledger'), findsOneWidget);
    expect(find.text('Offline Outbox'), findsOneWidget);

    // Verify bottom navigation tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Outlets'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('Login screen renders with full branding and inputs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const LoginScreen()));
    await tester.pump();

    expect(find.text('Sales Team App'), findsOneWidget);
    expect(find.text('Field. Focus. Growth.'), findsOneWidget);
    expect(find.text('Remember Me'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Healthy Smiles Healthier India'), findsOneWidget);
    expect(find.text('ANSU Bajra Danta Pvt. Ltd.'), findsOneWidget);
  });

  testWidgets('Outlet List screen renders and filters properly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const OutletListScreen(showBackButton: true)));
    await tester.pump();

    expect(find.text('Outlet List'), findsOneWidget);
    expect(find.text('Total Outlets: 10'), findsOneWidget);
    expect(find.text('Sharma Medical Store'), findsOneWidget);
    expect(find.text('Gupta General Store'), findsOneWidget);
    expect(find.text('Kalyan Chemist & Druggist'), findsOneWidget);
    expect(find.text('Visited'), findsWidgets);
  });

  testWidgets('Outlet Detail screen shows full financials and actions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const OutletDetailScreen(outletId: '1')));
    await tester.pump();

    expect(find.text('Outlet Details'), findsOneWidget);
    expect(find.text('Sharma Medical Store'), findsOneWidget);
    expect(find.text('Code: OUT001'), findsOneWidget);
    expect(find.text('Total Sale'), findsOneWidget);
    expect(find.text('Total Collection'), findsOneWidget);
    expect(find.text('Balance Due'), findsOneWidget);
    expect(find.text('Start Visit'), findsNothing); // Visited already
    expect(find.text('Visited'), findsOneWidget);
  });

  testWidgets('Collection Entry screen renders form, segmented mode, and last collection',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const CollectionEntryScreen(showBackButton: true)));
    await tester.pump();

    expect(find.text('Collection Entry'), findsOneWidget);
    expect(find.text('Sharma Medical Store'), findsOneWidget);
    expect(find.text('Against Invoice / Reference No.'), findsOneWidget);
    expect(find.text('Collection Amount (₹)'), findsOneWidget);
    expect(find.text('Payment Mode'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Cheque'), findsOneWidget);
    expect(find.text('Save & Generate Receipt'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
  });

  testWidgets('Market Hierarchy screen displays state, district, and market counts',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const MarketHierarchyScreen(showBackButton: true)));
    await tester.pump();

    expect(find.text('Market / District / State Wise'), findsOneWidget);
    expect(find.text('Uttar Pradesh'), findsOneWidget);
    expect(find.text('1,250 Outlets'), findsOneWidget);
    expect(find.text('Madhya Pradesh'), findsOneWidget);
    expect(find.text('820 Outlets'), findsOneWidget);
    expect(find.text('Bihar'), findsOneWidget);
  });

  testWidgets('District Wise screen displays district list for Uttar Pradesh',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const DistrictWiseScreen(stateName: 'Uttar Pradesh')));
    await tester.pump();

    expect(find.text('Uttar Pradesh'), findsOneWidget);
    expect(find.text('Kanpur'), findsOneWidget);
    expect(find.text('86 Outlets'), findsOneWidget);
    expect(find.text('Lucknow'), findsOneWidget);
    expect(find.text('145 Outlets'), findsOneWidget);
  });

  testWidgets('Party Ledger screen displays summary cards and transactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const PartyLedgerScreen(outletId: '1', showBackButton: true)));
    await tester.pump();

    expect(find.text('Party Ledger'), findsOneWidget);
    expect(find.text('Total Sale'), findsOneWidget);
    expect(find.text('Total Collection'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Statements'), findsOneWidget);
    expect(find.text('05 Sep 2026'), findsWidgets);
    expect(find.text('INV-20260820-002'), findsOneWidget);
  });

  testWidgets('Reports screen displays leaderboard rankings and user rank card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(const ReportsScreen(showBackButton: true)));
    await tester.pump();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('My Performance'), findsOneWidget);
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Overall'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('Amit Kumar'), findsOneWidget);
    expect(find.text('Rohit Sharma'), findsOneWidget);
    expect(find.text('Sandeep Yadav'), findsOneWidget);
    expect(find.text('Your Rank'), findsOneWidget);
    expect(find.text('Your Collection'), findsOneWidget);
  });
}
