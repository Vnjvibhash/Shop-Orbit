import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoporbit/models/product_model.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/models/category_model.dart';
import 'package:shoporbit/models/review_model.dart';
import 'package:shoporbit/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Future<List<UserModel>> getUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UserModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<void> updateUserStatus(String userId, bool isBlocked) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBlocked': isBlocked,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating user status: $e');
      rethrow;
    }
  }

  Future<void> approveRejectSeller(String sellerId, bool isApproved) async {
    try {
      await _firestore.collection('users').doc(sellerId).update({
        'isApproved': isApproved,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating seller status: $e');
      rethrow;
    }
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CategoryModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').add(category.toJson());
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').doc(category.id).update(category.toJson());
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Products
  Future<List<ProductModel>> getProducts({String? category, String? sellerId}) async {
    try {
      Query query = _firestore.collection('products');
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ProductModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }
    } catch (e) {
      print('Error getting product: $e');
    }
    return null;
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').add(product.toJson());
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toJson());
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Orders
  Future<List<OrderModel>> getOrders({String? userId, String? sellerId}) async {
    try {
      Query query = _firestore.collection('orders');
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return OrderModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      return [];
    }
  }

  Future<void> createOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').add(order.toJson());
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Reviews
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ReviewModel.fromJson(data);
          })
          .toList();
    } catch (e) {
      print('Error getting reviews: $e');
      return [];
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.collection('reviews').add(review.toJson());
      
      // Update product rating
      await _updateProductRating(review.productId);
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> _updateProductRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return;

      final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      await _firestore.collection('products').doc(productId).update({
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
      final usersSnapshot = await _firestore.collection('users').get();
      final sellersSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'seller').get();
      final productsSnapshot = await _firestore.collection('products').get();
      final ordersSnapshot = await _firestore.collection('orders').get();

      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalSellers': sellersSnapshot.docs.length,
        'totalProducts': productsSnapshot.docs.length,
        'totalOrders': ordersSnapshot.docs.length,
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
}