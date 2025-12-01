import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _confirmPasswordController.clear();
    });
    context.read<AuthProvider>().clearError();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (10-11 digits)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _showEmailConfirmationModal(BuildContext context, String email) {
    // Clear any errors before showing modal
    context.read<AuthProvider>().clearError();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.email, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text('Check Your Email'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isLogin 
                    ? 'Please verify your email address to continue.'
                    : 'Your admin account has been created successfully!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification email to:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check your inbox and click the verification link to activate your account. Once verified, you can sign in.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch back to login mode if we were in registration
                if (!_isLogin) {
                  setState(() {
                    _isLogin = true;
                  });
                }
                // Clear error state
                context.read<AuthProvider>().clearError();
              },
              child: Text(
                'Got it',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      if (_isLogin) {
        try {
          await authProvider.signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          
          // Clear error before navigation
          authProvider.clearError();
          
          // Auto-navigate to dashboard after successful login
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              context.go('/');
            }
          }
        } catch (e) {
          // Clear error state
          authProvider.clearError();
          
          // If it's an email confirmation error, show modal instead
          if (e.toString().contains('email_not_confirmed') || 
              e.toString().contains('Email not confirmed')) {
            if (mounted) {
              _showEmailConfirmationModal(context, _emailController.text.trim());
            }
          } else {
            // For other errors, they'll be shown in the error display area
            rethrow;
          }
        }
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwords do not match'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        final result = await authProvider.signUp(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        // Clear error after successful registration
        authProvider.clearError();

        if (mounted) {
          if (result['success'] == true) {
            if (result['needsEmailConfirmation'] == true) {
              // Show modal for email confirmation
              _showEmailConfirmationModal(context, result['email']);
            } else {
              // Registration and auto-login successful, navigate to dashboard
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                context.go('/');
              }
            }
          }
        }
      }
    } catch (e) {
      // Clear error state
      authProvider.clearError();
      
      if (mounted) {
        // Only show error if it's not about email confirmation
        if (!e.toString().contains('email_not_confirmed') && 
            !e.toString().contains('Email not confirmed')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? e.toString()),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // Show modal for email confirmation instead of error
          _showEmailConfirmationModal(context, _emailController.text.trim());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LAGONA ADMIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Sign in to continue' : 'Create admin account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Registration fields (only shown when not in login mode)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '09XXXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password field (only shown when registering)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (!_isLogin) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Error message (only show if not email confirmation error)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      if (authProvider.error != null && 
                          authProvider.error!.isNotEmpty &&
                          !authProvider.error!.toLowerCase().contains('email not confirmed') &&
                          !authProvider.error!.toLowerCase().contains('email_not_confirmed')) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Submit button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.buttonPrimary,
                          disabledBackgroundColor: AppColors.buttonDisabled,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isLogin ? 'Sign In' : 'Register',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Toggle between login and registration
                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Register'
                          : 'Already have an account? Sign in',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

