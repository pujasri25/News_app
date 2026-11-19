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

## Architecture: MVVM

The app follows an **MVVM (Model – View – ViewModel)** layering, with a `Repository` layer separating the ViewModel from the data source:

| MVVM Layer | Folder | Role |
|---|---|---|
| **Model** | `lib/models/` | Plain, null-safe data classes (`Article`, `ArticleResponse`) with `fromJson` parsing. |
| **Repository** | `lib/repositories/` | Abstracts the data source (`ArticleRepository`) from the ViewModel, delegating to `ApiService`. |
| **ViewModel** | `lib/cubits/` | `ArticleCubit` + `ArticleState` hold all presentation logic and expose an immutable state stream to the View. |
| **View** | `lib/views/` | `ListScreen` / `DetailScreen` and reusable widgets render state and forward user actions to the ViewModel. |

### Why Bloc/Cubit as the ViewModel implementation

- **Unidirectional data flow**: the View never mutates state directly — it calls methods on the Cubit, which emits a new immutable `ArticleState`. This avoids the bugs that come from scattered, mutable ViewModel fields in a classic `ChangeNotifier` setup.
- **Testability**: `Cubit` methods are plain functions that emit states, so business logic (pagination, search debouncing, error handling) can be unit-tested without any widget tree.
- **Built-in reactive wiring**: `BlocProvider`/`BlocBuilder` give the View a ready-made subscription to the ViewModel's state stream, with automatic disposal — no manual `addListener`/`removeListener` bookkeeping.
- **Scales with app state complexity**: as more screens are added, each can own a focused Cubit (ViewModel) without a global state container, keeping the MVVM boundaries clean.

## Technical Details

- **Networking**: `Dio` with a centralized API client (`ApiService`) and typed error handling (timeouts, connection errors, bad responses).
- **Models**: Null-safe, with `fromJson` factory constructors (`Article`, `ArticleResponse`).
- **Image Loading**: `cached_network_image` for caching, with `placeholder` and `errorWidget` builders on every image.
- **Responsiveness**: `LayoutBuilder` in `ListScreen` switches between a single-column `ListView` on phones (`width < 600`) and a `GridView` (2–3 columns, based on width) on tablets.
- **Navigation**: Support for swipe gestures in the detail view with automatic fetching of new pages when reaching the end of the list.

## Folder Structure

```
lib/
├── models/         # Model layer — data models and JSON parsing
├── services/       # API clients and network logic
├── repositories/   # Repository layer — data abstraction between ViewModel and services
├── cubits/         # ViewModel layer — Cubit business logic and state classes
├── views/
│   ├── screens/    # View layer — main application screens (List, Detail)
│   └── widgets/    # View layer — reusable UI components (ArticleCard, ArticleGridCard, etc.)
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
- `flutter_bloc`: State Management (Cubit).
- `cached_network_image`: Image handling.
- `url_launcher`: Opening external links.
- `intl`: Date formatting.
