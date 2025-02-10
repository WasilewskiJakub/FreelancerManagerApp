import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user_service.dart';
import '../../domain/user_details.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<User?> registerUser({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       User? user = userCredential.user;

//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).set({
//           'firstName': firstName,
//           'lastName': lastName,
//           'email': email,
//           'createdAt': FieldValue.serverTimestamp(), // Data rejestracji
//         });

//         // Zapisz sesję użytkownika
//         await _saveUserSession(user.uid);
//       }
//       return user;
//     } catch (e) {
//       print("Błąd rejestracji: $e");
//       return null;
//     }
//   }

//   Future<User?> loginUser({required String email, required String password}) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       User? user = userCredential.user;
//       if (user != null) {
//         await _saveUserSession(user.uid);
//       }
//       return user;
//     } catch (e) {
//       print("Błąd logowania: $e");
//       return null;
//     }
//   }

//   Future<void> logoutUser() async {
//     await _clearUserSession();
//     await _auth.signOut();
//   }

//   /// Zapisuje sesję użytkownika
//   Future<void> _saveUserSession(String uid) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_uid', uid);
//     await prefs.setBool('isLoggedIn', true); // ✅ Dodano zapis isLoggedIn
//   }

//   /// Czyści sesję użytkownika
//   Future<void> _clearUserSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('user_uid');
//     await prefs.remove('isLoggedIn'); // ✅ Usuń isLoggedIn
//   }

//   /// Pobiera UID zapisane w pamięci
//   Future<String?> getUserSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_uid');
//   }

//   /// Sprawdza, czy użytkownik jest zalogowany
//   Future<bool> isUserLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? loggedIn = prefs.getBool('isLoggedIn'); 
//     print("Sprawdzanie sesji: isLoggedIn = $loggedIn"); // 🔍 Debug
//     return loggedIn ?? false;
//   }
// }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  /// **Rejestracja użytkownika i zapis w Firestore**
  Future<User?> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // 🔹 Tworzymy nowy obiekt `UserDetails`
        UserDetails newUser = UserDetails(
          id: user.uid,
          firstName: firstName,
          lastName: lastName,
          address: "Nie podano", // 📌 Domyślne wartości
          city: "Nie podano",
          country: "Nie podano",
          nip: "Nie podano",
          profileImage: null,
        );

        // 🔹 Zapis do Firestore przez `UserService`
        await _userService.createUser(newUser);

        // 🔹 Zapis sesji użytkownika
        await _saveUserSession(user.uid);
      }
      return user;
    } catch (e) {
      print("Błąd rejestracji: $e");
      return null;
    }
  }

  /// **Logowanie użytkownika**
  Future<User?> loginUser({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _saveUserSession(user.uid);
      }
      return user;
    } catch (e) {
      print("Błąd logowania: $e");
      return null;
    }
  }

  /// **Wylogowanie użytkownika**
  Future<void> logoutUser() async {
    await _clearUserSession();
    await _auth.signOut();
  }

  /// **Zapisuje sesję użytkownika**
  Future<void> _saveUserSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_uid', uid);
    await prefs.setBool('isLoggedIn', true);
  }

  /// **Czyści sesję użytkownika**
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('isLoggedIn');
  }

  /// **Pobiera UID zapisane w pamięci**
  Future<String?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_uid');
  }

  /// **Sprawdza, czy użytkownik jest zalogowany**
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
