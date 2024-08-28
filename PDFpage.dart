import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> consolidateHttpClientResponseBytes(
    HttpClientResponse response) async {
  // Create a BytesBuilder to accumulate the response body.
  var builder = BytesBuilder();

  // Read bytes from the response stream and append them to the builder.
  await response.forEach(builder.add);

  // Return the consolidated bytes.
  return builder.toBytes();
}

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key, required this.link, required this.title});
  final String link;
  final String title;

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String pathPDF = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl(widget.link);
  }

  Future<void> createFileOfPdfUrl(String? url) async {
    if (url == null || url.isEmpty) {
      throw ArgumentError('URL cannot be null or empty');
    }

    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
            'Failed to download PDF. Status code: ${response.statusCode}');
      }

      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      var filePath = "${dir.path}/$filename";
      File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        pathPDF = filePath;
        isLoading = false;
      });
    } catch (e) {
      /* print('Error downloading PDF: $e');
      throw Exception('Error parsing asset file!');*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator.adaptive(
              backgroundColor: Colors.transparent,
            ))
          : Stack(
              children: <Widget>[
                PDFView(
                  filePath: pathPDF,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: true,
                  fitEachPage: true,
                  pageSnap: true,
                  defaultPage: currentPage!,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation:
                      false, // if set to true the link is handled in flutter
                  onRender: (_pages) {
                    setState(() {
                      pages = _pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    _controller.complete(pdfViewController);
                  },
                  onLinkHandler: (String? uri) {},
                  onPageChanged: (int? page, int? total) {
                    print('page change: $page/$total');
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
                errorMessage.isEmpty
                    ? !isReady
                        ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : Container()
                    : Center(
                        child: Text(errorMessage),
                      )
              ],
            ),
    );
  }
}
