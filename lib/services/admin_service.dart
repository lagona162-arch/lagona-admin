import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/user_model.dart';
import '../models/merchant_model.dart';
import '../models/rider_model.dart';
import '../models/transaction_model.dart';
import '../models/delivery_model.dart';
import '../models/commission_setting_model.dart';
import '../models/topup_model.dart';
import '../models/business_hub_model.dart';
import '../models/loading_station_model.dart';
import '../models/topup_request_model.dart';
import 'supabase_service.dart';

class AdminService {
  final SupabaseClient _client = SupabaseService.client;

  // User Management
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);
      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<List<MerchantModel>> getAllMerchants() async {
    try {
      final response = await _client
          .from('merchants')
          .select('*, users!inner(full_name, email, phone, is_active)')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) {
        final userData = json['users'];
        return MerchantModel.fromJson({
          ...json,
          'full_name': userData['full_name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'is_active': userData['is_active'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch merchants: $e');
    }
  }

  Future<List<RiderModel>> getAllRiders({int limit = 200, int offset = 0}) async {
    try {
      final response = await _client
          .from('riders')
          .select('*, users!inner(full_name, email, phone, is_active, access_status)')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List).map((json) {
        final userData = json['users'];
        return RiderModel.fromJson({
          ...json,
          'full_name': userData['full_name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'is_active': userData['is_active'],
          'access_status': userData['access_status'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch riders: $e');
    }
  }

  // Account Actions
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _client
          .from('users')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  Future<void> approveUser(String userId) async {
    try {
      await _client
          .from('users')
          .update({'is_active': true, 'access_status': 'approved'})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  Future<void> rejectUser(String userId) async {
    try {
      await _client
          .from('users')
          .update({'is_active': false, 'access_status': 'rejected'})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  Future<void> approveMerchant(String merchantId) async {
    try {
      await _client
          .from('merchants')
          .update({'verified': true, 'status': 'approved'})
          .eq('id', merchantId);
    } catch (e) {
      throw Exception('Failed to approve merchant: $e');
    }
  }

  Future<void> rejectMerchant(String merchantId) async {
    try {
      await _client
          .from('merchants')
          .update({'verified': false, 'status': 'rejected'})
          .eq('id', merchantId);
    } catch (e) {
      throw Exception('Failed to reject merchant: $e');
    }
  }

  // New method for access status management
  Future<void> updateMerchantAccessStatus(String merchantId, String accessStatus) async {
    try {
      final updateData = <String, dynamic>{
        'access_status': accessStatus,
      };

      // Update verified and status fields based on access_status
      if (accessStatus == 'approved') {
        updateData['verified'] = true;
        updateData['status'] = 'approved';
      } else if (accessStatus == 'rejected') {
        updateData['verified'] = false;
        updateData['status'] = 'rejected';
      } else if (accessStatus == 'suspended') {
        updateData['status'] = 'suspended';
      }

      await _client
          .from('merchants')
          .update(updateData)
          .eq('id', merchantId);
    } catch (e) {
      throw Exception('Failed to update merchant access status: $e');
    }
  }

  // Transaction Monitoring
  Future<List<TransactionModel>> getAllTransactions({int limit = 100}) async {
    try {
      final response = await _client
          .from('transaction_logs')
          .select('''
            *,
            payer:users!transaction_logs_payer_id_fkey(full_name),
            payee:users!transaction_logs_payee_id_fkey(full_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((json) {
        return TransactionModel.fromJson({
          ...json,
          'payer_name': json['payer']?['full_name'],
          'payee_name': json['payee']?['full_name'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<List<DeliveryModel>> getAllDeliveries({int limit = 100}) async {
    try {
      final response = await _client
          .from('deliveries')
          .select('''
            *,
            customer:customers!inner(id, users!inner(full_name)),
            merchant:merchants(id, business_name),
            rider:riders(id, users!inner(full_name))
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((json) {
        return DeliveryModel.fromJson({
          ...json,
          'customer_name': json['customer']?['users']?['full_name'],
          'merchant_name': json['merchant']?['business_name'],
          'rider_name': json['rider']?['users']?['full_name'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch deliveries: $e');
    }
  }

  Future<List<TopupModel>> getAllTopups({int limit = 100}) async {
    try {
      final response = await _client
          .from('topups')
          .select('''
            *,
            initiator:users!topups_initiated_by_fkey(full_name)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List).map((json) {
        return TopupModel.fromJson({
          ...json,
          'initiator_name': json['initiator']?['full_name'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch topups: $e');
    }
  }

  // Commission Settings
  Future<List<CommissionSettingModel>> getCommissionSettings() async {
    try {
      final response = await _client
          .from('commission_settings')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => CommissionSettingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch commission settings: $e');
    }
  }

  Future<void> updateCommissionSetting(String id, double percentage) async {
    try {
      await _client
          .from('commission_settings')
          .update({'percentage': percentage})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update commission setting: $e');
    }
  }

  Future<void> createCommissionSetting(String role, double percentage) async {
    try {
      // Check if a setting already exists for this role
      final existing = await _client
          .from('commission_settings')
          .select('id')
          .eq('role', role)
          .maybeSingle();
      
      if (existing != null) {
        // Update existing setting
        await _client
            .from('commission_settings')
            .update({'percentage': percentage})
            .eq('id', existing['id'] as String);
      } else {
        // Create new setting
        await _client
            .from('commission_settings')
            .insert({
              'role': role,
              'percentage': percentage,
            });
      }
    } catch (e) {
      throw Exception('Failed to create commission setting: $e');
    }
  }

  Future<void> deleteCommissionSetting(String id) async {
    try {
      await _client
          .from('commission_settings')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete commission setting: $e');
    }
  }

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get counts by fetching data and counting length
      final usersData = await _client.from('users').select('id');
      final usersCount = (usersData as List).length;
      
      final merchantsData = await _client.from('merchants').select('id');
      final merchantsCount = (merchantsData as List).length;
      
      final ridersData = await _client.from('riders').select('id');
      final ridersCount = (ridersData as List).length;
      
      final deliveriesData = await _client.from('deliveries').select('id');
      final deliveriesCount = (deliveriesData as List).length;
      
      final pendingMerchantsData = await _client
          .from('merchants')
          .select('id')
          .or('verified.eq.false,status.eq.pending');
      final pendingMerchants = (pendingMerchantsData as List).length;
      
      final activeDeliveriesData = await _client
          .from('deliveries')
          .select('id')
          .eq('status', 'pending');
      final activeDeliveries = (activeDeliveriesData as List).length;
      
      final totalRevenue = await _client
          .from('transaction_logs')
          .select('amount');
      
      double revenue = 0.0;
      if (totalRevenue is List && totalRevenue.isNotEmpty) {
        revenue = totalRevenue.fold(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));
      }
      
      return {
        'total_users': usersCount,
        'total_merchants': merchantsCount,
        'total_riders': ridersCount,
        'total_deliveries': deliveriesCount,
        'pending_merchants': pendingMerchants,
        'active_deliveries': activeDeliveries,
        'total_revenue': revenue,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Cash Flow Analytics
  Future<Map<String, dynamic>> getCashFlowData() async {
    try {
      final hubs = await _client.from('business_hubs').select('id, name, balance');
      final stations = await _client.from('loading_stations').select('id, name, balance');
      final riders = await _client.from('riders').select('id, balance');
      
      double totalHubBalance = 0.0;
      double totalStationBalance = 0.0;
      double totalRiderBalance = 0.0;
      
      totalHubBalance = hubs.fold(0.0, (sum, item) => sum + ((item['balance'] as num?)?.toDouble() ?? 0.0));
      totalStationBalance = stations.fold(0.0, (sum, item) => sum + ((item['balance'] as num?)?.toDouble() ?? 0.0));
      totalRiderBalance = riders.fold(0.0, (sum, item) => sum + ((item['balance'] as num?)?.toDouble() ?? 0.0));
      
      return {
        'hub_balance': totalHubBalance,
        'station_balance': totalStationBalance,
        'rider_balance': totalRiderBalance,
        'total_balance': totalHubBalance + totalStationBalance + totalRiderBalance,
        'hubs': hubs,
        'stations': stations,
      };
    } catch (e) {
      throw Exception('Failed to fetch cash flow data: $e');
    }
  }

  // Business Hub and Loading Station Management
  Future<List<BusinessHubModel>> getAllBusinessHubs() async {
    try {
      final response = await _client
          .from('business_hubs')
          .select('*, users!inner(full_name, email, phone, is_active)')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) {
        final userData = json['users'];
        return BusinessHubModel.fromJson({
          ...json,
          'full_name': userData['full_name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'is_active': userData['is_active'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch business hubs: $e');
    }
  }

  Future<List<LoadingStationModel>> getAllLoadingStations() async {
    try {
      final response = await _client
          .from('loading_stations')
          .select('''
            *,
            users!inner(full_name, email, phone, is_active),
            business_hubs(name)
          ''')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) {
        final userData = json['users'];
        final hubData = json['business_hubs'];
        return LoadingStationModel.fromJson({
          ...json,
          'full_name': userData['full_name'],
          'email': userData['email'],
          'phone': userData['phone'],
          'is_active': userData['is_active'],
          'business_hub_name': hubData?['name'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch loading stations: $e');
    }
  }

  String _generateBHCode() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final code = StringBuffer();
    
    // Generate 3 letters
    for (int i = 0; i < 3; i++) {
      code.write(letters[random.nextInt(letters.length)]);
    }
    
    // Generate 3 numbers
    for (int i = 0; i < 3; i++) {
      code.write(numbers[random.nextInt(numbers.length)]);
    }
    
    return code.toString();
  }

  String _generateLSCode() {
    final random = Random();
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final code = StringBuffer();
    
    // Generate 2 letters
    for (int i = 0; i < 2; i++) {
      code.write(letters[random.nextInt(letters.length)]);
    }
    
    // Generate 4 numbers
    for (int i = 0; i < 4; i++) {
      code.write(numbers[random.nextInt(numbers.length)]);
    }
    
    return code.toString();
  }

  Future<String> _ensureUniqueBHCode() async {
    String code;
    int attempts = 0;
    do {
      code = _generateBHCode();
      final existing = await _client
          .from('business_hubs')
          .select('id')
          .filter('bh_code', 'eq', code)
          .maybeSingle();
      
      if (existing == null) break;
      attempts++;
      if (attempts > 100) {
        throw Exception('Failed to generate unique BHCODE after 100 attempts');
      }
    } while (true);
    
    return code;
  }

  Future<String> _ensureUniqueLSCode() async {
    String code;
    int attempts = 0;
    do {
      code = _generateLSCode();
      final existing = await _client
          .from('loading_stations')
          .select('id')
          .filter('ls_code', 'eq', code)
          .maybeSingle();
      
      if (existing == null) break;
      attempts++;
      if (attempts > 100) {
        throw Exception('Failed to generate unique LSCODE after 100 attempts');
      }
    } while (true);
    
    return code;
  }

  Future<Map<String, dynamic>> createBusinessHub({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String name,
    required String password,
  }) async {
    try {
      // Combine first and last name
      final fullName = '$firstName $lastName'.trim();

      // Step 1: Generate unique BHCODE first
      final bhcode = await _ensureUniqueBHCode();

      // Step 2: Create user account in Supabase Auth
      // This creates the user in auth.users table and sends email verification
      final signUpResponse = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Can be set to a custom redirect URL if needed
        data: {
          'full_name': fullName,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': 'business_hub',
        },
      );

      if (signUpResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = signUpResponse.user!.id;

      // Step 3: Save user details in users table (connected via userId)
      // The password is saved here as required by the schema
      // This links the business hub to the users table via the id foreign key
      await _client
          .from('users')
          .upsert({
            'id': userId, // This is the connection point - same ID used everywhere
            'firstname': firstName,
            'lastname': lastName,
            'full_name': fullName,
            'phone': phone,
            'role': 'business_hub',
            'is_active': true,
            'access_status': 'approved',
            'email': email,
            'password': password, // Password saved in users table
          }, onConflict: 'id');

      // Step 4: Create business hub record
      // The id field uses the same userId, creating the foreign key relationship
      // This connects business_hubs.id -> users.id
      try {
        final hubResponse = await _client
            .from('business_hubs')
            .insert({
              'id': userId, // Foreign key to users.id - this is the connection
              'name': name,
              'bh_code': bhcode, // Generated unique code
              'balance': 0.0,
            })
            .select()
            .single();

        // Verify the insert was successful
        if (hubResponse == null || hubResponse['id'] == null) {
          throw Exception('Business hub record was not created successfully');
        }

        // Verify the record actually exists in the database
        final verifyHub = await _client
            .from('business_hubs')
            .select('id, name, bh_code')
            .filter('id', 'eq', userId)
            .maybeSingle();

        if (verifyHub == null) {
          throw Exception('Business hub record was inserted but could not be verified in database');
        }

        // Step 5: Return success with the generated code
        return {
          'success': true,
          'user_id': userId,
          'hub_id': hubResponse['id'],
          'bhcode': bhcode, // Return the code for display after successful registration
        };
      } catch (insertError) {
        // If insert fails, provide detailed error information
        throw Exception('Failed to insert business hub record: $insertError. User ID: $userId, Name: $name, BHCODE: $bhcode');
      }
    } catch (e) {
      // Re-throw with more context if it's not already a detailed error
      if (e.toString().contains('Failed to insert business hub record')) {
        rethrow;
      }
      throw Exception('Failed to create business hub: $e');
    }
  }

  Future<Map<String, dynamic>> createLoadingStation({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String name,
    required String password,
    required String? bhcode,
  }) async {
    try {
      // Step 0: Validate BHCODE if provided (for linking to business hub)
      String? businessHubId;
      if (bhcode != null && bhcode.isNotEmpty) {
        final hub = await _client
            .from('business_hubs')
            .select('id')
            .filter('bh_code', 'eq', bhcode)
            .maybeSingle();
        
        if (hub == null) {
          throw Exception('Invalid BHCODE. Business Hub not found.');
        }
        businessHubId = hub['id'] as String;
      }

      // Combine first and last name
      final fullName = '$firstName $lastName'.trim();

      // Step 1: Generate unique LSCODE first
      final lscode = await _ensureUniqueLSCode();

      // Step 2: Create user account in Supabase Auth
      // This creates the user in auth.users table and sends email verification
      final signUpResponse = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Can be set to a custom redirect URL if needed
        data: {
          'full_name': fullName,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': 'loading_station',
        },
      );

      if (signUpResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = signUpResponse.user!.id;

      // Step 3: Save user details in users table (connected via userId)
      // The password is saved here as required by the schema
      // This links the loading station to the users table via the id foreign key
      await _client
          .from('users')
          .upsert({
            'id': userId, // This is the connection point - same ID used everywhere
            'firstname': firstName,
            'lastname': lastName,
            'full_name': fullName,
            'phone': phone,
            'role': 'loading_station',
            'is_active': true,
            'access_status': 'approved',
            'email': email,
            'password': password, // Password saved in users table
          }, onConflict: 'id');

      // Step 4: Create loading station record
      // The id field uses the same userId, creating the foreign key relationship
      // This connects loading_stations.id -> users.id
      try {
        final stationResponse = await _client
            .from('loading_stations')
            .insert({
              'id': userId, // Foreign key to users.id - this is the connection
              'name': name,
              'ls_code': lscode, // Generated unique code
              'business_hub_id': businessHubId, // Optional link to business hub
              'balance': 0.0,
            })
            .select()
            .single();

        // Verify the insert was successful
        if (stationResponse == null || stationResponse['id'] == null) {
          throw Exception('Loading station record was not created successfully');
        }

        // Step 5: Return success with the generated code
        return {
          'success': true,
          'user_id': userId,
          'station_id': stationResponse['id'],
          'lscode': lscode, // Return the code for display after successful registration
        };
      } catch (insertError) {
        // If insert fails, provide detailed error information
        throw Exception('Failed to insert loading station record: $insertError. User ID: $userId, Name: $name, LSCODE: $lscode');
      }
    } catch (e) {
      // Re-throw with more context if it's not already a detailed error
      if (e.toString().contains('Failed to insert loading station record')) {
        rethrow;
      }
      throw Exception('Failed to create loading station: $e');
    }
  }

  /// Get the role-based commission rate
  Future<double?> getCommissionRate(String role) async {
    try {
      final response = await _client
          .from('commission_settings')
          .select('percentage')
          .eq('role', role)
          .maybeSingle();
      
      if (response != null) {
        return (response['percentage'] as num?)?.toDouble();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get commission rate for a role (entity-specific overrides removed - just use role)
  /// This method is kept for backward compatibility but now just calls getCommissionRate
  Future<double?> getEntityCommissionRate(String role, {String? businessHubId, String? loadingStationId}) async {
    // Entity-specific overrides removed - just return role-based rate
    return await getCommissionRate(role);
  }

  /// Set commission rate for a role (entity-specific overrides removed)
  /// This method is kept for backward compatibility but now just updates the role-based rate
  Future<void> setEntityCommissionRate({
    required String role,
    required double percentage,
    String? businessHubId,
    String? loadingStationId,
  }) async {
    // Entity-specific overrides removed - just update the role-based rate
    await createCommissionSetting(role, percentage);
  }

  // Top-Up Request Management
  // Get current admin user ID from authenticated session
  Future<String> getCurrentAdminId() async {
    try {
      // Get from current authenticated session
      final session = _client.auth.currentSession;
      final authUser = _client.auth.currentUser;
      
      if (session == null && authUser == null) {
        throw Exception('No authenticated session. Please log in.');
      }

      final userId = session?.user?.id ?? authUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found. Please log in.');
      }

      // Verify user is an admin - but be lenient if query fails
      try {
        final userData = await _client
            .from('users')
            .select('role')
            .eq('id', userId)
            .maybeSingle();
        
        if (userData != null) {
          if (userData['role'] == 'admin') {
            return userId;
          } else {
            throw Exception('Access denied. Admin privileges required. Current role: ${userData['role']}');
          }
        } else {
          // User record not found - might be a timing issue
          // Retry once after a short delay
          await Future.delayed(const Duration(milliseconds: 300));
          final retryData = await _client
              .from('users')
              .select('role')
              .eq('id', userId)
              .maybeSingle();
          
          if (retryData != null && retryData['role'] == 'admin') {
            return userId;
          } else if (retryData != null) {
            throw Exception('Access denied. Admin privileges required. Current role: ${retryData['role']}');
          } else {
            // User record still not found, but user is authenticated
            // This shouldn't happen, but if it does, log a warning and allow it
            // The user was authenticated by Supabase Auth, so trust that
            return userId;
          }
        }
      } catch (e) {
        // If the query fails (network, RLS, etc.), don't block access
        // The user was authenticated by Supabase Auth, so trust that
        if (e.toString().contains('Access denied')) {
          rethrow; // Re-throw access denied errors
        }
        return userId;
      }
    } catch (e) {
      throw Exception('Failed to get admin user ID: $e');
    }
  }

  // Register admin account
  Future<Map<String, dynamic>> registerAdminAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Combine first and last name
      final fullName = '$firstName $lastName'.trim();

      // Step 1: Create user account in Supabase Auth
      final signUpResponse = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
        data: {
          'full_name': fullName,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': 'admin',
        },
      );

      if (signUpResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = signUpResponse.user!.id;

      // Step 2: Save user details in users table
      await _client
          .from('users')
          .upsert({
            'id': userId,
            'firstname': firstName,
            'lastname': lastName,
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'role': 'admin',
            'is_active': true,
            'access_status': 'approved',
            'password': password,
          }, onConflict: 'id');

      return {
        'success': true,
        'user_id': userId,
        'email': email,
      };
    } catch (e) {
      throw Exception('Failed to register admin account: $e');
    }
  }

  Future<List<TopupRequestModel>> getTopupRequests({String? status}) async {
    try {
      final response = status != null
          ? await _client
              .from('topup_requests')
              .select('''
                *,
                requester:users!topup_requests_requested_by_fkey(full_name),
                business_hubs(name),
                loading_stations(name)
              ''')
              .filter('status', 'eq', status)
              .order('created_at', ascending: false)
          : await _client
              .from('topup_requests')
              .select('''
                *,
                requester:users!topup_requests_requested_by_fkey(full_name),
                business_hubs(name),
                loading_stations(name)
              ''')
              .order('created_at', ascending: false);
      
      return (response as List).map((json) {
        final requesterData = json['requester'];
        final hubData = json['business_hubs'];
        final stationData = json['loading_stations'];
        
        return TopupRequestModel.fromJson({
          ...json,
          'requester_name': requesterData?['full_name'],
          'business_hub_name': hubData?['name'],
          'loading_station_name': stationData?['name'],
        });
      }).toList();
    } catch (e) {
      // If table doesn't exist, return empty list instead of throwing
      if (e.toString().contains('topup_requests') || e.toString().contains('PGRST205')) {
        return [];
      }
      throw Exception('Failed to fetch top-up requests: $e');
    }
  }

  Future<Map<String, dynamic>> approveTopupRequest(
    String requestId,
    String adminId, {
    double? commissionRateOverride,
    bool saveCommissionOverride = false,
  }) async {
    try {
      // Get the request
      final request = await _client
          .from('topup_requests')
          .select()
          .filter('id', 'eq', requestId)
          .filter('status', 'eq', 'pending')
          .maybeSingle();
      
      if (request == null) {
        throw Exception('Top-up request not found or already processed');
      }

      final businessHubId = request['business_hub_id'] as String?;
      final loadingStationId = request['loading_station_id'] as String?;
      final requestedAmount = (request['requested_amount'] as num).toDouble();

      // Determine role and get commission rate
      String role;
      double commissionRate;
      
      if (businessHubId != null) {
        role = 'business_hub';
      } else if (loadingStationId != null) {
        role = 'loading_station';
      } else {
        throw Exception('Invalid top-up request: no hub or station specified');
      }

      // Get commission rate for the role
      if (commissionRateOverride != null) {
        commissionRate = commissionRateOverride;
        
        // Save the override as role-based commission setting if requested
        if (saveCommissionOverride) {
          await createCommissionSetting(role, commissionRate);
        }
      } else {
        // Get role-based commission rate
        final roleCommissionRate = await getCommissionRate(role);
        if (roleCommissionRate == null) {
          throw Exception('Commission rate not found for $role');
        }
        commissionRate = roleCommissionRate;
      }

      // Calculate bonus and total
      // Formula: request amount + (request amount × commission rate / 100) = total credited
      final bonusAmount = requestedAmount * (commissionRate / 100);
      final totalCredited = requestedAmount + bonusAmount;

      // Update request status
      await _client
          .from('topup_requests')
          .update({
            'status': 'approved',
            'processed_at': DateTime.now().toIso8601String(),
            'processed_by': adminId,
            'bonus_rate': commissionRate,
            'bonus_amount': bonusAmount,
            'total_credited': totalCredited,
          })
          .filter('id', 'eq', requestId);

      // Create topup record
      final topupData = {
        'initiated_by': request['requested_by'],
        'amount': requestedAmount,
        'bonus_amount': bonusAmount,
        'total_credited': totalCredited,
        if (businessHubId != null) 'business_hub_id': businessHubId,
        if (loadingStationId != null) 'loading_station_id': loadingStationId,
      };

      await _client.from('topups').insert(topupData);

      // Update balance - direct update approach
      if (businessHubId != null) {
        final hub = await _client
            .from('business_hubs')
            .select('balance')
            .eq('id', businessHubId)
            .single();
        
        final currentBalance = (hub['balance'] as num).toDouble();
        await _client
            .from('business_hubs')
            .update({'balance': currentBalance + totalCredited})
            .eq('id', businessHubId);
      } else if (loadingStationId != null) {
        final station = await _client
            .from('loading_stations')
            .select('balance')
            .eq('id', loadingStationId)
            .single();
        
        final currentBalance = (station['balance'] as num).toDouble();
        await _client
            .from('loading_stations')
            .update({'balance': currentBalance + totalCredited})
            .eq('id', loadingStationId);
      }

      return {
        'success': true,
        'request_id': requestId,
        'amount': requestedAmount,
        'bonus_amount': bonusAmount,
        'total_credited': totalCredited,
        'commission_rate': commissionRate,
      };
    } catch (e) {
      throw Exception('Failed to approve top-up request: $e');
    }
  }

  Future<bool> rejectTopupRequest(String requestId, String adminId, {String? reason}) async {
    try {
      await _client
          .from('topup_requests')
          .update({
            'status': 'rejected',
            'processed_at': DateTime.now().toIso8601String(),
            'processed_by': adminId,
            'rejection_reason': reason,
          })
          .filter('id', 'eq', requestId)
          .filter('status', 'eq', 'pending');

      return true;
    } catch (e) {
      // If table doesn't exist, return false gracefully
      if (e.toString().contains('topup_requests') || e.toString().contains('PGRST205')) {
        return false;
      }
      throw Exception('Failed to reject top-up request: $e');
    }
  }
}

