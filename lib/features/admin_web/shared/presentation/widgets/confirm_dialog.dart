// lib/features/admin_web/shared/presentation/widgets/confirm_dialog.dart
// Dialog konfirmasi untuk aksi tulis (setujui, tolak, nonaktifkan, dll.)

import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

enum ConfirmVariant { primary, danger, warning }

class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.variant = ConfirmVariant.primary,
    this.requireNote = false,
    this.noteLabel = 'Catatan',
    this.notePlaceholder = 'Tulis catatan...',
    this.noteRequired = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final ConfirmVariant variant;
  final bool requireNote;
  final String noteLabel;
  final String notePlaceholder;
  final bool noteRequired;

  /// Returns the note (if [requireNote] is true) or null, or returns null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    ConfirmVariant variant = ConfirmVariant.primary,
    bool requireNote = false,
    String noteLabel = 'Catatan',
    String notePlaceholder = 'Tulis catatan...',
    bool noteRequired = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        variant: variant,
        requireNote: requireNote,
        noteLabel: noteLabel,
        notePlaceholder: notePlaceholder,
        noteRequired: noteRequired,
      ),
    );
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  final _noteController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (widget.noteRequired && _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.noteLabel} wajib diisi.')),
      );
      return;
    }
    setState(() => _loading = true);
    Navigator.of(context).pop(
      widget.requireNote ? _noteController.text.trim() : '',
    );
  }

  Color get _confirmColor => switch (widget.variant) {
        ConfirmVariant.danger => AdminColors.bdTxLight,
        ConfirmVariant.warning => AdminColors.wnTxLight,
        ConfirmVariant.primary => AdminColors.g6,
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.message),
          if (widget.requireNote) ...[
            const SizedBox(height: 16),
            Text(
              widget.noteLabel + (widget.noteRequired ? ' *' : ''),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: widget.notePlaceholder,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(null),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: _confirmColor,
          ),
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
