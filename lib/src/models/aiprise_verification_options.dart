// ignore_for_file: non_constant_identifier_names

class AiPriseVerificationOptions {
  AiPriseVerificationOptionAmlConfig? AML_CONFIG;

  AiPriseVerificationOptions({
    this.AML_CONFIG,
  });

  Map<String, dynamic> toJson() => {
        if (AML_CONFIG != null) 'id_verification_module': AML_CONFIG,
      };
}

class AiPriseVerificationOptionAmlConfig {
  num fuzziness_score;
  num exact_match;
  bool monitoring;

  AiPriseVerificationOptionAmlConfig({
    required this.fuzziness_score,
    required this.exact_match,
    required this.monitoring,
  });

  Map<String, dynamic> toJson() => {
        'fuzziness_score': fuzziness_score,
        'exact_match': exact_match,
        'monitoring': monitoring,
      };
}
