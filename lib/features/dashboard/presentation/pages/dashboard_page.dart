import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_loading_state.dart';
import 'widgets/dashboard_error_state.dart';
import 'widgets/dashboard_content.dart';

class DashboardPage extends StatefulWidget {
  final bool showAppBar;

  const DashboardPage({super.key, this.showAppBar = true});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  String selectedPeriod = 'month';
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> periods = ['week', 'month', 'year'];

  final Map<String, String> periodLabels = {
    'week': 'Cette semaine',
    'month': 'Ce mois',
    'year': 'Cette année',
  };

  final Map<String, IconData> periodIcons = {
    'week': Icons.date_range,
    'month': Icons.calendar_month,
    'year': Icons.calendar_today,
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    context.read<DashboardBloc>().add(LoadDashboardData(period: selectedPeriod));
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPeriodChanged(String period) {
    if (period != selectedPeriod) {
      HapticFeedback.selectionClick();
      setState(() {
        selectedPeriod = period;
      });
      context.read<DashboardBloc>().add(
        ChangeDashboardPeriod(period: period),
      );
    }
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    context.read<DashboardBloc>().add(
      RefreshDashboardData(period: selectedPeriod),
    );
  }

  Future<void> _onPullToRefresh() async {
    context.read<DashboardBloc>().add(
      RefreshDashboardData(period: selectedPeriod),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return DashboardLoadingState(showAppBar: widget.showAppBar);
          }

          if (state is DashboardError && state.currentData == null) {
            return DashboardErrorState(
              message: state.message,
              showAppBar: widget.showAppBar,
              onRetry: () => context.read<DashboardBloc>().add(
                LoadDashboardData(period: selectedPeriod),
              ),
            );
          }

          final data = _extractData(state);
          if (data == null) {
            return DashboardLoadingState(showAppBar: widget.showAppBar);
          }

          return RefreshIndicator(
            onRefresh: _onPullToRefresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (widget.showAppBar)
                  DashboardAppBar(
                    selectedPeriod: selectedPeriod,
                    periods: periods,
                    periodLabels: periodLabels,
                    periodIcons: periodIcons,
                    onPeriodChanged: _onPeriodChanged,
                    onRefresh: _onRefresh,
                  ),
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: DashboardContent(
                        data: data,
                        selectedPeriod: selectedPeriod,
                        periodLabels: periodLabels,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  dynamic _extractData(DashboardState state) {
    return state is DashboardLoaded
        ? state.data
        : state is DashboardError
            ? state.currentData
            : state is DashboardRefreshing
                ? state.currentData
                : null;
  }
}