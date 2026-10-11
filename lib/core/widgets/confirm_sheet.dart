import 'package:flutter/material.dart';
import 'primary_button.dart';

class ConfirmSheetItem {
  final String label;
  final String value;
  final bool isHighlight;

  const ConfirmSheetItem({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });
}

class ConfirmSheet extends StatelessWidget {
  final String title;
  final List<ConfirmSheetItem> items;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String confirmLabel;

  const ConfirmSheet({
    super.key,
    required this.title,
    required this.items,
    required this.onConfirm,
    this.onCancel,
    this.isLoading = false,
    this.confirmLabel = 'Confirm & Proceed',
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required List<ConfirmSheetItem> items,
    required Future<void> Function() onConfirmed,
    String confirmLabel = 'Confirm & Proceed',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _StatefulConfirmSheet(
        title: title,
        items: items,
        onConfirmed: onConfirmed,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _StatefulConfirmSheet extends StatefulWidget {
  final String title;
  final List<ConfirmSheetItem> items;
  final Future<void> Function() onConfirmed;
  final String confirmLabel;

  const _StatefulConfirmSheet({
    required this.title,
    required this.items,
    required this.onConfirmed,
    required this.confirmLabel,
  });

  @override
  State<_StatefulConfirmSheet> createState() => _StatefulConfirmSheetState();
}

class _StatefulConfirmSheetState extends State<_StatefulConfirmSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item.value,
                          style: TextStyle(
                            fontWeight: item.isHighlight ? FontWeight.bold : FontWeight.w600,
                            fontSize: item.isHighlight ? 18 : 15,
                            color: item.isHighlight ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: widget.confirmLabel,
              isLoading: _isLoading,
              onPressed: () async {
                final navigator = Navigator.of(context);
                setState(() => _isLoading = true);
                try {
                  await widget.onConfirmed();
                  navigator.pop(true);
                } catch (_) {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
            const SizedBox(height: 12),
            if (!_isLoading)
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
