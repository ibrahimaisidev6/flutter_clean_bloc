import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/bloc.dart';
import 'widgets/create_payment_header.dart';
import 'widgets/payment_type_selector.dart';
import 'widgets/payment_form_section.dart';
import 'widgets/payment_submit_button.dart';

class CreatePaymentPage extends StatelessWidget {
  const CreatePaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PaymentBloc>(),
      child: const CreatePaymentView(),
    );
  }
}

class CreatePaymentView extends StatefulWidget {
  const CreatePaymentView({super.key});

  @override
  State<CreatePaymentView> createState() => _CreatePaymentViewState();
}

class _CreatePaymentViewState extends State<CreatePaymentView>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _referenceController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  PaymentType _selectedType = PaymentType.expense;
  bool _isLoading = false;
  
  File? _attachmentFile;
  String? _attachmentFileName;

  final List<String> _categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Santé',
    'Loisirs',
    'Shopping',
    'Éducation',
    'Services',
    'Salaire',
    'Freelance',
    'Investissement',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _onTypeChanged(PaymentType type) {
    HapticFeedback.selectionClick();
    setState(() => _selectedType = type);
  }

  void _onCategorySelected(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      _categoryController.text = category;
    });
  }

  void _onAttachmentChanged(File? file, String? fileName) {
    setState(() {
      _attachmentFile = file;
      _attachmentFileName = fileName;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      CustomSnackBar.showError(
        context,
        message: 'Veuillez corriger les erreurs dans le formulaire',
      );
      return;
    }

    HapticFeedback.lightImpact();
    final amount = double.parse(_amountController.text);

    final payment = Payment(
      id: 0,
      userId: 1,
      title: _titleController.text.trim(),
      amount: amount,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      reference: _referenceController.text.trim().isEmpty
          ? 'REF-${DateTime.now().millisecondsSinceEpoch}'
          : _referenceController.text.trim(),
      type: _selectedType,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<PaymentBloc>().add(
      CreatePayment(
        payment,
        userId: 1,
        title: _titleController.text.trim(),
        amount: amount,
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _categoryController.text.trim().isEmpty 
            ? null 
            : _categoryController.text.trim(),
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        attachmentFile: _attachmentFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Nouveau paiement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        ),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is PaymentCreated) {
            HapticFeedback.lightImpact();
            CustomSnackBar.showSuccess(
              context,
              message: 'Paiement créé avec succès',
            );
            Navigator.of(context).pop(true);
          } else if (state is PaymentError) {
            HapticFeedback.mediumImpact();
            CustomSnackBar.showError(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CreatePaymentHeader(),
                      const SizedBox(height: 32),
                      PaymentTypeSelector(
                        selectedType: _selectedType,
                        onTypeChanged: _onTypeChanged,
                      ),
                      const SizedBox(height: 24),
                      PaymentFormSection(
                        formKey: _formKey,
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        amountController: _amountController,
                        categoryController: _categoryController,
                        referenceController: _referenceController,
                        selectedType: _selectedType,
                        categories: _categories,
                        attachmentFile: _attachmentFile,
                        attachmentFileName: _attachmentFileName,
                        onCategorySelected: _onCategorySelected,
                        onAttachmentChanged: _onAttachmentChanged,
                      ),
                      const SizedBox(height: 32),
                      PaymentSubmitButton(
                        selectedType: _selectedType,
                        isLoading: _isLoading,
                        hasAttachment: _attachmentFile != null,
                        onSubmit: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}