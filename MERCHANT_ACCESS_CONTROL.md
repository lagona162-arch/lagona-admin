# Merchant Access Control System

## Overview

The Lagona Admin Panel now includes a comprehensive **Merchant Access Control System** that prevents merchants from accessing the system until their applications are reviewed and approved by administrators.

---

## Key Features

### 1. **Access Status Field**
Merchants now have an `access_status` field with four possible values:

- **`pending`** (default): Initial status for new merchant applications
- **`approved`**: Merchant has been approved and can access the system
- **`rejected`**: Merchant application has been denied
- **`suspended`**: Merchant access has been temporarily revoked

### 2. **Merchant Applications Screen**
A dedicated screen (`/merchant-applications`) for reviewing and managing merchant applications.

**Features:**
- View all merchant applications with filtering
- Statistics dashboard showing counts by status
- Approve/Reject/Suspend actions with confirmations
- Detailed merchant information viewer
- Search functionality
- Status-based filtering

### 3. **Access Control Logic**
```
Merchant can access system ONLY IF:
  - access_status = 'approved' 
  AND 
  - user.is_active = true
```

---

## Database Changes

### Migration Applied

The following changes were made to the `merchants` table:

```sql
-- Add access_status column
ALTER TABLE public.merchants 
ADD COLUMN access_status TEXT DEFAULT 'pending';

-- Add constraint for valid status values
ALTER TABLE public.merchants 
ADD CONSTRAINT merchants_access_status_check 
CHECK (access_status IN ('pending', 'approved', 'rejected', 'suspended'));

-- Create index for faster queries
CREATE INDEX idx_merchants_access_status 
ON public.merchants(access_status);

-- Helper function to check merchant access
CREATE FUNCTION check_merchant_access(merchant_user_id UUID)
RETURNS BOOLEAN
```

**Location:** `/supabase_migrations/add_merchant_access_status.sql`

### How to Apply Migration

1. **Option 1: Using Supabase Dashboard**
   - Go to your Supabase project
   - Navigate to SQL Editor
   - Copy and paste the contents of `supabase_migrations/add_merchant_access_status.sql`
   - Click "Run"

2. **Option 2: Using Supabase CLI**
   ```bash
   supabase db push
   ```

3. **Option 3: Manually via psql**
   ```bash
   psql -h your-supabase-host -U postgres -d postgres -f supabase_migrations/add_merchant_access_status.sql
   ```

---

## Admin Workflows

### Workflow 1: Review New Merchant Application

```
1. Admin receives notification (or checks dashboard)
   └─ "Pending Review: 5 applications"

2. Navigate to Applications screen
   └─ Click "Applications" in sidebar
   └─ Or Dashboard → "Review Applications" quick action

3. Review merchant details
   └─ Business Name
   └─ Owner Information
   └─ DTI Number & Mayor's Permit
   └─ Contact Information
   └─ Application Date

4. Make decision:
   
   APPROVE:
   ├─ Click ✓ (Approve) icon
   ├─ Review confirmation dialog
   ├─ Confirm approval
   └─ Result: access_status → 'approved'
              merchant can now access system
   
   REJECT:
   ├─ Click ✗ (Reject) icon
   ├─ Enter reason for rejection (optional)
   ├─ Confirm rejection
   └─ Result: access_status → 'rejected'
              merchant cannot access system

5. Notification sent to merchant (future enhancement)
```

### Workflow 2: Suspend an Approved Merchant

```
1. Navigate to Applications screen

2. Filter by "Approved" status

3. Find merchant to suspend

4. Click 🚫 (Suspend) icon

5. Confirm suspension
   └─ Result: access_status → 'suspended'
              merchant immediately loses access

6. To restore access:
   └─ Click 🔄 (Restore) icon
   └─ Confirm restoration
   └─ Result: access_status → 'approved'
```

### Workflow 3: Approve Previously Rejected Merchant

```
1. Navigate to Applications screen

2. Filter by "Rejected" status

3. Find merchant to reconsider

4. Click ✓ (Approve) icon

5. Confirm approval
   └─ Result: access_status → 'approved'
              merchant gains access
```

---

## UI Components

### 1. Statistics Cards
Located at the top of the Merchant Applications screen:

