import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/user_details.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUser(UserDetails user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print("Błąd tworzenia użytkownika: $e");
      throw Exception("Nie udało się utworzyć użytkownika.");
    }
  }

  Future<UserDetails?> getCurrentUserDetails() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? UserDetails.fromDocument(doc) : null;
  }

  Stream<UserDetails?> getCurrentUserDetailsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      return doc.exists ? UserDetails.fromDocument(doc) : null;
    });
  }

  Future<UserDetails?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? UserDetails.fromDocument(doc) : null;
  }

  Future<void> updateUser(UserDetails user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print("Błąd aktualizacji użytkownika: $e");
      throw Exception("Nie udało się zaktualizować danych użytkownika.");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print("Błąd usuwania użytkownika: $e");
      throw Exception("Nie udało się usunąć użytkownika.");
    }
  }
}
