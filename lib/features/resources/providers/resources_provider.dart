import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/resources_repository.dart';
import '../models/resource_model.dart';

final resourcesRepositoryProvider = Provider<ResourcesRepository>((ref) {
  return ResourcesRepository();
});

final resourcesStreamProvider = StreamProvider<List<ResourceModel>>((ref) {
  return ref.watch(resourcesRepositoryProvider).streamResources();
});

final resourcesNotifierProvider = AsyncNotifierProvider<ResourcesNotifier, void>(ResourcesNotifier.new);

class ResourcesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  ResourcesRepository get _repo => ref.read(resourcesRepositoryProvider);

  Future<ResourceModel> addResource({
    required String title,
    required String subject,
    required String fileType,
    required String localPath,
  }) async {
    return _repo.addResource(
      title: title,
      subject: subject,
      fileType: fileType,
      localPath: localPath,
    );
  }

  Future<void> deleteResource(String resourceId) async {
    await _repo.deleteResource(resourceId);
  }
}