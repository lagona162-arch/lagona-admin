import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../models/merchant_model.dart';
import '../models/rider_model.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _applicationType = 'merchant'; // 'merchant' or 'rider'

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
        context.read<AdminProvider>().loadRiders(forceRefresh: true);
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
                      'Applications',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and approve merchant and rider registration requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().loadMerchants(forceRefresh: true);
                        context.read<AdminProvider>().loadRiders(forceRefresh: true);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applications',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Review and approve merchant and rider registration requests',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().loadMerchants(forceRefresh: true);
                        context.read<AdminProvider>().loadRiders(forceRefresh: true);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Application Type Selector
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeButton('merchant', 'Merchants', Icons.store),
                _buildTypeButton('rider', 'Riders', Icons.motorcycle),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Statistics Cards
          Consumer<AdminProvider>(
            builder: (context, provider, child) {
              if (_applicationType == 'merchant') {
                final merchants = provider.merchants;
                final pending = merchants.where((m) => m.accessStatus == 'pending').length;
                final approved = merchants.where((m) => m.accessStatus == 'approved').length;
                final rejected = merchants.where((m) => m.accessStatus == 'rejected').length;
                final suspended = merchants.where((m) => m.accessStatus == 'suspended').length;
                
                return isMobile
                    ? Column(
                        children: [
                          _buildStatCard(
                            'Pending Review',
                            pending.toString(),
                            Icons.pending_actions,
                            AppColors.statusPending,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Approved',
                            approved.toString(),
                            Icons.check_circle,
                            AppColors.success,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Rejected',
                            rejected.toString(),
                            Icons.cancel,
                            AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Suspended',
                            suspended.toString(),
                            Icons.block,
                            AppColors.textSecondary,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Pending Review',
                              pending.toString(),
                              Icons.pending_actions,
                              AppColors.statusPending,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Approved',
                              approved.toString(),
                              Icons.check_circle,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Rejected',
                              rejected.toString(),
                              Icons.cancel,
                              AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Suspended',
                              suspended.toString(),
                              Icons.block,
                              AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
              } else {
                // Rider statistics based on access_status if available, fallback to is_active
                final riders = provider.riders;
                int pending = 0, approved = 0, rejected = 0;
                for (final r in riders) {
                  final status = (r.accessStatus ?? ((r.isActive ?? false) ? 'approved' : 'pending')).toLowerCase();
                  if (status == 'approved') approved++;
                  else if (status == 'rejected') rejected++;
                  else pending++;
                }
                return isMobile
                    ? Column(
                        children: [
                          _buildStatCard(
                            'Pending Review',
                            pending.toString(),
                            Icons.pending_actions,
                            AppColors.statusPending,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Approved',
                            approved.toString(),
                            Icons.check_circle,
                            AppColors.success,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            'Rejected',
                            rejected.toString(),
                            Icons.cancel,
                            AppColors.error,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Pending Review',
                              pending.toString(),
                              Icons.pending_actions,
                              AppColors.statusPending,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Approved',
                              approved.toString(),
                              Icons.check_circle,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Rejected',
                              rejected.toString(),
                              Icons.cancel,
                              AppColors.error,
                            ),
                          ),
                        ],
                      );
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Filters
          isMobile
              ? Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: _applicationType == 'merchant'
                            ? 'Search by business name or email'
                            : 'Search by name or email',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_applicationType == 'merchant')
                      DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Access Status',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'all';
                          });
                        },
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
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
                        decoration: InputDecoration(
                          labelText: 'Search',
                          hintText: _applicationType == 'merchant'
                              ? 'Search by business name or email'
                              : 'Search by name or email',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
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
                      width: 220,
                      child: _applicationType == 'merchant'
                          ? DropdownButtonFormField<String>(
                              value: _statusFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Access Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('All Status')),
                                DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                                DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _statusFilter = value ?? 'all';
                                });
                              },
                            )
                          : DropdownButtonFormField<String>(
                              value: _statusFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter by Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'all', child: Text('All Status')),
                                DropdownMenuItem(value: 'pending', child: Text('Pending Review')),
                                DropdownMenuItem(value: 'approved', child: Text('Approved')),
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
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadMerchants();
                            provider.loadRiders();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_applicationType == 'merchant') {
                  return _buildMerchantTable(provider);
                } else {
                  return _buildRiderTable(provider);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _applicationType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _applicationType = type;
            _statusFilter = 'all';
            _searchQuery = '';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMerchantTable(AdminProvider provider) {
    final isMobile = Responsive.isMobile(context);
    
    var filteredMerchants = provider.merchants.where((merchant) {
      final matchesSearch = merchant.businessName.toLowerCase().contains(_searchQuery) ||
          (merchant.email?.toLowerCase().contains(_searchQuery) ?? false);
      
      final matchesStatus = _statusFilter == 'all' || merchant.accessStatus == _statusFilter;
      
      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredMerchants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No merchant applications found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 1200,
        columns: const [
          DataColumn2(label: Text('Business Name'), size: ColumnSize.L),
          DataColumn2(label: Text('Owner'), size: ColumnSize.M),
          DataColumn2(label: Text('Email'), size: ColumnSize.L),
          DataColumn2(label: Text('Phone'), size: ColumnSize.M),
          DataColumn2(label: Text('DTI Number'), size: ColumnSize.M),
          DataColumn2(label: Text('Applied On'), size: ColumnSize.M),
          DataColumn2(label: Text('Access Status'), size: ColumnSize.M),
          DataColumn2(label: Text('Actions'), size: ColumnSize.L),
        ],
        rows: filteredMerchants.map((merchant) {
          return DataRow2(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (merchant.accessStatus == 'pending') {
                  return Colors.orange.shade50;
                }
                return null;
              },
            ),
            cells: [
              DataCell(
                Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        merchant.businessName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(merchant.fullName ?? 'N/A')),
              DataCell(Text(merchant.email ?? 'N/A')),
              DataCell(Text(merchant.phone ?? 'N/A')),
              DataCell(Text(merchant.dtiNumber ?? 'N/A')),
              DataCell(Text(DateFormat('MMM d, y').format(merchant.createdAt))),
              DataCell(_buildAccessStatusChip(merchant.accessStatus)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (merchant.accessStatus == 'pending') ...[
                      Tooltip(
                        message: 'Approve Application',
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          onPressed: () => _approveMerchant(merchant),
                        ),
                      ),
                      Tooltip(
                        message: 'Reject Application',
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: AppColors.error),
                          onPressed: () => _rejectMerchant(merchant),
                        ),
                      ),
                    ],
                    if (merchant.accessStatus == 'approved') ...[
                      Tooltip(
                        message: 'Suspend Access',
                        child: IconButton(
                          icon: const Icon(Icons.block, color: AppColors.statusPending),
                          onPressed: () => _suspendMerchant(merchant),
                        ),
                      ),
                    ],
                    if (merchant.accessStatus == 'suspended') ...[
                      Tooltip(
                        message: 'Restore Access',
                        child: IconButton(
                          icon: const Icon(Icons.restore, color: AppColors.primary),
                          onPressed: () => _approveMerchant(merchant),
                        ),
                      ),
                    ],
                    if (merchant.accessStatus == 'rejected') ...[
                      Tooltip(
                        message: 'Approve Application',
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          onPressed: () => _approveMerchant(merchant),
                        ),
                      ),
                    ],
                    Tooltip(
                      message: 'View Full Details',
                      child: IconButton(
                        icon: const Icon(Icons.visibility, color: AppColors.primary),
                        onPressed: () => _showMerchantDetails(merchant),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRiderTable(AdminProvider provider) {
    final isMobile = Responsive.isMobile(context);
    
    var filteredRiders = provider.riders.where((rider) {
      final matchesSearch = (rider.fullName?.toLowerCase().contains(_searchQuery) ?? false) ||
          (rider.email?.toLowerCase().contains(_searchQuery) ?? false);
      
      final access = (rider.accessStatus ?? ((rider.isActive ?? false) ? 'approved' : 'pending')).toLowerCase();
      final matchesStatus = _statusFilter == 'all' ||
          (_statusFilter == 'pending' && access == 'pending') ||
          (_statusFilter == 'approved' && access == 'approved') ||
          (_statusFilter == 'rejected' && access == 'rejected');
      
      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredRiders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No rider applications found',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 1200,
        columns: const [
          DataColumn2(label: Text('Rider Name'), size: ColumnSize.L),
          DataColumn2(label: Text('Email'), size: ColumnSize.L),
          DataColumn2(label: Text('Phone'), size: ColumnSize.M),
          DataColumn2(label: Text('Plate Number'), size: ColumnSize.M),
          DataColumn2(label: Text('Vehicle Type'), size: ColumnSize.M),
          DataColumn2(label: Text('Applied On'), size: ColumnSize.M),
          DataColumn2(label: Text('Status'), size: ColumnSize.M),
          DataColumn2(label: Text('Actions'), size: ColumnSize.L),
        ],
        rows: filteredRiders.map((rider) {
          final access = (rider.accessStatus ?? ((rider.isActive ?? false) ? 'approved' : 'pending')).toLowerCase();
          return DataRow2(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (access == 'pending') {
                  return Colors.orange.shade50;
                }
                return null;
              },
            ),
            cells: [
              DataCell(
                Row(
                  children: [
                    Icon(
                      Icons.motorcycle,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rider.fullName ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(rider.email ?? 'N/A')),
              DataCell(Text(rider.phone ?? 'N/A')),
              DataCell(Text(rider.plateNumber ?? 'N/A')),
              DataCell(Text(rider.vehicleType ?? 'N/A')),
              DataCell(Text(DateFormat('MMM d, y').format(rider.createdAt))),
              DataCell(_buildRiderAccessStatusChip(access)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (access == 'pending') ...[
                      Tooltip(
                        message: 'Approve Application',
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          onPressed: () => _approveRider(rider),
                        ),
                      ),
                      Tooltip(
                        message: 'Reject Application',
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: AppColors.error),
                          onPressed: () => _rejectRider(rider),
                        ),
                      ),
                    ] else if (access == 'approved') ...[
                      Tooltip(
                        message: 'Suspend Access',
                        child: IconButton(
                          icon: const Icon(Icons.block, color: AppColors.statusPending),
                          onPressed: () => _rejectRider(rider),
                        ),
                      ),
                    ] else ...[
                      Tooltip(
                        message: 'Approve Application',
                        child: IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                          onPressed: () => _approveRider(rider),
                        ),
                      ),
                    ],
                    Tooltip(
                      message: 'View Full Details',
                      child: IconButton(
                        icon: const Icon(Icons.visibility, color: AppColors.primary),
                        onPressed: () => _showRiderDetails(rider),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessStatusChip(String accessStatus) {
    Color color;
    IconData icon;
    String label;
    
    switch (accessStatus) {
      case 'approved':
        color = AppColors.success;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case 'suspended':
        color = AppColors.textSecondary;
        icon = Icons.block;
        label = 'Suspended';
        break;
      case 'pending':
      default:
        color = AppColors.statusPending;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderStatusChip(bool isApproved) {
    final color = isApproved ? AppColors.success : AppColors.statusPending;
    final icon = isApproved ? Icons.check_circle : Icons.pending;
    final label = isApproved ? 'Approved' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderAccessStatusChip(String accessStatus) {
    late Color color;
    late IconData icon;
    late String label;
    switch (accessStatus) {
      case 'approved':
        color = AppColors.success;
        icon = Icons.check_circle;
        label = 'Approved';
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel;
        label = 'Rejected';
        break;
      case 'pending':
      default:
        color = AppColors.statusPending;
        icon = Icons.pending;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Merchant Actions
  Future<void> _approveMerchant(MerchantModel merchant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Approve Merchant'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this merchant application?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Business: ${merchant.businessName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Owner: ${merchant.fullName ?? "N/A"}'),
                  Text('Email: ${merchant.email ?? "N/A"}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The merchant will gain full access to the system.',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().updateMerchantAccessStatus(merchant.id, 'approved');
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${merchant.businessName} has been approved!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _rejectMerchant(MerchantModel merchant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('Reject Merchant'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this merchant application?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Business: ${merchant.businessName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Owner: ${merchant.fullName ?? "N/A"}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The merchant will not be able to access the system.',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cancel),
            label: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().updateMerchantAccessStatus(merchant.id, 'rejected');
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cancel, color: Colors.white),
                const SizedBox(width: 12),
                Text('${merchant.businessName} has been rejected'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _suspendMerchant(MerchantModel merchant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: AppColors.statusPending, size: 28),
            SizedBox(width: 12),
            Text('Suspend Merchant'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to suspend this merchant?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Business: ${merchant.businessName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The merchant will temporarily lose access to the system.',
              style: TextStyle(color: AppColors.statusPending, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusPending),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.block),
            label: const Text('Suspend'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().updateMerchantAccessStatus(merchant.id, 'suspended');
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block, color: Colors.white),
                const SizedBox(width: 12),
                Text('${merchant.businessName} has been suspended'),
              ],
            ),
            backgroundColor: AppColors.statusPending,
          ),
        );
      }
    }
  }

  void _showMerchantDetails(MerchantModel merchant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.store, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(merchant.businessName)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('Business Information', [
                  _buildDetailRow('Business Name', merchant.businessName),
                  _buildDetailRow('Slogan', merchant.slogan ?? 'N/A'),
                  _buildDetailRow('DTI Number', merchant.dtiNumber ?? 'N/A'),
                  _buildDetailRow('Mayor Permit', merchant.mayorPermit ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Owner Information', [
                  _buildDetailRow('Owner Name', merchant.fullName ?? 'N/A'),
                  _buildDetailRow('Email', merchant.email ?? 'N/A'),
                  _buildDetailRow('Phone', merchant.phone ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Location', [
                  _buildDetailRow('Address', merchant.address ?? 'N/A'),
                  _buildDetailRow('Loading Station', merchant.loadingStationName ?? 'Not Assigned'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Status', [
                  _buildDetailRow('Access Status', merchant.accessStatus.toUpperCase()),
                  _buildDetailRow('Verified', merchant.verified ? 'Yes' : 'No'),
                  _buildDetailRow('Account Active', (merchant.isActive ?? false) ? 'Yes' : 'No'),
                  _buildDetailRow('Applied On', DateFormat('MMM d, y h:mm a').format(merchant.createdAt)),
                ]),
              ],
            ),
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

  // Rider Actions
  Future<void> _approveRider(RiderModel rider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Approve Rider'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this rider application?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${rider.fullName ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Email: ${rider.email ?? "N/A"}'),
                  Text('Plate: ${rider.plateNumber ?? "N/A"}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The rider will gain full access to the system.',
              style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().approveUser(rider.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('${rider.fullName ?? "Rider"} has been approved!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _rejectRider(RiderModel rider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('Reject Rider'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this rider application?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${rider.fullName ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Email: ${rider.email ?? "N/A"}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The rider will not be able to access the system.',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cancel),
            label: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().rejectUser(rider.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cancel, color: Colors.white),
                const SizedBox(width: 12),
                Text('${rider.fullName ?? "Rider"} has been rejected'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showRiderDetails(RiderModel rider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.motorcycle, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(rider.fullName ?? 'Rider')),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('Personal Information', [
                  _buildDetailRow('Name', rider.fullName ?? 'N/A'),
                  _buildDetailRow('Email', rider.email ?? 'N/A'),
                  _buildDetailRow('Phone', rider.phone ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Vehicle Information', [
                  _buildDetailRow('Plate Number', rider.plateNumber ?? 'N/A'),
                  _buildDetailRow('Vehicle Type', rider.vehicleType ?? 'N/A'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Documents & Photos', [
                  if ((rider.profilePictureUrl ?? '').isNotEmpty)
                    _buildImageTile('Profile Photo', rider.profilePictureUrl!),
                  if ((rider.driversLicenseUrl ?? '').isNotEmpty)
                    _buildImageTile('Driver’s License', rider.driversLicenseUrl!),
                  if ((rider.licenseCardUrl ?? '').isNotEmpty)
                    _buildImageTile('License Card', rider.licenseCardUrl!),
                  if ((rider.officialReceiptUrl ?? '').isNotEmpty)
                    _buildImageTile('Official Receipt (OR)', rider.officialReceiptUrl!),
                  if ((rider.certificateOfRegistrationUrl ?? '').isNotEmpty)
                    _buildImageTile('Certificate of Registration (CR)', rider.certificateOfRegistrationUrl!),
                  if ((rider.vehicleFrontPictureUrl ?? '').isNotEmpty)
                    _buildImageTile('Vehicle Front', rider.vehicleFrontPictureUrl!),
                  if ((rider.vehicleSidePictureUrl ?? '').isNotEmpty)
                    _buildImageTile('Vehicle Side', rider.vehicleSidePictureUrl!),
                  if ((rider.vehicleBackPictureUrl ?? '').isNotEmpty)
                    _buildImageTile('Vehicle Back', rider.vehicleBackPictureUrl!),
                  if (((rider.profilePictureUrl ?? '') +
                          (rider.driversLicenseUrl ?? '') +
                          (rider.licenseCardUrl ?? '') +
                          (rider.officialReceiptUrl ?? '') +
                          (rider.certificateOfRegistrationUrl ?? '') +
                          (rider.vehicleFrontPictureUrl ?? '') +
                          (rider.vehicleSidePictureUrl ?? '') +
                          (rider.vehicleBackPictureUrl ?? ''))
                      .isEmpty)
                    _buildDetailRow('Documents', 'No images uploaded'),
                ]),
                const Divider(height: 32),
                _buildDetailSection('Status', [
                  _buildDetailRow('Account Status', (rider.isActive ?? false) ? 'Approved' : 'Pending'),
                  _buildDetailRow('Operational Status', rider.status.toUpperCase()),
                  _buildDetailRow('Balance', '₱${rider.balance.toStringAsFixed(2)}'),
                  _buildDetailRow('Commission Rate', '${rider.commissionRate.toStringAsFixed(2)}%'),
                  _buildDetailRow('Applied On', DateFormat('MMM d, y h:mm a').format(rider.createdAt)),
                ]),
              ],
            ),
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

  void _showLicenseImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.white, size: 64),
                                const SizedBox(height: 16),
                                const Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(String label, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
          ),
          InkWell(
            onTap: () => _showLicenseImage(url),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.grey.shade400, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Center(
            child: TextButton.icon(
              onPressed: () => _showLicenseImage(url),
              icon: const Icon(Icons.fullscreen),
              label: const Text('View Full Size'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