```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│ Pending Review  │   Approved      │    Rejected     │   Suspended     │
│      🟠 5       │     ✅ 23       │      ❌ 2       │     🚫 1       │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

### 2. Data Table Columns
- Business Name (with icon)
- Owner
- Email
- Phone
- DTI Number
- Applied On
- Access Status (chip)
- Actions (buttons)

### 3. Status Chips
Visual indicators with color coding:

| Status    | Color  | Icon | Description                     |
|-----------|--------|------|---------------------------------|
| Pending   | Orange | ⏱️   | Awaiting admin review           |
| Approved  | Green  | ✅   | Can access system               |
| Rejected  | Red    | ❌   | Application denied              |
| Suspended | Grey   | 🚫   | Access temporarily revoked      |

### 4. Action Buttons

**For Pending Applications:**
- ✅ Approve - Grant access
- ❌ Reject - Deny access
- 👁️ View Details - See full information

**For Approved Merchants:**
- 🚫 Suspend - Temporarily revoke access
- 👁️ View Details

**For Suspended Merchants:**
- 🔄 Restore - Restore access
- 👁️ View Details

**For Rejected Applications:**
- ✅ Approve - Grant access (reconsideration)
- 👁️ View Details

---

## Navigation

### Sidebar Menu
```
LAGONA ADMIN
├── Dashboard
├── Users
├── Merchants (list view)
├── Applications ← NEW
├── Riders
├── Transactions
├── Deliveries
├── Top-Ups
└── Commission
```

### Routes
- **Merchant Applications**: `/merchant-applications`
- **Merchants List**: `/merchants` (view-only)

---

## API Methods

### AdminService

```dart
// Update merchant access status
Future<void> updateMerchantAccessStatus(String merchantId, String accessStatus)

// Parameters:
//   merchantId: UUID of the merchant
//   accessStatus: 'pending' | 'approved' | 'rejected' | 'suspended'

// Example:
await adminService.updateMerchantAccessStatus(
  'merchant-uuid-here',
  'approved'
);
```

### AdminProvider

```dart
// Provider method with state management
Future<bool> updateMerchantAccessStatus(String merchantId, String accessStatus)

// Returns: true if successful, false if error

// Usage in widget:
final success = await context.read<AdminProvider>()
    .updateMerchantAccessStatus(merchantId, 'approved');

if (success) {
  // Show success message
}
```

---

## Security Implementation

### Row Level Security (RLS) - Recommended Setup

Add these policies to your Supabase `merchants` table:

```sql
-- Policy 1: Merchants can only read their own data
CREATE POLICY "Merchants can view own profile"
ON merchants FOR SELECT
USING (
  auth.uid() = id 
  AND access_status = 'approved'
);

-- Policy 2: Only approved merchants can update their data
CREATE POLICY "Approved merchants can update profile"
ON merchants FOR UPDATE
USING (
  auth.uid() = id 
  AND access_status = 'approved'
);

-- Policy 3: Admins can view all merchants
CREATE POLICY "Admins can view all merchants"
ON merchants FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Policy 4: Admins can update any merchant
CREATE POLICY "Admins can update any merchant"
ON merchants FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);
```

### Backend Validation

For your merchant mobile app, implement this check:

```dart
// Check if merchant can access system
Future<bool> canMerchantAccess(String merchantId) async {
  final result = await supabase
      .from('merchants')
      .select('access_status, users!inner(is_active)')
      .eq('id', merchantId)
      .single();
  
  return result['access_status'] == 'approved' 
      && result['users']['is_active'] == true;
}

