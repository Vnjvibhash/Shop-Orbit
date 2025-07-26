import 'package:flutter/material.dart';
import 'package:shoporbit/models/user_model.dart';
import 'package:shoporbit/services/firestore_service.dart';
import 'package:shoporbit/widgets/common/loading_widget.dart';

class ManageSellersScreen extends StatefulWidget {
  const ManageSellersScreen({super.key});

  @override
  State<ManageSellersScreen> createState() => _ManageSellersScreenState();
}

class _ManageSellersScreenState extends State<ManageSellersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> sellers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    try {
      final allUsers = await _firestoreService.getUsers();
      setState(() {
        sellers = allUsers.where((user) => user.role == 'seller').toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sellers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _toggleSellerApproval(UserModel seller) async {
    try {
      await _firestoreService.approveRejectSeller(seller.id, !seller.isApproved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seller.isApproved ? 'Seller rejected' : 'Seller approved',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadSellers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating seller status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleSellerBlock(UserModel seller) async {
    try {
      await _firestoreService.updateUserStatus(seller.id, !seller.isBlocked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seller.isBlocked ? 'Seller unblocked' : 'Seller blocked',
          ),
          backgroundColor: Colors.green,
        ),
      );
      _loadSellers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating seller status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sellers'),
      ),
      body: isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadSellers,
              child: sellers.isEmpty
                  ? const Center(
                      child: Text('No sellers found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sellers.length,
                      itemBuilder: (context, index) {
                        final seller = sellers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(seller),
                              child: Icon(
                                _getStatusIcon(seller),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(seller.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(seller.email),
                                Text(
                                  'Status: ${_getStatusText(seller)}',
                                  style: TextStyle(
                                    color: _getStatusColor(seller),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Joined: ${seller.createdAt.day}/${seller.createdAt.month}/${seller.createdAt.year}',
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'toggle_approval') {
                                  _showToggleApprovalDialog(seller);
                                } else if (value == 'toggle_block') {
                                  _showToggleBlockDialog(seller);
                                } else if (value == 'view_products') {
                                  _viewSellerProducts(seller);
                                }
                              },
                              itemBuilder: (context) => [
                                if (!seller.isBlocked)
                                  PopupMenuItem(
                                    value: 'toggle_approval',
                                    child: Row(
                                      children: [
                                        Icon(
                                          seller.isApproved ? Icons.close : Icons.check_circle,
                                          color: seller.isApproved ? Colors.red : Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(seller.isApproved ? 'Reject' : 'Approve'),
                                      ],
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 'toggle_block',
                                  child: Row(
                                    children: [
                                      Icon(
                                        seller.isBlocked ? Icons.check_circle : Icons.block,
                                        color: seller.isBlocked ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(seller.isBlocked ? 'Unblock' : 'Block'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'view_products',
                                  child: Row(
                                    children: [
                                      Icon(Icons.inventory, color: Colors.blue),
                                      const SizedBox(width: 8),
                                      const Text('View Products'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getStatusColor(UserModel seller) {
    if (seller.isBlocked) return Colors.red;
    if (!seller.isApproved) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(UserModel seller) {
    if (seller.isBlocked) return Icons.block;
    if (!seller.isApproved) return Icons.pending;
    return Icons.store;
  }

  String _getStatusText(UserModel seller) {
    if (seller.isBlocked) return 'Blocked';
    if (!seller.isApproved) return 'Pending Approval';
    return 'Approved';
  }

  void _showToggleApprovalDialog(UserModel seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${seller.isApproved ? 'Reject' : 'Approve'} Seller'),
        content: Text(
          'Are you sure you want to ${seller.isApproved ? 'reject' : 'approve'} ${seller.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleSellerApproval(seller);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: seller.isApproved ? Colors.red : Colors.green,
            ),
            child: Text(seller.isApproved ? 'Reject' : 'Approve'),
          ),
        ],
      ),
    );
  }

  void _showToggleBlockDialog(UserModel seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${seller.isBlocked ? 'Unblock' : 'Block'} Seller'),
        content: Text(
          'Are you sure you want to ${seller.isBlocked ? 'unblock' : 'block'} ${seller.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleSellerBlock(seller);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: seller.isBlocked ? Colors.green : Colors.red,
            ),
            child: Text(seller.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  void _viewSellerProducts(UserModel seller) {
    // Navigate to seller products view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing products for ${seller.name}'),
      ),
    );
  }
}