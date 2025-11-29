import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_colors.dart';
import '../utils/responsive.dart';

class HubStationRegistrationScreen extends StatefulWidget {
  const HubStationRegistrationScreen({super.key});

  @override
  State<HubStationRegistrationScreen> createState() => _HubStationRegistrationScreenState();
}

class _HubStationRegistrationScreenState extends State<HubStationRegistrationScreen> {
  String _accountType = 'business_hub'; // 'business_hub' or 'loading_station'
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bhcodeController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  double? _businessHubCommissionRate;
  double? _loadingStationCommissionRate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommissionRates();
    });
  }

  Future<void> _loadCommissionRates() async {
    final provider = context.read<AdminProvider>();
    final bhRate = await provider.getCommissionRate('business_hub');
    final lsRate = await provider.getCommissionRate('loading_station');
    
    setState(() {
      _businessHubCommissionRate = bhRate;
      _loadingStationCommissionRate = lsRate;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bhcodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<AdminProvider>();
    Map<String, dynamic> result;

    try {
      // Clean phone number - remove any non-digit characters
      final cleanedPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (_accountType == 'business_hub') {
        result = await provider.createBusinessHub(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          phone: cleanedPhone,
          name: _nameController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        result = await provider.createLoadingStation(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          phone: cleanedPhone,
          name: _nameController.text.trim(),
          password: _passwordController.text,
          bhcode: _bhcodeController.text.trim().isEmpty ? null : _bhcodeController.text.trim(),
        );
      }

      if (mounted) {
        final code = _accountType == 'business_hub' ? result['bhcode'] : result['lscode'];
        final codeLabel = _accountType == 'business_hub' ? 'BHCODE' : 'LSCODE';
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                const Text('Registration Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account created successfully!'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$codeLabel:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please save this code. It will be needed for linking accounts.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _resetForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _nameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _bhcodeController.clear();
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
          Text(
            'Register Business Hub / Loading Station',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create new Business Hub or Loading Station accounts',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Account Type Selector
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeButton('business_hub', 'Business Hub', Icons.business),
                _buildTypeButton('loading_station', 'Loading Station', Icons.local_shipping),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Commission Rate Display
          if (_accountType == 'business_hub' && _businessHubCommissionRate != null)
            _buildCommissionInfoCard(
              'Business Hub Commission Rate',
              '${_businessHubCommissionRate!.toStringAsFixed(2)}%',
              AppColors.primary,
            )
          else if (_accountType == 'loading_station' && _loadingStationCommissionRate != null)
            _buildCommissionInfoCard(
              'Loading Station Commission Rate',
              '${_loadingStationCommissionRate!.toStringAsFixed(2)}%',
              AppColors.success,
            ),
          if ((_accountType == 'business_hub' && _businessHubCommissionRate != null) ||
              (_accountType == 'loading_station' && _loadingStationCommissionRate != null))
            const SizedBox(height: 16),

          // Registration Form
          Expanded(
            child: SingleChildScrollView(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name *',
                            hintText: 'Enter first name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name *',
                            hintText: 'Enter last name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            hintText: 'Enter email address (e.g., user@example.com)',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            // Email validation regex
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number *',
                            hintText: 'Enter phone number (09XXXXXXXXX)',
                            prefixIcon: Icon(Icons.phone),
                            helperText: 'Format: 09XXXXXXXXX (11 digits starting with 09)',
                            counterText: '',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            
                            // Check if it's all digits (should be guaranteed by formatter, but double-check)
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Phone number must contain only digits';
                            }
                            
                            // Check if it starts with 09
                            if (!value.startsWith('09')) {
                              return 'Phone number must start with 09';
                            }
                            
                            // Check if it's exactly 11 digits
                            if (value.length != 11) {
                              return 'Phone number must be exactly 11 digits';
                            }
                            
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Business/Station Name
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _accountType == 'business_hub' ? 'Business Hub Name *' : 'Loading Station Name *',
                            hintText: _accountType == 'business_hub' ? 'Enter business hub name' : 'Enter loading station name',
                            prefixIcon: const Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter ${_accountType == 'business_hub' ? 'business hub' : 'loading station'} name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // BHCODE (only for Loading Station)
                        if (_accountType == 'loading_station') ...[
                          TextFormField(
                            controller: _bhcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Business Hub Code (BHCODE)',
                              hintText: 'Enter BHCODE to link to Business Hub',
                              prefixIcon: Icon(Icons.qr_code),
                              helperText: 'Optional: Link this Loading Station to a Business Hub',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Divider(),
                        const SizedBox(height: 16),

                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password *',
                            hintText: 'Enter password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password *',
                            hintText: 'Confirm password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        Consumer<AdminProvider>(
                          builder: (context, provider, child) {
                            return ElevatedButton(
                              onPressed: provider.isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Register ${_accountType == 'business_hub' ? 'Business Hub' : 'Loading Station'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, IconData icon) {
    final isSelected = _accountType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _accountType = type;
            _bhcodeController.clear();
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

  Widget _buildCommissionInfoCard(String title, String rate, Color color) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.percent, color: color, size: 32),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rate,
                    style: TextStyle(
                      fontSize: 24,
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
}

