import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoporbit/models/user_model.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/models/category_model.dart';
import 'package:shoporbit/models/review_model.dart';
import 'package:shoporbit/providers/cart_provider.dart';

/// Centralized Firebase repository for all database operations
class FirebaseRepository {
  static final FirebaseRepository _instance = FirebaseRepository._internal();
  factory FirebaseRepository() => _instance;
  FirebaseRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Collections
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _productsCollection =>
      _firestore.collection('products');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _categoriesCollection =>
      _firestore.collection('categories');
  CollectionReference get _reviewsCollection =>
      _firestore.collection('reviews');
  CollectionReference _getCartCollection(String userId) {
    return _usersCollection.doc(userId).collection('cart');
  }

  CollectionReference _wishlistCollection(String userId) =>
      _usersCollection.doc(userId).collection('wishlist');

  // User Operations
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _usersCollection.doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }
    } catch (e) {
      print('Error getting current user data: $e');
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _usersCollection
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting users by role: $e');
      return [];
    }
  }

  Future<void> updateUserStatus(
    String userId, {
    bool? isBlocked,
    bool? isApproved,
  }) async {
    try {
      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (isBlocked != null) updateData['isBlocked'] = isBlocked;
      if (isApproved != null) updateData['isApproved'] = isApproved;

      await _usersCollection.doc(userId).update(updateData);
    } catch (e) {
      print('Error updating user status: $e');
      rethrow;
    }
  }

  // Product Operations
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _productsCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _productsCollection
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final snapshot = await _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting products by seller: $e');
      return [];
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }
    } catch (e) {
      print('Error getting product by ID: $e');
    }
    return null;
  }

  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toJson());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Order Operations
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final snapshot = await _ordersCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting all orders: $e');
      return [];
    }
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting orders by user: $e');
      return [];
    }
  }

  Future<List<OrderModel>> getOrdersBySeller(String sellerId) async {
    try {
      final snapshot = await _ordersCollection
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting orders by seller: $e');
      return [];
    }
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add(order.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Category Operations
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _categoriesCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<String> addCategory(CategoryModel category) async {
    try {
      final docRef = await _categoriesCollection.add(category.toJson());
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _categoriesCollection.doc(category.id).update(category.toJson());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Review Operations
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final snapshot = await _reviewsCollection
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ReviewModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting product reviews: $e');
      return [];
    }
  }

  Future<String> addReview(ReviewModel review) async {
    try {
      final docRef = await _reviewsCollection.add(review.toJson());

      // Update product rating
      await _updateProductRating(review.productId);

      return docRef.id;
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return;

      final totalRating = reviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      await _productsCollection.doc(productId).update({
        'averageRating': averageRating,
        'reviewCount': reviews.length,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  // Analytics
  Future<Map<String, int>> getAnalytics() async {
    try {
      final futures = await Future.wait([
        _usersCollection.get(),
        _usersCollection.where('role', isEqualTo: 'seller').get(),
        _productsCollection.get(),
        _ordersCollection.get(),
      ]);

      return {
        'totalUsers': futures[0].docs.length,
        'totalSellers': futures[1].docs.length,
        'totalProducts': futures[2].docs.length,
        'totalOrders': futures[3].docs.length,
      };
    } catch (e) {
      print('Error getting analytics: $e');
      return {
        'totalUsers': 0,
        'totalSellers': 0,
        'totalProducts': 0,
        'totalOrders': 0,
      };
    }
  }

  // Search Operations
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _productsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Batch Operations
  Future<void> initializeSampleData() async {
    _firestore.batch();

    try {
      // Note: This would typically be done once during app setup
      // The sample data would be imported from sample_data.dart
      print(
        'Sample data initialization should be done manually or through Firebase console',
      );
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  // Real-time streams
  Stream<List<ProductModel>> getProductsStream() {
    return _productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          }).toList(),
        );
  }

  Stream<List<OrderModel>> getOrdersStream({String? userId, String? sellerId}) {
    Query query = _ordersCollection;

    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (sellerId != null) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return OrderModel.fromJson(data);
          }).toList(),
        );
  }

  // Cart Operations
  Future<void> addToCart(
    String userId,
    ProductModel product,
    int quantity,
  ) async {
    final cartItemRef = _getCartCollection(userId).doc(product.id);

    // Use a transaction for safety
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartItemRef);

      if (snapshot.exists) {
        // If the item already exists, increment the quantity
        final existingQuantity =
            (snapshot.data() as Map<String, dynamic>)['quantity'] as int;
        transaction.update(cartItemRef, {
          'quantity': existingQuantity + quantity,
        });
      } else {
        // If the item doesn't exist, create a new document for it
        final cartItem = CartItem(product: product, quantity: quantity);
        transaction.set(cartItemRef, cartItem.toMap());
      }
    });
  }

  Future<void> removeFromCart(String userId, String productId) async {
    await _getCartCollection(userId).doc(productId).delete();
  }

  Future<void> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      // If quantity is zero or less, remove the item
      await removeFromCart(userId, productId);
    } else {
      // Otherwise, update the quantity field
      await _getCartCollection(
        userId,
      ).doc(productId).update({'quantity': quantity});
    }
  }

  Future<void> clearCart(String userId) async {
    final cartSnapshot = await _getCartCollection(userId).get();
    final batch = _firestore.batch();

    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Stream<List<CartItem>> getCartStream(String userId) {
    return _getCartCollection(userId).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return [];

      // Map each document in the subcollection to a CartItem object
      return snapshot.docs.map((doc) {
        return CartItem.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Wishlist Operations
  Future<void> addToWishlist(String userId, ProductModel product) async {
    await _wishlistCollection(userId).doc(product.id).set(product.toJson());
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    await _wishlistCollection(userId).doc(productId).delete();
  }

  Stream<List<ProductModel>> getWishlistStream(String userId) {
    return _wishlistCollection(userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }
}
