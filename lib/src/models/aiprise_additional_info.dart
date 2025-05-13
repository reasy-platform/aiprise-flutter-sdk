// ignore_for_file: non_constant_identifier_names

class AiPriseAdditionalInfo {
  String additional_info_type;
  String additional_info_data;

  AiPriseAdditionalInfo({
    required this.additional_info_type,
    required this.additional_info_data,
  });

  Map<String, String> toJson() => {
        'additional_info_type': additional_info_type,
        'additional_info_data': additional_info_data,
      };
}
