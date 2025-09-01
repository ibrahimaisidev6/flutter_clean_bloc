// payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import 'widgets/payments_view.dart';

class PaymentsPage extends StatelessWidget {
  final bool showAppBar;

  const PaymentsPage({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PaymentListBloc>()..add(const LoadPayments()),
      child: PaymentsView(showAppBar: showAppBar),
    );
  }
}