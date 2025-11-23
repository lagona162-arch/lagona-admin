import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
      context.read<AdminProvider>().loadCashFlowData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.dashboardStats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = provider.dashboardStats;
        final cashFlow = provider.cashFlowData;
        final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

        final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
        final titleSize = ResponsiveHelper.getResponsiveFontSize(context, 28);
        final isMobile = Responsive.isMobile(context);
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Statistics Cards
              GridView.count(
                crossAxisCount: ResponsiveHelper.getGridColumns(context, 4),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: isMobile ? 12 : 16,
                mainAxisSpacing: isMobile ? 12 : 16,
                childAspectRatio: isMobile ? 1.7 : (Responsive.isTablet(context) ? 1.75 : 1.6),
                children: [
                  _buildStatCard(
                    'Total Users',
                    stats['total_users']?.toString() ?? '0',
                    Icons.people,
                    AppColors.primary,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Total Merchants',
                    stats['total_merchants']?.toString() ?? '0',
                    Icons.store,
                    AppColors.success,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Total Riders',
                    stats['total_riders']?.toString() ?? '0',
                    Icons.motorcycle,
                    AppColors.statusPending,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Total Deliveries',
                    stats['total_deliveries']?.toString() ?? '0',
                    Icons.local_shipping,
                    AppColors.secondary,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Pending Merchants',
                    stats['pending_merchants']?.toString() ?? '0',
                    Icons.pending_actions,
                    AppColors.statusPending,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Active Deliveries',
                    stats['active_deliveries']?.toString() ?? '0',
                    Icons.delivery_dining,
                    AppColors.statusReady,
                    isMobile,
                  ),
                  _buildStatCard(
                    'Total Revenue',
                    currencyFormat.format(stats['total_revenue'] ?? 0),
                    Icons.attach_money,
                    AppColors.primary,
                    isMobile,
                  ),
                  _buildStatCard(
                    'System Balance',
                    currencyFormat.format(cashFlow['total_balance'] ?? 0),
                    Icons.account_balance_wallet,
                    AppColors.secondary,
                    isMobile,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Cash Flow Section
              Text(
                'Cash Flow Breakdown',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22), 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              isMobile
                  ? Column(
                      children: [
                        _buildCashFlowCard(
                          'Business Hubs',
                          currencyFormat.format(cashFlow['hub_balance'] ?? 0),
                          AppColors.primaryLight.withOpacity(0.3),
                          AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _buildCashFlowCard(
                          'Loading Stations',
                          currencyFormat.format(cashFlow['station_balance'] ?? 0),
                          AppColors.success.withOpacity(0.2),
                          AppColors.success,
                        ),
                        const SizedBox(height: 12),
                        _buildCashFlowCard(
                          'Riders',
                          currencyFormat.format(cashFlow['rider_balance'] ?? 0),
                          AppColors.statusPending.withOpacity(0.2),
                          AppColors.statusPending,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildCashFlowCard(
                            'Business Hubs',
                            currencyFormat.format(cashFlow['hub_balance'] ?? 0),
                            AppColors.primaryLight.withOpacity(0.3),
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCashFlowCard(
                            'Loading Stations',
                            currencyFormat.format(cashFlow['station_balance'] ?? 0),
                            AppColors.success.withOpacity(0.2),
                            AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCashFlowCard(
                            'Riders',
                            currencyFormat.format(cashFlow['rider_balance'] ?? 0),
                            AppColors.statusPending.withOpacity(0.2),
                            AppColors.statusPending,
                          ),
                        ),
                      ],
                    ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 22), 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: isMobile ? 8 : 16,
                runSpacing: isMobile ? 8 : 16,
                children: [
                  _buildQuickActionButton(
                    'Review Applications',
                    Icons.approval,
                    AppColors.statusPending,
                    () => context.go('/merchant-applications'),
                  ),
                  _buildQuickActionButton(
                    'View Transactions',
                    Icons.receipt_long,
                    AppColors.primary,
                    () => context.go('/transactions'),
                  ),
                  _buildQuickActionButton(
                    'Manage Users',
                    Icons.people_alt,
                    AppColors.success,
                    () => context.go('/users'),
                  ),
                  _buildQuickActionButton(
                    'Commission Settings',
                    Icons.settings,
                    AppColors.secondary,
                    () => context.go('/commission-settings'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isMobile) {
    final iconSize = isMobile ? 28.0 : 32.0;
    final valueFontSize = isMobile ? 28.0 : 32.0;
    final titleFontSize = isMobile ? 12.0 : 13.0;
    final verticalPadding = isMobile ? 16.0 : 20.0;
    final iconSpacing = isMobile ? 8.0 : 12.0;
    final titleSpacing = isMobile ? 6.0 : 8.0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(height: iconSpacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            SizedBox(height: titleSpacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowCard(String title, String amount, Color bgColor, Color textColor) {
    return Card(
      elevation: 2,
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}

