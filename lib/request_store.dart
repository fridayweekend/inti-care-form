import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injectable boundary: widget tests never contact a real Firebase project.
abstract class RequestStore {
  Future<String?> restoreReference();
  Future<String> create(Map<String, dynamic> fields);
  Future<Map<String, dynamic>?> load(String id);
  Future<void> clearPending();
  Future<void> startNewRequest();
  String? get reference;
}

class FirebaseRequestStore implements RequestStore {
  String? _reference;
  String? _owner;
  @override
  String? get reference => _reference;

  Future<User> _user() async {
    final auth = FirebaseAuth.instance;
    // Wait for persisted web authentication before considering a new identity.
    final existing = await auth.authStateChanges().first;
    final user = existing ?? (await auth.signInAnonymously()).user;
    if (user == null) throw StateError('Anonymous sign-in did not complete.');
    return user;
  }

  @override
  Future<String?> restoreReference() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('intiCare.pending');
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _reference = data['id'] as String;
      _owner = data['owner'] as String;
    }
    return _reference;
  }

  @override
  Future<String> create(Map<String, dynamic> fields) async {
    if (_reference != null) {
      throw StateError(
        'Retrieve the existing reference before starting again.',
      );
    }
    final user = await _user();
    final ref = FirebaseFirestore.instance.collection('campusRequests').doc();
    _reference = ref.id;
    _owner = user.uid;
    final prefs = await SharedPreferences.getInstance();
    // Persist before writing. A restart must never silently allocate a new ID.
    final stored = await prefs.setString(
      'intiCare.pending',
      jsonEncode({'id': ref.id, 'owner': user.uid}),
    );
    if (!stored) {
      _reference = null;
      throw StateError('Unable to retain the request reference locally.');
    }
    // No timeout: offline writes remain pending until the backend acknowledges.
    await ref.set({
      ...fields,
      'ownerUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'submitted',
    });
    return ref.id;
  }

  @override
  Future<Map<String, dynamic>?> load(String id) async {
    final user = await _user();
    if (_owner != null && user.uid != _owner) {
      throw StateError(
        'Use the original browser profile and anonymous account.',
      );
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('campusRequests')
        .doc(id)
        .get(const GetOptions(source: Source.server));
    return snapshot.data();
  }

  @override
  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('intiCare.pending');
    _reference = null;
    _owner = null;
  }

  @override
  Future<void> startNewRequest() => clearPending();
}
