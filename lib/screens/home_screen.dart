import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'login_mobile_screen.dart';
import 'register_mobile_screen.dart';
import '../services/auth/auth_service.dart';
import 'homepage_dashboard/dashboard_mobile_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if(kIsWeb || (Platform.isWindows || Platform.isLinux || Platform.isMacOS)){
          return const _DesktopHomeLayout();
        }else{
          return const _MobileHomeLayout();
        }
      }
    );
  }
}

// -----------------------------------------------------------------------------
//           WERSJA IOS/ANDROID - Ekran startowy (Freelancer Manager)
// -----------------------------------------------------------------------------
class _MobileHomeLayout extends StatelessWidget {
  const _MobileHomeLayout({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: AuthService().isUserLoggedIn(), // Sprawdza, czy użytkownik jest zalogowany
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator()); // Loader podczas sprawdzania
      }
      if (snapshot.data == true) {
        // Jeśli zalogowany -> przechodzi do Dashboard
        Future.microtask(() {
          // Navigator.pushReplacementNamed(context, '/home');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(), // Tu wstaw swój dashboard
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
        return const SizedBox(); // Zwrot pustego widgetu, bo i tak zaraz przekieruje
      }

      // Jeśli użytkownik NIE jest zalogowany -> pokazuje ekran startowy
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 4,
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
                  SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Text(
                              'Freelancer Manager',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Zarządzaj projektami,\n'
                              'zadaniami i fakturami!\n'
                              'Osiągnij więcej jako freelancer!',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: const Color.fromARGB(219, 255, 255, 255),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: ClipPath(
                child: Container(
                  color: const Color.fromARGB(255, 253, 245, 254),
                  child: _buildLoginButtons(context),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildLoginButtons(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // LOGIN button
              ElevatedButton(
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginMobileScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 68, 20, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text(
                  'LOG IN',
                  style: TextStyle(
                    fontSize: 18
                    ,color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(height: 30),

              // SIGN UP button
              OutlinedButton(
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterMobileScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(60),
                ),
                child: const Text(
                  'REGISTER',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 68, 20, 100)
                  ),
                ),
              ),
              const SizedBox(height: 50),

              Text(
                'Zarządzaj swoimi projektami i zadaniami\n'
                'z każdego miejsca na ziemi!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 66, 66, 66),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//           WERSJA DESKTOP/WEB - Ekran startowy
// -----------------------------------------------------------------------------
class _DesktopHomeLayout extends StatelessWidget {
  const _DesktopHomeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lewa część: Logowanie/Rejestracja, prawa część: obrazek freelancer_bg
    return Scaffold(
      body: Row(
        children: [
          // Lewa kolumna (logowanie/rejestracja)
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.blueGrey[50],
              child: Center(
                child: SizedBox(
                  width: 400, // maksymalna szerokość "formularza"
                  child: _buildLoginArea(context),
                ),
              ),
            ),
          ),
          // Prawa kolumna (obrazek)
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/freelancer_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),
                Center(
                  child: Text(
                    'Freelancer Manager',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginArea(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Zaloguj się',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email/Username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (_) {}),
                    const Text('Remember me'),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // ...
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('LOGIN'),
            ),
            const SizedBox(height: 20),
            Text(
              'Nie masz konta?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // ...
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('ZAREJESTRUJ SIĘ'),
            ),
          ],
        ),
      ),
    );
  }
}
