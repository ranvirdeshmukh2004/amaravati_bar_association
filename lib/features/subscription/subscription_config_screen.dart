import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'package:drift/drift.dart' as drift; // For Value

class SubscriptionConfigScreen extends ConsumerStatefulWidget {
  const SubscriptionConfigScreen({super.key});

  @override
  ConsumerState<SubscriptionConfigScreen> createState() =>
      _SubscriptionConfigScreenState();
}

class _SubscriptionConfigScreenState
    extends ConsumerState<SubscriptionConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  DateTime? _startDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final db = ref.read(databaseProvider);
    final config = await db.subscriptionConfigDao.getConfig();
    if (mounted) {
      setState(() {
        if (config != null) {
          _amountController.text = config.monthlyAmount.toString();
          _startDate = config.subscriptionStartDate;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    try {
      final db = ref.read(databaseProvider);
      final amount = double.parse(_amountController.text);
      
      await db.subscriptionConfigDao.updateConfig(amount, _startDate!); // DAO method takes (double, DateTime)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration Saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Subscription Start Date'),
                subtitle: Text(
                  _startDate == null
                      ? 'Not Set'
                      : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
