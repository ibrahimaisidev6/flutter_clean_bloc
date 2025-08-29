import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/payment.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/bloc.dart';
import 'edit_payment_page.dart'; // Assure-toi que ce chemin est correct

class PaymentDetailPage extends StatelessWidget {
  final String paymentId;

  const PaymentDetailPage({
    super.key,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PaymentBloc>()..add(LoadPaymentDetail(int.parse(paymentId))),
      child: PaymentDetailView(paymentId: paymentId),
    );
  }
}

class PaymentDetailView extends StatelessWidget {
  final String paymentId;

  const PaymentDetailView({
    super.key,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du paiement'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paiement supprimé avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is PaymentProcessed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paiement traité avec succès'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<PaymentBloc>().add(LoadPaymentDetail(int.parse(paymentId)));
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError && state.currentPayment == null) {
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
                    onPressed: () => context.read<PaymentBloc>().add(LoadPaymentDetail(int.parse(paymentId))),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final payment = _getPaymentFromState(state);
          if (payment == null) {
            return const Center(child: Text('Aucun paiement trouvé'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentHeader(context, payment),
                const SizedBox(height: 24),
                _buildPaymentDetails(context, payment),
                const SizedBox(height: 24),
                _buildActionButtons(context, payment),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentHeader(BuildContext context, Payment payment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: payment.isIncome ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                payment.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: payment.isIncome ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${payment.isIncome ? '+' : '-'}${payment.amount.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: payment.isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(payment.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(payment.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                payment.status.displayName, // Utilisation de l'extension
                style: TextStyle(
                  color: _getStatusColor(payment.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context, Payment payment) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Titre', payment.title),
            if (payment.description != null && payment.description!.isNotEmpty)
              _buildDetailRow('Description', payment.description!),
            _buildDetailRow('Type', payment.type.displayName), // Utilisation de l'extension
            _buildDetailRow('Statut', payment.status.displayName), // Utilisation de l'extension
            if (payment.category != null && payment.category!.isNotEmpty)
              _buildDetailRow('Catégorie', payment.category!),
            if (payment.reference.isNotEmpty)
              _buildDetailRow('Référence', payment.reference),
            _buildDetailRow('Date de création', DateFormat('dd/MM/yyyy à HH:mm').format(payment.createdAt)),
            _buildDetailRow('Dernière modification', DateFormat('dd/MM/yyyy à HH:mm').format(payment.updatedAt)),
            if (payment.processedAt != null)
              _buildDetailRow('Date de traitement', DateFormat('dd/MM/yyyy à HH:mm').format(payment.processedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Payment payment) {
    return Column(
      children: [
        if (payment.isPending) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _processPayment(context, payment.id.toString()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle),
                  SizedBox(width: 8),
                  Text('Traiter le paiement'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _editPayment(context, payment),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 4),
                    Text('Modifier'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDeleteConfirmation(context, payment.id.toString()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 4),
                    Text('Supprimer'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _processPayment(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Traiter le paiement'),
        content: const Text('Êtes-vous sûr de vouloir traiter ce paiement ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PaymentBloc>().add(ProcessPayment(int.parse(paymentId)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Traiter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editPayment(BuildContext context, Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPaymentPage(payment: payment),
      ),
    ).then((updated) {
      if (updated == true) {
        context.read<PaymentBloc>().add(LoadPaymentDetail(int.parse(paymentId)));
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le paiement'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce paiement ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PaymentBloc>().add(DeletePayment(int.parse(paymentId)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Payment? _getPaymentFromState(PaymentState state) {
    if (state is PaymentLoaded) return state.payment;
    if (state is PaymentError) return state.currentPayment;
    return null;
  }

  String _getStatusText(PaymentStatus status) {
    return status.displayName; // Utilisation de l'extension
  }

  String _getTypeText(PaymentType type) {
    return type.displayName; // Utilisation de l'extension
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