import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../bloc/bloc.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_payments_card.dart';
import '../widgets/monthly_chart_card.dart';

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

  final List<String> periods = [
    'week',
    'month',
    'year',
  ];

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
    
    // Animations
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

    // Démarrer les animations
    _slideController.forward();
    _fadeController.forward();

    context.read<DashboardBloc>().add(LoadDashboardData(period: selectedPeriod));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = widget.showAppBar
        ? SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: const FlexibleSpaceBar(
                title: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                centerTitle: false,
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(periodIcons[selectedPeriod], size: 20),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                  onSelected: (period) {
                    if (period != selectedPeriod) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedPeriod = period;
                      });
                      context.read<DashboardBloc>().add(
                            ChangeDashboardPeriod(period: period),
                          );
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  itemBuilder: (context) {
                    return periods.map((period) {
                      final isSelected = period == selectedPeriod;
                      return PopupMenuItem(
                        value: period,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppConstants.primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  periodIcons[period],
                                  color: isSelected 
                                      ? AppConstants.primaryColor 
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                periodLabels[period] ?? period,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? AppConstants.primaryColor : Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppConstants.primaryColor,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<DashboardBloc>().add(
                          RefreshDashboardData(period: selectedPeriod),
                        );
                  },
                ),
              ),
            ],
          )
        : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildLoadingState();
          }

          if (state is DashboardError && state.currentData == null) {
            return _buildErrorState(state.message);
          }

          final data = state is DashboardLoaded
              ? state.data
              : state is DashboardError
                  ? state.currentData!
                  : state is DashboardRefreshing
                      ? state.currentData
                      : null;

          if (data == null) {
            return _buildLoadingState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(
                    RefreshDashboardData(period: selectedPeriod),
                  );
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (appBar != null) appBar,
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildWelcomeHeader(),
                          const SizedBox(height: 24),
                          _buildStatsGrid(data.stats),
                          const SizedBox(height: 24),
                          MonthlyChartCard(chartData: data.monthlyChart),
                          const SizedBox(height: 24),
                          RecentPaymentsCard(
                            payments: data.recentPayments,
                            onSeeAll: () {
                              // TODO: Navigate to payments page
                            }, onViewAll: () {
                              // TODO: Navigate to all payments page
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
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

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        if (widget.showAppBar)
          const SliverAppBar(
            title: Text('Dashboard'),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const LoadingWidget(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chargement du dashboard...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return CustomScrollView(
      slivers: [
        if (widget.showAppBar)
          const SliverAppBar(
            title: Text('Erreur'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        SliverFillRemaining(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<DashboardBloc>().add(
                                LoadDashboardData(period: selectedPeriod),
                              );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Text(
                            'Réessayer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  periodLabels[selectedPeriod] ?? selectedPeriod,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          StatsCard(
            title: 'Revenus totaux',
            value: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: 'F CFA',
              decimalDigits: 0,
            ).format(stats.totalIncome),
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: '+${stats.completedPayments} paiements',
          ),
          StatsCard(
            title: 'Dépenses totales',
            value: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: 'F CFA',
              decimalDigits: 0,
            ).format(stats.totalExpense),
            icon: Icons.trending_down,
            color: Colors.red,
            subtitle: '${stats.totalPayments} paiements',
          ),
          StatsCard(
            title: 'Balance nette',
            value: NumberFormat.currency(
              locale: 'fr_FR',
              symbol: 'F CFA',
              decimalDigits: 0,
            ).format(stats.netBalance),
            icon: stats.netBalance >= 0
                ? Icons.account_balance_wallet
                : Icons.warning,
            color: stats.netBalance >= 0 ? Colors.blue : Colors.orange,
            subtitle: periodLabels[stats.period] ?? stats.period,
          ),
          StatsCard(
            title: 'En attente',
            value: '${stats.pendingPayments}',
            icon: Icons.schedule,
            color: Colors.orange,
            subtitle: '${stats.failedPayments} échecs',
          ),
        ],
      ),
    );
  }
}