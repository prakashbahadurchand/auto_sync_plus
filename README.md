# Auto Sync Plus

A Flutter package that provides utilities for caching and managing offline data, images, and PDFs with seamless syncing capabilities. It includes features to check for network connectivity, download and cache files, and handle offline usage with fallbacks.

## Features

- **Synced Widgets**:
  - `SyncedImageView`: Automatically loads images from network or local cache with placeholder support when offline.
  - `SyncedPDFView`: Displays PDFs from network or local cache with fallback support and smooth rendering using `SfPdfViewer`.

- **Offline Support**:
  - Cache images, PDFs, and data for offline use.
  - Automatically switch between online and offline sources based on connectivity.

- **Data Management**:
  - Save and load structured data using `flutter_cache_manager`.
  - Fetch and cache data from an API with the option to cache images and PDFs.

- **Cache Management**:
  - Clear cached data and files selectively for efficient storage management.

## Installation

To use `auto_sync_plus` in your project, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  auto_sync_plus:
    git:
      url: https://github.com/prakashbahadurchand/auto_sync_plus.git
```

## Example Usage for auto sync plus

- On Repository:

```dart

import 'package:auto_sync_plus/auto_sync_plus.dart';

class CoreRepo {
  final AutoSyncPlus autoSync = AutoSyncPlus();

  final List<AutoSyncPlusParam> _syncTasks = [
    AutoSyncPlusParam(
      key: 'first_api_call',
      apiCall: () => CoreApiClient(buildDioClient(null)).getDataFromFirstApiCall(),
      fromJson: (json) => FirstApiDto.fromJson(json),
      toJson: (dto) => dto.toJson(),
    ),
    AutoSyncPlusParam(
      key: 'second_api_call',
      apiCall: () => CoreApiClient(buildDioClient(null)).getDataFromSecondApiCall(),
      fromJson: (json) => SecondApiDto.fromJson(json),
      toJson: (dto) => dto.toJson(),
    ),
  ];

  // Get sync percentage for showing download progress
  Stream<double> syncAllDataWithProgress() async* {
    await for (var progress in autoSync.fetchAndCacheMultipleData(params: _syncTasks)) {
      yield progress; // Emit progress as a percentage
    }
  }

  // Fetching and caching for first API call
  Future<List<FirstApiDto>> getDataFromFirstApiCall() => autoSync.fetchAndCacheData(
        key: 'first_api_call',
        apiCall: () => CoreApiClient(buildDioClient(null)).getDataFromFirstApiCall(), // API call to get data
        fromJson: (json) => FirstApiDto.fromJson(json),  // Mapping the JSON response to DTO
        toJson: (dto) => dto.toJson(),  // Mapping the DTO to JSON for caching
      );

  // Fetching and caching another API call
  Future<List<SecondApiDto>> getDataFromSecondApiCall() => autoSync.fetchAndCacheData(
        key: 'second_api_call',
        apiCall: () => CoreApiClient(buildDioClient(null)).getDataFromSecondApiCall(), // API call to get data
        fromJson: (json) => SecondApiDto.fromJson(json),  // Mapping the JSON response to DTO
        toJson: (dto) => dto.toJson(),  // Mapping the DTO to JSON for caching
      );
}


```

- On Widgets:

```dart

    // ImageView Sized:
    SyncedImageView(
        url: imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder: 'assets/images/img_placeholder.png',
    );

    // PDF View Full Screen:
    SyncedPDFView(url: pdfUrl);
```
