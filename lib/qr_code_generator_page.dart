import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'fullscreen_qr_code_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QRCodeGeneratorPage extends StatefulWidget {
  @override
  _QRCodeGeneratorPageState createState() => _QRCodeGeneratorPageState();
}

class _QRCodeGeneratorPageState extends State<QRCodeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';
  Color _qrColor = Colors.black;
  Color _backgroundColor = Colors.white;

  Future<void> _shareQRCode() async {
    try {
      final qrImage = QrPainter(
        data: _qrData,
        version: QrVersions.auto,
        color: _qrColor,
        emptyColor: _backgroundColor,
      );

      // Geçici dosya konumunu alın
      final tempDir = await getTemporaryDirectory();
      final qrFile = File('${tempDir.path}/qr_code.png');

      // QR kodunu PNG olarak kaydet
      final pictureData = await qrImage.toImageData(200);
      await qrFile.writeAsBytes(pictureData!.buffer.asUint8List());

      // Dosyayı paylaş
      await Share.shareXFiles([XFile(qrFile.path)], text: 'Bu benim QR kodum');
    } catch (e) {
      print('QR kod paylaşımı sırasında bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Kod Oluşturucu'),
          backgroundColor: Colors.teal, // App bar rengi
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (_qrData.isNotEmpty) {
                _shareQRCode(); // Paylaşma fonksiyonunu çağır
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Metin veya URL girin',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _qrData = value; // Kullanıcının girdiği veriyi al
                });
              },
            ),
            SizedBox(height: 20),
            // Renk seçimi için
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('QR Rengi:'),
                ColorPickerButton(
                  initialColor: _qrColor,
                  onColorSelected: (color) {
                    setState(() {
                      _qrColor = color;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Arka Plan Rengi:'),
                ColorPickerButton(
                  initialColor: _backgroundColor,
                  onColorSelected: (color) {
                    setState(() {
                      _backgroundColor = color;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            // QR kodu görüntüleme
            GestureDetector(
              onTap: () {
                if (_qrData.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenQRCodePage(
                        qrData: _qrData,
                        qrColor: _qrColor,
                        backgroundColor: _backgroundColor,
                      ),
                    ),
                  );
                }
              },
              child: QrImageView(
                data: _qrData.isEmpty ? " " : _qrData, // Fallback for empty input
                size: 200.0, // Size of the QR code
                foregroundColor: _qrColor, // QR kod rengi
                backgroundColor: _backgroundColor, // Arka plan rengi
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerButton extends StatelessWidget {
  final Function(Color) onColorSelected;
  final Color initialColor;

  ColorPickerButton({required this.onColorSelected, required this.initialColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.color_lens, color: initialColor),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Color selectedColor = initialColor; // Seçilen rengi başlangıç rengi olarak ayarlayın
            return AlertDialog(
              title: Text('Renk Seçin'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    selectedColor = color; // Kullanıcının seçtiği rengi güncelleyin
                  },
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Tamam'),
                  onPressed: () {
                    onColorSelected(selectedColor); // Seçilen rengi ana ekrana gönderin
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('İptal'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Diyalogdan çık
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
