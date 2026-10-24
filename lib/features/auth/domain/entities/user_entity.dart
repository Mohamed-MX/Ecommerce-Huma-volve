/// Domain entity representing an authenticated user profile
class UserEntity {
  final int id;
  final String email;
  final String name;
  final String role;
  final String avatar;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatar,
  });
}
