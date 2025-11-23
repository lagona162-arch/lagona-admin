import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/merchant_model.dart';
import '../models/rider_model.dart';
import '../models/transaction_model.dart';
import '../models/delivery_model.dart';
import '../models/commission_setting_model.dart';
import '../models/topup_model.dart';
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
      await _client
          .from('commission_settings')
          .insert({
            'role': role,
            'percentage': percentage,
          });
    } catch (e) {
      throw Exception('Failed to create commission setting: $e');
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
}

