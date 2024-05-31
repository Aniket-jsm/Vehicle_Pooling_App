class User {
  // final String id; // You can uncomment and add this if you need an id field
  final String name;
  final String phoneNumber; // Changed to camelCase
  final String address;
  final String image_url;

  User( {
    required this.name,
    required this.phoneNumber, // Added required keyword
    required this.address,
    required this.image_url,
  });
}
