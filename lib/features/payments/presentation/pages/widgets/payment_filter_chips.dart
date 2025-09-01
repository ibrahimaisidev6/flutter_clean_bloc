// widgets/payment_filter_chips.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../../bloc/bloc.dart';
import '../controllers/payments_controller.dart';
import '../utils/payment_utils.dart';

class PaymentFilterChips extends StatelessWidget {
  final PaymentsController controller;

  const PaymentFilterChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.selectedStatus != null)
              _FilterChip(
                label: PaymentUtils.getStatusText(controller.selectedStatus!),
                color: PaymentUtils.getStatusColor(controller.selectedStatus!),
                onDelete: () {
                  controller.updateFilters(null, controller.selectedType, controller.dateRange);
                  _applyFilters(context);
                },
              ),
            if (controller.selectedType != null)
              _FilterChip(
                label: PaymentUtils.getTypeText(controller.selectedType!),
                color: controller.selectedType == PaymentType.income ? Colors.green : Colors.red,
                onDelete: () {
                  controller.updateFilters(controller.selectedStatus, null, controller.dateRange);
                  _applyFilters(context);
                },
              ),
            if (controller.dateRange != null)
              _FilterChip(
                label: _formatDateRange(controller.dateRange!),
                color: Colors.blue,
                onDelete: () {
                  controller.updateFilters(controller.selectedStatus, controller.selectedType, null);
                  _applyFilters(context);
                },
              ),
            if (controller.hasActiveFilters())
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: ActionChip(
                  label: const Text('Tout effacer'),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    controller.clearFilters();
                    context.read<PaymentListBloc>().add(const ClearFilters());
                  },
                  backgroundColor: Colors.grey[100],
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTimeRange range) {
    return '${DateFormat('dd/MM').format(range.start)} - ${DateFormat('dd/MM').format(range.end)}';
  }

  void _applyFilters(BuildContext context) {
    context.read<PaymentListBloc>().add(FilterPayments(
          status: controller.selectedStatus,
          type: controller.selectedType,
          startDate: controller.dateRange?.start,
          endDate: controller.dateRange?.end,
        ));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onDelete;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        deleteIcon: Icon(Icons.close, size: 18, color: color),
        onDeleted: onDelete,
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }
}