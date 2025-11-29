import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';
import '../models/topup_request_model.dart';

class TopupsScreen extends StatefulWidget {
  const TopupsScreen({super.key});

  @override
  State<TopupsScreen> createState() => _TopupsScreenState();
}

class _TopupsScreenState extends State<TopupsScreen> {
  String _searchQuery = '';
  String _viewType = 'all'; // 'all', 'requests', 'completed'
  String _statusFilter = 'pending';

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
        context.read<AdminProvider>().loadTopups(forceRefresh: true);
        // Try to load requests, but don't fail if table doesn't exist
        context.read<AdminProvider>().loadTopupRequests(forceRefresh: true).catchError((e) {
          // Silently handle missing table
          debugPrint('Top-up requests table not available: $e');
        });
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
                      'Top-Up Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().loadTopups(forceRefresh: true);
                        context.read<AdminProvider>().loadTopupRequests(forceRefresh: true);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top-Up Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AdminProvider>().loadTopups(forceRefresh: true);
                        context.read<AdminProvider>().loadTopupRequests(forceRefresh: true);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // View Type Selector
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewTypeButton('all', 'All', Icons.list),
                _buildViewTypeButton('requests', 'Requests', Icons.request_quote),
                _buildViewTypeButton('completed', 'Completed', Icons.check_circle),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Consumer<AdminProvider>(
            builder: (context, provider, child) {
              final allRequests = provider.topupRequests;
              final pending = allRequests.where((r) => r.status == 'pending').length;
              final completed = provider.topups.length;

              return isMobile
                  ? Column(
                      children: [
                        _buildStatCard('Pending Requests', pending.toString(), Icons.pending_actions, AppColors.statusPending),
                        const SizedBox(height: 12),
                        _buildStatCard('Completed Top-Ups', completed.toString(), Icons.check_circle, AppColors.success),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Pending Requests', pending.toString(), Icons.pending_actions, AppColors.statusPending),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Completed Top-Ups', completed.toString(), Icons.check_circle, AppColors.success),
                        ),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),
          
          // Search and Filters
          isMobile
              ? Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Search by name or account',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    if (_viewType == 'requests') ...[
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
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'pending';
                          });
                          context.read<AdminProvider>().loadTopupRequests(
                                status: _statusFilter == 'all' ? null : _statusFilter,
                                forceRefresh: true,
                              );
                        },
                      ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search by name or account',
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
                    if (_viewType == 'requests') ...[
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
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'approved', child: Text('Approved')),
                            DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value ?? 'pending';
                            });
                            context.read<AdminProvider>().loadTopupRequests(
                                  status: _statusFilter == 'all' ? null : _statusFilter,
                                  forceRefresh: true,
                                );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
          const SizedBox(height: 24),
          
          // Data Table
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.topups.isEmpty && provider.topupRequests.isEmpty) {
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
                          onPressed: () {
                            provider.loadTopups();
                            provider.loadTopupRequests();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

                if (_viewType == 'requests' || _viewType == 'all') {
                  return _buildRequestsTable(provider, currencyFormat);
                } else {
                  return _buildCompletedTable(provider, currencyFormat);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(String type, String label, IconData icon) {
    final isSelected = _viewType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _viewType = type;
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

  Widget _buildRequestsTable(AdminProvider provider, NumberFormat currencyFormat) {
    var filteredRequests = provider.topupRequests.where((request) {
      final matchesSearch = (request.requesterName?.toLowerCase().contains(_searchQuery) ?? false) ||
          (request.businessHubName?.toLowerCase().contains(_searchQuery) ?? false) ||
          (request.loadingStationName?.toLowerCase().contains(_searchQuery) ?? false);
      final matchesStatus = _statusFilter == 'all' || request.status == _statusFilter;
      final matchesView = _viewType == 'all' || _viewType == 'requests';
      return matchesSearch && matchesStatus && matchesView;
    }).toList();

    if (filteredRequests.isEmpty && _viewType == 'requests') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No top-up requests found',
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
          DataColumn2(label: Text('Type'), size: ColumnSize.S),
          DataColumn2(label: Text('Requester'), size: ColumnSize.L),
          DataColumn2(label: Text('Account'), size: ColumnSize.M),
          DataColumn2(label: Text('Amount'), size: ColumnSize.S),
          DataColumn2(label: Text('Bonus'), size: ColumnSize.S),
          DataColumn2(label: Text('Total'), size: ColumnSize.S),
          DataColumn2(label: Text('Status'), size: ColumnSize.S),
          DataColumn2(label: Text('Date'), size: ColumnSize.M),
          DataColumn2(label: Text('Actions'), size: ColumnSize.M),
        ],
        rows: filteredRequests.map((request) {
          return DataRow2(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (request.status == 'pending') {
                  return Colors.orange.shade50;
                }
                return null;
              },
            ),
            cells: [
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.request_quote, size: 16, color: AppColors.statusPending),
                  const SizedBox(width: 4),
                  const Text('Request'),
                ],
              )),
              DataCell(Text(request.requesterName ?? 'N/A')),
              DataCell(Text(request.businessHubName ?? request.loadingStationName ?? 'N/A')),
              DataCell(Text(currencyFormat.format(request.requestedAmount))),
              DataCell(Text(
                request.bonusAmount != null ? currencyFormat.format(request.bonusAmount!) : 'N/A',
                style: request.bonusAmount != null
                    ? TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)
                    : null,
              )),
              DataCell(Text(
                request.totalCredited != null ? currencyFormat.format(request.totalCredited!) : 'N/A',
                style: request.totalCredited != null
                    ? TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)
                    : null,
              )),
              DataCell(_buildStatusChip(request.status)),
              DataCell(Text(DateFormat('MMM d, y h:mm a').format(request.createdAt))),
              DataCell(
                request.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Approve Request',
                            child: IconButton(
                              icon: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              onPressed: () => _approveRequest(request),
                            ),
                          ),
                          Tooltip(
                            message: 'Reject Request',
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: AppColors.error, size: 20),
                              onPressed: () => _rejectRequest(request),
                            ),
                          ),
                        ],
                      )
                    : const Text('Processed', style: TextStyle(fontSize: 12)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompletedTable(AdminProvider provider, NumberFormat currencyFormat) {
    var filteredTopups = provider.topups.where((topup) {
      final matchesSearch = topup.initiatorName?.toLowerCase().contains(_searchQuery) ?? false;
      return matchesSearch;
    }).toList();

    if (filteredTopups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No completed top-ups found',
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
        minWidth: 900,
        columns: const [
          DataColumn2(label: Text('Type'), size: ColumnSize.S),
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
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  const Text('Completed'),
                ],
              )),
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
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
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

  Future<void> _approveRequest(TopupRequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Text('Approve Top-Up Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this top-up request?'),
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
                  Text('Requester: ${request.requesterName ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Amount: ₱${request.requestedAmount.toStringAsFixed(2)}'),
                  if (request.businessHubName != null) Text('Business Hub: ${request.businessHubName}'),
                  if (request.loadingStationName != null) Text('Loading Station: ${request.loadingStationName}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The account balance will be credited with the amount plus bonus.',
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
      final success = await context.read<AdminProvider>().approveTopupRequest(request.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Top-up request approved successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AdminProvider>().error ?? 'Failed to approve request',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(TopupRequestModel request) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('Reject Top-Up Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reject this top-up request?'),
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
                  Text('Requester: ${request.requesterName ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Amount: ₱${request.requestedAmount.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason (Optional)',
                hintText: 'Enter reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
      final success = await context.read<AdminProvider>().rejectTopupRequest(
            request.id,
            reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
          );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cancel, color: Colors.white),
                const SizedBox(width: 12),
                Text('Top-up request rejected'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AdminProvider>().error ?? 'Failed to reject request',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

