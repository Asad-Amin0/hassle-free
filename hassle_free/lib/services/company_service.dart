import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CompanyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Get company profile (real-time stream) ──────────────────────────────
  Stream<Map<String, dynamic>> getCompanyProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value({});

    return _db
        .collection('companies')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  // ─── Update company profile ──────────────────────────────────────────────
  Future<bool> updateCompanyProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _db.collection('companies').doc(user.uid).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
          'email': user.email,
        },
        SetOptions(merge: true),
      );
      debugPrint('Company profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating company profile: $e');
      return false;
    }
  }
}
