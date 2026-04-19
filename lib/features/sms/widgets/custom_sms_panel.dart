import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amaravati_bar_association/features/database/app_database.dart';
import 'package:amaravati_bar_association/features/database/database_provider.dart';
import 'package:amaravati_bar_association/features/sms/sms_service.dart';
import '../../../core/auth/app_session.dart';
import '../../../core/widgets/responsive_split_view.dart';

// Provider to fetch all active members
final allMembersProvider = StreamProvider<List<Member>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.membersDao.watchAllMembers(sortAscending: true);
});

class CustomSmsPanel extends ConsumerStatefulWidget {
  const CustomSmsPanel({super.key});

  @override
  ConsumerState<CustomSmsPanel> createState() => _CustomSmsPanelState();
}

class _CustomSmsPanelState extends ConsumerState<CustomSmsPanel> {
  final Set<String> _selectedPhones = {};
  final TextEditingController _messageController = TextEditingController();
  String _searchQuery = '';
  bool _selectAll = false;
  bool _isSending = false;

  void _toggleSelection(String phone) {
    setState(() {
      if (_selectedPhones.contains(phone)) {
        _selectedPhones.remove(phone);
      } else {
        _selectedPhones.add(phone);
      }
      _selectAll = false; // Deselect "Select All" if individual is toggled
      // Note: Logic to check if all are now selected could be added but skipping for performance
    });
  }

  void _handleSelectAll(List<Member> members) {
    setState(() {
      if (_selectAll) {
        _selectedPhones.clear();
        _selectAll = false;
      } else {
        _selectedPhones.clear();
        for (var m in members) {
           if (m.mobileNumber.isNotEmpty) {
             _selectedPhones.add(m.mobileNumber);
           }
        }
        _selectAll = true;
      }
    });
  }
  
  String get _previewMessage {
    String msg = _messageController.text;
    if (msg.isEmpty) return 'Message Preview...';
    // Example replacement for preview (using dummy data)
    return msg
      .replaceAll('{{Name}}', 'John Doe')
      .replaceAll('{{RegistrationNumber}}', 'ABA/123/2023');
  }

  List<Member> _filterMembers(List<Member> members) {
    if (_searchQuery.isEmpty) return members;
    final q = _searchQuery.toLowerCase();
    return members.where((m) =>
      m.firstName.toLowerCase().contains(q) ||
      m.surname.toLowerCase().contains(q) ||
      m.registrationNumber.toLowerCase().contains(q) ||
      m.mobileNumber.contains(q)
    ).toList();
  }

