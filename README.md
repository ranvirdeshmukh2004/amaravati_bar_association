# Amravati District Bar Association — Subscription Management System

A **desktop-first subscription and member management application** built with Flutter for the Amravati District Bar Association (ADBA). The app manages member records, subscription payments, donation tracking, receipt generation, and comprehensive reporting — all stored locally with no cloud dependencies.

---

## ✨ Features

### 📋 Member Management
- Add, edit, and manage member records with full details (name, enrollment number, DOB, address, mobile, email, blood group, profile photo)
- Member status tracking (Active/Suspended/Deceased)
- Member search and autocomplete across the application
- Experience Certificate generation (DOCX format)

### 💰 Subscription Tracking
- Record subscription payments with multiple payment modes (Cash, UPI, Cheque, Bank Transfer)
- Real-time subscription dashboard with status overview
- Configurable subscription amounts per financial year
- Year-end closing with automatic balance carry-forward

### 🧾 Receipt Generation
- Auto-generated PDF receipts for subscriptions and donations
- Standardized receipt numbering system
- Print-ready receipt layout

### 📊 Dashboard & Analytics
- KPI cards showing key financial metrics
- Monthly subscription trend charts
- Payment mode distribution (Pie chart)
- Top defaulters list
- System alerts and recent activity feed

### 💝 Donation Management
- Record donations from members and non-members
- Donor detail tracking (name, mobile, email, address, organization)
- Donation receipts with unique numbering

### 📑 Arrears Management
- Track past outstanding dues per member
- Clear arrears with linked payment records
- Period-based arrears tracking (e.g., "2020-2023")

### 📱 SMS Notifications
- Send payment reminders to defaulting members
- Custom SMS panel for bulk messaging
- Due alert panel with member filtering

### 📁 Export & Reporting
- Generate Provisional Voter Lists (XLSX) for eligible members
- Export Pending/Defaulter lists with customizable fields
- Full data backup & restore (JSON)
- Database backup & restore (SQLite)
- CSV/XLSX export for subscription records

### 🔒 Security
- Local password-protected admin access
- Developer mode with PIN access for diagnostics
- Encrypted password storage via `flutter_secure_storage`

### 🎨 UI/UX
- Modern gradient-based dark/light theme
- Collapsible sidebar navigation
- Keyboard shortcuts (Ctrl+M → Add Member, Ctrl+S → Subscription Entry)
- Responsive layout adapting to different window sizes

---

## 🛠 Tech Stack

