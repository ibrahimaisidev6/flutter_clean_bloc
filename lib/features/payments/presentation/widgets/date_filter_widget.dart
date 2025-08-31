import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatefulWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onRangeChanged;

  const DateFilterWidget({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> with TickerProviderStateMixin {
  String? selectedPeriod;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final Map<String, DateTimeRange Function()> quickFilters = {
    'Aujourd\'hui': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    },
    'Cette semaine': () {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    },
    'Ce mois': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    },
    '30 derniers jours': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    },
    '3 derniers mois': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month - 2, now.day),
        end: now,
      );
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickFiltersSection(),
          const SizedBox(height: 24),
          _buildCustomDateSection(),
          if (widget.selectedRange != null) ...[
            const SizedBox(height: 16),
            _buildSelectedRangeInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.flash_on, color: Colors.blue, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Filtres rapides',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickFilters.entries.map((entry) {
            final isSelected = selectedPeriod == entry.key;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (isSelected) {
                  setState(() => selectedPeriod = null);
                  widget.onRangeChanged(null);
                } else {
                  setState(() => selectedPeriod = entry.key);
                  widget.onRangeChanged(entry.value());
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.calendar_month, color: Colors.purple, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              'Période personnalisée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _selectCustomDateRange,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.date_range,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedRange == null
                                ? 'Sélectionner une période'
                                : 'Période sélectionnée',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.selectedRange == null ? Colors.grey[600] : Colors.purple,
                            ),
                          ),
                          if (widget.selectedRange != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Du ${DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.selectedRange!.start)}\nau ${DateFormat('dd MMMM yyyy', 'fr_FR').format(widget.selectedRange!.end)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.selectedRange != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _clearCustomRange,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.clear,
                                size: 20,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedRangeInfo() {
    if (widget.selectedRange == null) return const SizedBox.shrink();

    final duration = widget.selectedRange!.end.difference(widget.selectedRange!.start).inDays + 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Période active',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$duration jour${duration > 1 ? 's' : ''} sélectionné${duration > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectCustomDateRange() async {
    // Réinitialiser le filtre rapide sélectionné
    setState(() => selectedPeriod = null);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.purple,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      HapticFeedback.selectionClick();
      widget.onRangeChanged(picked);
    }
  }

  void _clearCustomRange() {
    HapticFeedback.selectionClick();
    setState(() => selectedPeriod = null);
    widget.onRangeChanged(null);
  }
}