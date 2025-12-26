
  void _showDonorDetailsDialog(Donation d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(d.donorName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.phone, 'Mobile', d.donorMobile ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.email, 'Email', d.donorEmail ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on, 'Address', d.donorAddress ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.business, 'Organization', d.organization ?? 'N/A'),
            const Divider(),
             _detailRow(Icons.receipt, 'Receipt', d.receiptNumber),
             _detailRow(Icons.currency_rupee, 'Amount', d.amount.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
