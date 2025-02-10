import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:freelancer_manager_app/screens/login_mobile_screen.dart';
import 'package:freelancer_manager_app/screens/projects/add_poject_mobile_screen.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

Future main() async{

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD7YSwFm-H_eYTdS48hEj5ZECFHJNQL8Q8",
        authDomain: "freelancermanager-dfa0e.firebaseapp.com",
        projectId: "freelancermanager-dfa0e",
        storageBucket: "freelancermanager-dfa0e.firebasestorage.app",
        messagingSenderId: "151357356470",
        appId: "1:151357356470:web:9f3a2754a3c66756ae6917",
        measurementId: "G-5D0YE17QLW"
      )
    );
  } else {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      window_size.setWindowTitle('Freelancer Manager');
      window_size.setWindowMinSize(const Size(900, 650));
    } else {
      await Firebase.initializeApp();
    }
  }
  runApp(const FreelancerManagerApp());
}

class FreelancerManagerApp extends StatelessWidget {
  const FreelancerManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freelancer Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login_mobile': (context) => const LoginMobileScreen(),
        // '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
