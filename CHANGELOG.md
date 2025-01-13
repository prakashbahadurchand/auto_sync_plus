# Changelog

All notable changes to this project will be documented in this file.

## [0.0.3] - 2024-12-21

### New Features

- **AutoSyncPlusParam Model**:
  - Introduced `AutoSyncPlusParam` model for structured API call parameters.
  - Simplified multiple API fetch and cache operations using the new model.
- **Progress Stream**:
  - Added stream-based progress updates for multiple API calls.
  - Real-time progress tracking for better user feedback.

### Improvements

- **Code Refactoring**:
  - Improved code readability and maintainability.
  - Enhanced error handling and logging mechanisms.

## [0.0.2] - 2024-12-14

### New Features

- **Enhanced Caching**:
  - Integrated `flutter_cache_manager` for efficient caching of large JSON data.
  - Moved caching tasks to background threads using `compute` for better performance.
- **Multiple API Fetch**:
  - Added support for fetching data from multiple APIs with progress tracking using `AutoSyncPlusParam` model.
  - Stream-based progress updates for multiple API calls.
- **Improved File Management**:
  - Recursive URL search for images and PDFs in nested JSON structures.
  - Efficient file management to avoid redundant downloads.
- **Logging**:
  - Optional logging for debugging and monitoring.

### Improvements

- **Performance**:
  - Optimized network checks and file operations.
  - Improved error handling to ensure fallback to cache in case of API errors.
- **User Experience**:
  - Enhanced feedback with detailed logging.
  - Streamlined API data handling with progress updates.

## [0.0.1] - 2024-12-07

### Initial Release

#### Added Features

- **Synced Widgets**:
  - `SyncedImageView`:
    - Dynamically loads images from a network source or local cache.
    - Placeholder support when offline or URL is null.
    - Automatically determines file source based on connectivity.
  - `SyncedPDFView`:
    - Displays PDFs from a network or local cache.
    - Smooth rendering using `SfPdfViewer`.
    - Custom error messages for failed loads.
- **Offline Support**:
  - Local caching for images and PDFs.
  - Fallback mechanisms for offline access.

#### Utilities

- **Network Connectivity Check**:
  - Detects online/offline status with `ConnectivityPlus`.
- **Data Management**:
  - Save and load structured data using `SharedPreferences`.
- **File Handling**:
  - Download and cache files (images and PDFs) locally.
  - Unique file naming to prevent conflicts.
- **Cache Management**:
  - Options to clear cached preferences and files selectively.
- **API Data Handling**:
  - Fetch and cache API data with optional support for image and PDF caching.

#### Improvements

- **User Experience**:
  - Smooth loading indicators with `CircularProgressIndicator`.
  - Centralized error handling for better feedback.
- **Performance**:
  - Asynchronous handling for responsiveness.
  - Optimized local fallback for offline users.