// Use before allowing merchant to proceed
if (!await canMerchantAccess(currentMerchantId)) {
  // Show "Pending Approval" or "Access Denied" screen
  return PendingApprovalScreen();
}
```

---

## Testing Checklist

### Admin Panel Tests

- [ ] **View Applications**
  - [ ] Can view all merchant applications
  - [ ] Statistics cards show correct counts
  - [ ] Filtering works (pending/approved/rejected/suspended)
  - [ ] Search functionality works

- [ ] **Approve Merchant**
  - [ ] Approve button visible for pending merchants
  - [ ] Confirmation dialog appears
  - [ ] Status updates to 'approved' after confirmation
  - [ ] Success notification shows
  - [ ] Table refreshes automatically

- [ ] **Reject Merchant**
  - [ ] Reject button visible for pending merchants
  - [ ] Can enter rejection reason
  - [ ] Status updates to 'rejected'
  - [ ] Rejection confirmation works

- [ ] **Suspend Merchant**
  - [ ] Suspend button visible for approved merchants
  - [ ] Status updates to 'suspended'
  - [ ] Merchant loses access immediately

- [ ] **Restore Access**
  - [ ] Restore button visible for suspended merchants
  - [ ] Status updates back to 'approved'
  - [ ] Merchant regains access

- [ ] **View Details**
  - [ ] Full merchant information displays
  - [ ] All fields show correctly
  - [ ] Modal can be closed

### Database Tests

- [ ] **Migration Applied**
  - [ ] `access_status` column exists
  - [ ] Default value is 'pending'
  - [ ] Constraint allows only valid values
  - [ ] Index created successfully

- [ ] **Status Updates**
  - [ ] Can update from pending to approved
  - [ ] Can update from pending to rejected
  - [ ] Can update from approved to suspended
  - [ ] Can update from suspended to approved
  - [ ] Invalid status values rejected

### Integration Tests

- [ ] **Merchant App Access**
  - [ ] Pending merchants cannot access system
  - [ ] Approved merchants can access system
  - [ ] Rejected merchants cannot access system
  - [ ] Suspended merchants lose access immediately
  - [ ] Restored merchants regain access immediately

---

## Error Handling

### Common Scenarios

1. **Network Error During Approval**
   ```
   Error: Failed to update merchant access status
   Action: Show error message, allow retry
   ```

2. **Merchant Not Found**
   ```
   Error: Merchant record not found
   Action: Refresh list, show error notification
   ```

3. **Database Connection Lost**
   ```
   Error: Unable to connect to database
   Action: Show error, provide refresh button
   ```

4. **Invalid Status Value**
   ```
   Error: Invalid access status value
   Action: Log error, prevent update
   ```

---

## Future Enhancements

### Phase 1 - Notifications
- [ ] Email notifications to merchants on approval/rejection
- [ ] SMS notifications for important status changes
- [ ] Admin notifications for new applications
- [ ] Push notifications in merchant mobile app

### Phase 2 - Automation
- [ ] Auto-approve based on criteria
- [ ] Fraud detection checks
- [ ] Document verification API integration
- [ ] Bulk approval/rejection

### Phase 3 - Analytics
- [ ] Application approval rate metrics
- [ ] Average approval time tracking
- [ ] Rejection reason analytics
- [ ] Merchant performance tracking post-approval

### Phase 4 - Workflow
- [ ] Multi-level approval system
- [ ] Comments/notes on applications
- [ ] Application review assignment
- [ ] Scheduled reviews

---

## Troubleshooting

### Issue: Status Not Updating

**Symptoms:** Click approve/reject but status doesn't change

**Solutions:**
1. Check browser console for errors
2. Verify Supabase connection
3. Check RLS policies
4. Ensure merchant ID is valid

### Issue: Merchant Still Has Access After Rejection

**Symptoms:** Rejected merchant can still access system

**Solutions:**
1. Verify RLS policies on merchants table
2. Check merchant app access control logic
3. Clear merchant app cache/storage
4. Force logout on merchant app

### Issue: Can't See Applications

**Symptoms:** Applications screen is empty

**Solutions:**
1. Check if merchants exist in database
2. Verify Supabase credentials
3. Check browser console for errors
4. Refresh page and retry

---

## Support & Maintenance

### Monitoring
- Monitor approval/rejection rates
- Track average time to approval
- Watch for unusual patterns
- Review suspended merchant cases

### Regular Tasks
- Weekly review of pending applications
- Monthly audit of rejected applications
- Quarterly review of suspended merchants
- Annual policy review

---

## Summary

The Merchant Access Control System provides:

✅ **Controlled Access** - Merchants can't access system until approved
✅ **Admin Control** - Full approval/rejection workflow
✅ **Flexible Management** - Suspend/restore access as needed
✅ **Audit Trail** - Track all status changes
✅ **User-Friendly UI** - Intuitive interface for admins
✅ **Secure** - Database constraints and validation

This system ensures quality control over merchant onboarding while providing administrators with powerful tools to manage access effectively.

