import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'custom_snackbar.dart';

/// Visualizador moderno de documentos PDF con opciones para imprimir y compartir
class PdfViewer extends StatelessWidget {
  final Uint8List pdfData;
  final String title;
  final String filename;

  const PdfViewer({
    super.key,
    required this.pdfData,
    required this.title,
    required this.filename,
  });

  /// Mostrar el visualizador como un modal
  static Future<void> show(
    BuildContext context, {
    required Uint8List pdfData,
    required String title,
    required String filename,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: PdfViewer(
          pdfData: pdfData,
          title: title,
          filename: filename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        // Handle indicator
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Documento PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: colorScheme.onSurface),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        
        // Divider
        Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
        
        // PDF Preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PdfPreview(
                build: (format) => pdfData,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                maxPageWidth: 700,
                actions: const [],
                pdfPreviewPageDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                scrollViewDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
                previewPageMargin: const EdgeInsets.all(8),
                useActions: false,
                initialPageFormat: PdfPageFormat.a4,
                pdfFileName: filename,
              ),
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Botón de imprimir
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.print_rounded,
                  label: 'Imprimir',
                  onPressed: () => _printPdf(context),
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 8),
              // Botón de compartir
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.share_rounded,
                  label: 'Compartir',
                  onPressed: () => _sharePdf(context),
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 8),
              // Botón de descargar
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.download_rounded,
                  label: 'Descargar',
                  onPressed: () => _downloadPdf(context),
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Construye un botón de acción moderno
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        foregroundColor: isPrimary ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        elevation: isPrimary ? 1 : 0,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        minimumSize: const Size(10, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isPrimary 
              ? BorderSide.none 
              : BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: isPrimary ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  // Imprimir el PDF
  Future<void> _printPdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) => pdfData,
        name: filename,
      );
    } catch (e) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al imprimir: $e',
      );
    }
  }

  // Compartir el PDF
  Future<void> _sharePdf(BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.pdf');
      await file.writeAsBytes(pdfData);
      
      await Share.shareFiles(
        [file.path],
        text: 'Compartir $title',
      );
    } catch (e) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al compartir: $e',
      );
    }
  }

  // Descargar el PDF
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      // En plataformas móviles, guardar en la carpeta de descargas
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('No se pudo acceder al almacenamiento');
        }
        
        final downloadPath = directory.path;
        final file = File('$downloadPath/$filename.pdf');
        await file.writeAsBytes(pdfData);
        
        CustomSnackbar.showSuccess(
          context: context,
          message: 'PDF guardado en: ${file.path}',
          icon: Icons.file_download_done_rounded,
        );
      } 
      // En escritorio, usar el diálogo de impresión para guardar como PDF
      else {
        await Printing.layoutPdf(
          onLayout: (format) => pdfData,
          name: filename,
          usePrinterSettings: true,
        );
        
        CustomSnackbar.showSuccess(
          context: context,
          message: 'PDF listo para guardar',
          icon: Icons.file_download_done_rounded,
        );
      }
    } catch (e) {
      CustomSnackbar.showError(
        context: context,
        message: 'Error al descargar: $e',
      );
    }
  }

  // Mostrar mensaje en snackbar
  void _showSnackbar(BuildContext context, String message, {bool isError = false}) {
    if (isError) {
      CustomSnackbar.showError(
        context: context,
        message: message,
      );
    } else {
      CustomSnackbar.showSuccess(
        context: context,
        message: message,
      );
    }
  }
} 