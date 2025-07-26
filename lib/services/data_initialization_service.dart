import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoporbit/sample_data.dart';

/// Service to initialize Firebase with sample data
class DataInitializationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initialize all sample data in Firebase
  Future<void> initializeAllSampleData() async {
    try {
      print('Starting sample data initialization...');
      
      // Check if data already exists
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      if (usersSnapshot.docs.isNotEmpty) {
        print('Sample data already exists. Skipping initialization.');
        return;
      }

      // Initialize in order: users, categories, products, orders, reviews
      await _initializeUsers();
      await _initializeCategories();
      await _initializeProducts();
      await _initializeOrders();
      await _initializeReviews();
      
      print('Sample data initialization completed successfully!');
    } catch (e) {
      print('Error initializing sample data: $e');
      rethrow;
    }
  }

  /// Initialize sample users
  Future<void> _initializeUsers() async {
    print('Initializing users...');
    
    final users = sampleData['users'] as List<dynamic>;
    final batch = _firestore.batch();

    for (final userData in users) {
      final userMap = Map<String, dynamic>.from(userData);
      
      // Convert timestamp placeholders to actual timestamps
      userMap['createdAt'] = Timestamp.now();
      userMap['updatedAt'] = Timestamp.now();
      
      // Create user document with email as ID for easier reference
      final userRef = _firestore.collection('users').doc(userMap['email']);
      userMap['id'] = userMap['email']; // Set ID to email for consistency
      
      batch.set(userRef, userMap);
    }

    await batch.commit();
    print('Users initialized successfully');
  }

  /// Initialize sample categories
  Future<void> _initializeCategories() async {
    print('Initializing categories...');
    
    final categories = sampleData['categories'] as List<dynamic>;
    final batch = _firestore.batch();

    for (final categoryData in categories) {
      final categoryMap = Map<String, dynamic>.from(categoryData);
      
      // Convert timestamp placeholders to actual timestamps
      categoryMap['createdAt'] = Timestamp.now();
      categoryMap['updatedAt'] = Timestamp.now();
      
      final categoryRef = _firestore.collection('categories').doc();
      categoryMap['id'] = categoryRef.id;
      
      batch.set(categoryRef, categoryMap);
    }

    await batch.commit();
    print('Categories initialized successfully');
  }

  /// Initialize sample products
  Future<void> _initializeProducts() async {
    print('Initializing products...');
    
    final products = sampleData['products'] as List<dynamic>;
    final batch = _firestore.batch();

    for (final productData in products) {
      final productMap = Map<String, dynamic>.from(productData);
      
      // Convert timestamp placeholders to actual timestamps
      productMap['createdAt'] = Timestamp.now();
      productMap['updatedAt'] = Timestamp.now();
      
      final productRef = _firestore.collection('products').doc();
      productMap['id'] = productRef.id;
      
      batch.set(productRef, productMap);
    }

    await batch.commit();
    print('Products initialized successfully');
  }

  /// Initialize sample orders
  Future<void> _initializeOrders() async {
    print('Initializing orders...');
    
    final orders = sampleData['orders'] as List<dynamic>;
    final batch = _firestore.batch();

    for (final orderData in orders) {
      final orderMap = Map<String, dynamic>.from(orderData);
      
      // Convert timestamp placeholders to actual timestamps
      orderMap['createdAt'] = Timestamp.now();
      orderMap['updatedAt'] = Timestamp.now();
      
      final orderRef = _firestore.collection('orders').doc();
      orderMap['id'] = orderRef.id;
      
      batch.set(orderRef, orderMap);
    }

    await batch.commit();
    print('Orders initialized successfully');
  }

  /// Initialize sample reviews
  Future<void> _initializeReviews() async {
    print('Initializing reviews...');
    
    final reviews = sampleData['reviews'] as List<dynamic>;
    final batch = _firestore.batch();

    for (final reviewData in reviews) {
      final reviewMap = Map<String, dynamic>.from(reviewData);
      
      // Convert timestamp placeholders to actual timestamps
      reviewMap['createdAt'] = Timestamp.now();
      reviewMap['updatedAt'] = Timestamp.now();
      
      final reviewRef = _firestore.collection('reviews').doc();
      reviewMap['id'] = reviewRef.id;
      
      batch.set(reviewRef, reviewMap);
    }

    await batch.commit();
    print('Reviews initialized successfully');
  }

  /// Create sample user accounts with authentication
  Future<void> createSampleUserAccounts() async {
    print('Creating sample user accounts...');
    
    final users = sampleData['users'] as List<dynamic>;
    
    for (final userData in users) {
      final userMap = Map<String, dynamic>.from(userData);
      final email = userMap['email'] as String;
      final password = 'password123'; // Default password for sample accounts
      
      try {
        // Create auth account
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (credential.user != null) {
          // Update user document with auth UID
          await _firestore.collection('users').doc(email).update({
            'id': credential.user!.uid,
          });
          
          print('Created account for: $email');
        }
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('Account already exists for: $email');
        } else {
          print('Error creating account for $email: $e');
        }
      }
    }
    
    print('Sample user accounts creation completed');
  }

  /// Reset all data (use with caution!)
  Future<void> resetAllData() async {
    print('WARNING: Resetting all data...');
    
    final collections = ['users', 'categories', 'products', 'orders', 'reviews'];
    
    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cleared collection: $collection');
    }
    
    print('All data reset completed');
  }

  /// Check if sample data exists
  Future<bool> hasSampleData() async {
    try {
      final snapshot = await _firestore.collection('users').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking sample data: $e');
      return false;
    }
  }

  /// Get initialization status
  Future<Map<String, int>> getInitializationStatus() async {
    try {
      final futures = await Future.wait([
        _firestore.collection('users').get(),
        _firestore.collection('categories').get(),
        _firestore.collection('products').get(),
        _firestore.collection('orders').get(),
        _firestore.collection('reviews').get(),
      ]);

      return {
        'users': futures[0].docs.length,
        'categories': futures[1].docs.length,
        'products': futures[2].docs.length,
        'orders': futures[3].docs.length,
        'reviews': futures[4].docs.length,
      };
    } catch (e) {
      print('Error getting initialization status: $e');
      return {
        'users': 0,
        'categories': 0,
        'products': 0,
        'orders': 0,
        'reviews': 0,
      };
    }
  }
}