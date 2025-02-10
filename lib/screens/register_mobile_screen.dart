import 'package:flutter/material.dart';
import 'package:freelancer_manager_app/services/auth/auth_service.dart';
import 'package:freelancer_manager_app/screens/login_mobile_screen.dart';

class RegisterMobileScreen extends StatefulWidget {
  const RegisterMobileScreen({Key? key}) : super(key: key);

  @override
  _RegisterMobileScreenState createState() => _RegisterMobileScreenState();
}

class _RegisterMobileScreenState extends State<RegisterMobileScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool isLoading = false;

  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final user = await _authService.registerUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );

      setState(() {
        isLoading = false; // Ukrywamy loader
      });

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zarejestrowano pomyślnie!')),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginMobileScreen()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd rejestracji, spróbuj ponownie.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 20, 100),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 68, 20, 100), Color.fromARGB(255, 118, 103, 129)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/freelancer_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              color: Colors.white,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'REGISTER',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) => firstName = value,
                      validator: (value) => value!.isEmpty ? 'Enter first name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) => lastName = value,
                      validator: (value) => value!.isEmpty ? 'Enter last name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) => email = value,
                      validator: (value) => value!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => password = value,
                      validator: (value) => value!.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 68, 20, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size.fromHeight(50),
                            ),
                            child: const Text('REGISTER', style: TextStyle(color: Colors.white)),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


