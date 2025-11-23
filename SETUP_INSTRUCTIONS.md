# Lagona Admin Setup Instructions

## Quick Start Guide

Follow these steps to get your Lagona Admin Panel up and running with the new Merchant Access Control system.

---

## Prerequisites

✅ Flutter SDK 3.9.2 or higher installed
✅ Supabase project created
✅ Web browser (Chrome recommended)

---

## Step 1: Database Migration

### Apply the Merchant Access Status Migration

You need to add the `access_status` field to your merchants table. Choose one of these methods:

### Method A: Supabase Dashboard (Easiest)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the contents of `supabase_migrations/add_merchant_access_status.sql`
5. Paste into the SQL editor
6. Click **Run** or press `Ctrl/Cmd + Enter`
7. Verify success message appears

### Method B: Supabase CLI

```bash
# If you have Supabase CLI installed
supabase db push
```

### Method C: Manual SQL

```bash
# Connect to your database
psql -h your-supabase-host.supabase.co -U postgres -d postgres

# Run the migration file
\i supabase_migrations/add_merchant_access_status.sql
```

### Verify Migration

Run this query in SQL Editor to verify:

```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'merchants' AND column_name = 'access_status';
```

You should see:
```
column_name   | data_type | column_default
--------------+-----------+----------------
access_status | text      | 'pending'::text
```

---

## Step 2: Install Dependencies

```bash
cd /Users/markangelosangil/Desktop/lagona_admin
flutter pub get
```

---

## Step 3: Run the Application

### For Development

```bash
flutter run -d chrome
```

The app will open in Chrome browser.

### For Production Build

```bash
flutter build web --release
```

Build output will be in `build/web/` directory.

---

## Step 4: Test the Merchant Access Control

### Create Test Data (Optional)

Run this in Supabase SQL Editor to create test merchants:

```sql
-- Insert test user for merchant 1 (pending)
INSERT INTO users (full_name, email, password, role, phone)
VALUES ('Test Merchant Pending', 'merchant.pending@test.com', 'password123', 'merchant', '09123456789')
RETURNING id;

-- Note the ID returned, then use it here (replace 'USER_ID_HERE')
INSERT INTO merchants (id, business_name, dti_number, mayor_permit, address, verified, access_status)
VALUES ('USER_ID_HERE', 'Pending Store', 'DTI-123456', 'MP-789012', '123 Test St', false, 'pending');

-- Repeat for other statuses (approved, rejected, suspended)
```

### Test Workflow

1. **Navigate to Applications**
   - Click "Applications" in sidebar
   - Or use Dashboard → "Review Applications" button

2. **View Pending Applications**
   - You should see test merchant with "Pending" status
   - Statistics cards should show counts

3. **Approve a Merchant**
   - Click ✅ (Approve) icon
   - Confirm in dialog
   - Verify status changes to "Approved"
   - Check success notification appears

4. **Reject a Merchant**
   - Filter or find a pending merchant
   - Click ❌ (Reject) icon
   - Optionally enter reason
   - Confirm rejection
   - Verify status changes to "Rejected"

5. **Suspend a Merchant**
   - Filter by "Approved"
   - Click 🚫 (Suspend) icon
   - Confirm suspension
   - Verify status changes to "Suspended"

6. **Restore Access**
   - Filter by "Suspended"
   - Click 🔄 (Restore) icon
   - Confirm restoration
   - Verify status back to "Approved"

---

## Step 5: Configure Row Level Security (Recommended)

For production, add these RLS policies in Supabase:

### Go to: Database → Tables → merchants → Policies

**Policy 1: Merchants View Own Profile**
```sql
CREATE POLICY "Merchants can view own profile"
ON merchants FOR SELECT
USING (
  auth.uid() = id 
  AND access_status = 'approved'
);
```

**Policy 2: Approved Merchants Update Profile**
```sql
CREATE POLICY "Approved merchants can update profile"
ON merchants FOR UPDATE
USING (
  auth.uid() = id 
  AND access_status = 'approved'
);
```

**Policy 3: Admins View All**
```sql
CREATE POLICY "Admins can view all merchants"
ON merchants FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);
```

**Policy 4: Admins Update Any**
```sql
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

---

## Navigation Guide

### Main Sections

```
📊 Dashboard               - Overview and statistics
👥 Users                   - All system users
🏪 Merchants              - Merchant list view (read-only)
📋 Applications ⭐ NEW     - Approve/reject merchant applications
🏍️ Riders                 - Rider management
💰 Transactions           - Financial transactions
🚚 Deliveries             - Delivery tracking
💵 Top-Ups                - Top-up monitoring
⚙️ Commission             - Commission settings
```

---

## Features Overview

### Merchant Applications Screen

**Location:** `/merchant-applications`

**Capabilities:**
- ✅ View all merchant applications
- ✅ Filter by status (pending/approved/rejected/suspended)
- ✅ Search by business name or email
- ✅ Approve pending applications
- ✅ Reject pending applications (with reason)
- ✅ Suspend approved merchants
- ✅ Restore suspended merchants
- ✅ View full merchant details
- ✅ Real-time statistics

**Status Flow:**
```
New Application → PENDING
                    ↓
         ┌──────────┴──────────┐
         ↓                     ↓
    APPROVED              REJECTED
         ↓                     ↑
    SUSPENDED ←→ Restore →────┘
