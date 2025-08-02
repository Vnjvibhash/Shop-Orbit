import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoporbit/providers/auth_provider.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';
import 'package:shoporbit/widgets/cards/order_card.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> orders = [];
  bool isLoading = true;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sellerId = authProvider.currentUser?.id;
      
      if (sellerId != null) {
        final sellerOrders = await _firestoreService.getOrders(sellerId: sellerId);
        setState(() {
          orders = sellerOrders;
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

  List<OrderModel> get filteredOrders {
    if (selectedStatus == 'all') {
      return orders;
    }
    return orders.where((order) => order.status == selectedStatus).toList();
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(order.id, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter('all', 'All'),
                  _buildStatusFilter('pending', 'Pending'),
                  _buildStatusFilter('confirmed', 'Confirmed'),
                  _buildStatusFilter('shipped', 'Shipped'),
                  _buildStatusFilter('delivered', 'Delivered'),
                  _buildStatusFilter('cancelled', 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedStatus == 'all' ? 'No orders yet' : 'No $selectedStatus orders',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Orders will appear here when customers place them',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          order: order,
                          onTap: () => _showOrderDetails(order),
                          isSeller: true,
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildStatusFilter(String status, String label) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatus = status;
          });
        },
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
                        _buildOrderActions(order),
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
            Text('Order ID: ${order.id}'),
            Text('Status: ${order.status.toUpperCase()}'),
            Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Payment Method: ${order.paymentMethod}'),
            Text('Order Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
            const SizedBox(height: 8),
            const Text('Shipping Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(order.shippingAddress),
          ],
        ),
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
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _getAvailableActions(order.status).map((action) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _updateOrderStatus(order, action);
                  },
                  child: Text('Mark as ${action.toUpperCase()}'),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableActions(String currentStatus) {
    switch (currentStatus) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered'];
      default:
        return [];
    }
  }
}