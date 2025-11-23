# Admin Features Implementation Guide

## Overview
This document outlines all admin-specific features implemented in the Lagona Admin Panel, mapped to the original EPIC requirements.

---

## EPIC 1: User Registration and Hierarchy Setup

### Feature 1.1 – Multi-Role Registration System

#### ✅ Merchant Registration Review
**Screen**: Merchants Screen (`/merchants`)

**Capabilities**:
- View all merchant registration requests
- Filter by status (Verified, Pending, Rejected)
- View business documents:
  - DTI Number
  - Mayor's Permit
  - Business Address
  - GCash QR Code
- **Approve merchants**: Click ✅ icon → Sets `verified = true`, `status = 'approved'`
- **Reject merchants**: Click ❌ icon → Sets `verified = false`, `status = 'rejected'`
- View detailed merchant information

**Database Impact**:
```sql
-- Approve
UPDATE merchants SET verified = true, status = 'approved' WHERE id = ?;

-- Reject
UPDATE merchants SET verified = false, status = 'rejected' WHERE id = ?;
```

#### ✅ Rider Registration Review
**Screen**: Riders Screen (`/riders`)

**Capabilities**:
- View all registered riders
- Monitor rider information:
  - Plate Number
  - Vehicle Type
  - Balance
  - Commission Rate
  - Current Status
- Filter by status (Available, Busy, Offline)
- View rider details

**Note**: Rider approval can be implemented via the Users screen by managing their active status.

#### ✅ Account Blacklist & Suspension
**Screen**: Users Screen (`/users`)

**Capabilities**:
- **Suspend accounts**: Click 🚫 icon → Sets `is_active = false`
- **Activate accounts**: Click ✅ icon → Sets `is_active = true`
- Filter users by role
- Search by name or email
- View all user details

**Database Impact**:
```sql
-- Suspend
UPDATE users SET is_active = false WHERE id = ?;

-- Activate
UPDATE users SET is_active = true WHERE id = ?;
```

### Feature 1.2 – Hierarchy Initialization Codes

**Monitoring Capabilities**:
- View Business Hub Codes (BHCODE) in Dashboard
- View Loading Station Codes (LSCODE) in Dashboard
- Monitor hierarchy relationships
- Track merchants under loading stations

---

## EPIC 2: Dynamic Commission and Top-Up System

### Feature 2.1 – Commission and Fee Management

#### ✅ Commission Settings Management
**Screen**: Commission Settings Screen (`/commission-settings`)

**Capabilities**:
- View all commission percentages by role:
  - Business Hub
  - Loading Station
  - Rider
  - Merchant
  - Shareholder
- **Add new commission settings**: Click "Add Setting" button
- **Update existing rates**: Click edit icon → Modify percentage
- Visual cards with role-based color coding

**Database Operations**:
```sql
-- Create
INSERT INTO commission_settings (role, percentage) VALUES (?, ?);

-- Update
UPDATE commission_settings SET percentage = ? WHERE id = ?;
```

#### ✅ Commission Visibility
**Screens**: Multiple

**Capabilities**:
- View Business Hub commission share in Dashboard
- View Loading Station bonuses in Dashboard
- Track Rider commission rates in Riders Screen
- Monitor delivery fee breakdowns in Deliveries Screen

### Feature 2.2 – Top-Up Flow Management

#### ✅ Top-Up Monitoring
**Screen**: Top-Ups Screen (`/topups`)

**Capabilities**:
- View all top-up transactions
- Monitor:
  - Initiator
  - Base Amount
  - Bonus Amount
  - Total Credited
  - Timestamp
- Search by initiator
- Track bonus calculations
- Audit trail for all top-ups

**Example**:
```
Business Hub tops up ₱5,000
Bonus rate: 50%
Bonus: ₱2,500
Total Credited: ₱7,500
```

---

## EPIC 6: Admin Dashboard and Controls

### Feature 6.1 – Cash Flow and Transaction Monitoring

#### ✅ Dashboard Overview
**Screen**: Dashboard Screen (`/`)

**Statistics Displayed**:
- Total Users
- Total Merchants
- Total Riders
- Total Deliveries
- Pending Merchants
- Active Deliveries
- Total Revenue
- System Balance

