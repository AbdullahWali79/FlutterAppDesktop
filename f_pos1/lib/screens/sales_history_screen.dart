import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/sale.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<AppState>().sales;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
      ),
      body: ListView.builder(
        itemCount: sales.length,
        itemBuilder: (context, index) {
          final sale = sales[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: ExpansionTile(
              title: Text(
                dateFormat.format(sale.timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Total: \$${sale.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                ),
              ),
              children: [
                if (sale.customer != null)
                  ListTile(
                    title: const Text('Customer'),
                    subtitle: Text(
                      '${sale.customer!.name} (${sale.customer!.phone})',
                    ),
                  ),
                const Divider(),
                ...sale.items.map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        '\$${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                      ),
                      trailing: Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${sale.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
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