// widgets/payments_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../../bloc/bloc.dart';
import '../controllers/payments_controller.dart';
import 'payments_app_bar.dart';
import 'payments_states.dart';
import 'payments_list.dart';
import 'payment_filter_chips.dart';

class PaymentsContent extends StatelessWidget {
  final PaymentsController controller;
  final bool showAppBar;
  final VoidCallback onFilterTap;
  final VoidCallback onRefreshTap;

  const PaymentsContent({
    super.key,
    required this.controller,
    required this.showAppBar,
    required this.onFilterTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentListBloc, PaymentListState>(
      builder: (context, state) {
        if (state is PaymentListLoading) {
          return PaymentsLoadingState(showAppBar: showAppBar);
        }

        if (state is PaymentListError) {
          final payments = state.currentPayments ?? [];
          if (payments.isEmpty) {
            return PaymentsErrorState(
              showAppBar: showAppBar,
              message: state.message,
            );
          }
        }

        List<Payment> payments = [];
        bool hasReachedMax = false;

        if (state is PaymentListLoaded) {
          payments = state.payments;
          hasReachedMax = state.hasReachedMax;
        } else if (state is PaymentListError) {
          payments = state.currentPayments ?? [];
          hasReachedMax = true;
        } else if (state is PaymentListRefreshing) {
          payments = state.currentPayments;
          hasReachedMax = false;
        } else if (state is PaymentListLoadingMore) {
          payments = state.currentPayments;
          hasReachedMax = false;
        }

        if (payments.isEmpty) {
          return PaymentsEmptyState(showAppBar: showAppBar);
        }

        return _buildPaymentsList(payments, hasReachedMax);
      },
    );
  }

  Widget _buildPaymentsList(List<Payment> payments, bool hasReachedMax) {
    final appBar = showAppBar
        ? PaymentsAppBar(
            controller: controller,
            onFilterTap: onFilterTap,
            onRefreshTap: onRefreshTap,
          )
        : null;

    return CustomScrollView(
      controller: controller.scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (appBar != null) appBar,
        if (controller.hasActiveFilters())
          SliverToBoxAdapter(
            child: PaymentFilterChips(controller: controller),
          ),
        SliverToBoxAdapter(child: PaymentStatsWidget(payments: payments)),
        PaymentsList(
          controller: controller,
          payments: payments,
          hasReachedMax: hasReachedMax,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}