import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});
