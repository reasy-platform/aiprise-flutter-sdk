// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;

import './get_search_params.dart';

import '../models/aiprise_environment.dart';
import '../models/aiprise_user_data.dart';
import '../models/aiprise_additional_info.dart';
import '../models/aiprise_ui_options.dart';
import '../models/aiprise_verification_options.dart';
import '../models/aiprise_theme_options.dart';

Future<AiPriseSessionInfo> createVerificationSession(
    AiPriseEnvironment mode,
    String templateID,
    String? callbackURL,
    String? eventsCallbackURL,
    String? clientReferenceID,
    Map? clientReferenceData,
    AiPriseUserData? userData,
    List<AiPriseAdditionalInfo>? additionalInfo,
    AiPriseUiOptions? uiOptions,
    AiPriseVerificationOptions? verificationOptions,
    AiPriseThemeOptions? theme) async {
  // Detect the base URL
  final baseURL = mode == AiPriseEnvironment.sandbox
      ? 'https://api-sandbox.aiprise.com'
      : 'https://api.aiprise.com';

  // Call the API
  final response = await http.post(
    Uri.parse('$baseURL/api/v1/verify/get_verification_session_url_for_sdk'),
    body: jsonEncode({
      'redirect_uri': 'flutter',
      'template_id': templateID,
      if (callbackURL != null) 'callback_url': callbackURL,
      if (eventsCallbackURL != null) 'events_callback_url': eventsCallbackURL,
      if (clientReferenceID != null) 'client_reference_id': clientReferenceID,
      if (clientReferenceData != null)
        'client_reference_data': clientReferenceData,
      if (userData != null) 'user_data': userData.toJson(),
      if (additionalInfo != null)
        'additional_info': additionalInfo.map((e) => e.toJson()).toList(),
      if (uiOptions != null) 'ui_options': uiOptions.toJson(),
      if (verificationOptions != null)
        'verification_options': verificationOptions.toJson(),
      if (theme != null) 'theme_options': theme.toJson(),
    }),
  );

  // Parse the response
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final sessionURL = json['verification_url'];
    final kycSessionID = getSearchParams(sessionURL)['verification_session_id'];
    final kybSessionID =
        getSearchParams(sessionURL)['business_onboarding_session_id'];
    final sessionID = kycSessionID ?? kybSessionID ?? '';
    return AiPriseSessionInfo(
      verification_url: sessionURL,
      verification_session_id: sessionID,
    );
  } else {
    throw Exception('Unable to create session');
  }
}

// Response Object
class AiPriseSessionInfo {
  String verification_url;
  String verification_session_id;

  AiPriseSessionInfo({
    required this.verification_url,
    required this.verification_session_id,
  });
}
