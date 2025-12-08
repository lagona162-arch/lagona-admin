import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';
import '../models/topup_request_model.dart';

class TopupRequestsScreen extends StatefulWidget {
  const TopupRequestsScreen({super.key});

  @override
  State<TopupRequestsScreen> createState() => _TopupRequestsScreenState();
}

class _TopupRequestsScreenState extends State<TopupRequestsScreen> {
  String _statusFilter = 'pending';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadTopupRequests(status: _statusFilter);
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
                      'Top-Up Requests',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadTopupRequests(
                            status: _statusFilter,
                            forceRefresh: true,
                          ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top-Up Requests',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadTopupRequests(
                            status: _statusFilter,
                            forceRefresh: true,
                          ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // Statistics Cards
          Consumer<AdminProvider>(
            builder: (context, provider, child) {
              final allRequests = provider.topupRequests;
              final pending = allRequests.where((r) => r.status == 'pending').length;
              final approved = allRequests.where((r) => r.status == 'approved').length;
              final rejected = allRequests.where((r) => r.status == 'rejected').length;

              return isMobile
                  ? Column(
                      children: [
                        _buildStatCard('Pending', pending.toString(), Icons.pending_actions, AppColors.statusPending),
                        const SizedBox(height: 12),
                        _buildStatCard('Approved', approved.toString(), Icons.check_circle, AppColors.success),
                        const SizedBox(height: 12),
                        _buildStatCard('Rejected', rejected.toString(), Icons.cancel, AppColors.error),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('Pending', pending.toString(), Icons.pending_actions, AppColors.statusPending),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Approved', approved.toString(), Icons.check_circle, AppColors.success),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard('Rejected', rejected.toString(), Icons.cancel, AppColors.error),
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
                        hintText: 'Search by requester name',
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
                        DropdownMenuItem(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value ?? 'all';
                        });
                        context.read<AdminProvider>().loadTopupRequests(
                              status: _statusFilter == 'all' ? null : _statusFilter,
                              forceRefresh: true,
                            );
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
                          hintText: 'Search by requester name',
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
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'approved', child: Text('Approved')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'all';
                          });
                          context.read<AdminProvider>().loadTopupRequests(
                                status: _statusFilter == 'all' ? null : _statusFilter,
                                forceRefresh: true,
                              );
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
                if (provider.isLoading && provider.topupRequests.isEmpty) {
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
                          onPressed: () => provider.loadTopupRequests(status: _statusFilter == 'all' ? null : _statusFilter),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredRequests = provider.topupRequests.where((request) {
                  final matchesSearch = (request.requesterName?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (request.businessHubName?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (request.loadingStationName?.toLowerCase().contains(_searchQuery) ?? false);
                  final matchesStatus = _statusFilter == 'all' || request.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

                if (filteredRequests.isEmpty) {
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
                      DataColumn2(label: Text('Requester'), size: ColumnSize.L),
                      DataColumn2(label: Text('Account'), size: ColumnSize.M),
                      DataColumn2(label: Text('Amount'), size: ColumnSize.S),
                      DataColumn2(label: Text('Bonus'), size: ColumnSize.S),
                      DataColumn2(label: Text('Total'), size: ColumnSize.S),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S),
                      DataColumn2(label: Text('Requested'), size: ColumnSize.M),
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
                          DataCell(Text(request.requesterName ?? 'N/A')),
                          DataCell(Text(
                            request.businessHubName ?? request.loadingStationName ?? 'N/A',
                          )),
                          DataCell(Text(currencyFormat.format(request.requestedAmount))),
                          DataCell(Text(
                            request.bonusAmount != null
                                ? currencyFormat.format(request.bonusAmount!)
                                : 'N/A',
                            style: request.bonusAmount != null
                                ? TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)
                                : null,
                          )),
                          DataCell(Text(
                            request.totalCredited != null
                                ? currencyFormat.format(request.totalCredited!)
                                : 'N/A',
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
                                          icon: const Icon(Icons.check_circle, color: AppColors.success),
                                          onPressed: () => _approveRequest(request),
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'Reject Request',
                                        child: IconButton(
                                          icon: const Icon(Icons.cancel, color: AppColors.error),
                                          onPressed: () => _rejectRequest(request),
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text('Processed'),
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
    final provider = context.read<AdminProvider>();
    
    // Determine role and get current commission rate
    String role;
    String? entityId;
    if (request.businessHubId != null) {
      role = 'business_hub';
      entityId = request.businessHubId;
    } else if (request.loadingStationId != null) {
      role = 'loading_station';
      entityId = request.loadingStationId;
    } else {
      role = 'unknown';
    }

    // Load current commission rate for the role
    final currentCommissionRate = await provider.getCommissionRate(role);
    
    // Initialize controllers
    final commissionController = TextEditingController(
      text: currentCommissionRate?.toStringAsFixed(2) ?? '0.00',
    );
    double commissionRate = currentCommissionRate ?? 0.0;
    bool saveCommissionOverride = false;

    final confirmed = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate values based on current commission rate
            // Formula: Bonus = Amount × (Commission Rate / 100)
            // Total = Amount + Bonus
            final bonusAmount = request.requestedAmount * (commissionRate / 100);
            final totalCredited = request.requestedAmount + bonusAmount;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 28),
                  SizedBox(width: 12),
                  Text('Approve Top-Up Request'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Review and approve this top-up request:'),
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
                          Text('Requester: ${request.requesterName ?? "N/A"}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Requested Amount: ₱${request.requestedAmount.toStringAsFixed(2)}'),
                          if (request.businessHubName != null) ...[
                            const SizedBox(height: 4),
                            Text('Business Hub: ${request.businessHubName}'),
                          ],
                          if (request.loadingStationName != null) ...[
                            const SizedBox(height: 4),
                            Text('Loading Station: ${request.loadingStationName}'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commissionController,
                      decoration: const InputDecoration(
                        labelText: 'Commission Rate (%)',
                        hintText: 'Enter commission rate',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0 && parsed <= 100) {
                          setState(() {
                            commissionRate = parsed;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (entityId != null)
                      CheckboxListTile(
                        title: const Text('Save this commission rate for this ${role.replaceAll('_', ' ')}'),
                        subtitle: Text(
                          'Override existing commission setting${currentCommissionRate != null ? ' (Current: ${currentCommissionRate!.toStringAsFixed(2)}%)' : ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        value: saveCommissionOverride,
                        onChanged: (value) {
                          setState(() {
                            saveCommissionOverride = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Requested Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '₱${request.requestedAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bonus (${commissionRate.toStringAsFixed(2)}%):', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '₱${bonusAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '   = ₱${request.requestedAmount.toStringAsFixed(2)} × ${commissionRate.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total to Credit:', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                '₱${totalCredited.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '   = ₱${request.requestedAmount.toStringAsFixed(2)} + ₱${bonusAmount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  onPressed: () {
                    final finalRate = double.tryParse(commissionController.text);
                    if (finalRate != null && finalRate >= 0 && finalRate <= 100) {
                      Navigator.pop(context, {
                        'commissionRate': finalRate,
                        'saveOverride': saveCommissionOverride,
                      });
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != null && mounted) {
      final finalCommissionRate = confirmed['commissionRate'] as double;
      final saveOverride = confirmed['saveOverride'] as bool;
      
      final success = await provider.approveTopupRequest(
        request.id,
        commissionRateOverride: finalCommissionRate,
        saveCommissionOverride: saveOverride,
      );
      
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
              provider.error ?? 'Failed to approve request',
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

