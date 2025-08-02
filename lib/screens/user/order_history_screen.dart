import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';
import 'package:shoporbit/widgets/cards/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        final userOrders = await _firestoreService.getOrders(userId: userId);
        setState(() {
          orders = userOrders;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: orders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your orders will appear here',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          order: order,
                          onTap: () => _showOrderDetails(order),
                        );
                      },
                    ),
            ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderInfo(order),
                        const SizedBox(height: 16),
                        _buildOrderItems(order),
                        const SizedBox(height: 16),
                        _buildTrackingInfo(order),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfo(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Order ID', order.id),
            _buildInfoRow('Status', order.status.toUpperCase()),
            _buildInfoRow(
              'Total Amount',
              '\$${order.totalAmount.toStringAsFixed(2)}',
            ),
            _buildInfoRow('Payment Method', order.paymentMethod),
            _buildInfoRow('Payment Status', order.isPaid ? 'Paid' : 'Pending'),
            _buildInfoRow(
              'Order Date',
              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
            ),
            const SizedBox(height: 8),
            const Text(
              'Shipping Address:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(order.shippingAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${order.items.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...order.items.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.productImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Quantity: ${item.quantity}'),
                          Text('Price: \$${item.price.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Tracking',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildTrackingStep('Order Placed', true, order.createdAt),
            _buildTrackingStep(
              'Confirmed',
              _isStatusReached(order.status, 'confirmed'),
              null,
            ),
            _buildTrackingStep(
              'Shipped',
              _isStatusReached(order.status, 'shipped'),
              null,
            ),
            _buildTrackingStep(
              'Delivered',
              _isStatusReached(order.status, 'delivered'),
              null,
            ),
            if (order.status == 'cancelled')
              _buildTrackingStep('Cancelled', true, null, isError: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep(
    String title,
    bool isCompleted,
    DateTime? date, {
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? (isError ? Colors.red : Colors.green)
                  : Colors.grey[300],
            ),
            child: Icon(
              isCompleted
                  ? (isError ? Icons.close : Icons.check)
                  : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.white : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? (isError ? Colors.red : Colors.green)
                        : Colors.grey,
                  ),
                ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isStatusReached(String currentStatus, String targetStatus) {
    const statusOrder = ['pending', 'confirmed', 'shipped', 'delivered'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final targetIndex = statusOrder.indexOf(targetStatus);
    return currentIndex >= targetIndex;
  }
}
