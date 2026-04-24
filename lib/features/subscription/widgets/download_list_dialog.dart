import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../export_service.dart';
import '../subscription_service.dart';

/// A dialog that lets users choose between downloading:
/// 1. Provisional Voter List (fully paid members)
/// 2. Pending People Details (members with dues)
///
/// Each option shows default columns and an expandable section
/// to toggle additional fields before downloading.
class DownloadListDialog extends ConsumerStatefulWidget {
  final List<SubscriptionStatus> allStatuses;

  const DownloadListDialog({super.key, required this.allStatuses});

  @override
  ConsumerState<DownloadListDialog> createState() => _DownloadListDialogState();
}

class _DownloadListDialogState extends ConsumerState<DownloadListDialog> {
  bool _isExporting = false;

  // Extra fields state
  late List<ExtraField> _voterExtras;
  late List<ExtraField> _pendingExtras;
  bool _showVoterExtras = false;
  bool _showPendingExtras = false;

  @override
  void initState() {
    super.initState();
    _voterExtras = voterListExtraFields();
    _pendingExtras = pendingListExtraFields();
  }

  int get _paidCount =>
      widget.allStatuses.where((s) => s.balance <= 0).length;
  int get _pendingCount =>
      widget.allStatuses.where((s) => s.balance > 0).length;

  Future<void> _downloadVoterList() async {
    setState(() => _isExporting = true);
    final success = await ref
        .read(subscriptionExportProvider)
        .exportVoterListXlsx(widget.allStatuses, extraFields: _voterExtras);
    if (mounted) {
      setState(() => _isExporting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Voter List saved to Documents\\provisionalVoterList!'
                : 'Export failed. Check disk space and try again.',
          ),
          backgroundColor: success ? Colors.green[700] : Colors.red[400],
        ),
      );
    }
  }

  Future<void> _downloadPendingList() async {
    setState(() => _isExporting = true);
    final success = await ref
        .read(subscriptionExportProvider)
        .exportPendingListXlsx(widget.allStatuses, extraFields: _pendingExtras);
    if (mounted) {
      setState(() => _isExporting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Pending list saved to Documents\\pendingVoterList!'
                : 'Export failed. Check disk space and try again.',
          ),
          backgroundColor: success ? Colors.green[700] : Colors.red[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: _isExporting
            ? const Padding(
                padding: EdgeInsets.all(48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating file...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Title ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Download List',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose a list to download as .xlsx',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            splashRadius: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // ==========================================
                      // OPTION 1: Provisional Voter List
                      // ==========================================
                      _buildDownloadCard(
                        context: context,
                        icon: Icons.how_to_vote_rounded,
                        iconColor: Colors.green[700]!,
                        title: 'Provisional Voter List',
                        subtitle:
                            'Fully paid members only • $_paidCount members',
                        defaultFields: 'Sr. No., Name, Phone Number',
                        showExtras: _showVoterExtras,
                        extraFields: _voterExtras,
                        onToggleExtras: () => setState(
                          () => _showVoterExtras = !_showVoterExtras,
                        ),
                        onFieldToggle: (index, val) => setState(
                          () => _voterExtras[index].selected = val,
                        ),
                        onDownload: _downloadVoterList,
                      ),

                      const SizedBox(height: 14),

                      // ==========================================
                      // OPTION 2: Pending People Details
                      // ==========================================
                      _buildDownloadCard(
                        context: context,
                        icon: Icons.pending_actions_rounded,
                        iconColor: Colors.red[700]!,
                        title: 'Pending People Details',
                        subtitle:
                            'Members with dues • $_pendingCount members',
                        defaultFields:
                            'Sr. No., Name, Phone Number, Due Amount',
                        showExtras: _showPendingExtras,
                        extraFields: _pendingExtras,
                        onToggleExtras: () => setState(
                          () => _showPendingExtras = !_showPendingExtras,
                        ),
                        onFieldToggle: (index, val) => setState(
                          () => _pendingExtras[index].selected = val,
                        ),
                        onDownload: _downloadPendingList,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDownloadCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String defaultFields,
    required bool showExtras,
    required List<ExtraField> extraFields,
    required VoidCallback onToggleExtras,
    required void Function(int, bool) onFieldToggle,
    required VoidCallback onDownload,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBorderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final headerBgColor = iconColor.withOpacity(isDark ? 0.15 : 0.08);
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final defaultFieldsColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final extraFieldsBgColor = isDark ? Colors.grey[850] : Colors.grey[50];
    final extraFieldsBorderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;
    final fieldTextColor = isDark ? Colors.grey[200] : Colors.grey[900];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Default Fields Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Default: $defaultFields',
                    style: TextStyle(
                      fontSize: 12,
                      color: defaultFieldsColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add More Fields Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              onPressed: onToggleExtras,
              icon: Icon(
                showExtras ? Icons.expand_less : Icons.add_circle_outline,
                size: 18,
              ),
              label: Text(
                showExtras ? 'Hide extra fields' : 'Add more fields',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
              ),
            ),
          ),

          // Extra Fields Checkboxes (Animated)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: extraFieldsBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: extraFieldsBorderColor),
                ),
                child: Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: List.generate(extraFields.length, (i) {
                    final field = extraFields[i];
                    return SizedBox(
                      width: 210,
                      child: CheckboxListTile(
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          field.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: fieldTextColor,
                          ),
                        ),
                        value: field.selected,
                        onChanged: (val) =>
                            onFieldToggle(i, val ?? false),
                      ),
                    );
                  }),
                ),
              ),
            ),
            crossFadeState: showExtras
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // Download Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.file_download, size: 18),
              label: const Text('Download .xlsx'),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
