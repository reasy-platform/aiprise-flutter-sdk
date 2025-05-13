// ignore_for_file: non_constant_identifier_names

class AiPriseUiOptions {
  AiPriseUiOptionIdVerification? id_verification_module;

  AiPriseUiOptions({
    this.id_verification_module,
  });

  Map<String, dynamic> toJson() => {
        if (id_verification_module != null)
          'id_verification_module': id_verification_module,
      };
}

class AiPriseUiOptionIdVerification {
  String? allowed_country_code;

  AiPriseUiOptionIdVerification({
    this.allowed_country_code,
  });

  Map<String, String?> toJson() => {
        if (allowed_country_code != null)
          'allowed_country_code': allowed_country_code,
      };
}
