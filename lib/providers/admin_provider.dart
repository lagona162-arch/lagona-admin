import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/merchant_model.dart';
import '../models/rider_model.dart';
import '../models/transaction_model.dart';
import '../models/delivery_model.dart';
import '../models/commission_setting_model.dart';
import '../models/topup_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  String? _error;

  List<UserModel> _users = [];
  List<MerchantModel> _merchants = [];
  List<RiderModel> _riders = [];
  List<TransactionModel> _transactions = [];
  List<DeliveryModel> _deliveries = [];
  List<CommissionSettingModel> _commissionSettings = [];
  List<TopupModel> _topups = [];
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _cashFlowData = {};

  // Cache flags to prevent unnecessary reloads
  bool _usersLoaded = false;
  bool _merchantsLoaded = false;
  bool _ridersLoaded = false;
  bool _transactionsLoaded = false;
  bool _deliveriesLoaded = false;
  bool _commissionSettingsLoaded = false;
  bool _topupsLoaded = false;
  bool _dashboardStatsLoaded = false;
  bool _cashFlowDataLoaded = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<MerchantModel> get merchants => _merchants;
  List<RiderModel> get riders => _riders;
  List<TransactionModel> get transactions => _transactions;
  List<DeliveryModel> get deliveries => _deliveries;
  List<CommissionSettingModel> get commissionSettings => _commissionSettings;
  List<TopupModel> get topups => _topups;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  Map<String, dynamic> get cashFlowData => _cashFlowData;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadDashboardStats({bool forceRefresh = false}) async {
    if (_dashboardStatsLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _dashboardStats = await _adminService.getDashboardStats();
      _dashboardStatsLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (_usersLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _users = await _adminService.getAllUsers();
      _usersLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadMerchants({bool forceRefresh = false}) async {
    if (_merchantsLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _merchants = await _adminService.getAllMerchants();
      _merchantsLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadRiders({bool forceRefresh = false}) async {
    if (_ridersLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      // Fetch all riders in pages to avoid heavy single payloads
      const int pageSize = 200;
      int offset = 0;
      final List<RiderModel> all = [];
      while (true) {
        final page = await _adminService.getAllRiders(limit: pageSize, offset: offset);
        all.addAll(page);
        if (page.length < pageSize) break;
        offset += pageSize;
      }
      _riders = all;
      _ridersLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadTransactions({bool forceRefresh = false}) async {
    if (_transactionsLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _transactions = await _adminService.getAllTransactions();
      _transactionsLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadDeliveries({bool forceRefresh = false}) async {
    if (_deliveriesLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _deliveries = await _adminService.getAllDeliveries();
      _deliveriesLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadCommissionSettings({bool forceRefresh = false}) async {
    if (_commissionSettingsLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _commissionSettings = await _adminService.getCommissionSettings();
      _commissionSettingsLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadTopups({bool forceRefresh = false}) async {
    if (_topupsLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _topups = await _adminService.getAllTopups();
      _topupsLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> loadCashFlowData({bool forceRefresh = false}) async {
    if (_cashFlowDataLoaded && !forceRefresh) return;
    
    try {
      _setLoading(true);
      _setError(null);
      _cashFlowData = await _adminService.getCashFlowData();
      _cashFlowDataLoaded = true;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.updateUserStatus(userId, isActive);
      await loadUsers(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> approveUser(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.approveUser(userId);
      // Refresh affected collections so UI updates immediately
      await Future.wait([
        loadUsers(forceRefresh: true),
        loadRiders(forceRefresh: true),
      ]);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectUser(String userId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.rejectUser(userId);
      // Refresh affected collections so UI updates immediately
      await Future.wait([
        loadUsers(forceRefresh: true),
        loadRiders(forceRefresh: true),
      ]);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> approveMerchant(String merchantId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.approveMerchant(merchantId);
      await loadMerchants(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectMerchant(String merchantId) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.rejectMerchant(merchantId);
      await loadMerchants(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCommissionSetting(String id, double percentage) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.updateCommissionSetting(id, percentage);
      await loadCommissionSettings(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createCommissionSetting(String role, double percentage) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.createCommissionSetting(role, percentage);
      await loadCommissionSettings(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateMerchantAccessStatus(String merchantId, String accessStatus) async {
    try {
      _setLoading(true);
      _setError(null);
      await _adminService.updateMerchantAccessStatus(merchantId, accessStatus);
      await loadMerchants(forceRefresh: true);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}

