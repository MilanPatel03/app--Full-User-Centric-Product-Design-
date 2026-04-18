import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/app_user.dart';


/// DTO mapping from Supabase's [sb.User] to the domain [AppUser].
///
/// Lives ONLY in the data layer. The domain never sees [sb.User].
class UserDto {
  const UserDto._();

  /// Maps a Supabase [sb.User] to a domain [AppUser].
  static AppUser toDomain(sb.User user) => AppUser(
        id: user.id,
        email: user.email ?? '',
      );
}
