import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/sale_provider.dart';
import '../../data/providers/product_provider.dart';
import '../../data/models/sale.dart';
import '../../data/models/sale_item.dart';
import '../../data/models/product.dart';
import '../../config/constants.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final List<SaleItem> _saleItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _paymentMethod = 'Cash';
  String? _customerName;
  String? _customerPhone;
  String? _notes;
  double _discount = 0;
  double _tax = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
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
        title: const Text('New Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _completeSale,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildProductList(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildSaleDetails(),
                ),
              ],
            ),
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

  Widget _buildProductList() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var filteredProducts = productProvider.products;

        if (_searchQuery.isNotEmpty) {
          filteredProducts = filteredProducts.where((product) {
            return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (product.barcode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList();
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
        subtitle: Text(
          'Price: ${AppConstants.currencySymbol}${product.price.toStringAsFixed(2)}\nStock: ${product.stockQuantity}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () => _addProductToSale(product),
        ),
      ),
    );
  }

  Widget _buildSaleDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sale Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSaleItemsList(),
          ),
          const Divider(),
          _buildSaleSummary(),
          const SizedBox(height: 16),
          _buildPaymentDetails(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _completeSale,
            child: const Text('Complete Sale'),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItemsList() {
    if (_saleItems.isEmpty) {
      return const Center(
        child: Text('No items added to sale'),
      );
    }

    return ListView.builder(
      itemCount: _saleItems.length,
      itemBuilder: (context, index) {
        final item = _saleItems[index];
        return ListTile(
          title: Text(item.productName),
          subtitle: Text('${AppConstants.currencySymbol}${item.price.toStringAsFixed(2)} x ${item.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppConstants.currencySymbol}${item.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeItemFromSale(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaleSummary() {
    final subtotal = _saleItems.fold<double>(0, (sum, item) => sum + item.total);
    final total = subtotal - _discount + _tax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Subtotal: ${AppConstants.currencySymbol}${subtotal.toStringAsFixed(2)}'),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Discount',
                  prefixText: AppConstants.currencySymbol,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _discount = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Tax',
                  prefixText: AppConstants.currencySymbol,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _tax = double.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
        const Divider(),
        Text(
          'Total: ${AppConstants.currencySymbol}${total.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _paymentMethod,
          decoration: const InputDecoration(
            labelText: 'Payment Method',
          ),
          items: ['Cash', 'Card', 'Mobile Payment'].map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _paymentMethod = value;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Customer Name',
          ),
          onChanged: (value) {
            setState(() {
              _customerName = value;
            });
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Customer Phone',
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {
              _customerPhone = value;
            });
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Notes',
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
      ],
    );
  }

  void _addProductToSale(Product product) {
    if (product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product is out of stock')),
      );
      return;
    }

    final existingItemIndex = _saleItems.indexWhere((item) => item.productId == product.id);
    if (existingItemIndex != -1) {
      final existingItem = _saleItems[existingItemIndex];
      if (existingItem.quantity >= product.stockQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough stock available')),
        );
        return;
      }

      setState(() {
        _saleItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
          total: (existingItem.price * (existingItem.quantity + 1)) - existingItem.discount,
        );
      });
    } else {
      setState(() {
        _saleItems.add(
          SaleItem(
            productId: product.id!,
            productName: product.name,
            price: product.price,
            quantity: 1,
            total: product.price,
            saleId: 0, // Will be set when sale is created
          ),
        );
      });
    }
  }

  void _removeItemFromSale(int index) {
    setState(() {
      _saleItems.removeAt(index);
    });
  }

  Future<void> _completeSale() async {
    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to the sale')),
      );
      return;
    }

    final subtotal = _saleItems.fold<double>(0, (sum, item) => sum + item.total);
    final total = subtotal - _discount + _tax;

    final sale = Sale(
      date: DateTime.now(),
      totalAmount: total,
      discount: _discount,
      tax: _tax,
      customerName: _customerName,
      customerPhone: _customerPhone,
      notes: _notes,
      paymentMethod: _paymentMethod,
    );

    try {
      await context.read<SaleProvider>().createSale(sale, _saleItems);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating sale: $e')),
        );
      }
    }
  }
} 