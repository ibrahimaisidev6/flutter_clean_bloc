import 'package:flutter/material.dart';
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

class _DashboardPageState extends State<DashboardPage> {
  String selectedPeriod = 'month';
  
  final List<String> periods = [
    'week',
    'month', 
    'year',
  ];

  final Map<String, String> periodLabels = {
    'week': 'Semaine',
    'month': 'Mois',
    'year': 'Année',
  };

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData(period: selectedPeriod));
  }

  // Corrections pour dashboard_page.dart - lignes 89-95
  @override
  Widget build(BuildContext context) {
    final appBar = widget.showAppBar ? AppBar(
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          onSelected: (period) {
            if (period != selectedPeriod) {
              setState(() {
                selectedPeriod = period;
              });
              context.read<DashboardBloc>().add(
                ChangeDashboardPeriod(period: period),
              );
            }
          },
          itemBuilder: (context) {
            return periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Row(
                  children: [
                    Icon(
                      period == selectedPeriod 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(periodLabels[period] ?? period),
                  ],
                ),
              );
            }).toList();
          },
        ),
      ],
    ) : null;
    
    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(
            RefreshDashboardData(period: selectedPeriod),
          );
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: LoadingWidget());
            }
            
            if (state is DashboardError && state.currentData == null) {
              return _buildErrorView(state.message);
            }
            
            final data = state is DashboardLoaded 
                ? state.data 
                : state is DashboardError 
                    ? state.currentData!
                    : state is DashboardRefreshing
                        ? state.currentData
                        : null;
                        
            if (data == null) {
              return const Center(child: LoadingWidget());
            }
            
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodHeader(),
                      const SizedBox(height: 16),
                      _buildStatsGrid(data.stats),
                      const SizedBox(height: 24),
                      MonthlyChartCard(chartData: data.monthlyChart),
                      const SizedBox(height: 24),
                      RecentPaymentsCard(
                        payments: data.recentPayments,
                        onViewAll: () {
                          // TODO: Navigate to payments page
                        },
                      ),
                      const SizedBox(height: 100), // Extra space for bottom navigation
                    ],
                  ),
                ),
                if (state is DashboardRefreshing)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: LoadingWidget(),
                    ),
                  ),
                if (state is DashboardError && state.currentData != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Erreur: ${state.message}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildPeriodHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.8),
            AppConstants.primaryColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Période sélectionnée',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                periodLabels[selectedPeriod] ?? selectedPeriod,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            DateFormat('dd MMMM yyyy', 'fr_FR').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(stats) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatsCard(
          title: 'Revenus totaux',
          value: NumberFormat.currency(
            locale: 'fr_FR',
            symbol: '€',
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
            symbol: '€',
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
            symbol: '€',
            decimalDigits: 0,
          ).format(stats.netBalance),
          icon: stats.netBalance >= 0 ? Icons.account_balance_wallet : Icons.warning,
          color: stats.netBalance >= 0 ? AppConstants.primaryColor : Colors.orange,
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
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<DashboardBloc>().add(
                  LoadDashboardData(period: selectedPeriod),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}