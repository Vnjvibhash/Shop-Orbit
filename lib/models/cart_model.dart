import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoporbit/providers/cart_provider.dart';

class Cart {
  final String userId;
  final List<CartItem> items;
  final Timestamp updatedAt;

  Cart({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  factory Cart.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cart(
      userId: doc.id,
      items: (data['items'] as List<dynamic>)
          .map((itemData) => CartItem.fromMap(itemData))
          .toList(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}