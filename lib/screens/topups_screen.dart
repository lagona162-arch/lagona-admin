import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class TopupsScreen extends StatefulWidget {
  const TopupsScreen({super.key});

  @override
  State<TopupsScreen> createState() => _TopupsScreenState();
}

class _TopupsScreenState extends State<TopupsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTopups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final titleSize = ResponsiveHelper.getResponsiveFontSize(context, 28);
    
    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top-Up Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadTopups(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top-Up Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadTopups(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Search
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Search by initiator',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 24),
          
          // Data Table
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.topups.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadTopups(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredTopups = provider.topups.where((topup) {
                  final matchesSearch = topup.initiatorName?.toLowerCase().contains(_searchQuery) ?? false;
                  return matchesSearch;
                }).toList();

                final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

                return Card(
                  elevation: 2,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 900,
                    columns: const [
                      DataColumn2(label: Text('Top-Up ID'), size: ColumnSize.M),
                      DataColumn2(label: Text('Initiated By'), size: ColumnSize.L),
                      DataColumn2(label: Text('Amount'), size: ColumnSize.S),
                      DataColumn2(label: Text('Bonus'), size: ColumnSize.S),
                      DataColumn2(label: Text('Total Credited'), size: ColumnSize.S),
                      DataColumn2(label: Text('Date'), size: ColumnSize.M),
                    ],
                    rows: filteredTopups.map((topup) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(topup.id.substring(0, 8))),
                          DataCell(Text(topup.initiatorName ?? 'N/A')),
                          DataCell(Text(currencyFormat.format(topup.amount))),
                          DataCell(Text(
                            currencyFormat.format(topup.bonusAmount),
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataCell(Text(
                            currencyFormat.format(topup.totalCredited),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataCell(Text(DateFormat('MMM d, y h:mm a').format(topup.createdAt))),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

