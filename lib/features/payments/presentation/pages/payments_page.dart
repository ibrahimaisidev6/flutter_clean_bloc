import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/payment.dart';
import '../bloc/bloc.dart';
import '../widgets/payment_stats_widget.dart';
import '../widgets/date_filter_widget.dart';
import 'payment_detail_page.dart';
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

class _PaymentsViewState extends State<PaymentsView> {
  final _scrollController = ScrollController();
  PaymentStatus? _selectedStatus;
  PaymentType? _selectedType;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
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
    final appBar = widget.showAppBar ? AppBar(
      title: const Text('Paiements'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<PaymentListBloc>().add(const RefreshPayments()),
        ),
      ],
    ) : null;
    
    return Scaffold(
      appBar: appBar,
      body: BlocBuilder<PaymentListBloc, PaymentListState>(
        builder: (context, state) {
          if (state is PaymentListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentListError) {
            final payments = state.currentPayments ?? [];
            if (payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur: ${state.message}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<PaymentListBloc>().add(const RefreshPayments()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun paiement trouvé',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez par créer votre premier paiement',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_hasActiveFilters()) _buildFilterChips(),
              if (payments.isNotEmpty) PaymentStatsWidget(payments: payments),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<PaymentListBloc>().add(const RefreshPayments());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    itemCount: hasReachedMax ? payments.length : payments.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= payments.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final payment = payments[index];
                      return _buildPaymentCard(context, payment);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreatePayment(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedStatus != null)
            Chip(
              label: Text(_getStatusText(_selectedStatus!)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() => _selectedStatus = null);
                _applyFilters();
              },
            ),
          if (_selectedType != null)
            Chip(
              label: Text(_getTypeText(_selectedType!)),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() => _selectedType = null);
                _applyFilters();
              },
            ),
          if (_dateRange != null)
            Chip(
              label: Text(
                '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
              ),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() => _dateRange = null);
                _applyFilters();
              },
            ),
          if (_hasActiveFilters())
            ActionChip(
              label: const Text('Effacer'),
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedType = null;
                  _dateRange = null;
                });
                context.read<PaymentListBloc>().add(const ClearFilters());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToPaymentDetail(context, payment.id.toString()),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: payment.isIncome ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      payment.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: payment.isIncome ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (payment.description?.isNotEmpty == true)
                          Text(
                            payment.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(payment.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${payment.isIncome ? '+' : '-'}${payment.amount.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: payment.isIncome ? Colors.green : Colors.red,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(payment.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(payment.status).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _getStatusText(payment.status),
                          style: TextStyle(
                            color: _getStatusColor(payment.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.category?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(payment.category!),
                  backgroundColor: Colors.grey[100],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedStatus != null || _selectedType != null || _dateRange != null;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      MaterialPageRoute(builder: (context) => const CreatePaymentPage()),
    ).then((_) {
      context.read<PaymentListBloc>().add(const RefreshPayments());
    });
  }

  void _navigateToPaymentDetail(BuildContext context, String paymentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailPage(paymentId: paymentId),
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

class _FilterDialogState extends State<_FilterDialog> {
  PaymentStatus? _status;
  PaymentType? _type;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _status = widget.selectedStatus;
    _type = widget.selectedType;
    _dateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtres',
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
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PaymentStatus.values.map((status) {
                      return FilterChip(
                        label: Text(_getStatusText(status)),
                        selected: _status == status,
                        onSelected: (selected) {
                          setState(() {
                            _status = selected ? status : null;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PaymentType.values.map((type) {
                      return FilterChip(
                        label: Text(_getTypeText(type)),
                        selected: _type == type,
                        onSelected: (selected) {
                          setState(() {
                            _type = selected ? type : null;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  DateFilterWidget(
                    selectedRange: _dateRange,
                    onRangeChanged: (range) {
                      setState(() => _dateRange = range);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _status = null;
                      _type = null;
                      _dateRange = null;
                    });
                  },
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_status, _type, _dateRange);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
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
}