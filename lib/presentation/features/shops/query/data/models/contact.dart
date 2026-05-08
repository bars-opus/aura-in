class Contact {
  String id;

  final String email;

  final String number;

  Contact({
    required this.id,
    required this.email,
    required this.number,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      email: json['email'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'number': number};
  }
}
