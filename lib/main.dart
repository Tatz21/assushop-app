import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'screens/collection/collection_entry_screen.dart';
import 'screens/ledger/party_ledger_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/market/market_hierarchy_screen.dart';
import 'screens/more/more_screen.dart';
import 'screens/outlets/outlet_list_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/sales/add_sale_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const AnsuSalesApp());
}

class AnsuSalesApp extends StatelessWidget {
  final bool enableSplash;

  const AnsuSalesApp({
    super.key,
    this.enableSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            title: 'ANSU VISTAR - Sales Team App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: enableSplash
                ? const ResponsiveWrapper(child: SplashScreen())
                : (appState.isLoggedIn
                    ? const MainNavigationShell()
                    : const ResponsiveWrapper(child: LoginScreen())),
            routes: {
              '/login': (_) => const ResponsiveWrapper(child: LoginScreen()),
              '/home': (_) => const MainNavigationShell(),
              '/sales': (_) => const ResponsiveWrapper(
                    child: AddSaleScreen(showBackButton: true),
                  ),
              '/outlets': (_) => const ResponsiveWrapper(
                    child: OutletListScreen(showBackButton: true),
                  ),
              '/collection': (_) => const ResponsiveWrapper(
                    child: CollectionEntryScreen(showBackButton: true),
                  ),
              '/market': (_) => const ResponsiveWrapper(
                    child: MarketHierarchyScreen(showBackButton: true),
                  ),
              '/ledger': (_) => const ResponsiveWrapper(
                    child: PartyLedgerScreen(showBackButton: true),
                  ),
              '/reports': (_) => const ResponsiveWrapper(
                    child: ReportsScreen(showBackButton: true),
                  ),
              '/more': (_) => const ResponsiveWrapper(
                    child: MoreScreen(showBackButton: true),
                  ),
            },
          );
        },
      ),
    );
  }
}

