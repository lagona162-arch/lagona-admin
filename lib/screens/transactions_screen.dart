import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTransactions();
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
                      'Transaction Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _exportTransactions(),
                            icon: const Icon(Icons.download),
                            label: const Text('Export'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.read<AdminProvider>().loadTransactions(forceRefresh: true),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _exportTransactions(),
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.read<AdminProvider>().loadTransactions(forceRefresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Search
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'Search by payer or payee',
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
                if (provider.isLoading && provider.transactions.isEmpty) {
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
                          onPressed: () => provider.loadTransactions(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredTransactions = provider.transactions.where((txn) {
                  final matchesSearch = (txn.payerName?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (txn.payeeName?.toLowerCase().contains(_searchQuery) ?? false);
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
                      DataColumn2(label: Text('Transaction ID'), size: ColumnSize.M),
                      DataColumn2(label: Text('Payer'), size: ColumnSize.L),
                      DataColumn2(label: Text('Payee'), size: ColumnSize.L),
                      DataColumn2(label: Text('Amount'), size: ColumnSize.S),
                      DataColumn2(label: Text('Description'), size: ColumnSize.L),
                      DataColumn2(label: Text('Date'), size: ColumnSize.M),
                    ],
                    rows: filteredTransactions.map((txn) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(txn.id.substring(0, 8))),
                          DataCell(Text(txn.payerName ?? 'N/A')),
                          DataCell(Text(txn.payeeName ?? 'N/A')),
                          DataCell(Text(
                            currencyFormat.format(txn.amount),
                            style: TextStyle(
                              color: txn.amount >= 0 ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                          DataCell(Text(txn.description ?? 'N/A')),
                          DataCell(Text(DateFormat('MMM d, y h:mm a').format(txn.createdAt))),
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

  void _exportTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }
}