**Cash Flow Breakdown**:
- Business Hubs Balance
- Loading Stations Balance
- Riders Balance
- Total System Balance

#### ✅ Transaction Monitoring
**Screen**: Transactions Screen (`/transactions`)

**Capabilities**:
- View all financial transactions
- Monitor:
  - Transaction ID
  - Payer
  - Payee
  - Amount
  - Description
  - Timestamp
- Search by payer or payee
- Color-coded amounts (positive/negative)
- Export functionality (placeholder)

**Data Source**:
```sql
SELECT t.*, 
       payer.full_name as payer_name,
       payee.full_name as payee_name
FROM transaction_logs t
LEFT JOIN users payer ON t.payer_id = payer.id
LEFT JOIN users payee ON t.payee_id = payee.id
ORDER BY t.created_at DESC;
```

#### ✅ Delivery Monitoring
**Screen**: Deliveries Screen (`/deliveries`)

**Capabilities**:
- Track all deliveries (Pabili & Padala)
- Filter by:
  - Type (Pabili, Padala)
  - Status (Pending, Accepted, In Progress, Completed, Cancelled)
- View delivery details:
  - Customer
  - Merchant
  - Rider
  - Delivery Fee
  - Distance
  - Commission breakdown
- Status-based color coding

### Feature 6.2 – Admin Overrides and Account Management

#### ✅ Account Suspension
**Screen**: Users Screen

**Actions**:
- Suspend user accounts
- Activate suspended accounts
- Blacklist functionality through is_active flag
- Confirmation dialogs for all actions

#### ✅ Merchant Approval Override
**Screen**: Merchants Screen

**Actions**:
- Approve pending merchants
- Reject merchant applications
- Re-approve rejected merchants (manual intervention)
- View verification status

#### ✅ Transaction Corrections (Manual)
**Implementation**: Through database direct access

**Note**: UI for manual transaction corrections can be added as an enhancement. Current implementation allows viewing all transactions for audit purposes.

---

## Navigation Structure

```
Lagona Admin Panel
├── Dashboard (/)
│   ├── Statistics Cards
│   ├── Cash Flow Breakdown
│   └── Quick Actions
│
├── Users (/users)
│   ├── User List with Filters
│   ├── Suspend/Activate Actions
│   └── Role-based Filtering
│
├── Merchants (/merchants)
│   ├── Merchant List
│   ├── Approve/Reject Actions
│   ├── Status Filtering
│   └── Document Viewing
│
├── Riders (/riders)
│   ├── Rider List
│   ├── Status Monitoring
│   ├── Balance Tracking
│   └── Commission Rates
│
├── Transactions (/transactions)
│   ├── Transaction List
│   ├── Search & Filter
│   └── Export (Coming Soon)
│
├── Deliveries (/deliveries)
│   ├── Delivery List
│   ├── Type & Status Filters
│   └── Commission Breakdown
│
├── Top-Ups (/topups)
│   ├── Top-up History
│   ├── Bonus Calculations
│   └── Audit Trail
│
└── Commission (/commission-settings)
    ├── Commission Rates
    ├── Add New Setting
    └── Edit Existing Rates
```

---

## Key Admin Workflows

### 1. Approve a New Merchant
```
1. Navigate to Merchants screen
2. Filter by "Pending" status
3. Click on merchant row to view details
4. Review documents (DTI, Mayor's Permit)
5. Click ✅ Approve button
6. Confirm in dialog
7. Merchant status updated to "Verified"
```

### 2. Suspend a Problematic User
```
1. Navigate to Users screen
2. Search for user by name/email
3. Click 🚫 icon next to user
4. Confirm suspension
5. User's is_active set to false
6. User cannot access system
```

### 3. Update Commission Rates
```
1. Navigate to Commission Settings
2. Find role card (e.g., Rider)
3. Click Edit icon
4. Enter new percentage
5. Click Update
6. New rate applied to future transactions
```

### 4. Monitor Cash Flow
```
1. Open Dashboard
2. View "Cash Flow Breakdown" section
3. See balances for:
   - Business Hubs
   - Loading Stations
   - Riders
4. Total system balance displayed
```

