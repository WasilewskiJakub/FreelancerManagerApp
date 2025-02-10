import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../homepage_tasks/task_mobile_screen.dart';
import '../projects/project_mobile_screen.dart';
import '../invoices/invoices_screen.dart';
import '../../services/auth/auth_service.dart';
import '../projects/add_poject_mobile_screen.dart';
import '../analysis/analysis_mobile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ProjectsScreen(),       // Zakładka "Projekty"
    TasksScreen(),          // Zakładka "Taski"
    InvoicesScreen(),       // Zakładka "Faktury"
    AnalysisScreen(),       // Zakładka "Analiza"
  ];

  /// Tytuły do AppBar
  final List<String> _pageTitles = [
    "Projekty",
    "Taski",
    "Faktury",
    "Analiza",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: _buildAppBar(),

      // Drawer (otwierany z prawej strony)
      endDrawer: _buildDrawer(context),

      // Treść ekranu = IndexedStack, by utrzymać stan między zakładkami
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // Dolna nawigacja
      bottomNavigationBar: _buildBottomNavBar(),

      // Pływający przycisk + tylko w zakładce 0 (Projekty)
      floatingActionButton: _selectedIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// AppBar z tytułem zależnym od aktywnej zakładki
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 68, 20, 100),
      title: Text(
        _pageTitles[_selectedIndex],
        style: const TextStyle(color: Colors.white),
      ),
      automaticallyImplyLeading: false,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  /// Drawer (Menu) z prawej strony
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120.0,
            color: const Color.fromARGB(255, 68, 20, 100),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Wyloguj się'),
            onTap: () async {
              await AuthService().logoutUser();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login_mobile', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  /// Przycisk plus do dodawania nowego projektu (tylko w zakładce "Projekty")
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProjectScreen(user: user)),
          );
        }
      },
      backgroundColor: const Color.fromARGB(255, 68, 20, 100),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 32),
    );
  }

  /// Dolny pasek nawigacji z 4 zakładkami
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.folder, "Projekty", 0),
          _buildNavItem(Icons.check_circle, "Taski", 1),
          const SizedBox(width: 48), // Przerwa na FloatingActionButton
          _buildNavItem(Icons.receipt, "Faktury", 2),
          _buildNavItem(Icons.bar_chart, "Analiza", 3),
        ],
      ),
    );
  }

  /// Pojedynczy przycisk w bottom nav
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _selectedIndex == index;
    final Color activeColor = const Color.fromARGB(255, 68, 20, 100);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? activeColor : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

