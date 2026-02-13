# RKJ Fashions - Designer Boutique App

## 🌟 Overview
A premium Flutter-based fashion platform with a robust Node.js backend. Features dual interfaces for customers (User App) and shop owners (Admin Dashboard).

## 🏗️ Technical Stack
- **Frontend**: Flutter (Android, iOS)
- **Backend**: Node.js + Express (Hosted on Render)
- **Database**: PostgreSQL
- **Media**: Cloudinary (Image Storage)

## ✨ Features
- **👗 User Portal**: Premium "Pro Max" UI, Product Filtering, Cart, Manual UPI Payment Verification, India Post Tracking.
- **🛡️ Admin Dashboard**: Member Management, Product Inventory, Order Processing (Pack/Ship), UPI/Store Settings.

## 🚀 Getting Started

### 1. Backend Setup
- The server is hosted on Render using the `render.yaml` blueprint.
- Ensure your environment variables for `DATABASE_URL` and `CLOUDINARY_*` are configured in the Render dashboard.

### 2. Running Locally
```powershell
# Install dependencies
flutter pub get

# Run App
flutter run
```

## 📂 Folder Structure
- `lib/core`: Design tokens, themes, and global constants.
- `lib/data`: Data models, API services, and State Management (Provider).
- `lib/ui`: Screens and widgets for both Admin and User roles.
- `backend`: Node.js server source code.

## 🛠️ Build Scripts
- `fix_build.ps1`: Cleans and fixes Android build issues.
