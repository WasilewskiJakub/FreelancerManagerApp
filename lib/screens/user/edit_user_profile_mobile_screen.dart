import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/user_details.dart';
import '../../services/user/user_service.dart';
import '../homepage_dashboard/dashboard_mobile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  UserDetails? _userDetails;
  File? _imageFile;
  final picker = ImagePicker();

  String? _firstName, _lastName, _address, _city, _country, _nip;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDetails = await _userService.getCurrentUserDetails();
    if (userDetails != null) {
      setState(() {
        _userDetails = userDetails;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_userDetails == null) return;

    _formKey.currentState!.save();

    final updatedUser = _userDetails!.copyWith(
      firstName: _firstName?.isNotEmpty == true ? _firstName : _userDetails!.firstName,
      lastName: _lastName?.isNotEmpty == true ? _lastName : _userDetails!.lastName,
      address: _address?.isNotEmpty == true ? _address : _userDetails!.address,
      city: _city?.isNotEmpty == true ? _city : _userDetails!.city,
      country: _country?.isNotEmpty == true ? _country : _userDetails!.country,
      nip: _nip?.isNotEmpty == true ? _nip : _userDetails!.nip,
    );

    await _userService.updateUser(updatedUser);

    if (_imageFile != null) {
      // Tutaj mozna dodać obsługe do zapisywania zdjec w Firestore (usluga platna)!
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Zrób zdjęcie"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text("Wybierz z galerii"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 20, 100),
        title: const Text("Edytuj profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage("assets/images/default_profile.png") as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField("Imię", _userDetails?.firstName, (value) => _firstName = value),
              _buildTextField("Nazwisko", _userDetails?.lastName, (value) => _lastName = value),
              _buildTextField("Adres zamieszkania", _userDetails?.address, (value) => _address = value),
              _buildTextField("Miasto", _userDetails?.city, (value) => _city = value),
              _buildTextField("Kraj", _userDetails?.country, (value) => _country = value),
              _buildTextField("NIP", _userDetails?.nip, (value) => _nip = value, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 68, 20, 100),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Zapisz zmiany", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? initialValue, Function(String) onChanged,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) => null,
        onChanged: onChanged,
        keyboardType: keyboardType,
      ),
    );
  }
}

