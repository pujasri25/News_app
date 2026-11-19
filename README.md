# Simple News App (Flutter)

A production-grade News application built with Flutter, fetching articles from the Spaceflight News API.

## Features

### List Screen
- **Search**: Real-time search by title with debouncing.
- **Pagination**: Infinite scrolling to load more articles automatically.
- **Pull to Refresh**: Refresh the article list by pulling down.
- **Responsive Layout**: Adapts to different screen sizes.

### Detail Screen
- **Swipe Navigation**: Navigate between articles using horizontal swipes (similar to Gmail).
- **In-App Navigation**: Seamless transition from the list to the detailed view.
- **External Links**: "Read full article" button to open the original source in a browser.

## Technical Details

- **Architecture**: MVVM (Model-View-ViewModel) for clean separation of concerns.
- **State Management**: `Provider` (ChangeNotifier) for reactive UI updates.
- **Networking**: `Dio` with a centralized API client and error handling.
- **Image Loading**: `cached_network_image` for efficient image caching and placeholders.
- **Navigation**: Support for swipe gestures in the detail view with automatic fetching of new pages when reaching the end of the list.

## Folder Structure

```
lib/
├── models/         # Data models and JSON parsing
├── services/       # API clients and network logic
├── repositories/   # Data abstraction layer
├── viewmodels/     # Business logic and state management
├── views/
│   ├── screens/    # Main application screens (List, Detail)
│   └── widgets/    # Reusable UI components (ArticleCard, etc.)
└── main.dart       # App entry point and configuration
```

## Setup Instructions

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

## Packages Used

- `dio`: Networking.
- `provider`: State Management.
- `cached_network_image`: Image handling.
- `url_launcher`: Opening external links.
- `intl`: Date formatting.
