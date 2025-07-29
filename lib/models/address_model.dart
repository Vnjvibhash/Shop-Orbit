class Address {
  final String id;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String pincode;
  final String country;
  final String state;

  Address({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.pincode,
    required this.country,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'pincode': pincode,
      'country': country,
      'state': state,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? '',
      state: json['state'] ?? '',
    );
  }

  // A helper to get a formatted, readable address string
  String get formattedAddress =>
      '$addressLine1, ${addressLine2 != null ? '$addressLine2, ' : ''}$city, $state, $pincode, $country';
}
