// widgets/payments_filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../utils/payment_utils.dart';
import 'date_filter_widget.dart';

class PaymentsFilterDialog extends StatefulWidget {
  final PaymentStatus? selectedStatus;
  final PaymentType? selectedType;
  final DateTimeRange? dateRange;
  final Function(PaymentStatus?, PaymentType?, DateTimeRange?) onApply;

  const PaymentsFilterDialog({
    super.key,
    required this.selectedStatus,
    required this.selectedType,
    required this.dateRange,
    required this.onApply,
  });

  @override
  State<PaymentsFilterDialog> createState() => _PaymentsFilterDialogState();
}

class _PaymentsFilterDialogState extends State<PaymentsFilterDialog>
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              Expanded(child: _buildFilterContent()),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusFilterSection(
            selectedStatus: _status,
            onStatusChanged: (status) => setState(() => _status = status),
          ),
          const SizedBox(height: 32),
          _TypeFilterSection(
            selectedType: _type,
            onTypeChanged: (type) => setState(() => _type = type),
          ),
          const SizedBox(height: 32),
          _DateFilterSection(
            dateRange: _dateRange,
            onDateRangeChanged: (range) => setState(() => _dateRange = range),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
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
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
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
    );
  }
}

class _StatusFilterSection extends StatelessWidget {
  final PaymentStatus? selectedStatus;
  final ValueChanged<PaymentStatus?> onStatusChanged;

  const _StatusFilterSection({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterSection(
      title: 'Statut du paiement',
      icon: Icons.radio_button_checked,
      color: Colors.orange,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PaymentStatus.values.map((status) {
          final isSelected = selectedStatus == status;
          final color = PaymentUtils.getStatusColor(status);
          final text = PaymentUtils.getStatusText(status);

          return _FilterChipButton(
            label: text,
            color: color,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.selectionClick();
              onStatusChanged(isSelected ? null : status);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _TypeFilterSection extends StatelessWidget {
  final PaymentType? selectedType;
  final ValueChanged<PaymentType?> onTypeChanged;

  const _TypeFilterSection({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterSection(
      title: 'Type de transaction',
      icon: Icons.swap_horiz,
      color: Colors.blue,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: PaymentType.values.map((type) {
          final isSelected = selectedType == type;
          final color = type == PaymentType.income ? Colors.green : Colors.red;
          final text = PaymentUtils.getTypeText(type);
          final icon = type == PaymentType.income ? Icons.trending_up : Icons.trending_down;

          return _FilterChipButton(
            label: text,
            color: color,
            isSelected: isSelected,
            icon: icon,
            onTap: () {
              HapticFeedback.selectionClick();
              onTypeChanged(isSelected ? null : type);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _DateFilterSection extends StatelessWidget {
  final DateTimeRange? dateRange;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;

  const _DateFilterSection({
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterSection(
      title: 'Période',
      icon: Icons.date_range,
      color: Colors.purple,
      child: DateFilterWidget(
        selectedRange: dateRange,
        onRangeChanged: onDateRangeChanged,
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
          child,
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}