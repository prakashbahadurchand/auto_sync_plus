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
  - Save and load structured data using `SharedPreferences`.
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

class CoreRepo {
  final AutoSyncPlus autoSync = AutoSyncPlus();

  final List<Future<void> Function()> _syncTasks = [
    () => CoreRepo().getDataFromFirstApiCall(),
    () => CoreRepo().getDataFromSecondApiCall(),
  ];

  // Get sync percentage for show download all data with progress
  Stream<int> syncAllDataWithProgress() async* {
    final int totalTasks = _syncTasks.length;
    int completedTasks = 0;

    for (var syncTask in _syncTasks) {
      try {
        await syncTask();
        completedTasks++;
        yield (completedTasks / totalTasks * 100).toInt(); // Emit progress as percentage
      } catch (e) {
        log('Error syncing task: $e');
        toast('Error syncing task: $e');
      }
    }
  }

  // Fetching and caching for first api call
  Future<List<FirstApiDto>> getDataFromFirstApiCall() => autoSync.fetchAndCacheData(
        'first_api_call',
        () => CoreApiClient(buildDioClient(null)).getDataFromFirstApiCall(), // API call to get data
        (json) => FirstApiDto.fromJson(json),  // Mapping the JSON response to DTO
        (dto) => dto.toJson(),  // Mapping the DTO to JSON for caching
      );

  // Fetching and caching another api call
  Future<List<SecondApiDto>> getDataFromSecondApiCall() => autoSync.fetchAndCacheData(
        'second_api_call',
        () => CoreApiClient(buildDioClient(null)).getDataFromSecondApiCall(), // API call to get data
        (json) => SecondApiDto.fromJson(json),  // Mapping the JSON response to DTO
        (dto) => dto.toJson(),  // Mapping the DTO to JSON for caching
      );
}


```

- On Widgets:

```dart

    // ImageView:
    SyncedImageView(
        url: imageUrl,
        width: double.infinity,
        height: 50,
        fit: BoxFit.cover,
        placeholder: AppAsset.imgPlaceholder,
    );

    // PDF View:
    SyncedPDFView(url: pdfUrl);
```
