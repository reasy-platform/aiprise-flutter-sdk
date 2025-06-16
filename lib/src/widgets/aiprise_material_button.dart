import 'package:flutter/material.dart';
import 'package:overlay_dialog/overlay_dialog.dart';

import './aiprise_frame.dart';

import '../models/aiprise_environment.dart';
import '../models/aiprise_user_data.dart';
import '../models/aiprise_additional_info.dart';
import '../models/aiprise_ui_options.dart';
import '../models/aiprise_verification_options.dart';
import '../models/aiprise_theme_options.dart';

enum AiPriseMaterialButtonType { elevated, filled, filledTonal, outlined, text }

class AiPriseMaterialButton extends StatefulWidget {
  // 1 - ARGUMENTS

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
  final Function(String? sessionID)? onAbandoned;

  // Button Customization
  final AiPriseMaterialButtonType? type;
  final ButtonStyle? style;
  final Widget? child;

  // 2 - CONSTRUCTOR

  const AiPriseMaterialButton({
    super.key,
    // Session Payload
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

    // Callbacks
    this.onError,
    this.onStart,
    this.onResume,
    this.onBusinessProfileCreated,
    this.onSuccess,
    this.onComplete,
    this.onAbandoned,

    // Button Customization
    this.type = AiPriseMaterialButtonType.filled,
    this.style,
    this.child,
  });

  @override
  State<AiPriseMaterialButton> createState() => _AiPriseMaterialButtonState();
}

class _AiPriseMaterialButtonState extends State<AiPriseMaterialButton> {
  // 1 - SESSION EVENTS + BUTTON CLICKS

  String? _sessionID;
  String? _sessionStatus;

  handleSessionError(String errorCode) {
    setState(() {
      _sessionStatus = "error";
    });
    widget.onError?.call(errorCode);
  }

  handleSessionStart(String? sessionID) {
    setState(() {
      _sessionID = sessionID;
    });
    widget.onStart?.call(sessionID);
  }

  handleSessionResume(String? sessionID) {
    setState(() {
      _sessionID = sessionID;
    });
    widget.onResume?.call(sessionID);
  }

  handleBusinessProfileCreated(String? businessProfileId) {
    widget.onBusinessProfileCreated?.call(businessProfileId);
  }

  handleSessionSuccess(String? sessionID) {
    setState(() {
      _sessionStatus = "success";
    });
    widget.onSuccess?.call(sessionID);
  }

  handleSessionComplete(String? sessionID) {
    removeOverlay();
    setState(() {
      _sessionID = null;
      _sessionStatus = null;
    });
    widget.onComplete?.call(sessionID);
  }

  handleCloseClick() {
    // If session has error, close without confirmation
    if (_sessionStatus == "error") {
      removeOverlay();
      return;
    }
    // If session is completed, close modal, reset state and inform parent
    if (_sessionStatus == "success") {
      handleSessionComplete(_sessionID);
      return;
    }
    // Else, ask for confirmation before closing
    DialogHelper().show(
        context,
        DialogWidget.alert(
          closable: true,
          style: DialogStyle.material,
          title: "Stop Verification",
          content: "Are you sure you want to stop your verification?",
          actions: [
            DialogAction(
                title: "No",
                handler: () {
                  DialogHelper().hide(context);
                },
                isDestructive: true),
            DialogAction(
                title: "Yes",
                handler: () {
                  widget.onAbandoned?.call(_sessionID);
                  removeOverlay();
                  setState(() {
                    _sessionID = null;
                    _sessionStatus = null;
                  });
                  DialogHelper().hide(context);
                },
                isDefault: true),
          ],
        ));
  }

  // 2 - SHOW / HIDE OVERLAY

  OverlayEntry? overlayEntry;

  addOverlay() {
    removeOverlay();

    bool darkThemeEnabled = widget.theme?.background == "dark";
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: darkThemeEnabled ? Colors.black : Colors.white,
            elevation: 3,
            title: const Text("AiPrise"),
            titleTextStyle: TextStyle(
              color: darkThemeEnabled ? Colors.white : Colors.black,
              fontSize: 22,
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.close),
                color: darkThemeEnabled ? Colors.white : Colors.black,
                tooltip: 'Stop Verification',
                onPressed: handleCloseClick,
              ),
            ],
          ),
          body: SafeArea(
              maintainBottomViewPadding: true,
              child: AiPriseFrame(
                // Session Payload
                mode: widget.mode,
                templateID: widget.templateID,
                sessionID: widget.sessionID,
                callbackURL: widget.callbackURL,
                eventsCallbackURL: widget.eventsCallbackURL,
                clientReferenceID: widget.clientReferenceID,
                clientReferenceData: widget.clientReferenceData,
                userProfileID: widget.userProfileID,
                userData: widget.userData,
                additionalInfo: widget.additionalInfo,
                uiOptions: widget.uiOptions,
                verificationOptions: widget.verificationOptions,
                theme: widget.theme,
                // Callbacks
                onError: handleSessionError,
                onStart: handleSessionStart,
                onResume: handleSessionResume,
                onBusinessProfileCreated: handleBusinessProfileCreated,
                onSuccess: handleSessionSuccess,
                onComplete: handleSessionComplete,
              )),
        );
      },
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  // 3 - BUTTON WIDGET

  @override
  Widget build(BuildContext context) {
    final child = widget.child ?? const Text('Verify with AiPrise');

    // Elevated Button
    if (widget.type == AiPriseMaterialButtonType.elevated) {
      return ElevatedButton(
          style: widget.style, child: child, onPressed: () => addOverlay());
    }
    // Filled Button
    else if (widget.type == AiPriseMaterialButtonType.filled) {
      return FilledButton(
          style: widget.style, child: child, onPressed: () => addOverlay());
    }
    // Filled Tonal Button
    else if (widget.type == AiPriseMaterialButtonType.filledTonal) {
      return FilledButton.tonal(
          style: widget.style, child: child, onPressed: () => addOverlay());
    }
    // Outlined Button
    else if (widget.type == AiPriseMaterialButtonType.outlined) {
      return OutlinedButton(
          style: widget.style, child: child, onPressed: () => addOverlay());
    }
    // Text Button
    else {
      return TextButton(
          style: widget.style, child: child, onPressed: () => addOverlay());
    }
  }
}
