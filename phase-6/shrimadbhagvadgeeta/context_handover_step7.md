# Project Architecture & Context Handover (Post-Step 7)

## 1. Project Overview
**Name:** Shrimad Bhagavad Gita App
**Tech Stack:** Flutter, Riverpod (State Management), Hive (Local DB / Offline-First), Supabase (Auth + Sync).
**Architecture:** Clean Architecture (Presentation, Domain, Data).
**Design System:** "Sacred Editorial" (A strict, custom design system matching provided Stitch high-fidelity screens).

## 2. Core Architectural Pillars
### 2.1. Clean Architecture Boundaries
- **Domain:** Pure Dart. Contains Entities (e.g., `Chapter`, `Shlok`, `Bookmark`, `Collection`) and abstract Repository interfaces. NEVER contains UI or framework logic.
- **Data:** Implements Repositories. Uses Hive for local storage and Supabase for remote sync. Handles data mapping (DTOs) and offline-first queueing.
- **Presentation:** Flutter widgets, Riverpod providers for state management. Responsible for all UI rendering and reading from/writing to repositories via providers.

### 2.2. Offline-First Synchronization
- **Primary Source of Truth:** Local Hive boxes.
- **Sync Mechanism:** All writes go to Hive first, then a background sync to Supabase is attempted. If offline or Supabase fails, the operation is pushed to a `PendingSyncQueue` (Hive-backed).
- **Queue Replay:** The app periodically checks the queue and replays failed mutations when connectivity is restored.

### 2.3. The "Sacred Editorial" Design System
- **Philosophy:** Generous negative space, tonal surfaces, no hard borders, and a focus on typography.
- **Components:** Uses custom components like `SectionContainer` (which relies on `SurfaceTier` for depth) instead of standard Material widgets with shadows/borders.
- **Typography:** Strict usage of `NotoSerifDevanagari` (Sanskrit), `NotoSerif` (English translation/wisdom), and `Inter` (UI/Utility).
- **Animations:** "Meditative Pace" — all animations must be slow-out (minimum 300ms) to maintain a serene experience.

## 3. Work Completed in Step 7 (Final UI Polish)
The objective of Step 7 was to implement the main app UI structure and screens exactly as specified in the Stitch design screenshots, adhering strictly to the "Sacred Editorial" system without modifying the domain layer.

### 3.1. App Shell & Bottom Navigation
- Implemented `AppShell` with a custom `_SacredBottomNav`.
- Removed top borders in favor of a subtle ambient shadow and surface tier separation.
- Added the "amber pill" indicator behind the active tab icon, complete with meditative scale and fade animations.

### 3.2. Home Screen (Tab 0)
- Rebuilt `HomeScreen` to include:
  - **Daily Sadhana Header:** Featuring a streak counter and motivational quote.
  - **Verse of the Day Card:** Highlighting large Devanagari text, English translation, and an amber "Reflect" CTA pill.
  - **Themes of Wisdom:** A 4-item list of common spiritual themes (e.g., Inner Peace, Righteous Duty).
  - **Continue Reading Card:** Showing a chapter thumbnail, progress dots, and a play button.
  - **Curated Insights:** Editorial-style cards for deep-dive articles.

### 3.3. Explore Screen (Tab 1 - Chapters)
- Updated `ChaptersScreen` with a new "The 18 Chapters" editorial header and an Overall Progress badge.
- Fixed routing from `/chapter/:chapterId` to `/explore/chapter/:chapterId` to work correctly within the `ShellRoute`.
- Enhanced `ChapterCard`:
  - Added a left accent line (amber/green depending on progress).
  - Added a status badge (Completed / In Progress / Not Started).
  - Integrated `Chapter.description` (falling back to a static map in the presentation layer if null in the domain).

### 3.4. Shlok List Screen (Chapter Index)
- Rebuilt `ShlokListScreen` to feature a compact list view.
- Each row now displays an amber verse number, the first line of Sanskrit, and a translation preview.
- Added a sticky "Resume Reading" bottom bar.
- Fixed nested routing to `/explore/chapter/:chapterId/verse/:shlokId`.

### 3.5. Library Screen (Tab 2 - Bookmarks & Collections)
- Completely restructured `BookmarksScreen` from a tabbed interface to a vertical scroll layout ("Collections-first").
- **Header:** Added "PERSONAL ARCHIVES" eyebrow, "My Library" title, and an amber "+ New Collection" button.
- **Collections:** Full-width cards featuring a tinted icon square, name, and a decorative avatar stack (currently showing a placeholder 0 count until `CollectionItem` query is implemented).
- **Curated Journeys:** Added a static, non-functional section at the bottom (shows "Coming soon" snackbar on tap).

### 3.6. Profile Screen (Tab 3)
- Updated `ProfileScreen` with new statistics rows (Day Streak, Verses Read, Min Meditated).
- Added a horizontal scrolling "My Collections" quick-access section.
- Added a "Milestones" card with a timeline-style dot indicator.
- Included new preference rows for "Notifications" and "Account Security".

## 4. Current State & Known Limitations
- **Mock Data in UI:** The `ChapterProgress` (Completed/In Progress) is currently mocked via `chapterProgressProvider` purely in the presentation layer. This is by design for Step 7 to avoid altering the domain layer prematurely.
- **Unimplemented Features:** "Curated Journeys", "+ New Collection", "Notifications", and "Account Security" buttons currently trigger "Coming soon" snackbars.
- **Code Health:** `flutter analyze` runs completely clean (0 issues) after removing unused variables and fixing the `Collection` entity reference in the `_AvatarStack`. All routes navigate correctly.

## 5. Next Steps
- Transition mock progress tracking (`chapterProgressProvider`) to use a real `ReadingProgressRepository` backed by Hive/Supabase.
- Implement the UI and logic for adding/removing items from a `Collection` (`CollectionItem` queries).
- Implement actual user statistics (Streaks, Minutes Meditated).