```

---

## Troubleshooting

### Issue: "Failed to update merchant access status"

**Solution:**
1. Check Supabase connection in browser console
2. Verify migration was applied successfully
3. Check RLS policies aren't blocking admin access

### Issue: Applications screen is empty

**Solution:**
1. Verify merchants exist in database
2. Check Supabase credentials in `lib/config/supabase_config.dart`
3. Open browser console for error messages
4. Click "Refresh" button

### Issue: Changes not saving

**Solution:**
1. Check network tab in browser developer tools
2. Verify Supabase project is active (not paused)
3. Check database connection
4. Try clearing browser cache

### Issue: Can't see status changes

**Solution:**
1. Click "Refresh" button
2. Hard reload page (Ctrl/Cmd + Shift + R)
3. Check if update was successful in database

---

## Performance Tips

### For Large Datasets

If you have many merchants (>1000):

1. **Enable Pagination**
   - Modify `admin_service.dart`
   - Add limit/offset parameters
   - Implement "Load More" button

2. **Add Server-Side Filtering**
   - Move filtering to database queries
   - Use Supabase `.filter()` methods

3. **Optimize Queries**
   - Create additional indexes
   - Use materialized views for statistics

### Example: Add Pagination

```dart
// In admin_service.dart
Future<List<MerchantModel>> getAllMerchants({
  int limit = 100,
  int offset = 0,
}) async {
  final response = await _client
      .from('merchants')
      .select('*, users!inner(full_name, email, phone, is_active)')
      .range(offset, offset + limit - 1)
      .order('created_at', ascending: false);
  
  // ... rest of code
}
```

---

## Security Checklist

Before going to production:

- [ ] Database migration applied successfully
- [ ] RLS policies configured on merchants table
- [ ] RLS policies configured on users table
- [ ] Admin authentication implemented
- [ ] HTTPS enabled on hosting
- [ ] Environment variables secured
- [ ] Supabase anon key properly restricted
- [ ] Service role key never exposed to client
- [ ] Rate limiting configured
- [ ] Backup strategy in place

---

## Deployment Options

### Option 1: Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
flutter build web --release
firebase deploy
```

### Option 2: Vercel

```bash
npm install -g vercel
flutter build web --release
cd build/web
vercel
```

### Option 3: Netlify

```bash
npm install -g netlify-cli
flutter build web --release
cd build/web
netlify deploy --prod
```

### Option 4: GitHub Pages

```bash
flutter build web --release --base-href "/lagona_admin/"
# Push build/web to gh-pages branch
```

---

## Next Steps

1. **Add Authentication**
   - Implement admin login page
   - Integrate Supabase Auth
   - Add session management

2. **Enable Notifications**
   - Email notifications to merchants
   - Admin notifications for new applications
   - SMS alerts for important status changes

3. **Add Audit Logging**
   - Track who approved/rejected
   - Log all status changes
   - Create admin activity report

4. **Implement Bulk Actions**
   - Select multiple applications
   - Bulk approve/reject
   - Export selected merchants

---

## Support

### Documentation
- **README.md** - General project information
- **ADMIN_FEATURES.md** - Complete feature documentation
- **MERCHANT_ACCESS_CONTROL.md** - Detailed access control guide
- **This File** - Setup and troubleshooting

### Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review browser console for errors
3. Check Supabase logs
4. Verify migration was applied
5. Review RLS policies

---

## Development Notes

### Project Structure

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase credentials
├── models/
│   └── merchant_model.dart           # Updated with access_status
├── services/
│   └── admin_service.dart            # New updateMerchantAccessStatus method
├── providers/
│   └── admin_provider.dart           # State management for access control
├── screens/
│   ├── merchant_applications_screen.dart  # NEW - Main applications screen
│   ├── merchants_screen.dart         # Updated for new status
│   └── dashboard_screen.dart         # Updated with quick action
└── main.dart                          # Updated with new route
```

### Key Files Modified

✏️ `lib/models/merchant_model.dart` - Added accessStatus field
✏️ `lib/services/admin_service.dart` - Added updateMerchantAccessStatus
✏️ `lib/providers/admin_provider.dart` - Added status update provider
✏️ `lib/screens/merchants_screen.dart` - Updated for accessStatus
✏️ `lib/screens/dashboard_screen.dart` - Added quick action button
✏️ `lib/main.dart` - Added new route and navigation item

### New Files Created

🆕 `lib/screens/merchant_applications_screen.dart` - Complete applications UI
🆕 `supabase_migrations/add_merchant_access_status.sql` - Database migration
🆕 `MERCHANT_ACCESS_CONTROL.md` - Feature documentation
🆕 `SETUP_INSTRUCTIONS.md` - This file

---

## Conclusion

You now have a fully functional Merchant Access Control system! 🎉

Merchants cannot access the system until approved, giving you complete control over who can use your platform.

**Quick Access:**
- Applications: Click "Applications" in sidebar
- Dashboard: See pending count in stats
- Quick Action: "Review Applications" button

Happy administrating! 🚀