  Future<void> _sendSms() async {
    if (_selectedPhones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one member.')));
      return;
    }
    if (_messageController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a message.')));
       return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Send'),
        content: Text('Send SMS to ${_selectedPhones.length} members?\n\nPreview:\n$_previewMessage'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSending = true);

    try {
      // Create Personalized Messages logic if needed. 
      // Current requirement: "Free-text custom message" with placeholders.
      // Fast2SMS API with 'Route: v3'/Transactional usually takes ONE message for ALL numbers.
      // If we use placeholders that vary per user (like Name), we MUST send Individual SMS calls OR use a provider that supports variable mapping.
      // Fast2SMS Bulk V2 usually supports one message for all.
      // NOTE: If user puts {{Name}}, and we send one payload... Fast2SMS DOES NOT natively replace {{Name}} from our DB unless we upload a CSV/Contact Group.
      // With the current Cloud Function design (accepting list of valid numbers + 1 message), 
      // we CANNOT support {{Name}} for bulk send unless we make 1 API call per user or the API supports it.
      
      // OPTION 1: Loop in Frontend -> Many Cloud Function calls (Expensive, slow)
      // OPTION 2: Loop in Backend -> Pass map of {phone: name} (Better, but complexity)
      // OPTION 3: Disallow Placeholders for Bulk if unsupported.
      // 
      // Re-reading prompt: "Optional placeholders: {{Name}}".
      // Implementation Plan decision: If placeholders are present, we probably need to send individually or batched.
      // Given the constraints and typical Fast2SMS implementation:
      // If placeholders are detected, we'll warn or send sequentially.
      // For this MVP, let's assume we send one common message OR strip placeholders if bulk. 
      // ACTUALLY, usually with these features, people want the placeholder.
      // Let's implement a simple batch looper in the Service/Frontend for this specific requirement if placeholders exist.
      // 
      // Revised Strategy:
      // If message contains {{}}, we must send individually (or grouped by name?). No, individually.
      // Since `sendSms` Cloud Function takes `numbers` (array) and `message` (string).
      // We can't use placeholders with a single Cloud Function call unless we change the CF signature.
      // Let's stick to "Common Message" for now to follow the architecture simplicity, 
      // OR update the logic.
      // 
      // Compromise: I will check for placeholders. If present, I warn "Bulk placeholders require individual sending which may take time". 
      // Or I send 1 request per user.
      // Cloud Function limit is usually high enough for loop.
      // Let's implement Client-side loop for placeholders for now, as it's safest without changing CF signature too much.
      
      final hasPlaceholders = _messageController.text.contains('{{');
      
      if (hasPlaceholders) {
         // We need to map phones back to names.
         // This is complex because _selectedPhones is just a set of strings.
         // I need the Member objects.
         final members = ref.read(allMembersProvider).value ?? [];
         final selectedMembers = members.where((m) => _selectedPhones.contains(m.mobileNumber)).toList();
         
         int successCount = 0;
         for (var m in selectedMembers) {
           String personalized = _messageController.text
             .replaceAll('{{Name}}', '${m.firstName} ${m.surname}')
             .replaceAll('{{RegistrationNumber}}', m.registrationNumber);
             
           await ref.read(smsServiceProvider).sendSms(
             numbers: [m.mobileNumber],
             message: personalized,
             type: 'custom',
           );
           successCount++;
         }
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent $successCount personalized messages.')));

      } else {
         // Bulk Send
         final count = await ref.read(smsServiceProvider).sendSms(
          numbers: _selectedPhones.toList(),
          message: _messageController.text,
          type: 'custom',
        );
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully sent to $count members.')));
      }

      setState(() {
        _selectedPhones.clear();
        _messageController.clear();
        _selectAll = false;
      });
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }



// ... class ...
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

    return ResponsiveSplitView(
      scrollableLeft: false,
      left: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Members',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            Expanded(
                child: membersAsync.when(
              data: (allMembers) {
                final members = _filterMembers(allMembers);
                return Column(
                  children: [
                     CheckboxListTile(
                        title: Text('Select All (${members.length})'),
                        value: _selectAll,
                        onChanged: isViewer ? null : (val) => _handleSelectAll(members),
                        controlAffinity: ListTileControlAffinity.leading,
                     ),
                     const Divider(height: 1),
                     Expanded(
                       child: ListView.builder(
                         itemCount: members.length,
                         itemBuilder: (context, index) {
                           final m = members[index];
                           final isSelected = _selectedPhones.contains(m.mobileNumber);
                           if (m.mobileNumber.isEmpty) return const SizedBox.shrink();
                           
                           return CheckboxListTile(
                             value: isSelected,
                             title: Text('${m.firstName} ${m.surname}'),
                             subtitle: Text('${m.registrationNumber} • ${m.mobileNumber}'),
                             onChanged: isViewer ? null : (val) => _toggleSelection(m.mobileNumber),
                             secondary: CircleAvatar(child: Text(m.firstName[0])),
                           );
                         },
                       ),
                     ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${_selectedPhones.length} members selected'),
            )
          ],
        ),
      ),
      right: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compose Message', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type your message here...',
                  helperText: 'Available placeholders: {{Name}}, {{RegistrationNumber}}',
                ),
                onChanged: (v) => setState((){}),
                readOnly: isViewer,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${_messageController.text.length} chars', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(_previewMessage, style: const TextStyle(fontFamily: 'monospace')),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: (_isSending || isViewer) ? null : _sendSms,
                  icon: _isSending 
                    ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth:2, color: Colors.white)) 
                    : (isViewer ? const Icon(Icons.block) : const Icon(Icons.send)),
                  label: Text(_isSending ? 'Sending...' : (isViewer ? 'Sending Disabled (Viewer)' : 'Send SMS')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
