library auto_sync_plus.synced_widgets;

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'auto_sync_plus.dart';

// Photo Widget:
class SyncedImageView extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final String placeholder;
  const SyncedImageView({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return url == null
        ? Image.asset(
            placeholder,
            width: width,
            height: height,
            fit: fit,
          )
        : FutureBuilder<bool>(
            future: AutoSyncPlus.hasInternetAccess(),
            builder: (context, connectivitySnapshot) {
              if (connectivitySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (connectivitySnapshot.hasData && connectivitySnapshot.data!) {
                return Image.network(url!, width: width, height: height, fit: fit);
              }

              return FutureBuilder<String?>(
                future: AutoSyncPlus().getSavedFilePath(url!),
                builder: (context, fileSnapshot) {
                  if (fileSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (fileSnapshot.hasData && fileSnapshot.data != null) {
                    return Image.file(
                      File(fileSnapshot.data!),
                      width: width,
                      height: height,
                      fit: fit,
                    );
                  }

                  return Image.asset(
                    placeholder,
                    width: width,
                    height: height,
                    fit: fit,
                  );
                },
              );
            },
          );
  }
}

// PDF Widget:
class SyncedPDFView extends StatelessWidget {
  final String url;

  const SyncedPDFView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AutoSyncPlus.hasInternetAccess(),
      builder: (context, connectivitySnapshot) {
        if (connectivitySnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (connectivitySnapshot.hasData && connectivitySnapshot.data!) {
          // If connected, load the PDF from the network
          return SfPdfViewer.network(
            url,
            onDocumentLoadFailed: (exception) {
              return log('Failed to load PDF: ${exception.error}');
            },
          );
        }

        // If not connected, load the PDF from local storage
        return FutureBuilder<String?>(
          future: AutoSyncPlus().getSavedFilePath(url),
          builder: (context, fileSnapshot) {
            if (fileSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (fileSnapshot.hasData && fileSnapshot.data != null) {
              return SfPdfViewer.file(
                File(fileSnapshot.data!),
                onDocumentLoadFailed: (exception) {
                  return log('Failed to load PDF: ${exception.error}');
                },
              );
            }

            return _buildErrorWidget('Failed to load PDF. Please check your internet connection.');
          },
        );
      },
    );
  }

  // Centralized text widget for errors
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }
}
