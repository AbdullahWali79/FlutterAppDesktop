import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/product.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
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

  Future<void> _showProductDialog({Product? product}) async {
    final isEdit = product != null;
    final idController = TextEditingController(text: product?.id ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Product ID'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter product ID' : null,
                  enabled: !isEdit, // Don't allow editing ID
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter category' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter price';
                    final val = double.tryParse(v);
                    if (val == null || val < 0) return 'Enter valid price';
                    return null;
                  },
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter stock';
                    final val = int.tryParse(v);
                    if (val == null || val < 0) return 'Enter valid stock';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final newProduct = Product(
                  id: idController.text.trim(),
                  name: nameController.text.trim(),
                  category: categoryController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  stock: int.parse(stockController.text.trim()),
                );
                final appState = context.read<AppState>();
                if (isEdit) {
                  await appState.updateProduct(newProduct);
                } else {
                  await appState.addProduct(newProduct);
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final appState = context.read<AppState>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await appState.deleteProduct(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppState>().products;
    final filteredProducts = _filterProducts(products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredProducts.map((product) => DataRow(
                    cells: [
                      DataCell(Text(product.id)),
                      DataCell(Text(product.name)),
                      DataCell(Text(product.category)),
                      DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                      DataCell(Text(product.stock.toString(), style: TextStyle(color: product.stock > 0 ? Colors.black : Colors.red))),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () => _showProductDialog(product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            color: Colors.red,
                            onPressed: () => _confirmDelete(product),
                          ),
                        ],
                      )),
                    ],
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 