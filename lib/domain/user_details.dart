import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String? id;
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String country;
  final String nip;
  final String? profileImage;

  UserDetails({
    this.id,
    required this.firstName,
    required this.lastName,
    this.address = "Nie podano",
    this.city = "Nie podano",
    this.country = "Nie podano",
    this.nip = "Nie podano",
    this.profileImage,
  });

  /// 🔹 Konwersja `UserDetails` do mapy Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'country': country,
      'nip': nip,
      'profileImage': profileImage,
    };
  }

  /// 🔹 Tworzenie obiektu `UserDetails` na podstawie dokumentu Firestore
  factory UserDetails.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserDetails(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      address: data['address'] ?? "Nie podano",
      city: data['city'] ?? "Nie podano",
      country: data['country'] ?? "Nie podano",
      nip: data['nip'] ?? "Nie podano",
      profileImage: data['profileImage'],
    );
  }

  /// 🔹 Metoda `copyWith` do aktualizacji obiektu
  UserDetails copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? country,
    String? nip,
    String? profileImage,
  }) {
    return UserDetails(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      nip: nip ?? this.nip,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
