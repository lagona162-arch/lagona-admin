import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/supabase_service.dart';
import 'providers/admin_provider.dart';
import 'utils/app_colors.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/merchants_screen.dart';
import 'screens/applications_screen.dart';
import 'screens/riders_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/deliveries_screen.dart';
import 'screens/commission_settings_screen.dart';
import 'screens/topups_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handling to prevent web app from crashing on uncaught exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught zone error: $error');
    return true; // prevent default crashing behavior
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };
  
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const LagonaAdminApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(
          currentPath: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: '/merchants',
          name: 'merchants',
          builder: (context, state) => const MerchantsScreen(),
        ),
        GoRoute(
          path: '/merchant-applications',
          name: 'merchant-applications',
          builder: (context, state) => const ApplicationsScreen(),
        ),
        GoRoute(
          path: '/riders',
          name: 'riders',
          builder: (context, state) => const RidersScreen(),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/deliveries',
          name: 'deliveries',
          builder: (context, state) => const DeliveriesScreen(),
        ),
        GoRoute(
          path: '/commission-settings',
          name: 'commission-settings',
          builder: (context, state) => const CommissionSettingsScreen(),
        ),
        GoRoute(
          path: '/topups',
          name: 'topups',
          builder: (context, state) => const TopupsScreen(),
        ),
      ],
    ),
  ],
);

class LagonaAdminApp extends StatelessWidget {
  const LagonaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lagona Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.textWhite,
          onSecondary: AppColors.textWhite,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
          onError: AppColors.textWhite,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 2,
          color: AppColors.cardBackground,
          shadowColor: AppColors.cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.textWhite,
            disabledBackgroundColor: AppColors.buttonDisabled,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.inputBorderFocused, width: 2),
          ),
          fillColor: AppColors.inputBackground,
          filled: true,
        ),
      ),
      routerConfig: _router,
    );
  }
}

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentPath;

  const MainLayout({super.key, required this.child, required this.currentPath});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isDrawerExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: isMobile
          ? AppBar(
              backgroundColor: AppColors.primary,
              title: const Text('LAGONA ADMIN'),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            )
          : null,
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: isMobile
          ? Container(
              color: AppColors.background,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(widget.currentPath),
                  child: widget.child,
                ),
              ),
            )
          : Row(
              children: [
                // Desktop Sidebar Navigation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isDrawerExpanded ? 250 : 70,
                  child: Container(
                    color: AppColors.secondary,
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_isDrawerExpanded)
                                const Expanded(
                                  child: Text(
                                    'LAGONA ADMIN',
                                    style: TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: IconButton(
                                    icon: Icon(
                                      _isDrawerExpanded ? Icons.menu_open : Icons.menu,
                                      color: AppColors.textWhite,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isDrawerExpanded = !_isDrawerExpanded;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    splashRadius: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: AppColors.textWhite.withOpacity(0.24)),
                  
                        // Navigation Items
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildNavItem(
                                icon: Icons.dashboard,
                                label: 'Dashboard',
                                path: '/',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.people,
                                label: 'Users',
                                path: '/users',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.store,
                                label: 'Merchants',
                                path: '/merchants',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.approval,
                                label: 'Applications',
                                path: '/merchant-applications',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.motorcycle,
                                label: 'Riders',
                                path: '/riders',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.receipt_long,
                                label: 'Transactions',
                                path: '/transactions',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.local_shipping,
                                label: 'Deliveries',
                                path: '/deliveries',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.account_balance_wallet,
                                label: 'Top-Ups',
                                path: '/topups',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                              _buildNavItem(
                                icon: Icons.settings,
                                label: 'Commission',
                                path: '/commission-settings',
                                context: context,
                                isExpanded: _isDrawerExpanded,
                              ),
                            ],
                          ),
                        ),
                        
                        // Footer
                        Divider(color: AppColors.textWhite.withOpacity(0.24)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _isDrawerExpanded
                              ? Text(
                                  'v1.0.0',
                                  style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 12),
                                )
                              : Icon(Icons.info_outline, color: AppColors.textWhite.withOpacity(0.7), size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(widget.currentPath),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.secondary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LAGONA ADMIN',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildNavItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              path: '/',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.people,
              label: 'Users',
              path: '/users',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.store,
              label: 'Merchants',
              path: '/merchants',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.approval,
              label: 'Applications',
              path: '/merchant-applications',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.motorcycle,
              label: 'Riders',
              path: '/riders',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.receipt_long,
              label: 'Transactions',
              path: '/transactions',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.local_shipping,
              label: 'Deliveries',
              path: '/deliveries',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.account_balance_wallet,
              label: 'Top-Ups',
              path: '/topups',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Commission',
              path: '/commission-settings',
              context: context,
              isExpanded: true,
              isMobile: true,
            ),
            Divider(color: AppColors.textWhite.withOpacity(0.24)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String path,
    required BuildContext context,
    required bool isExpanded,
    bool isMobile = false,
  }) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive = currentPath == path;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          context.go(path);
          if (isMobile) {
            Navigator.of(context).pop(); // Close drawer on mobile
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
            border: isActive
                ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? AppColors.primary : AppColors.textWhite),
              if (isExpanded) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
