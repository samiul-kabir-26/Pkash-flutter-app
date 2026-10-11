import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/profile_repository.dart';

final userProfileProvider = FutureProvider.autoDispose<FullUserProfile>((ref) async {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) {
    throw Exception('Not authenticated');
  }
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile(session.user.id);
});
