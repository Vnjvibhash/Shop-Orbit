import 'package:flutter/material.dart';
import 'package:shoporbit/models/order_model.dart';
import 'package:shoporbit/models/user_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/order_card.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<OrderModel> orders = [];
  List<UserModel> sellers = [];
  bool isLoading = true;
  String selectedStatus = 'all';
  String selectedSellerId = 'all';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      sellers = await _firestoreService.getUsersByRole('seller');
      orders = await _firestoreService.getOrders();
      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  List<OrderModel> get filteredOrders {
    var results = orders;
    if (selectedSellerId != 'all') {
      results = results
          .where((order) => order.sellerId == selectedSellerId)
          .toList();
    }
    if (selectedStatus != 'all') {
      results = results
          .where((order) => order.status == selectedStatus)
          .toList();
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedSellerId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Seller',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All Sellers'),
                    ),
                    ...sellers.map(
                      (seller) => DropdownMenuItem(
                        value: seller.id,
                        child: Text(seller.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedSellerId = value ?? 'all');
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadAllData,
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
                            (selectedStatus == 'all' &&
                                    selectedSellerId == 'all')
                                ? 'No orders yet'
                                : 'No matching orders',
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
                        final sellerName = sellers
                            .firstWhere(
                              (s) => s.id == order.sellerId,
                              orElse: () => UserModel(
                                id: '',
                                name: '(Unknown Seller)',
                                email: '',
                                role: '',
                                profileImage: null,
                                addresses: [],
                                isBlocked: false,
                                isApproved: false,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            )
                            .name;
                        return OrderCard(
                          order: order,
                          onTap: () => _showOrderDetails(order, sellerName),
                          isSeller: false,
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
          setState(() => selectedStatus = status);
        },
      ),
    );
  }

  void _showOrderDetails(OrderModel order, String sellerName) {
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
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Information',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text('Order ID: ${order.id}'),
                                Text('Seller: $sellerName'),
                                Text('Status: ${order.status.toUpperCase()}'),
                                Text(
                                  'Total: \$${order.totalAmount.toStringAsFixed(2)}',
                                ),
                                Text('Payment Method: ${order.paymentMethod}'),
                                Text(
                                  'Order Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
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
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Items (${order.items.length})',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ...order.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              item.productImage,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Quantity: ${item.quantity}',
                                              ),
                                              Text(
                                                'Price: \$${item.price.toStringAsFixed(2)}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
}
