import 'package:flutter/material.dart';
import '../user/edit_user_profile_mobile_screen.dart';
import '../../domain/user_details.dart';
import '../../services/user/user_service.dart';

class UserProfileCard extends StatelessWidget {
  
  const UserProfileCard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    UserService userService = UserService();
    
    return StreamBuilder<UserDetails?>(
      stream: userService.getCurrentUserDetailsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 68, 20, 100),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                "Nie znaleziono danych użytkownika",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final userData = snapshot.data!;
        final String name = "${userData.firstName} ${userData.lastName}";

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 68, 20, 100),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: userData.profileImage != null
                    ? NetworkImage(userData.profileImage!)
                    : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name.isNotEmpty ? name : "Nieznany użytkownik",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
