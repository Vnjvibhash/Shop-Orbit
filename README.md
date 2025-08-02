# ShopOrbit - Multi-Role E-commerce Flutter App

<p align="center">
  <img src="assets/images/logo.png?raw=true" alt="ShopOrbit Logo" height="400"/>
</p>

A complete 3-module shopping application built with Flutter and Firebase, featuring role-based access control for Admin, Seller, and User roles.

## Features

### 🔐 Authentication System

- Firebase Authentication with email/password
- Role-based registration (Admin, Seller, User)
- Automatic role-based navigation
- Seller approval system
- User blocking/unblocking functionality

### 👨‍💼 Admin Module
- **Dashboard**: Analytics overview (total users, sellers, products, orders)
- **User Management**: View and block/unblock users
- **Seller Management**: Approve/reject sellers, view their products
- **Category Management**: Add, edit, and organize product categories
- **Order Monitoring**: View all orders across all sellers

### 🏪 Seller Module
- **Dashboard**: Personal analytics and earnings tracking
- **Product Management**: Add, edit, delete products with images
- **Inventory Management**: Track stock levels and low inventory alerts
- **Order Management**: Process and update order status
- **Profile Management**: Update seller information

### 🛒 User Module
- **Product Browsing**: Browse by categories and search functionality
- **Product Details**: View detailed product information and reviews
- **Shopping Cart**: Add to cart, update quantities, remove items
- **Wishlist**: Save products for later
- **Order Placement**: Checkout with address and payment method selection
- **Order History**: Track order status and view past purchases
- **Reviews & Ratings**: Leave product reviews and ratings

## Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Material Design 3**: Modern UI components
- **Provider**: State management
- **Google Fonts**: Typography

### Backend
- **Firebase Authentication**: User authentication and authorization
- **Cloud Firestore**: NoSQL database for storing app data
- **Firebase Storage**: Image storage for product photos
- **Firebase Security Rules**: Role-based data access control

### Architecture
- **Clean Architecture**: Separated concerns with models, services, providers, and UI
- **Repository Pattern**: Abstracted data access through FirestoreService
- **Provider Pattern**: Reactive state management
- **Modular Design**: Separate modules for each user role

## Project Structure
```
lib/
├── main.dart                # App entry point with Firebase initialization
├── theme.dart               # Material Design theme configuration
├── data_schema.dart         # Firestore database schema documentation
├── models/                  # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── order_model.dart
│   ├── category_model.dart
│   ├── address_model.dart
│   ├── cart_model.dart
│   └── review_model.dart
├── services/                # Business logic and API services
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   └── cart_provider.dart
├── screens/                 # UI screens organized by role
│   ├── auth/
│   ├── admin/
│   ├── seller/
│   └── user/
│       ├── user_model.dart
│       ├── product_model.dart
│       ├── order_model.dart
│       ├── category_model.dart
│       ├── wishlist_screen.dart
│       └── review_model.dart
└── widgets/                 # Reusable UI components
    ├── common/
    ├── product_card.dart
    ├── order_card.dart
    └── dashboard_card.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project with Authentication, Firestore, and Storage enabled
- Android Studio or VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ShopOrbit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Authentication, Firestore, and Storage
   - Configure FlutterFire:
     ```bash
     flutterfire configure
     ```

4. **Set up Firestore Security Rules**
   - Copy the rules from `firestore.rules` to your Firebase console
   - Deploy the rules and indexes:
     ```bash
     firebase deploy --only firestore
     ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Authentication

- Email/Password authentication enabled
- Custom claims for role-based access (optional enhancement)

### Firestore Database

- Collections: users, categories, products, orders, reviews
- Composite indexes for efficient queries
- Security rules for role-based access

### Storage

- Product images storage
- Organized by seller/product structure

## Sample Data

The app includes comprehensive sample data:

- 1 Admin user
- 2 Seller users with different product categories
- 2 Customer users
- 5 Product categories with subcategories
- 10+ Sample products with realistic data
- Sample orders and reviews

## Key Features Implementation

### Role-Based Access Control

- AuthWrapper component manages navigation based on user role
- Firestore security rules enforce data access permissions
- UI components adapt based on user role

### Real-time Updates

- Provider pattern ensures UI updates when data changes
- Firestore listeners for real-time data synchronization
- Immediate reflection of cart and order changes

### Image Handling

- Firebase Storage for product image uploads
- Fallback UI for missing images
- Optimized image loading with error handling

### Search and Filtering

- Full-text search across product names and descriptions
- Category-based filtering
- Sort by price, rating, and name

### Order Management

- Multi-seller order support (separate orders per seller)
- Order status tracking with visual indicators
- Payment method simulation

## Testing Accounts

For testing purposes, you can create accounts with these roles:

- **Admin**: Full system access
- **Seller**: Product and order management (requires admin approval)
- **User**: Shopping and order placement

## Future Enhancements

- [ ] Push notifications with Firebase Cloud Messaging
- [ ] Real payment gateway integration
- [ ] Advanced analytics and reporting
- [ ] Multi-language support
- [ ] Advanced search with filters
- [ ] Product recommendations
- [ ] Chat/messaging system
- [ ] Inventory alerts
- [ ] Sales reporting for sellers

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please create an issue in the repository or contact the development team.
