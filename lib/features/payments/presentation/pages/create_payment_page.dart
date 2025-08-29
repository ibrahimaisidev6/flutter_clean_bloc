import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/bloc.dart';

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

class _CreatePaymentViewState extends State<CreatePaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _referenceController = TextEditingController();

  PaymentType _selectedType = PaymentType.expense;
  bool _isLoading = false;

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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau paiement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is PaymentCreated) {
            CustomSnackBar.showSuccess(
              context,
              message: 'Paiement créé avec succès',
            );
            Navigator.of(context).pop(true);
          } else if (state is PaymentError) {
            CustomSnackBar.showError(
              context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeSelector(),
                  const SizedBox(height: 24),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildCategoryField(),
                  const SizedBox(height: 16),
                  _buildReferenceField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return AnimatedCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type de transaction',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  PaymentType.income,
                  'Revenus',
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTypeOption(
                  PaymentType.expense,
                  'Dépenses',
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(PaymentType type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Titre',
        hintText: 'Ex: Courses alimentaires, Salaire mensuel...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez entrer un titre';
        }
        if (value.trim().length < 3) {
          return 'Le titre doit contenir au moins 3 caractères';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (optionnel)',
        hintText: 'Description détaillée...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Montant',
        hintText: '0.00',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.euro),
        suffixText: '€',
        prefixIconColor: _selectedType == PaymentType.income ? Colors.green : Colors.red,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez entrer un montant';
        }
        final amount = double.tryParse(value);
        if (amount == null) {
          return 'Veuillez entrer un montant valide';
        }
        if (amount <= 0) {
          return 'Le montant doit être supérieur à 0';
        }
        if (amount > 1000000) {
          return 'Le montant ne peut pas dépasser 1 000 000 €';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: 'Catégorie (optionnel)',
            hintText: 'Sélectionnez ou tapez une catégorie',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            return GestureDetector(
              onTap: () {
                _categoryController.text = category;
              },
              child: Chip(
                label: Text(category),
                backgroundColor: _categoryController.text == category
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.grey[100],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReferenceField() {
    return TextFormField(
      controller: _referenceController,
      decoration: const InputDecoration(
        labelText: 'Référence (optionnel)',
        hintText: 'Référence du paiement',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedButton(
        onPressed: _submitForm,
        isLoading: _isLoading,
        backgroundColor: _selectedType == PaymentType.income ? Colors.green : Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'Créer le paiement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    
    // Créer un objet Payment pour correspondre à l'interface du repository
    final payment = Payment(
      id: 0, // Sera ignoré par le serveur
      userId: 1, // Correction: userId doit être un int, pas String
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
      CreatePayment(payment, userId: 1, title: _titleController.text.trim(), amount: amount, type: _selectedType),
    );
  }
}