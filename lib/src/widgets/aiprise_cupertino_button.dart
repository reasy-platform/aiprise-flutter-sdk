import 'package:flutter/cupertino.dart';
import 'package:overlay_dialog/overlay_dialog.dart';

import './aiprise_frame.dart';

import '../models/aiprise_environment.dart';
import '../models/aiprise_user_data.dart';
import '../models/aiprise_additional_info.dart';
import '../models/aiprise_ui_options.dart';
import '../models/aiprise_verification_options.dart';
import '../models/aiprise_theme_options.dart';

enum AiPriseCupertinoButtonType { regular, filled }

class AiPriseCupertinoButton extends StatefulWidget {
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
  final AiPriseCupertinoButtonType? type;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? minSize;
  final double? pressedOpacity;
  final BorderRadius? borderRadius;
  final AlignmentGeometry alignment;
  final Widget? child;

  // 2 - CONSTRUCTOR

  const AiPriseCupertinoButton({
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
    this.type = AiPriseCupertinoButtonType.filled,
    this.padding,
    this.color,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  State<AiPriseCupertinoButton> createState() => _AiPriseCupertinoButtonState();
}

class _AiPriseCupertinoButtonState extends State<AiPriseCupertinoButton> {
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
          style: DialogStyle.cupertino,
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
        return CupertinoPageScaffold(
          resizeToAvoidBottomInset: false,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: darkThemeEnabled
                ? CupertinoColors.black
                : CupertinoColors.white,
            leading: GestureDetector(
                onTap: handleCloseClick,
                child: Icon(CupertinoIcons.xmark,
                    color: darkThemeEnabled
                        ? CupertinoColors.white
                        : CupertinoColors.black)),
            middle: Text(
              "AiPrise",
              style: TextStyle(
                  color: darkThemeEnabled
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ),
          ),
          child: SafeArea(
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
    // Regular Button
    if (widget.type == AiPriseCupertinoButtonType.regular) {
      return CupertinoButton(
          padding: widget.padding,
          color: widget.color,
          minSize: widget.minSize,
          pressedOpacity: widget.pressedOpacity,
          borderRadius: widget.borderRadius,
          alignment: widget.alignment,
          child: child,
          onPressed: () => addOverlay());
    }
    // Filled Button
    else {
      return CupertinoButton.filled(
          padding: widget.padding,
          minSize: widget.minSize,
          pressedOpacity: widget.pressedOpacity,
          borderRadius: widget.borderRadius,
          alignment: widget.alignment,
          child: child,
          onPressed: () => addOverlay());
    }
  }
}
