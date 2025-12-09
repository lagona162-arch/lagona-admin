import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/admin_service.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;
  final AdminService _adminService = AdminService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        _currentUser = session.user;
        _error = null;
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        _currentUser = session.user;
        notifyListeners();
      }
    });

    // Check for existing session
    final session = _client.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      notifyListeners();
    }
  }

  User? get currentUser {
    // Always get the latest from Supabase to ensure we have the real state
    final sessionUser = _client.auth.currentSession?.user;
    final authUser = _client.auth.currentUser;
    return _currentUser ?? sessionUser ?? authUser;
  }
  
  bool get isAuthenticated {
    // Check both the cached user and the current session
    // Always check Supabase directly to get the real-time state
    final session = _client.auth.currentSession;
    final authUser = _client.auth.currentUser;
    final hasSession = session != null;
    final hasUser = authUser != null;
    
    // Update cached user if we have a session but cached is null
    if (hasSession && _currentUser == null) {
      _currentUser = session?.user ?? authUser;
    }
    
    return hasSession && hasUser;
  }
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Register admin account
      final result = await _adminService.registerAdminAccount(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      // Try to sign in after registration
      // If email confirmation is required, we'll handle it gracefully
      try {
        await signIn(email: email, password: password);
        return {'success': true, 'needsEmailConfirmation': false};
      } catch (signInError) {
        // If sign in fails due to email not confirmed, return success but indicate email confirmation needed
        if (signInError.toString().contains('email_not_confirmed') || 
            signInError.toString().contains('Email not confirmed')) {
          return {'success': true, 'needsEmailConfirmation': true, 'email': email};
        }
        // For other errors, rethrow
        rethrow;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sign in with Supabase Auth
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Verify user is an admin
      try {
        final userData = await _client
            .from('users')
            .select('role')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (userData != null && userData['role'] != 'admin') {
          await signOut();
          throw Exception('Access denied. Admin privileges required.');
        }
      } catch (e) {
        // If query fails, don't block login - user was authenticated by Supabase
      }

      _currentUser = response.user;
      _isLoading = false;
      _error = null; // Clear any previous errors
      notifyListeners();
    } catch (e) {
      final errorString = e.toString();
      
      // Check if it's an email confirmation error
      if (errorString.contains('email_not_confirmed') || 
          errorString.contains('Email not confirmed')) {
        _error = 'Please verify your email address before signing in. Check your inbox for the verification link.';
      } else {
        _error = errorString.replaceAll('Exception: ', '').replaceAll('AuthApiException: ', '');
      }
      
      _isLoading = false;
      _currentUser = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.auth.signOut();
      
      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

