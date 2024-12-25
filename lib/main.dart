import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const FlashlightApp());
}

class FlashlightApp extends StatelessWidget {
  const FlashlightApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashlight App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: const FlashlightHomePage(),
    );
  }
}

class FlashlightHomePage extends StatefulWidget {
  const FlashlightHomePage({Key? key}) : super(key: key);

  @override
  _FlashlightHomePageState createState() => _FlashlightHomePageState();
}

class _FlashlightHomePageState extends State<FlashlightHomePage> {
  bool isFlashlightOn = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      var result = await Permission.camera.request();
      if (!result.isGranted) {
        _showPermissionDialog();
      }
    }
  }

  Future<void> _toggleFlashlight() async {
    if (!await Permission.camera.isGranted) {
      _showPermissionDialog();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isFlashlightOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        isFlashlightOn = !isFlashlightOn;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('Camera permission is required to use the flashlight.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blue, // AppBar color
        title: const Text('Flashlight App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flashlight Icon
              Icon(
                isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                color: isFlashlightOn ? Colors.yellow : Colors.white,
                size: 120.0,
              ),
              const SizedBox(height: 30),
              // Flashlight Status
              Text(
                isFlashlightOn ? 'Flashlight is ON' : 'Flashlight is OFF',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: isLoading ? null : _toggleFlashlight,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                  isFlashlightOn ? 'Turn Off Flashlight' : 'Turn On Flashlight',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
