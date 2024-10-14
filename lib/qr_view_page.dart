import 'package:flutter/material.dart';
import 'package:qr_app/home_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class QRViewPage extends StatefulWidget {
  final VoidCallback decreaseCounter;
  final int remainingAttempts;

  QRViewPage({required this.decreaseCounter, required this.remainingAttempts});

  @override
  _QRViewPageState createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool showBorder = false;
  bool hasScanned = false;
  bool isFlashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.teal, // App bar rengi
        title: Text('QR Tarayıcı', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
            ),
            onPressed: () async {
              if (controller != null) {
                await controller!.toggleFlash();
                setState(() {
                  isFlashOn = !isFlashOn;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.teal,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          if (result != null && showBorder)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  if (result != null &&
                      Uri.tryParse(result!.code!)?.hasAbsolutePath == true) {
                    await _launchURL(result!.code!);
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Git',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        if (!hasScanned) {
          result = scanData;
          showBorder = true;
          widget.decreaseCounter();

          if (widget.remainingAttempts <= 0) {
            _showWarningDialog();
          }

          hasScanned = true;
        }
      });
    });
  }

  void _showWarningDialog() {
    controller?.pauseCamera();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Uyarı', style: TextStyle(color: Colors.red)),
          content: Text('Hakkınız kalmamıştır.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL açılamadı: $url')),
      );
    }
  }
}
