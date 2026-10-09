import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Innovation #1: SMS/USSD alert subscriptions (app side).
///
/// Farmers/cooperative managers opt in with their phone number and home
/// district. The sync pipeline reads /subscribers (falling back to
/// data/subscribers.json) and sends bilingual SMS alerts whenever a
/// watched district's risk level escalates - no internet needed on the
/// farmer's side.
class AlertSubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Subscribe a phone number to risk alerts for [districtId] ('all'
  /// watches every district). Idempotent per phone+district.
  Future<void> subscribe({
    required String phone,
    required String districtId,
    required String districtName,
    String language = 'rw',
    String role = 'farmer',
  }) async {
    final normalized = _normalizePhone(phone);
    final docId = '${normalized}_$districtId'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    await _firestore.collection('subscribers').doc(docId).set({
      'phone': normalized,
      'district_id': districtId,
      'district_name': districtName,
      'language': language,
      'role': role,
      'opted_in_at': FieldValue.serverTimestamp(),
      'active': true,
    });
  }

  /// Remove an opt-in (SMS STOP handling / in-app unsubscribe).
  Future<void> unsubscribe({
    required String phone,
    required String districtId,
  }) async {
    final normalized = _normalizePhone(phone);
    final docId = '${normalized}_$districtId'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    await _firestore.collection('subscribers').doc(docId).delete();
  }

  Future<bool> isSubscribed({
    required String phone,
    required String districtId,
  }) async {
    final normalized = _normalizePhone(phone);
    final docId = '${normalized}_$districtId'
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    final doc = await _firestore.collection('subscribers').doc(docId).get();
    return doc.exists && (doc.data()?['active'] ?? true) == true;
  }

  static String _normalizePhone(String phone) {
    var p = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (p.startsWith('0')) {
      p = '+250${p.substring(1)}';
    }
    if (!p.startsWith('+')) {
      p = '+$p';
    }
    return p;
  }

  /// Show the opt-in dialog; returns true if the subscription succeeded.
  static Future<bool> showSubscribeDialog(
    BuildContext context, {
    required String districtId,
    required String districtName,
  }) async {
    final controller = TextEditingController();
    String language = 'rw';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF152629),
              title: const Text(
                'SMS Risk Alerts',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get a bilingual SMS when $districtName\'s post-harvest '
                    'risk escalates. Works on any phone - no internet needed.',
                    style: const TextStyle(
                      color: Color(0xFFB0BEC5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '078xxxxxxx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: language,
                    dropdownColor: const Color(0xFF1A3035),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => language = value ?? 'rw');
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: const Color(0xFF0B1617),
                  ),
                  child: const Text('Subscribe'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || controller.text.trim().isEmpty) return false;

    try {
      await AlertSubscriptionService().subscribe(
        phone: controller.text.trim(),
        districtId: districtId,
        districtName: districtName,
        language: language,
      );
      return true;
    } catch (e) {
      debugPrint('SMS subscription failed: $e');
      return false;
    }
  }
}
