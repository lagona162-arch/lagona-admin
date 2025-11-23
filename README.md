# Lagona Admin Panel

A comprehensive Flutter web admin dashboard for managing the Lagona delivery system. This admin panel provides full control over users, merchants, riders, transactions, deliveries, and commission settings.

## Features

### 1. Dashboard Overview
- Real-time statistics and metrics
- Total users, merchants, riders, and deliveries
- Active delivery tracking
- Revenue and cash flow monitoring
- Visual breakdown of balances across business hubs, loading stations, and riders

### 2. User Management
- View all users with role-based filtering
- Suspend/activate user accounts
- Search and filter capabilities
- Detailed user information

### 3. Merchant Management
- Review merchant registration requests
- Approve or reject merchant applications
- View business documents (DTI, Mayor's Permit)
- Monitor merchant verification status
- Blacklist functionality

### 3.1 Merchant Applications (NEW ⭐)
- Dedicated screen for reviewing merchant applications
- **Access Control System**: Merchants cannot access the system until approved
- Four status levels: Pending, Approved, Rejected, Suspended
- Real-time statistics dashboard
- Approve/Reject with confirmation dialogs
- Suspend and restore merchant access
- Detailed application viewer
- Search and filter capabilities

### 4. Rider Management
- View all registered riders
- Monitor rider status (available, busy, offline)
- Track rider balances and commissions
- View vehicle information and plate numbers
- Real-time activity tracking

### 5. Transaction Monitoring
- View all financial transactions
- Track cash flow between users
- Export transaction reports
- Search and filter transactions

### 6. Delivery Monitoring
- Track all deliveries (Pabili and Padala)
- Monitor delivery status in real-time
- View delivery fees and commissions
- Filter by type, status, and date

### 7. Commission Settings
- Manage commission percentages for all roles
- Dynamic fee configuration
- Role-based commission rates:
  - Business Hubs
  - Loading Stations
  - Riders
  - Merchants
  - Shareholders

### 8. Top-Up Management
- Monitor all top-up transactions
- View bonus calculations
- Track credited amounts
- Audit trail for all top-ups

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **Backend**: Supabase
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: 
  - DataTable2 for advanced tables
  - FL Chart for data visualization
  - Material Design 3

## Setup Instructions

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Web browser (Chrome recommended)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd lagona_admin
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Supabase:
The Supabase credentials are already configured in `lib/config/supabase_config.dart`:
- URL: `https://lpcjaxssqvgvgtvwabkv.supabase.co`
- Anon Key: Already configured

4. **Apply Database Migration** (Required for Merchant Access Control):
   
   Go to your Supabase SQL Editor and run the migration file:
   ```
   supabase_migrations/add_merchant_access_status.sql
   ```
   
   This adds the `access_status` field to the merchants table, enabling access control.

5. Run the application:
```bash
flutter run -d chrome
```

Or for production build:
```bash
flutter build web
```

📖 **For detailed setup instructions, see [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)**

## Project Structure

```
lib/
├── config/
│   └── supabase_config.dart        # Supabase configuration
├── models/
│   ├── user_model.dart             # User data model
│   ├── merchant_model.dart         # Merchant data model
│   ├── rider_model.dart            # Rider data model
│   ├── transaction_model.dart      # Transaction data model
│   ├── delivery_model.dart         # Delivery data model
│   ├── commission_setting_model.dart # Commission settings model
│   └── topup_model.dart            # Top-up data model
├── services/
│   ├── supabase_service.dart       # Supabase initialization
│   └── admin_service.dart          # Admin operations service
├── providers/
│   └── admin_provider.dart         # State management
├── screens/
│   ├── dashboard_screen.dart       # Main dashboard
│   ├── users_screen.dart           # User management
│   ├── merchants_screen.dart       # Merchant list view
│   ├── merchant_applications_screen.dart # NEW: Application approvals
│   ├── riders_screen.dart          # Rider management
│   ├── transactions_screen.dart    # Transaction monitoring
│   ├── deliveries_screen.dart      # Delivery tracking
│   ├── commission_settings_screen.dart # Commission settings
│   └── topups_screen.dart          # Top-up monitoring
└── main.dart                       # App entry point
```

## Database Schema

The application connects to a Supabase database with the following main tables:

- **users**: Core user information
- **merchants**: Merchant profiles and verification data
- **riders**: Rider profiles and status
- **deliveries**: Delivery records (Pabili & Padala)
- **transactions_logs**: Financial transaction records
- **commission_settings**: Dynamic commission configuration
- **topups**: Top-up transaction history
- **business_hubs**: Business hub data
- **loading_stations**: Loading station information

## Admin Capabilities

### EPIC 1: User Registration and Hierarchy
- ✅ Review and approve/reject merchant registrations
- ✅ Review and approve/reject rider registrations
- ✅ Blacklist and reinstate accounts
- ✅ Manage user status (active/suspended)

### EPIC 2: Dynamic Commission System
- ✅ Define and update commission percentages
- ✅ Manage delivery fees by role
- ✅ Monitor top-up transactions
- ✅ Track bonus calculations

### EPIC 6: Admin Dashboard and Controls
- ✅ View and monitor all transactions
- ✅ Track loading balance and cash flow
- ✅ Monitor Business Hubs, Loading Stations, and Riders
- ✅ Visual reports and analytics
- ✅ Suspend, blacklist, or reinstate accounts
- ✅ Manual transaction overrides

## Usage Guide

### Navigation
Use the left sidebar to navigate between different sections:
- **Dashboard**: Overview and statistics
- **Users**: All system users
- **Merchants**: Merchant list view
- **Applications** ⭐NEW: Review and approve merchant applications
- **Riders**: Rider monitoring
- **Transactions**: Financial transactions
- **Deliveries**: Delivery tracking
- **Top-Ups**: Top-up monitoring
- **Commission**: Commission settings

### Common Tasks

#### Approve a Merchant (Updated Workflow)
1. Go to **Applications** screen (new dedicated page)
2. View pending applications with statistics
3. Click ✅ "Approve" button on merchant row
4. Review merchant details in confirmation dialog
5. Confirm action
6. Merchant gains system access immediately

📖 **For detailed merchant access control guide, see [MERCHANT_ACCESS_CONTROL.md](MERCHANT_ACCESS_CONTROL.md)**

#### Suspend a User
1. Go to Users screen
2. Find the user
3. Click suspend icon
4. Confirm action

#### Update Commission Settings
1. Go to Commission Settings
2. Click "Edit" on the role
3. Update percentage
4. Save changes

#### Monitor Cash Flow
1. View Dashboard
2. Check "Cash Flow Breakdown" section
3. See balances for Hubs, Stations, and Riders

## Deployment

### Web Deployment

Build for web:
```bash
flutter build web --release
```

The build output will be in `build/web/` directory. Deploy this to any static hosting service:
- Firebase Hosting
- Netlify
- Vercel
- AWS S3
- GitHub Pages

### Firebase Hosting Example
```bash
firebase init hosting
firebase deploy
```

## Security Notes

- The Supabase anon key is used for public API access
- Row Level Security (RLS) should be configured on Supabase
- Admin operations should require authentication
- Sensitive operations require confirmation dialogs

## Recent Updates

### Version 1.1.0 - Merchant Access Control System ⭐

**New Features:**
- ✅ Dedicated Merchant Applications screen
- ✅ Access status system (pending/approved/rejected/suspended)
- ✅ Merchants cannot access system until approved
- ✅ Real-time application statistics
- ✅ Approve/Reject/Suspend workflows with confirmations
- ✅ Detailed application viewer
- ✅ Enhanced merchant management

**Technical:**
- Database migration for `access_status` field
- Updated merchant model with access control
- New admin service methods
- Comprehensive documentation

## Future Enhancements

- [ ] Authentication system for admin login
- [ ] Export reports to CSV/PDF
- [ ] Email/SMS notifications for approvals
- [ ] Real-time notifications via WebSockets
- [ ] Advanced analytics charts
- [ ] Audit log for admin actions
- [ ] Bulk approve/reject operations
- [ ] Document verification automation
- [ ] Multi-language support
- [ ] Dark mode

## Support

For issues or questions, please contact the development team.

## Version

Current Version: 1.0.0

## License

© 2025 Lagona Admin. All rights reserved.
