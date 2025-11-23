import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';
import '../widgets/responsive_data_table.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _searchQuery = '';
  String _roleFilter = 'all';
  String _approvalFilter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.getHorizontalPadding(context);
    final titleSize = ResponsiveHelper.getResponsiveFontSize(context, 28);
    final isMobile = Responsive.isMobile(context);
    
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
                      'User Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadUsers(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadUsers(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          // Statistics Cards
          Consumer<AdminProvider>(
            builder: (context, provider, child) {
              final users = provider.users;
              final pending = users.where((u) => !u.isActive).length;
              final approved = users.where((u) => u.isActive).length;
              
              return isMobile
                  ? Column(
                      children: [
                        _buildStatCard(
                          'Pending Approval',
                          pending.toString(),
                          Icons.pending_actions,
                          AppColors.statusPending,
                        ),
                        const SizedBox(height: 12),
                        _buildStatCard(
                          'Approved Users',
                          approved.toString(),
                          Icons.check_circle,
                          AppColors.success,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Pending Approval',
                            pending.toString(),
                            Icons.pending_actions,
                            AppColors.statusPending,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Approved Users',
                            approved.toString(),
                            Icons.check_circle,
                            AppColors.success,
                          ),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          
          // Filters
          isMobile
              ? Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by name or email',
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
                      value: _approvalFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Approval Status',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'pending', child: Text('Pending Approval')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _approvalFilter = value ?? 'all';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _roleFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Role',
                        border: OutlineInputBorder(),
                      ),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Roles')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
                        DropdownMenuItem(value: 'rider', child: Text('Rider')),
                        DropdownMenuItem(value: 'customer', child: Text('Customer')),
                        DropdownMenuItem(value: 'business_hub', child: Text('Business Hub')),
                        DropdownMenuItem(value: 'loading_station', child: Text('Loading Station')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleFilter = value ?? 'all';
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
                          hintText: 'Search by name or email',
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
                        value: _approvalFilter,
                        decoration: const InputDecoration(
                          labelText: 'Approval Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Users')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending Approval')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _approvalFilter = value ?? 'all';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _roleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Roles')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
                          DropdownMenuItem(value: 'rider', child: Text('Rider')),
                          DropdownMenuItem(value: 'customer', child: Text('Customer')),
                          DropdownMenuItem(value: 'business_hub', child: Text('Business Hub')),
                          DropdownMenuItem(value: 'loading_station', child: Text('Loading Station')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _roleFilter = value ?? 'all';
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
                if (provider.isLoading && provider.users.isEmpty) {
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
                          onPressed: () => provider.loadUsers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredUsers = provider.users.where((user) {
                  final matchesSearch = user.fullName.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery);
                  final matchesRole = _roleFilter == 'all' || user.role == _roleFilter;
                  final matchesApproval = _approvalFilter == 'all' ||
                      (_approvalFilter == 'pending' && !user.isActive) ||
                      (_approvalFilter == 'approved' && user.isActive);
                  return matchesSearch && matchesRole && matchesApproval;
                }).toList();

                return ResponsiveDataTable(
                  dataTable: Card(
                    elevation: 2,
                    child: DataTable2(
                      columnSpacing: isMobile ? 8 : 12,
                      horizontalMargin: isMobile ? 8 : 12,
                      minWidth: 900,
                      columns: const [
                      DataColumn2(label: Text('Full Name'), size: ColumnSize.L),
                      DataColumn2(label: Text('Email'), size: ColumnSize.L),
                      DataColumn2(label: Text('Role'), size: ColumnSize.S),
                      DataColumn2(label: Text('Phone'), size: ColumnSize.M),
                      DataColumn2(label: Text('Created At'), size: ColumnSize.M),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S),
                      DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                    ],
                    rows: filteredUsers.map((user) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(user.fullName)),
                          DataCell(Text(user.email)),
                          DataCell(_buildRoleBadge(user.role)),
                          DataCell(Text(user.phone ?? 'N/A')),
                          DataCell(Text(DateFormat('MMM d, y').format(user.createdAt))),
                          DataCell(_buildStatusChip(user.isActive)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!user.isActive) ...[
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: AppColors.success),
                                    onPressed: () => _approveUser(user.id),
                                    tooltip: 'Approve',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: AppColors.error),
                                    onPressed: () => _rejectUser(user.id),
                                    tooltip: 'Reject',
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(Icons.block, color: AppColors.error),
                                    onPressed: () => _toggleUserStatus(user.id, user.isActive),
                                    tooltip: 'Suspend',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    switch (role) {
      case 'admin':
        color = AppColors.error;
        break;
      case 'merchant':
        color = AppColors.success;
        break;
      case 'rider':
        color = AppColors.statusPending;
        break;
      case 'customer':
        color = AppColors.primary;
        break;
      case 'business_hub':
        color = AppColors.secondary;
        break;
      case 'loading_station':
        color = AppColors.statusReady;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Chip(
      label: Text(
        isActive ? 'Active' : 'Suspended',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: isActive ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isActive ? AppColors.success : AppColors.error,
        fontWeight: FontWeight.bold,
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

  Future<void> _approveUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve User'),
        content: const Text('Are you sure you want to approve this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().approveUser(userId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User approved successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<AdminProvider>().error ?? 'Failed to approve user',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: const Text('Are you sure you want to reject this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().rejectUser(userId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User rejected successfully'),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<AdminProvider>().error ?? 'Failed to reject user',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Suspend User' : 'Activate User'),
        content: Text(
          currentStatus
              ? 'Are you sure you want to suspend this user?'
              : 'Are you sure you want to activate this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<AdminProvider>().updateUserStatus(userId, !currentStatus);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User status updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<AdminProvider>().error ?? 'Failed to update user status',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

