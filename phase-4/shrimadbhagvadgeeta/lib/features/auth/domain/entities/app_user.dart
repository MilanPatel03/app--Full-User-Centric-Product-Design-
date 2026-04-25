import 'package:equatable/equatable.dart';

/// Domain entity representing an authenticated user.
///
/// ## Design Constraint: Minimal & API-agnostic
/// This entity knows NOTHING about Supabase, Firebase, or any auth provider.
/// It carries only the facts the domain and UI actually need.
///
/// If a future backend adds a `username` field, add it here.
/// Never add Supabase-specific types (e.g., `User` from supabase_flutter).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
  });

  /// Stable UUID from the auth provider (Supabase `auth.users.id`).
  final String id;

  /// Verified email address.
  final String email;

  @override
  List<Object?> get props => [id, email];

  @override
  String toString() => 'AppUser(id: $id, email: $email)';
}
