import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/session_controller.dart';
import '../data/profile_repository.dart';

final userProfileProvider = FutureProvider.autoDispose<FullUserProfile>((ref) async {
  final scope = ref.watch(sessionScopeProvider);
  if (scope == null) {
    throw StateError('Not authenticated');
  }
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile(scope.userId);
});
