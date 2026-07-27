import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tool_core_app/l10n/app_localizations.dart';

import '../../domain/entities/work_order_status.dart';
import '../../domain/entities/work_order_status_codes.dart';
import '../cubit/order_detail_cubit.dart';
import '../cubit/order_detail_state.dart';
import 'sheet_widgets.dart';

Future<bool?> showChangeStatusSheet(
  BuildContext context,
  OrderDetailCubit cubit, {
  required String currentStatusCode,
  required List<WorkOrderStatus> statuses,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ChangeStatusSheet(
        currentStatusCode: currentStatusCode,
        statuses: statuses,
      ),
    ),
  );
}

class _ChangeStatusSheet extends StatefulWidget {
  final String currentStatusCode;
  final List<WorkOrderStatus> statuses;

  const _ChangeStatusSheet({
    required this.currentStatusCode,
    required this.statuses,
  });

  @override
  State<_ChangeStatusSheet> createState() => _ChangeStatusSheetState();
}

class _ChangeStatusSheetState extends State<_ChangeStatusSheet> {
  final _commentController = TextEditingController();
  String? _selectedCode;
  bool _saving = false;
  String? _errorCode;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Forward statuses only (catalog comes in workflow order), plus
  /// CANCELLED as the destructive option.
  List<WorkOrderStatus> get _forwardOptions {
    final currentIndex = widget.statuses.indexWhere(
      (s) => s.code == widget.currentStatusCode,
    );
    return [
      for (var i = currentIndex + 1; i < widget.statuses.length; i++)
        if (widget.statuses[i].code != WorkOrderStatusCodes.cancelled)
          widget.statuses[i],
    ];
  }

  WorkOrderStatus? get _cancelOption {
    for (final status in widget.statuses) {
      if (status.code == WorkOrderStatusCodes.cancelled) return status;
    }
    return null;
  }

  Future<void> _onSubmit() async {
    if (_selectedCode == null) return;
    setState(() {
      _saving = true;
      _errorCode = null;
    });
    final cubit = context.read<OrderDetailCubit>();
    final comment = _commentController.text.trim();
    final ok = await cubit.changeStatus(
      _selectedCode!,
      comment: comment.isEmpty ? null : comment,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _errorCode = ok
          ? null
          : (cubit.state is OrderDetailLoaded
                ? (cubit.state as OrderDetailLoaded).errorCode
                : null);
    });
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cancel = _cancelOption;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 20),
            Text(
              l10n.advanceStatus,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            for (final status in _forwardOptions)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _selectedCode == status.code
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _selectedCode == status.code
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
                title: Text(status.name),
                onTap: _saving
                    ? null
                    : () => setState(() => _selectedCode = status.code),
              ),
            if (cancel != null)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _selectedCode == cancel.code
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _selectedCode == cancel.code
                      ? scheme.error
                      : scheme.outlineVariant,
                ),
                title: Text(cancel.name, style: TextStyle(color: scheme.error)),
                onTap: _saving
                    ? null
                    : () => setState(() => _selectedCode = cancel.code),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.statusComment,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            SheetErrorBanner(errorCode: _errorCode),
            const SizedBox(height: 24),
            SheetSubmitButton(
              saving: _saving,
              onPressed: _selectedCode != null ? _onSubmit : null,
              label: l10n.save,
            ),
          ],
        ),
      ),
    );
  }
}
