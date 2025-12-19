import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../core/constants.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../receipt/receipt_service.dart';

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered subscriptions
final filteredSubscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return db.subscriptionsDao.watchAllSubscriptions().map((list) {
    if (query.isEmpty) return list;
    return list.where((d) {
      return d.firstName.toLowerCase().contains(query) ||
          d.lastName.toLowerCase().contains(query) ||
          d.receiptNumber.toLowerCase().contains(query) ||
          d.mobileNumber.contains(query);
    }).toList();
  });
});

class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(filteredSubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Records'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SearchBar(
              hintText: 'Search by Name, Mobile or Receipt No',
              leading: const Icon(Icons.search),
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).cardColor,
              ),
            ),
          ),
        ),
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return const Center(child: Text('No records found'));
          }
          return ListView.builder(
            itemCount: subscriptions.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final subscription = subscriptions[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    child: Text(
                      subscription.firstName[0],
                      style: const TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    '${subscription.firstName} ${subscription.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt: ${subscription.receiptNumber} • ${DateFormat('dd MMM yyyy').format(subscription.subscriptionDate)}',
                      ),
                      Text('Mode: ${subscription.paymentMode}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹ ${subscription.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'Download Receipt',
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preparing Receipt...'),
                            ),
                          );
                          final pdfBytes = await ReceiptService()
                              .generateReceipt(subscription);
                          await Printing.sharePdf(
                            bytes: pdfBytes,
                            filename:
                                'ABA_Subscription_Receipt_${subscription.receiptNumber}.pdf',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
