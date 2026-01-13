import 'package:flutter/material.dart';
import '../models.dart'; // Go up one level

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDetailCard(
          children: [
            _buildDetailRow(
              context,
              label: 'Internal Business ID',
              valueWidget: const Text(
                kInternalBusinessId,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: kPrimaryColor),
              ),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              label: 'Business Name',
              valueWidget: const Text(
                'Dairy King Wholesale',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
            const Divider(),
            _buildDetailRow(
              context,
              label: 'Contact Email',
              valueWidget: const Text(
                'info@dairyking.com',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Account Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDetailCard(
          children: [
            _buildDetailRow(
              context,
              label: 'Technical User ID (Firebase UID)',
              valueWidget: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  kTechnicalUserId,
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {}, // Mock Sign Out action
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sign Out (Mock)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required String label, required Widget valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }
}