| Component         | Technology                      |
|-------------------|---------------------------------|
| Framework         | Flutter (Desktop - Windows)     |
| Language          | Dart                            |
| Database          | SQLite via [Drift](https://drift.simonbinder.eu/) |
| State Management  | [Riverpod](https://riverpod.dev/) |
| PDF Generation    | `pdf` + `printing` packages     |
| Charts            | `fl_chart`                      |
| SMS               | Fast2SMS API                    |
| Security          | `flutter_secure_storage`        |

---

## 📦 Prerequisites

1. **Flutter SDK** — Version `3.10.4` or higher  
   ```bash
   flutter --version
   ```
2. **Windows Desktop Support** enabled  
   ```bash
   flutter config --enable-windows-desktop
   ```
3. **Visual Studio** — With "Desktop development with C++" workload (for Windows builds)

---

## 🚀 Getting Started

### Clone the Repository
```bash
git clone https://github.com/ranvirdeshmukh2004/amaravati_bar_association.git
cd amaravati_bar_association
```

### Install Dependencies
```bash
flutter pub get
```

### Run in Debug Mode
```bash
flutter run -d windows
```

### First Launch
On first launch, you'll be prompted to **set an admin password**. This password is stored securely on your machine and is required for all future logins.

**Developer Access:** Long-press the lock icon on the login screen and enter `dev123` to access the Developer Dashboard.

---

## 🏗 Building for Production

### Build Windows Executable
```bash
flutter build windows --release
```

The output executable will be at:
```
build\windows\x64\runner\Release\amaravati_bar_association.exe
```

### Database Location
- **Debug Mode:** `Documents\aba_donation.sqlite`
- **Release Mode:** `{Drive Root}\.aba_data\aba_donation.sqlite` (hidden directory)

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── auth/
│   │   └── app_session.dart           # Session & role management
│   ├── constants.dart                 # App-wide constants & colors
│   ├── theme.dart                     # Light & Dark theme definitions
│   ├── theme_provider.dart            # Theme state management
│   ├── utils.dart                     # Utility functions
│   └── app_gradients.dart             # Gradient definitions
├── features/
│   ├── auth/
│   │   ├── auth_controller.dart       # Local authentication logic
│   │   └── login_screen.dart          # Login & first-run setup UI
│   ├── dashboard/
│   │   ├── dashboard_screen.dart      # Main dashboard with KPIs
│   │   ├── dashboard_service.dart     # Dashboard data providers
│   │   ├── main_layout.dart           # App shell with sidebar
│   │   └── widgets/                   # Sidebar, charts, KPI cards
│   ├── database/
│   │   ├── app_database.dart          # Drift database definition
│   │   ├── app_database.g.dart        # Generated Drift code
│   │   ├── database_provider.dart     # Riverpod provider
│   │   ├── tables.dart                # Table schemas
│   │   ├── tables/                    # Extra table definitions
│   │   └── daos/                      # Data Access Objects
│   ├── members/
│   │   ├── member_form_screen.dart    # Add/Edit member
│   │   ├── member_list_screen.dart    # Member registry
│   │   ├── services/                  # Photo, certificate services
│   │   └── widgets/                   # Search, photo components
│   ├── subscription/
│   │   ├── subscription_form_screen.dart
│   │   ├── subscription_dashboard_screen.dart
│   │   ├── subscription_controller.dart
│   │   ├── export_service.dart
│   │   ├── arrears_clearance_screen.dart
│   │   ├── past_outstanding_screen.dart
│   │   └── widgets/                   # Filters, download dialogs
│   ├── donation/
│   │   └── donation_entry_screen.dart
│   ├── receipt/
│   │   └── receipt_service.dart       # PDF receipt generation
│   ├── records/
│   │   └── records_screen.dart        # Payment records view
│   ├── voter_list/
│   │   └── voter_list_service.dart    # Voter list PDF generation
│   ├── sms/
│   │   ├── sms_service.dart           # Fast2SMS integration
│   │   ├── sms_dashboard.dart
│   │   └── widgets/                   # SMS panels
│   ├── settings/
│   │   └── settings_screen.dart       # App settings & data management
│   └── developer/
│       ├── developer_dashboard.dart   # Dev tools & diagnostics
│       ├── developer_controller.dart  # Dev statistics
│       └── backup_service.dart        # SQLite backup/restore
assets/
├── icon_aba.png                       # Application icon
└── experience_certificate_template.docx
```

---

## 💾 Data Management

### Backup
- **Settings → Full Backup (JSON):** Exports all data to a JSON file
- **Developer Dashboard → Create Backup:** Copies the raw SQLite database

### Restore
- **Settings → Restore from Backup:** Imports from a JSON backup file
- **Developer Dashboard → Restore Backup:** Replaces the database file (requires app restart)

### Data Reset
- **Settings → Reset / Clear Data:** Selectively delete members, subscriptions, history, donations, or past clearance data (requires password confirmation)

---

## 🔐 Authentication

The app uses **local-only authentication**:

| Access Level | Credentials | Capabilities |
|---|---|---|
| **Admin** | Password (set on first run) | Full access to all features |
| **Developer** | PIN: `dev123` | Admin access + Developer Dashboard |

Password is stored encrypted locally via `flutter_secure_storage`. Change your password via **Settings → Change Password**.

---

## 📋 Financial Year

The app operates on the **Indian Financial Year** (April–March). The current FY is automatically calculated and displayed on the dashboard.

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -am 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

This project is proprietary software developed for the Amravati District Bar Association.

---

## 📞 Support

For issues or feature requests, please open a GitHub Issue or contact the development team at **GajSysAI Labs** — @works.ranvirdeshmukh.com
