import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aiprise_flutter_sdk/aiprise_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

// 1 - Material Button Example
class MaterialExample extends StatelessWidget {
  const MaterialExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material Example'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: AiPriseMaterialButton(
            mode: AiPriseEnvironment.sandbox,
            templateID: "example-template",
          ),
        ),
      ),
    );
  }
}

// 2 - Cupertino Button Example
class CupertinoExample extends StatelessWidget {
  const CupertinoExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(primaryColor: CupertinoColors.activeBlue),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Cupertino Example'),
        ),
        child: Center(
          child: AiPriseCupertinoButton(
            mode: AiPriseEnvironment.sandbox,
            templateID: "TEMPLATE_ID_HERE",
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool _isCameraPermissionGranted = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Permission.camera.request().then((cameraStatus) {
      if (cameraStatus.isPermanentlyDenied) {
        openAppSettings(); // Open settings to prompt user to allow camera permission!
      }
      if (cameraStatus.isGranted) {
        setState(() {
          _isCameraPermissionGranted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraPermissionGranted) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Camera permission not granted yet!")),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AiPrise SDK Examples'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'Material'), Tab(text: 'Cupertino')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [MaterialExample(), CupertinoExample()],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
