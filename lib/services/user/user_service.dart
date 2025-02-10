// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class UserService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<Map<String, dynamic>?> getCurrentUserData() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;

//     final doc = await _firestore.collection('users').doc(user.uid).get();
//     return doc.exists ? doc.data() : null;
//   }

//   Future<Map<String, dynamic>?> getUserById(String userId) async {
//     final doc = await _firestore.collection('users').doc(userId).get();
//     return doc.exists ? doc.data() : null;
//   }

//   Future<void> updateUser({
//     required String userId,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       await _firestore.collection('users').doc(userId).update(data);
//     } catch (e) {
//       print("Błąd aktualizacji użytkownika: $e");
//       throw Exception("Nie udało się zaktualizować danych użytkownika.");
//     }
//   }

//   Future<void> deleteUser(String userId) async {
//     try {
//       await _firestore.collection('users').doc(userId).delete();
//     } catch (e) {
//       print("Błąd usuwania użytkownika: $e");
//       throw Exception("Nie udało się usunąć użytkownika.");
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/user_details.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// **Tworzy nowy dokument użytkownika w Firestore**
  Future<void> createUser(UserDetails user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print("Błąd tworzenia użytkownika: $e");
      throw Exception("Nie udało się utworzyć użytkownika.");
    }
  }

  /// **Pobiera dane aktualnie zalogowanego użytkownika**
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

  /// **Pobiera dane użytkownika na podstawie jego UID**
  Future<UserDetails?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.exists ? UserDetails.fromDocument(doc) : null;
  }

  /// **Aktualizuje dane użytkownika**
  Future<void> updateUser(UserDetails user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print("Błąd aktualizacji użytkownika: $e");
      throw Exception("Nie udało się zaktualizować danych użytkownika.");
    }
  }

  /// **Usuwa konto użytkownika z Firestore**
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print("Błąd usuwania użytkownika: $e");
      throw Exception("Nie udało się usunąć użytkownika.");
    }
  }
}
