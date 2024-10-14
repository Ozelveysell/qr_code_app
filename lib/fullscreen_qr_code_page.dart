import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FullScreenQRCodePage extends StatelessWidget {
  final String qrData;
  final Color qrColor;
  final Color backgroundColor;

  FullScreenQRCodePage({
    required this.qrData,
    required this.qrColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Kod'),
        backgroundColor: Colors.teal, // App bar rengi
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent], // Gradient renkleri
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: QrImageView(
            data: qrData,
            size: MediaQuery.of(context).size.width * 0.8, // Ekranın %80'i
            foregroundColor: qrColor,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }
}
