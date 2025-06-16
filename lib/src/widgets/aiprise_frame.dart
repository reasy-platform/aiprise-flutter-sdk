import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../models/aiprise_environment.dart';
import '../models/aiprise_user_data.dart';
import '../models/aiprise_additional_info.dart';
import '../models/aiprise_ui_options.dart';
import '../models/aiprise_verification_options.dart';
import '../models/aiprise_theme_options.dart';
import '../services/create_verification_session.dart';

import '../assets/aiprise_icon.dart';

class AiPriseFrame extends StatefulWidget {
  // Session Payload
  final AiPriseEnvironment mode;
  final String templateID;
  final String? sessionID;
  final String? callbackURL;
  final String? eventsCallbackURL;
  final String? clientReferenceID;
  final Map? clientReferenceData;
  final String? userProfileID;
  final AiPriseUserData? userData;
  final List<AiPriseAdditionalInfo>? additionalInfo;
  final AiPriseUiOptions? uiOptions;
  final AiPriseVerificationOptions? verificationOptions;
  final AiPriseThemeOptions? theme;

  // Callbacks
  final Function(String errorCode)? onError;
  final Function(String? sessionID)? onStart;
  final Function(String? sessionID)? onResume;
  final Function(String? businessProfileId)? onBusinessProfileCreated;
  final Function(String? sessionID)? onSuccess;
  final Function(String? sessionID)? onComplete;

  // Constructor
  const AiPriseFrame({
    super.key,
    required this.mode,
    required this.templateID,
    this.sessionID,
    this.callbackURL,
    this.eventsCallbackURL,
    this.clientReferenceID,
    this.clientReferenceData,
    this.userProfileID,
    this.userData,
    this.additionalInfo,
    this.uiOptions,
    this.verificationOptions,
    this.theme,
    this.onError,
    this.onStart,
    this.onResume,
    this.onBusinessProfileCreated,
    this.onSuccess,
    this.onComplete,
  });

  @override
  State<AiPriseFrame> createState() => _AiPriseFrameState();
}

class _AiPriseFrameState extends State<AiPriseFrame> {
  late final WebViewController _controller;
  bool _isWebViewPageLoaded = false;

  String _sessionStatus = "idle"; // idle, loading, success, error
  String _sessionError = ""; // error message
  String? _sessionID;

  String _inputFileSource = "file";

  initializeSession() async {
    setState(() {
      _sessionStatus = "loading";
    });
    try {
      // 1 - CREATE NEW SESSION
      if (widget.sessionID == null) {
        final sessionInfo = await createVerificationSession(
            widget.mode,
            widget.templateID,
            widget.callbackURL,
            widget.eventsCallbackURL,
            widget.clientReferenceID,
            widget.clientReferenceData,
            widget.userProfileID,
            widget.userData,
            widget.additionalInfo,
            widget.uiOptions,
            widget.verificationOptions,
            widget.theme);
        if (!mounted) return;
        // Update the state
        setState(() {
          _sessionStatus = "success";
          _sessionID = sessionInfo.verification_session_id;
        });
        // Update the WebView path
        _controller.loadRequest(Uri.parse(sessionInfo.verification_url));
        // Inform the parent
        widget.onStart?.call(sessionInfo.verification_session_id);
      }
      // 2 - RESUME EXISTING SESSION
      else {
        // Wait for the next frame to ensure the widget is mounted
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Update the state
          setState(() {
            _sessionStatus = "success";
            _sessionID = widget.sessionID;
          });
          // Update the WebView path
          final baseUrl = widget.mode == AiPriseEnvironment.production
              ? "https://verify.aiprise.com/"
              : "https://verify-sandbox.aiprise.com/";
          _controller.loadRequest(Uri.parse(
              '$baseUrl?verification_session_id=${widget.sessionID}'));
          // Inform the parent
          widget.onResume?.call(widget.sessionID);
        });
      }
    } catch (e) {
      if (!mounted) return;
      // Update the state
      setState(() {
        _sessionStatus = "error";
        _sessionError = "Unable to create session.\nPlease try again.";
      });
      // Inform the parent
      widget.onError?.call("SESSION_FAILED");
    }
  }

  setupWebView() {
    // Create special params for iOS (to allow inline media playback)
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    // Create the webview controller
    _controller = WebViewController.fromPlatformCreationParams(params,
        onPermissionRequest: (resources) async {
      return resources.grant();
    })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // To keep track of the webview page's loading state
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isWebViewPageLoaded = true;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            // Update the state
            setState(() {
              _sessionStatus = "error";
              _sessionError = "Unable to start session.\nPlease try again.";
            });
            // Inform the parent
            widget.onError?.call("SESSION_FAILED");
          },
        ),
      )
      // To listen to postMessage from the client screen
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (JavaScriptMessage jsMessage) {
          if (jsMessage.message
              .startsWith("AiPriseVerification:BusinessProfileCreated:")) {
            final businessProfileId = jsMessage.message.split(":")[2];
            widget.onBusinessProfileCreated?.call(businessProfileId);
          } else if (jsMessage.message == 'AiPriseVerification:Success') {
            widget.onSuccess?.call(_sessionID);
          } else if (jsMessage.message == 'AiPriseVerification:Complete') {
            widget.onComplete?.call(_sessionID);
          } else if (jsMessage.message == "AiPriseFilePickerSource:camera") {
            setState(() {
              _inputFileSource = "camera";
            });
          } else if (jsMessage.message == "AiPriseFilePickerSource:file") {
            setState(() {
              _inputFileSource = "file";
            });
          } else if (jsMessage.message
              .startsWith("AiPriseVerification:Error:")) {
            final errorCode = jsMessage.message.split(":")[2];
            widget.onError?.call(errorCode);
          }
        },
      );

    // Android specific settings
    if (_controller.platform is AndroidWebViewController) {
      final myController = _controller.platform as AndroidWebViewController;
      // To allow media playback without user gesture (Android only)
      myController.setMediaPlaybackRequiresUserGesture(false);
      // To enable file picker (not supported in flutter webview for Android)
      myController.setOnShowFileSelector(_handleWebViewFilePickerForAndroid);
    }
  }

  Future<List<String>> _handleWebViewFilePickerForAndroid(
      FileSelectorParams params) async {
    // Handle camera picker
    if (_inputFileSource == "camera") {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return [];

      File pickedFile = File(photo.path);
      return [pickedFile.uri.toString()];
    }
    // Handle file picker
    else {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return [];

      File pickedFile = File(result.files.single.path!);
      return [pickedFile.uri.toString()];
    }
  }

  @override
  initState() {
    super.initState();
    setupWebView();
    initializeSession();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List aiPriseIconBytes = const Base64Decoder().convert(aiPriseIcon);

    return Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Success Layout
            if (_sessionStatus == "success")
              SizedBox.expand(
                child: WebViewWidget(controller: _controller),
              ),

            // Error Layout
            if (_sessionStatus == "error")
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(
                      aiPriseIconBytes,
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _sessionError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // Loading Layout
            if (_sessionStatus == "loading" ||
                (_sessionStatus == "success" && !_isWebViewPageLoaded))
              const Center(
                child: CupertinoActivityIndicator(
                  radius: 18,
                ),
              ),
          ],
        ));
  }
}
