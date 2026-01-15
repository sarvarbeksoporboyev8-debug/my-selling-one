import '../entities/watch.dart';
import '../repositories/watches_repository.dart';

/// Use case for getting user's watches
class GetMyWatchesUseCase {
  final WatchesRepository _repository;

  GetMyWatchesUseCase(this._repository);

  Future<List<Watch>> call() {
    return _repository.getMyWatches();
  }
}

/// Use case for creating a watch
class CreateWatchUseCase {
  final WatchesRepository _repository;

  CreateWatchUseCase(this._repository);

  Future<Watch> call(CreateWatch watch) {
    return _repository.createWatch(watch);
  }
}

/// Use case for updating a watch
class UpdateWatchUseCase {
  final WatchesRepository _repository;

  UpdateWatchUseCase(this._repository);

  Future<Watch> call(int watchId, CreateWatch watch) {
    return _repository.updateWatch(watchId, watch);
  }
}

/// Use case for deleting a watch
class DeleteWatchUseCase {
  final WatchesRepository _repository;

  DeleteWatchUseCase(this._repository);

  Future<void> call(int watchId) {
    return _repository.deleteWatch(watchId);
  }
}
