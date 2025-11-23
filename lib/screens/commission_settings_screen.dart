import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive.dart';

class CommissionSettingsScreen extends StatefulWidget {
  const CommissionSettingsScreen({super.key});

  @override
  State<CommissionSettingsScreen> createState() => _CommissionSettingsScreenState();
}

class _CommissionSettingsScreenState extends State<CommissionSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadCommissionSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
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
                      'Commission & Fee Settings',
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
                            onPressed: () => _showAddCommissionDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Setting'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.read<AdminProvider>().loadCommissionSettings(forceRefresh: true),
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
                      'Commission & Fee Settings',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddCommissionDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Setting'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => context.read<AdminProvider>().loadCommissionSettings(forceRefresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.commissionSettings.isEmpty) {
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
                          onPressed: () => provider.loadCommissionSettings(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.commissionSettings.isEmpty) {
                  return const Center(
                    child: Text('No commission settings found. Add one to get started.'),
                  );
                }

                final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
                final aspectRatio = isMobile ? 2.5 : (isTablet ? 2.3 : 2.2);
                
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 12 : 16,
                    mainAxisSpacing: isMobile ? 12 : 16,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: provider.commissionSettings.length,
                  itemBuilder: (context, index) {
                    final setting = provider.commissionSettings[index];
                    return _buildCommissionCard(setting, isMobile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(setting, bool isMobile) {
    Color color = _getRoleColor(setting.role);
    final iconSize = isMobile ? 28.0 : 24.0;
    final fontSize = isMobile ? 28.0 : 26.0;
    final roleFontSize = isMobile ? 12.0 : 11.0;
    final padding = isMobile ? 16.0 : 12.0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.percent, color: color, size: iconSize),
            SizedBox(height: isMobile ? 8 : 6),
            Text(
              '${setting.percentage.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 6 : 4),
            Flexible(
              child: Text(
                setting.role.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: roleFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 4),
            SizedBox(
              width: isMobile ? 28.0 : 24.0,
              height: isMobile ? 28.0 : 24.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: isMobile ? 18.0 : 16.0,
                  ),
                  onPressed: () => _showEditCommissionDialog(setting),
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(), // remove default 48x48 min size
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  splashRadius: isMobile ? 14.0 : 12.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'business_hub':
        return AppColors.secondary;
      case 'loading_station':
        return AppColors.statusReady;
      case 'rider':
        return AppColors.statusPending;
      case 'merchant':
        return AppColors.success;
      case 'shareholder':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showAddCommissionDialog() {
    final TextEditingController roleController = TextEditingController();
    final TextEditingController percentageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Commission Setting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'business_hub', child: Text('Business Hub')),
                DropdownMenuItem(value: 'loading_station', child: Text('Loading Station')),
                DropdownMenuItem(value: 'rider', child: Text('Rider')),
                DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
              ],
              onChanged: (value) {
                roleController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: 'Percentage',
                hintText: 'Enter percentage (e.g., 10.5)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (roleController.text.isNotEmpty && percentageController.text.isNotEmpty) {
                final percentage = double.tryParse(percentageController.text);
                if (percentage != null && percentage >= 0 && percentage <= 100) {
                  Navigator.pop(context);
                  final success = await context.read<AdminProvider>().createCommissionSetting(
                    roleController.text,
                    percentage,
                  );
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commission setting created successfully'),
                        backgroundColor: AppColors.success,
                      ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<AdminProvider>().error ?? 'Failed to create commission setting',
                          ),
                          backgroundColor: AppColors.error,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                } else if (percentage != null && (percentage < 0 || percentage > 100)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Percentage must be between 0 and 100'),
                      backgroundColor: AppColors.statusPending,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: AppColors.statusPending,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCommissionDialog(setting) {
    final TextEditingController percentageController = TextEditingController(
      text: setting.percentage.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${setting.role.replaceAll('_', ' ').toUpperCase()} Commission'),
        content: TextField(
          controller: percentageController,
          decoration: const InputDecoration(
            labelText: 'Percentage',
            hintText: 'Enter percentage (e.g., 10.5)',
            border: OutlineInputBorder(),
            suffixText: '%',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final percentage = double.tryParse(percentageController.text);
              if (percentage != null) {
                Navigator.pop(context);
                final success = await context.read<AdminProvider>().updateCommissionSetting(
                  setting.id,
                  percentage,
                );
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commission setting updated successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.read<AdminProvider>().error ?? 'Failed to update commission setting',
                        ),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

