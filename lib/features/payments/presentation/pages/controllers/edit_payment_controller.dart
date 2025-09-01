// controllers/edit_payment_controller.dart
import 'package:flutter/material.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';

class EditPaymentController extends ChangeNotifier {
  final Payment _originalPayment;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  late final TextEditingController categoryController;
  late final TextEditingController referenceController;

  PaymentType _selectedType = PaymentType.expense;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Getters
  PaymentType get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;

  EditPaymentController(this._originalPayment) {
    _initializeControllers();
    _setupChangeListeners();
  }

  void _initializeControllers() {
    titleController = TextEditingController(text: _originalPayment.title);
    descriptionController = TextEditingController(
        text: _originalPayment.description ?? '');
    amountController = TextEditingController(
        text: _originalPayment.amount.toString());
    categoryController = TextEditingController(
        text: _originalPayment.category ?? '');
    referenceController = TextEditingController(
        text: _originalPayment.reference);
    _selectedType = _originalPayment.type;
  }

  void _setupChangeListeners() {
    titleController.addListener(_onFormChanged);
    descriptionController.addListener(_onFormChanged);
    amountController.addListener(_onFormChanged);
    categoryController.addListener(_onFormChanged);
    referenceController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final hasChanges = titleController.text != _originalPayment.title ||
        descriptionController.text != (_originalPayment.description ?? '') ||
        amountController.text != _originalPayment.amount.toString() ||
        categoryController.text != (_originalPayment.category ?? '') ||
        referenceController.text != _originalPayment.reference ||
        _selectedType != _originalPayment.type;

    if (hasChanges != _hasChanges) {
      _hasChanges = hasChanges;
      notifyListeners();
    }
  }

  void updatePaymentType(PaymentType type) {
    if (_selectedType != type) {
      _selectedType = type;
      _onFormChanged();
      notifyListeners();
    }
  }

  void setCategory(String category) {
    categoryController.text = category;
  }

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  bool validate() {
    return formKey.currentState?.validate() ?? false;
  }

  Payment createUpdatedPayment() {
    final amount = double.parse(amountController.text);

    return Payment(
      id: _originalPayment.id,
      userId: _originalPayment.userId,
      title: titleController.text.trim(),
      amount: amount,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      category: categoryController.text.trim().isEmpty
          ? null
          : categoryController.text.trim(),
      reference: referenceController.text.trim().isEmpty
          ? _originalPayment.reference
          : referenceController.text.trim(),
      type: _selectedType,
      status: _originalPayment.status,
      createdAt: _originalPayment.createdAt,
      updatedAt: DateTime.now(),
      processedAt: _originalPayment.processedAt,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    categoryController.dispose();
    referenceController.dispose();
    super.dispose();
  }
}