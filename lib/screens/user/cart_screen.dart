import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/providers/cart_provider.dart';
import 'package:shoporbit/services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _addressController = TextEditingController();
  String selectedPaymentMethod = 'Cash on Delivery';
  bool isPlacingOrder = false;

  // Fee and charge variables for easy configuration
  final double deliveryCharge = 5.00;
  final double gstRate = 0.18; // 18%
  final double handlingFee = 2.00;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // Helper method to build the summary rows for costs
  Widget _buildPriceDetailRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Calculate all fees and totals
          final double subtotal = cartProvider.totalAmount;
          final double gstAmount = subtotal * gstRate;
          final double grandTotal =
              subtotal + deliveryCharge + gstAmount + handlingFee;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.product.images.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.product.images.first,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                ),
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                cartProvider.updateQuantity(
                                                  item.product.id,
                                                  item.quantity - 1,
                                                );
                                              },
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                if (item.quantity <
                                                    item.product.inventory) {
                                                  cartProvider.updateQuantity(
                                                    item.product.id,
                                                    item.quantity + 1,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                cartProvider.removeFromCart(item.product.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Updated bottom summary bar with detailed breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPriceDetailRow(
                      'Subtotal',
                      '\$${subtotal.toStringAsFixed(2)}',
                    ),
                    _buildPriceDetailRow(
                      'Delivery Charge',
                      '\$${deliveryCharge.toStringAsFixed(2)}',
                    ),
                    _buildPriceDetailRow(
                      'GST (18%)',
                      '\$${gstAmount.toStringAsFixed(2)}',
                    ),
                    _buildPriceDetailRow(
                      'Handling Fee',
                      '\$${handlingFee.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 24, thickness: 1),
                    _buildPriceDetailRow(
                      'Grand Total',
                      '\$${grandTotal.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isPlacingOrder
                            ? null
                            : () =>
                                  _showCheckoutDialog(cartProvider, grandTotal),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isPlacingOrder
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckoutDialog(CartProvider cartProvider, double grandTotal) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Checkout'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Shipping Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Cash on Delivery',
                      child: Text('Cash on Delivery'),
                    ),
                    DropdownMenuItem(
                      value: 'Credit Card',
                      child: Text('Credit Card'),
                    ),
                    DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Updated summary inside the dialog
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildPriceDetailRow(
                        'Subtotal',
                        '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                      ),
                      _buildPriceDetailRow(
                        'Delivery Charge',
                        '\$${deliveryCharge.toStringAsFixed(2)}',
                      ),
                      _buildPriceDetailRow(
                        'GST (18%)',
                        '\$${(cartProvider.totalAmount * gstRate).toStringAsFixed(2)}',
                      ),
                      _buildPriceDetailRow(
                        'Handling Fee',
                        '\$${handlingFee.toStringAsFixed(2)}',
                      ),
                      const Divider(),
                      _buildPriceDetailRow(
                        'Grand Total',
                        '\$${grandTotal.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _placeOrder(cartProvider, grandTotal);
              },
              child: const Text('Place Order'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider, double grandTotal) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter shipping address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final Map<String, List<CartItem>> itemsBySeller = {};
      for (final item in cartProvider.items) {
        if (!itemsBySeller.containsKey(item.product.sellerId)) {
          itemsBySeller[item.product.sellerId] = [];
        }
        itemsBySeller[item.product.sellerId]!.add(item);
      }

      for (final sellerId in itemsBySeller.keys) {
        final sellerItems = itemsBySeller[sellerId]!;
        final orderItems = sellerItems
            .map(
              (item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                productImage: item.product.images.first,
                price: item.product.price,
                quantity: item.quantity,
              ),
            )
            .toList();

        final order = OrderModel(
          id: '',
          userId: user.id,
          sellerId: sellerId,
          items: orderItems,
          totalAmount: grandTotal, // Save the final grand total
          status: 'pending',
          shippingAddress: _addressController.text,
          paymentMethod: selectedPaymentMethod,
          isPaid: selectedPaymentMethod != 'Cash on Delivery',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.createOrder(order);
      }

      cartProvider.clearCart();

      if (mounted) {
        Navigator.of(
          context,
        ).pop(); // Assuming this is to close a checkout summary page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }
}
