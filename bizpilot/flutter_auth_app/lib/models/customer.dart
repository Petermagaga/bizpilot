class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String notes;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.notes,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'name': name,
    'email': email,
    'phone': phone,
    'company': company,
    'notes': notes,
  };
}

}
