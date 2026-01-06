// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:autogumi_plaza/data_manager.dart';
import 'package:autogumi_plaza/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class PdfSignaturePage extends StatefulWidget {
  const PdfSignaturePage({super.key});

  @override
  State<PdfSignaturePage> createState() => _PdfSignaturePageState();
}

class _PdfSignaturePageState extends State<PdfSignaturePage> {
  final SignatureController _sigController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final TextEditingController _nameController = TextEditingController();

  bool _isFinishing =   false;
  bool _isLoadingPdf =  true;
  bool isClosed =       false;
  String? _pdfPath;
  String? _pdfError;

  // Route args
  String pdfUrl = '';
  int? bizonylatId;
  String title = 'Aláírás';

  bool get _canFinish => !isClosed  &&
    !_isFinishing                   &&
    !_isLoadingPdf                  &&
    _pdfPath != null                &&
    _sigController.isNotEmpty       &&
    _nameController.text.trim().isNotEmpty
  ;

  @override
  void initState() {
    super.initState();
    _sigController.addListener(_refresh);
    _nameController.addListener(_refresh);
    if(isClosed) _sigController.disabled = true;
  }

  @override
  void dispose() {
    _sigController.removeListener(_refresh);
    _nameController.removeListener(_refresh);
    _sigController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final args =  (ModalRoute.of(context)?.settings.arguments as Map?) ?? const {};
    pdfUrl =      (args['pdfUrl'] ?? args['source'] ?? '').toString();
    bizonylatId = _tryParseInt(args['bizonylatId'] ?? args['bizonylat_id']);
    title =       (args['title'] ?? args['name'] ?? 'Aláírás').toString();
    isClosed =    ((args['isClosed'] == true) || (args['isClosed']?.toString() == 'true'));
    // Kick off download once.
    if (_isLoadingPdf && _pdfPath == null && _pdfError == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPdfOnce());
    }

    return WillPopScope(
      onWillPop:  () async => !_isFinishing,
      child:      Scaffold(
        appBar: AppBar(title: Text(title)),
        body:   pdfUrl.isEmpty
          ? _errorBody('Missing PDF URL (pdfUrl/source).')
          : isClosed
            ? _buildPdfArea()
            : Column(
                children: [
                  Expanded(flex: 3, child: _buildPdfArea()),
                  Expanded(flex: 1, child: _signatureArea()),
                ],
              ),
        bottomNavigationBar: isClosed ? null : _bottomTray(),
      ),
    );
  }

  Widget _buildPdfArea() {
    if (_isLoadingPdf) {
      return const Center(
        child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
      );
    }

    if (_pdfError != null) {
      return _errorBody(_pdfError!);
    }

    if (_pdfPath == null) {
      return _errorBody('PDF not available.');
    }

    return PDFView(
      filePath: _pdfPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onError: (error) {
        if (!mounted) return;
        setState(() => _pdfError = 'PDFView error: $error');
      },
      onPageError: (page, error) {
        if (!mounted) return;
        setState(() => _pdfError = 'PDF page error (page $page): $error');
      },
    );
  }

  Future<void> _loadPdfOnce() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPdf = true;
      _pdfError = null;
      _pdfPath = null;
    });

    try {
      final fixedUrl = pdfUrl.replaceAll(r'\/', '/');
      final uri = Uri.tryParse(fixedUrl);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw Exception('Invalid URL: $fixedUrl');
      }
      final resp = await http.get(
        uri,
        headers: {
          'Accept': 'application/pdf,*/*',
          'User-Agent': 'Mozilla/5.0 (Flutter; Android) autogumi_plaza',
        },
      );
      final ct = (resp.headers['content-type'] ?? '').toLowerCase();
      final bytes = resp.bodyBytes;
      // quick “is this a PDF?” check: PDFs start with "%PDF"
      final isPdf = bytes.length >= 4 &&
          bytes[0] == 0x25 && // %
          bytes[1] == 0x50 && // P
          bytes[2] == 0x44 && // D
          bytes[3] == 0x46;   // F
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      // If not PDF, show what we actually got (usually HTML)
      if (!isPdf) {
        final preview = utf8.decode(bytes.take(300).toList(), allowMalformed: true);
        throw Exception('Not a PDF. content-type="$ct", preview="$preview"');
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/panel_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        _pdfPath = file.path;
        _isLoadingPdf = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pdfError = 'PDF load failed: $e';
        _isLoadingPdf = false;
      });
    }
  }

  Widget _signatureArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            enabled: !_isFinishing,
            decoration: const InputDecoration(
              labelText: 'Aláíró neve',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Signature(
                      controller: _sigController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const Positioned(
                  left: 12,
                  top: 10,
                  child: Text('Aláírás', style: TextStyle(color: Colors.grey)),
                ),
                Positioned(
                  right: 6,
                  top: 0,
                  child: IconButton(
                    tooltip: 'Törlés',
                    onPressed: (!_isFinishing && _sigController.isNotEmpty) ? _sigController.clear : null,
                    icon: const Icon(Icons.backspace),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomTray() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isFinishing ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Mégsem'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _canFinish ? _finishPressed : null,
                icon: _isFinishing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                label: Text(_isFinishing ? 'Mentés...' : 'Lezárás'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBody(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, size: 54),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishPressed() async {
    setState(() => _isFinishing = true);
    final Uint8List? pngBytes = await _sigController.toPngBytes();
    if (pngBytes == null) {
      setState(() => _isFinishing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sikertelen aláírás feldolgozás')));
      return;
    }
    final String signatureBase64 = base64.encode(pngBytes);
    final String signerName = _nameController.text.trim();
    await DataManager(quickCall: QuickCall.uploadSignature, input:{
      'bizonylat_id':   bizonylatId,
      'alairo':         signerName,
      'alairas':        signatureBase64,
    }).beginQuickCall;
    Navigator.pop(context);
  }

  int? _tryParseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
