Project Overview

Name: Shrimad Bhagavad Gita App
Goal: A production-grade, offline-first Bhagavad Gita reading application with a serene, manuscript-like “Sacred Editorial” experience.
Focus: High performance, strict Clean Architecture, and a calm, immersive reading flow.

Current Stage: Step 6 completed
(Authentication + Supabase Sync fully integrated, no analysis issues)

Core Engineering Principles
1. Clean Architecture (Strict)
Presentation → Domain → Data
UI depends only on Domain
Domain is pure and backend-agnostic
Data layer handles all external systems
2. Offline-First
Hive is the single source of truth for UI
App must function without internet
Backend is for sync, not primary data
3. Local-First Writes
All writes go to Hive first
UI updates instantly
Remote sync happens asynchronously
4. No Layer Violations
No DTOs in UI
No Hive models in Domain
No API leakage anywhere outside Data layer
Tech Stack
Flutter
State Management: Riverpod 2.x
Local Storage: Hive
Backend/Auth: Supabase
Networking: Dio
Navigation: GoRouter
Architecture: Clean Architecture
Design System: Sacred Editorial (custom, no default Material UI)
Architecture
Layers
Presentation
Screens, widgets
Riverpod providers
No business logic
Domain
Entities
Repository interfaces
UseCases
Result + Failure system
Data
DTOs (Freezed + JSON)
Mappers (DTO → Domain)
Local (Hive)
Remote (Dio / Supabase)
Repository implementations
Folder Structure (High Level)
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── providers/
│   ├── router/
│   ├── sync/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   ├── bookmarks/
│   ├── chapters/
│   ├── collections/
│   ├── shloks/
│   └── settings/
└── main.dart
Domain Model (FINAL)
Shlok
id (BG_<chapter>_<verse>)
chapterId
verseNumber
sanskritText
transliteration
translation
commentary (optional)
Chapter
id (BG_1)
index
title
titleSanskrit
verseCount
description (optional)
Bookmark
id
shlokId
createdAt
note (optional)
Collection
id
name
createdAt
CollectionItem
id
collectionId
shlokId
order
addedAt
Data Layer Rules
DTOs must be separate from domain models
Use Freezed + JSON
Use mappers for conversion
Hive models must be separate
Repositories return ONLY domain entities
Strategy

local → remote → update local

Result & Failure Pattern

All operations return:

Ok<T>
Err<T>

Failure types:

NetworkFailure
ServerFailure
CacheFailure
ValidationFailure
UnknownFailure

UI never uses try/catch.

Use Case Pattern
One class = one responsibility
Single public method: call()
Injected via Riverpod
Presentation Layer Rules (Riverpod)
UI does NOT access repositories directly
UI → Provider → UseCase → Repository
Use AsyncValue for all async state
No global mutable state
No business logic inside widgets
Provider Flow

UI → Provider → UseCase → Repository → Data Sources

Implementation Workflow (STRICT)
Project setup
Domain layer
Data layer
Presentation foundation
UI (feature-by-feature)
Backend integration

Rules:

Do NOT skip steps
Do NOT mix layers
Design System (Sacred Editorial)
Philosophy
Manuscript-like experience
Content-first UI
Calm, spacious layouts
Rules
No borders or dividers
Use surface layering
Serif = wisdom content
Sans = utility text
No default Material UI usage
Typography
Noto Serif (content)
Inter (UI)
Fonts are bundled locally (offline-first)
Animations
Minimum 300ms
Slow, meditative transitions
UI Development Rules
Build screen-by-screen
Create reusable components first
No hardcoded styles
Use theme + spacing system
Editorial UI Rendering Principles
UI should feel like a sacred manuscript
Avoid dense layouts
Maintain strong hierarchy:

Sanskrit → highest
Transliteration → secondary
Translation → readable body

List Rendering Rules
No separators
Use spacing only
Use ListView.builder / SliverList
BouncingScrollPhysics
Maintain breathing space
Loading & Error UX
Loading
Skeleton UI only
No spinners
Error
Calm editorial style
No harsh red
Retry via ref.invalidate
Interaction Rules
No ripple effects
Subtle scale animation (1 → 0.98)
300ms duration
Minimal feedback
Detail Screen Philosophy
Single focused content
Generous spacing
Optional sections shown conditionally
Immersive reading experience
Bookmark Interaction
Toggle state (reactive)
Uses providers + usecases
No direct repository access
Sync System Behavior (CRITICAL)
Write Flow

On add/remove:

Write to Hive (instant UI)
Trigger async sync to Supabase
Do NOT wait for response
Read Flow
UI always reads from Hive
Hydration

On login/app start:

Fetch remote data
Overwrite Hive
Current Limitation
No retry mechanism for failed sync
Features Implemented
Chapters (list + UI)
Shlok list (editorial rendering)
Shlok detail (immersive screen)
Bookmarks
Collections (partial UI)
Hive persistence
Supabase Auth
Sync system
In Progress / Next
Settings screen (theme + font scaling)
Search UI
Collections UI
Step 6.5: Sync reliability improvements
Current Task (NEXT)
Step 6.5 — Sync Refinement

Goals:

Retry mechanism for failed sync
Extend CollectionRepository sync
Ensure consistency between repositories

Constraints:

Do NOT change architecture
Do NOT change UI
Keep local-first
Keep fire-and-forget
Critical Rules for Future Work
Do NOT modify domain models
Do NOT introduce Material UI patterns
Do NOT break offline-first behavior
Do NOT move logic to UI
Do NOT add unnecessary packages
Notes for Continuation
Respect Clean Architecture strictly
Follow Sacred Editorial design rules
Maintain calm UX philosophy
Keep system scalable and backend-agnostic