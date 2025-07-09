import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/product_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/models/product.dart';
import '../../config/constants.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _buildProductList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedCategoryId == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId = null;
                  });
                },
              ),
              ...categoryProvider.categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${productProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        var filteredProducts = productProvider.products;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filteredProducts = filteredProducts.where((product) {
            return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (product.barcode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList();
        }

        // Apply category filter
        if (_selectedCategoryId != null) {
          filteredProducts = filteredProducts
              .where((product) => product.categoryId == _selectedCategoryId)
              .toList();
        }

        if (filteredProducts.isEmpty) {
          return const Center(
            child: Text('No products found'),
          );
        }

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}'),
            Row(
              children: [
                Text('Stock: '),
                _buildStockStatus(product.stockQuantity),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddEditProductDialog(context, product),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, product),
            ),
          ],
        ),
        onTap: () => _showProductDetails(context, product),
      ),
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

  Future<void> _showAddEditProductDialog(BuildContext context, [Product? product]) async {
    final TextEditingController nameController = TextEditingController(text: product?.name);
    final TextEditingController descriptionController = TextEditingController(text: product?.description);
    final TextEditingController priceController = TextEditingController(text: product?.price.toString());
    final TextEditingController barcodeController = TextEditingController(text: product?.barcode);
    final TextEditingController stockController = TextEditingController(text: product?.stockQuantity.toString());
    int? selectedCategoryId = product?.categoryId;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(labelText: 'Barcode'),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  return DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No Category'),
                      ),
                      ...categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      selectedCategoryId = value;
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newProduct = Product(
                id: product?.id,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0,
                categoryId: selectedCategoryId,
                barcode: barcodeController.text,
                stockQuantity: int.tryParse(stockController.text) ?? 0,
              );

              if (product == null) {
                await context.read<ProductProvider>().addProduct(newProduct);
              } else {
                await context.read<ProductProvider>().updateProduct(newProduct);
              }

              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(product == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ProductProvider>().deleteProduct(product.id!);
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Price: ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}'),
            Text('Stock: ${product.stockQuantity}'),
            if (product.description != null) Text('Description: ${product.description}'),
            if (product.barcode != null) Text('Barcode: ${product.barcode}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 