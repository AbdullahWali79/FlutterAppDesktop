import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/sale.dart';
import '../providers/app_state.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final List<SaleItem> _cartItems = [];
  Customer? _selectedCustomer;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
             product.category.toLowerCase().contains(query) ||
             product.id.toLowerCase().contains(query);
    }).toList();
  }

  void _addToCart(Product product) {
    setState(() {
      final existingItem = _cartItems.firstWhere(
        (item) => item.productId == product.id,
        orElse: () => SaleItem(
          productId: product.id,
          productName: product.name,
          quantity: 0,
          unitPrice: product.price,
          totalPrice: 0,
        ),
      );

      if (existingItem.quantity < product.stock) {
        if (_cartItems.contains(existingItem)) {
          _cartItems.remove(existingItem);
        }
        _cartItems.add(SaleItem(
          productId: product.id,
          productName: product.name,
          quantity: existingItem.quantity + 1,
          unitPrice: product.price,
          totalPrice: product.price * (existingItem.quantity + 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough stock available'),
          ),
        );
      }
    });
  }

  void _removeFromCart(SaleItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _updateQuantity(SaleItem item, int quantity) {
    if (quantity <= 0) {
      _removeFromCart(item);
      return;
    }

    final product = context.read<AppState>().products.firstWhere(
          (p) => p.id == item.productId,
        );

    if (quantity > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough stock available'),
        ),
      );
      return;
    }

    setState(() {
      _cartItems.remove(item);
      _cartItems.add(SaleItem(
        productId: item.productId,
        productName: item.productName,
        quantity: quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.unitPrice * quantity,
      ));
    });
  }

  Future<void> _completeSale() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
        ),
      );
      return;
    }

    Customer? customer;
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      customer = Customer(
        name: _nameController.text,
        phone: _phoneController.text,
      );
      await context.read<AppState>().addCustomer(customer);
    }

    final sale = Sale(
      items: _cartItems,
      customer: customer,
      totalAmount: _cartItems.fold(
        0,
        (sum, item) => sum + item.totalPrice,
      ),
    );

    await context.read<AppState>().addSale(sale);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sale completed successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;
    final filteredProducts = _filterProducts(products);
    final total = _cartItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
      ),
      body: Row(
        children: [
          // Products list
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search products',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Stock')),
                          DataColumn(label: Text('Add')),
                        ],
                        rows: filteredProducts.map((product) => DataRow(
                          cells: [
                            DataCell(Text(product.name)),
                            DataCell(Text(product.category)),
                            DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                            DataCell(Text(
                              product.stock.toString(),
                              style: TextStyle(
                                color: product.stock > 0 ? Colors.black : Colors.red,
                              ),
                            )),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart),
                                onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cart and customer info
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '\$${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => _updateQuantity(
                                      item,
                                      item.quantity - 1,
                                    ),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _updateQuantity(
                                      item,
                                      item.quantity + 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: \$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _completeSale,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                            child: const Text('Complete Sale'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 