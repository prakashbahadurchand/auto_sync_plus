# Changelog

All notable changes to this project will be documented in this file.

## [0.0.2] - 2024-12-14
### Bug Fixes
- Fixed issue where cached PDFs would fail to render in certain cases due to a missing null check.

### Improvements
- Improved error handling for network connectivity issues during image loading.
- Enhanced caching mechanism for faster offline access to images and PDFs.

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
