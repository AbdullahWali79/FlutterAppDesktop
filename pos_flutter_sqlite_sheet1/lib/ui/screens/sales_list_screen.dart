import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/sale_provider.dart';
import '../../data/models/sale.dart';
import '../../config/constants.dart';
import 'new_sale_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SaleProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showDateRangePicker,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToNewSale(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeHeader(),
          Expanded(
            child: _buildSalesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'From: ${_formatDate(_startDate)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'To: ${_formatDate(_endDate)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        if (saleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (saleProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${saleProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final sales = saleProvider.sales.where((sale) {
          return sale.date.isAfter(_startDate) && sale.date.isBefore(_endDate.add(const Duration(days: 1)));
        }).toList();

        if (sales.isEmpty) {
          return const Center(
            child: Text('No sales found for the selected period'),
          );
        }

        return ListView.builder(
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return _buildSaleCard(sale);
          },
        );
      },
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          'Sale #${sale.id}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDate(sale.date)}'),
            Text('Total: ${AppConstants.currencySymbol}${sale.totalAmount.toStringAsFixed(2)}'),
            Text('Payment: ${sale.paymentMethod}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(sale.status),
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _showSaleDetails(context, sale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _navigateToNewSale(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewSaleScreen()),
    );
  }

  void _showSaleDetails(BuildContext context, Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sale Details #${sale.id}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder(
                  future: context.read<SaleProvider>().loadSaleItems(sale.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = context.watch<SaleProvider>().currentSaleItems;
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.productName),
                          subtitle: Text('Quantity: ${item.quantity}'),
                          trailing: Text(
                            '${AppConstants.currencySymbol}${item.total.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              _buildSaleSummary(sale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaleSummary(Sale sale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subtotal: ${AppConstants.currencySymbol}${sale.totalAmount.toStringAsFixed(2)}'),
        Text('Discount: ${AppConstants.currencySymbol}${sale.discount.toStringAsFixed(2)}'),
        Text('Tax: ${AppConstants.currencySymbol}${sale.tax.toStringAsFixed(2)}'),
        const Divider(),
        Text(
          'Total: ${AppConstants.currencySymbol}${(sale.totalAmount - sale.discount + sale.tax).toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 