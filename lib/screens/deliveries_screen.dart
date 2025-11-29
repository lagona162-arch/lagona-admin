import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _loadData();
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdminProvider>().loadDeliveries(forceRefresh: true);
      }
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
                      'Delivery Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadDeliveries(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Monitoring',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadDeliveries(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Filters
          isMobile
              ? Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by customer or merchant',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _typeFilter,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Types')),
                        DropdownMenuItem(value: 'pabili', child: Text('Pabili')),
                        DropdownMenuItem(value: 'padala', child: Text('Padala')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _typeFilter = value ?? 'all';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value ?? 'all';
                        });
                      },
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search by customer or merchant',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _typeFilter,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Types')),
                          DropdownMenuItem(value: 'pabili', child: Text('Pabili')),
                          DropdownMenuItem(value: 'padala', child: Text('Padala')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _typeFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Data Table
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.deliveries.isEmpty) {
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
                          onPressed: () => provider.loadDeliveries(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredDeliveries = provider.deliveries.where((delivery) {
                  final matchesSearch = (delivery.customerName?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (delivery.merchantName?.toLowerCase().contains(_searchQuery) ?? false);
                  final matchesType = _typeFilter == 'all' || delivery.type == _typeFilter;
                  final matchesStatus = _statusFilter == 'all' || delivery.status == _statusFilter;
                  return matchesSearch && matchesType && matchesStatus;
                }).toList();

                final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

                return Card(
                  elevation: 2,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 1100,
                    columns: const [
                      DataColumn2(label: Text('ID'), size: ColumnSize.S),
                      DataColumn2(label: Text('Type'), size: ColumnSize.S),
                      DataColumn2(label: Text('Customer'), size: ColumnSize.M),
                      DataColumn2(label: Text('Merchant'), size: ColumnSize.M),
                      DataColumn2(label: Text('Rider'), size: ColumnSize.M),
                      DataColumn2(label: Text('Fee'), size: ColumnSize.S),
                      DataColumn2(label: Text('Distance'), size: ColumnSize.S),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S),
                      DataColumn2(label: Text('Date'), size: ColumnSize.M),
                    ],
                    rows: filteredDeliveries.map((delivery) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(delivery.id.substring(0, 8))),
                          DataCell(_buildTypeBadge(delivery.type)),
                          DataCell(Text(delivery.customerName ?? 'N/A')),
                          DataCell(Text(delivery.merchantName ?? 'N/A')),
                          DataCell(Text(delivery.riderName ?? 'N/A')),
                          DataCell(Text(currencyFormat.format(delivery.deliveryFee ?? 0))),
                          DataCell(Text('${delivery.distanceKm?.toStringAsFixed(2) ?? '0'} km')),
                          DataCell(_buildStatusChip(delivery.status)),
                          DataCell(Text(DateFormat('MMM d, y').format(delivery.createdAt))),
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

  Widget _buildTypeBadge(String type) {
    Color color = type == 'pabili' ? Colors.blue : Colors.purple;
    return Chip(
      label: Text(
        type.toUpperCase(),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Color.lerp(color, Colors.black, 0.3)!,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'completed':
        color = Colors.green;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'accepted':
        color = Colors.teal;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Color.lerp(color, Colors.black, 0.3)!,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

