// controllers/payments_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../create_payment_page.dart';

class PaymentsController extends ChangeNotifier {
  final TickerProvider vsync;
  late ScrollController scrollController;
  late AnimationController fabController;
  late AnimationController listController;
  late Animation<double> fabAnimation;
  late Animation<Offset> listAnimation;

  // Filters
  PaymentStatus? _selectedStatus;
  PaymentType? _selectedType;
  DateTimeRange? _dateRange;

  // State
  bool _showFab = true;

  // Getters
  PaymentStatus? get selectedStatus => _selectedStatus;
  PaymentType? get selectedType => _selectedType;
  DateTimeRange? get dateRange => _dateRange;
  bool get showFab => _showFab;
  Animation<double> get fabAnimationValue => fabAnimation;
  Animation<Offset> get listAnimationValue => listAnimation;

  PaymentsController(this.vsync);

  void initialize() {
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fabController,
      curve: Curves.elasticOut,
    ));

    listAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: listController,
      curve: Curves.easeOutCubic,
    ));

    fabController.forward();
    listController.forward();
  }

  void _onScroll() {
    // Masquer/afficher le FAB selon la direction du scroll
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) {
        fabController.reverse();
        _showFab = false;
        notifyListeners();
      }
    } else if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) {
        fabController.forward();
        _showFab = true;
        notifyListeners();
      }
    }
  }

  bool get isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void updateFilters(PaymentStatus? status, PaymentType? type, DateTimeRange? dateRange) {
    _selectedStatus = status;
    _selectedType = type;
    _dateRange = dateRange;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedType = null;
    _dateRange = null;
    notifyListeners();
  }

  bool hasActiveFilters() {
    return _selectedStatus != null || _selectedType != null || _dateRange != null;
  }

  Future<void> navigateToCreatePayment(BuildContext context) {
    return Navigator.push(
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
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    fabController.dispose();
    listController.dispose();
    super.dispose();
  }
}