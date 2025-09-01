import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../../../domain/entities/payment.dart';

class PaymentDetailsCard extends StatelessWidget {
  final Payment payment;

  const PaymentDetailsCard({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          _buildHeader(context),
          const SizedBox(height: 24),
          ..._buildDetailItems(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Informations détaillées',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailItems() {
    final List<Widget> items = [];

    items.add(_buildDetailItem(
      'Type de transaction',
      payment.type.displayName,
      Icons.swap_horiz,
      payment.isIncome ? Colors.green : Colors.red,
    ));

    if (payment.description != null && payment.description!.isNotEmpty) {
      items.add(_buildDetailItem(
        'Description',
        payment.description!,
        Icons.description,
        Colors.blue,
      ));
    }

    if (payment.category != null && payment.category!.isNotEmpty) {
      items.add(_buildDetailItem(
        'Catégorie',
        payment.category!,
        Icons.category,
        Colors.purple,
      ));
    }

    items.add(_buildDetailItem(
      'Référence',
      payment.reference,
      Icons.receipt_long,
      Colors.orange,
    ));

    items.add(_buildDetailItem(
      'Date de création',
      DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR')
          .format(payment.createdAt),
      Icons.schedule,
      Colors.grey,
    ));

    items.add(_buildDetailItem(
      'Dernière modification',
      DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR')
          .format(payment.updatedAt),
      Icons.update,
      Colors.grey,
    ));

    if (payment.processedAt != null) {
      items.add(_buildDetailItem(
        'Date de traitement',
        DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR')
            .format(payment.processedAt!),
        Icons.check_circle,
        Colors.green,
      ));
    }

    return items;
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}