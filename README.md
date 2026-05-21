# app--Full-User-Centric-Product-Design-
A calm, offline-first Bhagavad Gita reading app built with Flutter. Uses Clean Architecture, Riverpod, Hive, and Supabase. Focused on a manuscript-like reading experience with thoughtful typography, smooth interactions, and seamless sync for bookmarks and collections.

# Shrimad Bhagavad Gita App 🪔
A beautifully crafted, offline-first Bhagavad Gita reading application. 
This repository showcases my journey as an early-career Flutter developer (6 months - 1 YoE) exploring enterprise-level app development. I built this to dive deeply into **Clean Architecture**, **offline-first data synchronization**, and complex state management using **Riverpod**.
**Development Approach:** To tackle a project of this scale and architectural complexity, I developed this application using an AI-assisted pair-programming workflow. This approach allowed me to focus heavily on high-level system design, architectural decisions, and learning advanced Flutter concepts, while leveraging AI to accelerate implementation, generate boilerplate, and prototype rapidly. It's an exploration of how modern tools can scale a solo developer's capabilities.
---
## 🎯 Project Goal
The primary goal of this project is to create a production-grade, offline-first reading companion for the Shrimad Bhagavad Gita. It focuses on three main pillars:
1.  **A Meditative Reading Experience:** Utilizing a bespoke "Sacred Editorial" design system with generous negative space, tonal surfaces, and custom typography, purposefully avoiding standard, generic Material UI borders and shadows.
2.  **Robust Architecture:** Implementing strict Clean Architecture (Presentation, Domain, Data layers) to ensure the app is highly scalable, maintainable, and fully decoupled.
3.  **Seamless Offline-First UX:** Ensuring the app is fully functional without an internet connection, using Hive for local storage as the single source of truth, and Supabase for background cloud synchronization.
---
## ✅ What's Achieved Till Now
The core foundation, architecture, and primary screens of the application are built and structurally complete. The app currently features zero static analysis warnings (`flutter analyze` is clean).
### 1. Architecture & Infrastructure
*   **Clean Architecture:** Strict separation of concerns. Pure Dart Entities and Use Cases in the Domain layer, with DTOs and Data Sources in the Data layer.
*   **Result/Failure Pattern:** Implemented a sealed `Result<T>` class (Ok/Err) in the domain layer to handle exceptions cleanly without bubbling `try/catch` blocks into the UI.
*   **Offline-First Sync Engine:** The app reads exclusively from local Hive boxes. A `PendingSyncQueue` handles offline mutations, which are synced to Supabase in the background via a fire-and-forget mechanism when connectivity is restored.
*   **Authentication:** Supabase email/password auth login and signup UI with robust session state management.
### 2. UI / UX & Design System
*   **Sacred Editorial Engine:** A custom design system built with specific UI components (`SectionContainer`, `EditorialLayout`) and bundled offline fonts (Noto Serif Devanagari, Noto Serif, Inter).
*   **Home Screen:** Features a "Daily Sadhana" header, Verse of the Day, and themed wisdom sections.
*   **Explore Screen:** A chapter index highlighting all 18 chapters and overall reading progress.
*   **Reading Experience:** A compact verse list and a detailed verse screen featuring Sanskrit text, transliteration, and English translation.
*   **Library (Archives):** UI structure for managing Bookmarks and curated Collections.
*   **Profile:** UI for user statistics (Day streaks, verses read) and app preferences.
---
## 🚧 What's Remaining (Next Steps)
While the architecture and UI shell are robust, several features are currently mocked or pending logic wiring to the data layer:
*   **Real Reading Progress Tracking:** Transitioning the mocked UI progress dots to a fully functional `ReadingProgressRepository` powered by Hive/Supabase.
*   **Collections Logic:** Implementing the backend database logic to add, remove, and manage verses within user-created collections.
*   **Search Functionality:** Connecting the existing `SearchScreen` UI to the already written `SearchShloks` use case.
*   **Dynamic User Statistics:** Replacing placeholder data in the Profile tab with dynamically calculated streaks and reading time based on user activity.
*   **Settings Persistence:** Saving user preferences like Light/Dark mode and font scaling locally using `SharedPreferences` or Hive.
---
## 🏛️ Architecture Deep Dive
This project strictly adheres to **Clean Architecture** principles to ensure that the UI is decoupled from the business logic and data sources.
### Folder Structure
```text
lib/
├── core/
│   ├── constants/
│   ├── errors/ (failures.dart, result.dart)
│   ├── network/
│   ├── providers/ (Global app providers)
│   ├── router/ (GoRouter setup)
│   └── theme/
├── features/
│   ├── auth/ (domain, data, presentation)
│   ├── bookmarks/ (domain, data, presentation)
│   ├── chapters/ (domain, data, presentation)
│   ├── collections/ (domain, data, presentation)
│   └── shloks/ (domain, data, presentation)
└── main.dart
```
### Data Flow & Layers
1.  **Presentation Layer (`presentation/`)**: Contains all UI screens, widgets, and Riverpod providers. It handles state scoping and user interactions but contains zero business logic. It reads from and writes to the domain layer via Use Cases or Repository Interfaces.
2.  **Domain Layer (`domain/`)**: The pure Dart core of the application. It contains basic Entities (e.g., `AppUser`, `Shlok`, `Chapter`) and defines abstract Repositories. It knows nothing about Flutter, Hive, or Supabase.
3.  **Data Layer (`data/`)**: Implements the repositories defined in the Domain layer. It handles DTOs (Data Transfer Objects) and maps them to Domain Entities. It orchestrates reading from the **Local Data Source (Hive)** and syncing with the **Remote Data Source (Supabase)**.
### The Offline-First Sync Strategy
To provide a seamless experience:
*   The **UI always reads from Hive**, ensuring instant load times and full offline capability.
*   When a user performs an action (like adding a bookmark), it writes to Hive immediately, updating the UI instantly.
*   It then triggers a fire-and-forget sync to Supabase. If the sync fails (e.g., no internet), the operation is stored in a local `PendingSyncQueue` and retried automatically when the app is next launched or connectivity is restored.
---
## 🛠️ Tech Stack
*   **Framework:** Flutter (Customized UI, bypassing default Material styles)
*   **State Management:** Riverpod (v2.x)
*   **Local DB:** Hive & Hive Flutter (Offline-first caching)
*   **Backend & Auth:** Supabase (`supabase_flutter`)
*   **Networking:** Dio (Remote data fetching)
*   **Navigation:** GoRouter
---
## 🚀 Getting Started
If you'd like to run this project locally to explore the architecture or UI:
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/shrimadbhagvadgeeta.git
    cd shrimadbhagvadgeeta
    ```
2.  **Download Font Assets:**
    The aesthetic heavily relies on specific offline fonts. Run the provided script to download them before building:
    ```powershell
    powershell -File scripts/download_fonts.ps1
    ```
    *(After downloading, ensure the fonts section in `pubspec.yaml` is uncommented.)*
3.  **Install Dependencies & Run:**
    ```bash
    flutter pub get
    flutter run
    ```
    *Note: To fully test cloud sync features, you will need to provide your own Supabase URL and Anon Key in `main.dart`.*
