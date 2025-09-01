import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import 'package:payment_app/features/payments/presentation/pages/payment_detail_page.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/payment.dart';
import '../bloc/bloc.dart';
import 'widgets/payment_stats_widget.dart';
import 'widgets/date_filter_widget.dart';
import 'create_payment_page.dart';

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

class PaymentsView extends StatefulWidget {
  final bool showAppBar;

  const PaymentsView({super.key, this.showAppBar = true});

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late AnimationController _fabController;
  late AnimationController _listController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _listAnimation;

  PaymentStatus? _selectedStatus;
  PaymentType? _selectedType;
  DateTimeRange? _dateRange;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _listAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));

    _fabController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _navigateToPaymentDetail(BuildContext context, String paymentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailPage(paymentId: paymentId),
      ),
    );
  }

  void _onScroll() {
    // Masquer/afficher le FAB selon la direction du scroll
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) {
        _fabController.reverse();
        setState(() => _showFab = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) {
        _fabController.forward();
        setState(() => _showFab = true);
      }
    }

    // Pagination
    if (_isBottom) {
      context.read<PaymentListBloc>().add(const LoadMorePayments());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = widget.showAppBar
        ? SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Mes Paiements',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
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
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list),
                      if (_hasActiveFilters())
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showFilterDialog();
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
                    context
                        .read<PaymentListBloc>()
                        .add(const RefreshPayments());
                  },
                ),
              ),
            ],
          )
        : null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<PaymentListBloc, PaymentListState>(
        builder: (context, state) {
          if (state is PaymentListLoading) {
            return _buildLoadingState();
          }

          if (state is PaymentListError) {
            final payments = state.currentPayments ?? [];
            if (payments.isEmpty) {
              return _buildErrorState(state.message);
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
            return _buildEmptyState();
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (appBar != null) appBar,
              if (_hasActiveFilters())
                SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: PaymentStatsWidget(payments: payments)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= payments.length) {
                        return _buildLoadMoreIndicator();
                      }

                      final payment = payments[index];
                      return SlideTransition(
                        position: _listAnimation,
                        child: _buildModernPaymentCard(context, payment, index),
                      );
                    },
                    childCount:
                        hasReachedMax ? payments.length : payments.length + 1,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _navigateToCreatePayment(context);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        if (widget.showAppBar)
          SliverAppBar(
            title: const Text('Paiements'),
            backgroundColor: Theme.of(context).primaryColor,
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
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const CircularProgressIndicator(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chargement de vos paiements...',
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
          SliverAppBar(
            title: const Text('Erreur'),
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
                borderRadius: BorderRadius.circular(20),
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
                    'Une erreur est survenue',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
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
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context
                            .read<PaymentListBloc>()
                            .add(const RefreshPayments()),
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

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        if (widget.showAppBar)
          SliverAppBar(
            title: const Text('Paiements'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        SliverFillRemaining(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucun paiement trouvé',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Commencez par créer votre premier paiement',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _navigateToCreatePayment(context),
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Créer un paiement',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedStatus != null)
              _buildFilterChip(
                _getStatusText(_selectedStatus!),
                _getStatusColor(_selectedStatus!),
                () {
                  setState(() => _selectedStatus = null);
                  _applyFilters();
                },
              ),
            if (_selectedType != null)
              _buildFilterChip(
                _getTypeText(_selectedType!),
                _selectedType == PaymentType.income ? Colors.green : Colors.red,
                () {
                  setState(() => _selectedType = null);
                  _applyFilters();
                },
              ),
            if (_dateRange != null)
              _buildFilterChip(
                '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
                Colors.blue,
                () {
                  setState(() => _dateRange = null);
                  _applyFilters();
                },
              ),
            if (_hasActiveFilters())
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: ActionChip(
                  label: const Text('Tout effacer'),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedStatus = null;
                      _selectedType = null;
                      _dateRange = null;
                    });
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

  Widget _buildFilterChip(String label, Color color, VoidCallback onDelete) {
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

  Widget _buildModernPaymentCard(
      BuildContext context, Payment payment, int index) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 16,
        top: index == 0 ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _navigateToPaymentDetail(context, payment.id.toString());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            payment.isIncome ? Colors.green : Colors.red,
                            (payment.isIncome ? Colors.green : Colors.red)
                                .withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (payment.isIncome ? Colors.green : Colors.red)
                                    .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        payment.isIncome
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                          ),
                          if (payment.description?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              payment.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                payment.isIncome ? Colors.green : Colors.red,
                                (payment.isIncome ? Colors.green : Colors.red)
                                    .withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${payment.isIncome ? '+' : '-'}${payment.amount.toStringAsFixed(2)} F CFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payment.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(payment.status)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(payment.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(payment.status),
                                style: TextStyle(
                                  color: _getStatusColor(payment.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE dd MMMM yyyy', 'fr_FR')
                          .format(payment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    if (payment.category?.isNotEmpty == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          payment.category!,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedStatus != null ||
        _selectedType != null ||
        _dateRange != null;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _FilterDialog(
          selectedStatus: _selectedStatus,
          selectedType: _selectedType,
          dateRange: _dateRange,
          onApply: (status, type, dateRange) {
            setState(() {
              _selectedStatus = status;
              _selectedType = type;
              _dateRange = dateRange;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _applyFilters() {
    context.read<PaymentListBloc>().add(FilterPayments(
          status: _selectedStatus,
          type: _selectedType,
          startDate: _dateRange?.start,
          endDate: _dateRange?.end,
        ));
  }

  void _navigateToCreatePayment(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CreatePaymentPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ).then((_) {
      context.read<PaymentListBloc>().add(const RefreshPayments());
    });
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Complété';
      case PaymentStatus.failed:
        return 'Échoué';
    }
  }

  String _getTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.income:
        return 'Revenus';
      case PaymentType.expense:
        return 'Dépenses';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}

class _FilterDialog extends StatefulWidget {
  final PaymentStatus? selectedStatus;
  final PaymentType? selectedType;
  final DateTimeRange? dateRange;
  final Function(PaymentStatus?, PaymentType?, DateTimeRange?) onApply;

  const _FilterDialog({
    required this.selectedStatus,
    required this.selectedType,
    required this.dateRange,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog>
    with TickerProviderStateMixin {
  PaymentStatus? _status;
  PaymentType? _type;
  DateTimeRange? _dateRange;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _type = widget.selectedType;
    _dateRange = widget.dateRange;

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filtres avancés',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      'Statut du paiement',
                      Icons.radio_button_checked,
                      Colors.orange,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PaymentStatus.values.map((status) {
                          final isSelected = _status == status;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _status = isSelected ? null : status;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          _getStatusColor(status),
                                          _getStatusColor(status)
                                              .withOpacity(0.8),
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? _getStatusColor(status)
                                      : Colors.grey[300]!,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _getStatusColor(status)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection(
                      'Type de transaction',
                      Icons.swap_horiz,
                      Colors.blue,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PaymentType.values.map((type) {
                          final isSelected = _type == type;
                          final color = type == PaymentType.income
                              ? Colors.green
                              : Colors.red;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _type = isSelected ? null : type;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [color, color.withOpacity(0.8)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? color : Colors.grey[300]!,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    type == PaymentType.income
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isSelected ? Colors.white : color,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTypeText(type),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildFilterSection(
                      'Période',
                      Icons.date_range,
                      Colors.purple,
                      DateFilterWidget(
                        selectedRange: _dateRange,
                        onRangeChanged: (range) {
                          setState(() => _dateRange = range);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _status = null;
                            _type = null;
                            _dateRange = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Réinitialiser',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
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
                          widget.onApply(_status, _type, _dateRange);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(
                          child: Text(
                            'Appliquer les filtres',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
      String title, IconData icon, Color color, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Complété';
      case PaymentStatus.failed:
        return 'Échoué';
    }
  }

  String _getTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.income:
        return 'Revenus';
      case PaymentType.expense:
        return 'Dépenses';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}
