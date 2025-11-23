import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../providers/admin_provider.dart';
import '../utils/responsive.dart';
import '../utils/app_colors.dart';

class RidersScreen extends StatefulWidget {
  const RidersScreen({super.key});

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadRiders();
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
                      'Rider Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadRiders(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rider Management',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AdminProvider>().loadRiders(forceRefresh: true),
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
                        hintText: 'Search by name or plate number',
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
                        DropdownMenuItem(value: 'available', child: Text('Available')),
                        DropdownMenuItem(value: 'busy', child: Text('Busy')),
                        DropdownMenuItem(value: 'offline', child: Text('Offline')),
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
                  value: _statusFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'available', child: Text('Available')),
                    DropdownMenuItem(value: 'busy', child: Text('Busy')),
                    DropdownMenuItem(value: 'offline', child: Text('Offline')),
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
                if (provider.isLoading && provider.riders.isEmpty) {
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
                          onPressed: () => provider.loadRiders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var filteredRiders = provider.riders.where((rider) {
                  final matchesSearch = (rider.fullName?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (rider.email?.toLowerCase().contains(_searchQuery) ?? false);
                  final matchesStatus = _statusFilter == 'all' || rider.status == _statusFilter;
                  return matchesSearch && matchesStatus;
                }).toList();

                final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);

                return Card(
                  elevation: 2,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 1000,
                    columns: const [
                      DataColumn2(label: Text('Full Name'), size: ColumnSize.L),
                      DataColumn2(label: Text('Email'), size: ColumnSize.L),
                      DataColumn2(label: Text('Plate Number'), size: ColumnSize.S),
                      DataColumn2(label: Text('Vehicle'), size: ColumnSize.S),
                      DataColumn2(label: Text('Balance'), size: ColumnSize.S),
                      DataColumn2(label: Text('Commission'), size: ColumnSize.S),
                      DataColumn2(label: Text('Status'), size: ColumnSize.S),
                      DataColumn2(label: Text('Last Active'), size: ColumnSize.M),
                      DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                    ],
                    rows: filteredRiders.map((rider) {
                      return DataRow2(
                        cells: [
                          DataCell(Text(rider.fullName ?? 'N/A')),
                          DataCell(Text(rider.email ?? 'N/A')),
                          DataCell(Text(rider.plateNumber ?? 'N/A')),
                          DataCell(Text(rider.vehicleType ?? 'N/A')),
                          DataCell(Text(currencyFormat.format(rider.balance))),
                          DataCell(Text('${rider.commissionRate.toStringAsFixed(2)}%')),
                          DataCell(_buildStatusChip(rider.status)),
                          DataCell(Text(
                            rider.lastActive != null 
                                ? DateFormat('MMM d, y h:mm a').format(rider.lastActive!) 
                                : 'N/A'
                          )),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.blue),
                              onPressed: () => _showRiderDetails(rider),
                              tooltip: 'View Details',
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'available':
        color = Colors.green;
        break;
      case 'busy':
        color = Colors.orange;
        break;
      case 'offline':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Color.lerp(color, Colors.black, 0.3)!,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showRiderDetails(rider) {
    final currencyFormat = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.motorcycle, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(rider.fullName ?? 'Rider Details')),
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
                  _buildDetailRow('Balance', currencyFormat.format(rider.balance)),
                  _buildDetailRow('Commission Rate', '${rider.commissionRate.toStringAsFixed(2)}%'),
                  _buildDetailRow('Status', rider.status),
                  _buildDetailRow('Current Address', rider.currentAddress ?? 'N/A'),
                  _buildDetailRow('Last Active', rider.lastActive != null 
                      ? DateFormat('MMM d, y h:mm a').format(rider.lastActive!) 
                      : 'N/A'),
                  _buildDetailRow('Active', (rider.isActive ?? false) ? 'Yes' : 'No'),
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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

