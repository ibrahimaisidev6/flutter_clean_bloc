import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
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
  
  // Variables pour les justificatifs
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
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildTypeSelector(),
                      const SizedBox(height: 24),
                      _buildFormSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
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

  Widget _buildHeader() {
    return Container(
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_card,
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
                  'Nouveau paiement',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enregistrez vos revenus et dépenses avec justificatifs',
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

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horiz,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Type de transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  PaymentType.income,
                  'Revenus',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTypeOption(
                  PaymentType.expense,
                  'Dépenses',
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
      PaymentType type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                )
              : null,
          color: isSelected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_document,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Informations du paiement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Titre
          _buildModernTextField(
            controller: _titleController,
            label: 'Titre',
            hint: 'Ex: Courses alimentaires, Salaire mensuel...',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer un titre';
              }
              if (value.trim().length < 3) {
                return 'Le titre doit contenir au moins 3 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Description enrichie
          _buildDescriptionField(),
          const SizedBox(height: 20),
          
          // Montant
          _buildAmountField(),
          const SizedBox(height: 20),
          
          // Catégorie
          _buildCategoryField(),
          const SizedBox(height: 20),
          
          // Référence
          _buildModernTextField(
            controller: _referenceController,
            label: 'Référence',
            hint: 'Référence du paiement (optionnel)',
            icon: Icons.receipt_long,
            isOptional: true,
          ),
          const SizedBox(height: 24),
          
          // Section justificatifs
          _buildAttachmentSection(),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(width: 4),
            Text(
              '(optionnel, Markdown accepté)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Description détaillée de la transaction...\n\nVous pouvez utiliser **Markdown** pour formater votre texte.',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.description,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de la section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_file_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Justificatif',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Optionnel',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Zone de dépôt ou affichage du fichier
        if (_attachmentFile == null) 
          _buildFileDropZone()
        else 
          _buildFileDisplay(),
      ],
    );
  }

  Widget _buildFileDropZone() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: Colors.blue[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ajouter un justificatif',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'PDF, JPG, JPEG ou PNG (max 5MB)',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.blue[700],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Appuyez pour sélectionner',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: Colors.green[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fichier sélectionné',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _attachmentFileName ?? 'Fichier inconnu',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bouton changer
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton supprimer
                  GestureDetector(
                    onTap: _removeFile,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[700],
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.green[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Le fichier sera joint à votre paiement comme justificatif.',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isOptional = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'optionnel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (_selectedType == PaymentType.income
                        ? Colors.green
                        : Colors.red)
                    .withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedType == PaymentType.income
                          ? Colors.green
                          : Colors.red,
                      (_selectedType == PaymentType.income
                              ? Colors.green
                              : Colors.red)
                          .withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.euro,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              suffixText: 'F CFA',
              suffixStyle: TextStyle(
                color: _selectedType == PaymentType.income
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedType == PaymentType.income
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedType == PaymentType.income
                      ? Colors.green[300]!
                      : Colors.red[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedType == PaymentType.income
                      ? Colors.green
                      : Colors.red,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
                return 'Le montant ne peut pas dépasser 1 000 000 F CFA';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Catégorie',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'optionnel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _categoryController,
          decoration: InputDecoration(
            hintText: 'Sélectionnez ou tapez une catégorie',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _categoryController.text == category;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _categoryController.text = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedType == PaymentType.income ? Colors.green : Colors.red,
            (_selectedType == PaymentType.income ? Colors.green : Colors.red)
                .withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_selectedType == PaymentType.income
                    ? Colors.green
                    : Colors.red)
                .withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitForm,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                ] else ...[
                  const Icon(Icons.add_circle_outline, size: 24, color: Colors.white),
                  const SizedBox(width: 12),
                ],
                Text(
                  _isLoading ? 'Création en cours...' : 'Créer le paiement',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
                if (_attachmentFile != null && !_isLoading) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Avec justificatif',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes pour la gestion des fichiers
  Future<void> _pickFile() async {
    try {
      HapticFeedback.selectionClick();
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Validation de la taille du fichier (5MB max)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          CustomSnackBar.showError(
            context,
            message: 'Le fichier ne peut pas dépasser 5MB',
          );
          return;
        }
        
        setState(() {
          _attachmentFile = file;
          _attachmentFileName = result.files.single.name;
        });
        
        CustomSnackBar.showSuccess(
          context,
          message: 'Fichier sélectionné avec succès',
        );
      }
    } catch (e) {
      CustomSnackBar.showError(
        context,
        message: 'Erreur lors de la sélection du fichier',
      );
    }
  }

  void _removeFile() {
    HapticFeedback.selectionClick();
    setState(() {
      _attachmentFile = null;
      _attachmentFileName = null;
    });
    CustomSnackBar.showInfo(
      context,
      message: 'Fichier supprimé',
    );
  }

  IconData _getFileIcon() {
    if (_attachmentFileName == null) return Icons.insert_drive_file;
    
    final extension = _attachmentFileName!.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _amountController.clear();
    _categoryController.clear();
    _referenceController.clear();
    setState(() {
      _selectedType = PaymentType.expense;
      _attachmentFile = null;
      _attachmentFileName = null;
    });
  }

  void _showFormResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Réinitialiser le formulaire'),
          content: const Text(
            'Êtes-vous sûr de vouloir effacer toutes les données saisies ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
                CustomSnackBar.showInfo(
                  context,
                  message: 'Formulaire réinitialisé',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Effacer'),
            ),
          ],
        );
      },
    );
  }
}