### 5. Track Deliveries
```
1. Navigate to Deliveries screen
2. Filter by type (Pabili/Padala)
3. Filter by status
4. View delivery details
5. Monitor commission distribution
```

---

## Data Refresh Strategy

All screens implement real-time data refresh:
- **Manual Refresh**: Click "Refresh" button on any screen
- **Auto-refresh on Load**: Data loads when screen is accessed
- **State Management**: Provider pattern ensures data consistency

---

## Security Considerations

### Current Implementation
- ✅ Supabase Row Level Security (RLS) ready
- ✅ Confirmation dialogs for critical actions
- ✅ Role-based data filtering
- ✅ Audit trail through transaction logs

### Recommended Enhancements
- 🔲 Add authentication system
- 🔲 Implement admin role verification
- 🔲 Add activity logging for admin actions
- 🔲 Two-factor authentication
- 🔲 Session management
- 🔲 IP whitelisting

---

## API Endpoints Used

### Supabase Queries

```dart
// Users
client.from('users').select().order('created_at', ascending: false)

// Merchants with User Info
client.from('merchants')
  .select('*, users!inner(full_name, email, phone, is_active)')
  .order('created_at', ascending: false)

// Riders with User Info
client.from('riders')
  .select('*, users!inner(full_name, email, phone, is_active)')
  .order('created_at', ascending: false)

// Transactions
client.from('transaction_logs')
  .select('''
    *,
    payer:users!transaction_logs_payer_id_fkey(full_name),
    payee:users!transaction_logs_payee_id_fkey(full_name)
  ''')
  .order('created_at', ascending: false)

// Deliveries
client.from('deliveries')
  .select('''
    *,
    customer:customers!inner(id, users!inner(full_name)),
    merchant:merchants(id, business_name),
    rider:riders(id, users!inner(full_name))
  ''')
  .order('created_at', ascending: false)

// Commission Settings
client.from('commission_settings').select()

// Top-ups
client.from('topups')
  .select('*, initiator:users!topups_initiated_by_fkey(full_name)')
  .order('created_at', ascending: false)

// Dashboard Stats
client.from('users').select('id', count: CountOption.exact, head: true)
client.from('merchants').select('id', count: CountOption.exact, head: true)
// ... similar for other entities

// Cash Flow
client.from('business_hubs').select('id, name, balance')
client.from('loading_stations').select('id, name, balance')
client.from('riders').select('id, balance')
```

---

## Performance Considerations

### Current Optimizations
- Pagination support ready (limit parameter)
- Efficient joins in queries
- Card-based lazy loading
- Search/filter on client side for small datasets

### Recommended Enhancements
- Implement server-side pagination
- Add data caching layer
- Implement virtual scrolling for large tables
- Add loading skeletons
- Optimize database indexes

---

## Testing Checklist

### User Management
- [ ] View all users
- [ ] Search users
- [ ] Filter by role
- [ ] Suspend user
- [ ] Activate user

### Merchant Management
- [ ] View pending merchants
- [ ] Approve merchant
- [ ] Reject merchant
- [ ] View merchant details

### Rider Management
- [ ] View all riders
- [ ] Filter by status
- [ ] View rider details

### Transactions
- [ ] View transaction list
- [ ] Search transactions
- [ ] Export data

### Deliveries
- [ ] View deliveries
- [ ] Filter by type
- [ ] Filter by status

### Commission Settings
- [ ] View settings
- [ ] Add new setting
- [ ] Update existing setting

### Dashboard
- [ ] View statistics
- [ ] View cash flow
- [ ] Quick actions work

---

## Future Enhancement Ideas

### Short-term
1. Add authentication/login system
2. Implement CSV export for reports
3. Add date range filters
4. Real-time updates with Supabase subscriptions
5. Email notifications for actions

### Long-term
1. Advanced analytics dashboard with charts
2. Automated reporting system
3. Mobile app version
4. Multi-tenancy support
5. API rate limiting
6. Backup and restore functionality
7. Automated fraud detection
8. Machine learning for pattern recognition

---

## Conclusion

This admin panel provides comprehensive control over the Lagona delivery system, covering all essential admin tasks from the EPICs. The modular architecture allows for easy expansion and customization as business needs evolve.

