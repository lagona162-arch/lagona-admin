import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class MerchantsScreen extends StatefulWidget {
  const MerchantsScreen({super.key});

  @override
  State<MerchantsScreen> createState() => _MerchantsScreenState();
}

class _MerchantsScreenState extends State<MerchantsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

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
        context.read<AdminProvider>().loadMerchants(forceRefresh: true);
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
                      'Merchant Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadMerchants(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Merchant Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadMerchants(forceRefresh: true),
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
                        hintText: 'Search by business name or email',
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
                      value: _statusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Status',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'verified', child: Text('Verified')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
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
                          hintText: 'Search by business name or email',
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
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'verified', child: Text('Verified')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
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
                if (provider.isLoading && provider.merchants.isEmpty) {
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
                          onPressed: () => provider.loadMerchants(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredMerchants = provider.merchants.where((merchant) {
                  final matchesSearch = merchant.businessName.toLowerCase().contains(_searchQuery) ||
                      (merchant.email?.toLowerCase().contains(_searchQuery) ?? false);
                  
                  // Updated to use accessStatus instead of verified/status
                  final matchesStatus = _statusFilter == 'all' ||
                      (_statusFilter == 'verified' && merchant.accessStatus == 'approved') ||
                      (_statusFilter == 'pending' && merchant.accessStatus == 'pending') ||
                      (_statusFilter == 'rejected' && merchant.accessStatus == 'rejected');
                  
                  return matchesSearch && matchesStatus;
                }).toList();

                return Card(
                  elevation: 2,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 1000,
                    columns: const [
                      DataColumn2(label: Text('Business Name'), size: ColumnSize.L),
                      DataColumn2(label: Text('Email'), size: ColumnSize.L),
                      DataColumn2(label: Text('DTI Number'), size: ColumnSize.M),
                      DataColumn2(label: Text('Address'), size: ColumnSize.L),
                      DataColumn2(label: Text('Created At'), size: ColumnSize.M),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S),
                      DataColumn2(label: Text('Actions'), size: ColumnSize.M),
                    ],
                    rows: filteredMerchants.map((merchant) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(merchant.businessName)),
                          DataCell(Text(merchant.email ?? 'N/A')),
                          DataCell(Text(merchant.dtiNumber ?? 'N/A')),
                          DataCell(Text(merchant.address ?? 'N/A')),
                          DataCell(Text(DateFormat('MMM d, y').format(merchant.createdAt))),
                          DataCell(_buildStatusChip(merchant.accessStatus)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.blue),
                                  onPressed: () => _showMerchantDetails(merchant),
                                  tooltip: 'View Details',
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildStatusChip(String accessStatus) {
    Color color;
    String label;
    
    switch (accessStatus) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'suspended':
        color = Colors.grey;
        label = 'Suspended';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Color.lerp(color, Colors.black, 0.3)!,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showMerchantDetails(merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(merchant.businessName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', merchant.email ?? 'N/A'),
              _buildDetailRow('Phone', merchant.phone ?? 'N/A'),
              _buildDetailRow('DTI Number', merchant.dtiNumber ?? 'N/A'),
              _buildDetailRow('Mayor Permit', merchant.mayorPermit ?? 'N/A'),
              _buildDetailRow('Address', merchant.address ?? 'N/A'),
              _buildDetailRow('Slogan', merchant.slogan ?? 'N/A'),
              _buildDetailRow('Access Status', merchant.accessStatus.toUpperCase()),
              _buildDetailRow('Status', merchant.status ?? 'N/A'),
              _buildDetailRow('Verified', merchant.verified ? 'Yes' : 'No'),
              _buildDetailRow('Active', (merchant.isActive ?? false) ? 'Yes' : 'No'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

