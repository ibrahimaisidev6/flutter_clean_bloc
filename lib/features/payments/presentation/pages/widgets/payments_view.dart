// widgets/payments_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/bloc.dart';
import '../controllers/payments_controller.dart';
import 'payments_app_bar.dart';
import 'payments_content.dart';
import 'payments_floating_button.dart';
import 'payments_filter_dialog.dart';

class PaymentsView extends StatefulWidget {
  final bool showAppBar;

  const PaymentsView({super.key, this.showAppBar = true});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView>
    with TickerProviderStateMixin {
  late PaymentsController controller;

  @override
  void initState() {
    super.initState();
    controller = PaymentsController(this);
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: BlocBuilder<PaymentListBloc, PaymentListState>(
            builder: (context, state) {
              return PaymentsContent(
                controller: controller,
                showAppBar: widget.showAppBar,
                onFilterTap: _showFilterDialog,
                onRefreshTap: _onRefresh,
              );
            },
          ),
          floatingActionButton: PaymentsFloatingButton(
            controller: controller,
            onPressed: _navigateToCreatePayment,
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentsFilterDialog(
        selectedStatus: controller.selectedStatus,
        selectedType: controller.selectedType,
        dateRange: controller.dateRange,
        onApply: (status, type, dateRange) {
          controller.updateFilters(status, type, dateRange);
          _applyFilters();
        },
      ),
    );
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    context.read<PaymentListBloc>().add(const RefreshPayments());
  }

  void _applyFilters() {
    context.read<PaymentListBloc>().add(FilterPayments(
          status: controller.selectedStatus,
          type: controller.selectedType,
          startDate: controller.dateRange?.start,
          endDate: controller.dateRange?.end,
        ));
  }

  void _navigateToCreatePayment() {
    HapticFeedback.lightImpact();
    controller.navigateToCreatePayment(context).then((_) {
      context.read<PaymentListBloc>().add(const RefreshPayments());
    });
  }
}