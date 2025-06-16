// ignore_for_file: non_constant_identifier_names

class AiPriseUiOptions {
  AiPriseUiOptionCommon? common;
  AiPriseUiOptionIdVerification? id_verification_module;

  AiPriseUiOptions({
    this.common,
    this.id_verification_module,
  });

  Map<String, dynamic> toJson() => {
        if (common != null) 'common': common!.toJson(),
        if (id_verification_module != null)
          'id_verification_module': id_verification_module!.toJson(),
      };
}

class AiPriseUiOptionCommon {
  String? default_language;

  AiPriseUiOptionCommon({
    this.default_language,
  });

  Map<String, String?> toJson() => {
        if (default_language != null) 'default_language': default_language,
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
