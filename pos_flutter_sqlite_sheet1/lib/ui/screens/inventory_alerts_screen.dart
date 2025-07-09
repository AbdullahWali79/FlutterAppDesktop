import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/product_provider.dart';
import '../../data/models/product.dart';
import '../../config/constants.dart';

class InventoryAlertsScreen extends StatefulWidget {
  const InventoryAlertsScreen({super.key});

  @override
  State<InventoryAlertsScreen> createState() => _InventoryAlertsScreenState();
}

class _InventoryAlertsScreenState extends State<InventoryAlertsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Alerts'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'All',
                child: Text('All Alerts'),
              ),
              const PopupMenuItem(
                value: 'Out of Stock',
                child: Text('Out of Stock'),
              ),
              const PopupMenuItem(
                value: 'Critical Stock',
                child: Text('Critical Stock'),
              ),
              const PopupMenuItem(
                value: 'Low Stock',
                child: Text('Low Stock'),
              ),
              const PopupMenuItem(
                value: 'Medium Stock',
                child: Text('Medium Stock'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAlertSummary(context, products),
          Expanded(
            child: _buildAlertList(context, products),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSummary(BuildContext context, List<Product> products) {
    final outOfStock = products.where((p) => p.stockQuantity <= 0).length;
    final criticalStock = products.where((p) => p.stockQuantity > 0 && p.stockQuantity <= 2).length;
    final lowStock = products.where((p) => p.stockQuantity > 2 && p.stockQuantity <= 5).length;
    final mediumStock = products.where((p) => p.stockQuantity > 5 && p.stockQuantity <= 10).length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Out of Stock', outOfStock, Colors.red),
          _buildSummaryItem('Critical', criticalStock, Colors.purple),
          _buildSummaryItem('Low Stock', lowStock, Colors.orange),
          _buildSummaryItem('Medium', mediumStock, Colors.yellow.shade700),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertList(BuildContext context, List<Product> products) {
    List<Product> filteredProducts = products.where((product) {
      switch (_selectedFilter) {
        case 'Out of Stock':
          return product.stockQuantity <= 0;
        case 'Critical Stock':
          return product.stockQuantity > 0 && product.stockQuantity <= 2;
        case 'Low Stock':
          return product.stockQuantity > 2 && product.stockQuantity <= 5;
        case 'Medium Stock':
          return product.stockQuantity > 5 && product.stockQuantity <= 10;
        default:
          return true;
      }
    }).toList();

    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('No alerts found'),
      );
    }

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${product.categoryId}'),
                Text('Price: ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}'),
              ],
            ),
            trailing: _buildStockStatus(product.stockQuantity),
            onTap: () {
              // Navigate to product details or edit screen
            },
          ),
        );
      },
    );
  }

  Widget _buildStockStatus(int quantity) {
    Color color;
    String status;
    
    if (quantity <= 0) {
      color = Colors.red;
      status = 'Out of Stock';
    } else if (quantity <= 2) {
      color = Colors.purple;
      status = 'Critical Stock';
    } else if (quantity <= 5) {
      color = Colors.orange;
      status = 'Low Stock';
    } else if (quantity <= 10) {
      color = Colors.yellow.shade700;
      status = 'Medium Stock';
    } else {
      color = Colors.green;
      status = 'In Stock';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '$status ($quantity)',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 