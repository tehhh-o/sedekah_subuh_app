import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prim_derma_app/models/derma.dart';
import 'package:prim_derma_app/widget/style.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonateWebView extends StatefulWidget {
  final String desc;
  final String donation_id;
  final String token;
  final Derma derma;

  @override
  const DonateWebView(
      {super.key,
      required this.desc,
      required this.donation_id,
      required this.token,
      required this.derma});

  _DonateWebViewState createState() => _DonateWebViewState();
}

class _DonateWebViewState extends State<DonateWebView> {
  late WebViewController _controller;
  bool listenReceipt = false;
  bool readTermAndCond = false;

  bool validatePageUrl(String url) {
    if (listenReceipt) {
      return true;
    }

    if (url.contains('directpayIndex') ||  url.contains('directpay.my/pay')) {
      listenReceipt = true;
      setState(() {});
    } else if (url.contains('/derma')) {
      Navigator.of(context).pop();
      return false;
    }
    return url.contains('directpayIndex') || url.contains('sumbangan') || url.contains('directpay.my/pay');
  }

  bool listenReceiptUrl(String url) {
    if (!listenReceipt) {
      return false;
    }

    if (url.contains('FPXMain/termsAndConditions') && !readTermAndCond) {
      setState(() {
        readTermAndCond = true;
      });
    }

    return url.contains('directpayReceipt');
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding:
            EdgeInsets.zero, // Remove default padding around the title
        title: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              color: SECONDARY_TEAL),
          //color: Colors.red, // Set the background color to red
          padding: const EdgeInsets.all(24.0), // Add padding inside the title
          child: Text(
            'Transaksi Anda Akan Gagal!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white, // Set the text color to white
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Text(
          'Adakah anda pasti ingin meninggalkan halaman ini?',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Teruskan Transaksi'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void continueTransaction() {
    if (!readTermAndCond) {
      return;
    }
    _controller.goBack();
    setState(() {
      readTermAndCond = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // var token = await User.retrieveToken();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (validatePageUrl(url)) {
              //future action
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Tindakan anda gagal diteruskan')));
              _controller.loadRequest(
                Uri.parse('https://prim.my/api/derma/returnDermaView'),
                method: LoadRequestMethod.post,
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: Uint8List.fromList(utf8.encode(
                  Uri(queryParameters: {
                    'token': widget.token,
                    'donation_id': widget.donation_id,
                    'desc': widget.desc
                  }).query,
                )),
              );
            }
          },
          onPageFinished: (String url) {
            if (listenReceiptUrl(url)) {
              Derma.saveDermaHistory(widget.derma);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Sesi Transaksi Anda Telah Tamat')));
              Navigator.of(context).pop();
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://prim.my/api/derma/returnDermaView'),
        method: LoadRequestMethod.post,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: Uint8List.fromList(utf8.encode(
          Uri(queryParameters: {
            'token': widget.token,
            'donation_id': widget.donation_id,
            'desc': widget.desc
          }).query,
        )),
      );
  }

  Widget continueButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ElevatedButton(
          onPressed: continueTransaction,
          style: ElevatedButton.styleFrom(backgroundColor: SECONDARY_GREEN),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            //margin: EdgeInsets.all(5),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Text(
              'Teruskan Transaksi',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 16,
                  color: Colors.white),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, //When false, blocks the current route from being popped.
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        if (!listenReceipt) {
          Navigator.of(context).pop();
          return;
        }

        final result = await _showExitConfirmationDialog(context);
        if (result) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 75),
            Expanded(child: WebViewWidget(controller: _controller)),
            if (readTermAndCond) continueButton(),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: HIGHLIGHT_TEXT_COLOR),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (listenReceipt)
                      ? const Text(
                          'Jangan Tutup App ini Semasa Transaksi Anda Sedang Dijalankan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : PrimButton(
                          text: 'Kembali',
                          color: HIGHLIGHT_TEXT_COLOR,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
