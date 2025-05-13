// ignore_for_file: non_constant_identifier_names

class AiPriseUserData {
  String? first_name;
  String? middle_name;
  String? last_name;
  String? date_of_birth; // YYYY-MM-DD
  String? phone_number; // E.164 format
  String? email_address;
  String? ip_address;
  AiPriseUserAddress? address;

  AiPriseUserData({
    this.first_name,
    this.middle_name,
    this.last_name,
    this.date_of_birth,
    this.phone_number,
    this.email_address,
    this.ip_address,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        if (first_name != null) 'first_name': first_name,
        if (middle_name != null) 'middle_name': middle_name,
        if (last_name != null) 'last_name': last_name,
        if (date_of_birth != null) 'date_of_birth': date_of_birth,
        if (phone_number != null) 'phone_number': phone_number,
        if (email_address != null) 'email_address': email_address,
        if (ip_address != null) 'ip_address': ip_address,
        if (address != null) 'address': address?.toJson(),
      };
}

class AiPriseUserAddress {
  String? address_street_1;
  String? address_street_2;
  String? address_city;
  String? address_state;
  String? address_zip_code;
  String? address_country;

  AiPriseUserAddress({
    this.address_street_1,
    this.address_street_2,
    this.address_city,
    this.address_state,
    this.address_zip_code,
    this.address_country,
  });

  Map<String, String?> toJson() => {
        if (address_street_1 != null) 'address_street_1': address_street_1,
        if (address_street_2 != null) 'address_street_2': address_street_2,
        if (address_city != null) 'address_city': address_city,
        if (address_state != null) 'address_state': address_state,
        if (address_zip_code != null) 'address_zip_code': address_zip_code,
        if (address_country != null) 'address_country': address_country,
      };
}
