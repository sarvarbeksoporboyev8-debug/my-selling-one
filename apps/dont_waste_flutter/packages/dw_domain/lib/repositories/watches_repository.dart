import '../entities/watch.dart';

/// Repository interface for buyer watches
abstract class WatchesRepository {
  /// Get user's watches
  Future<List<Watch>> getMyWatches();

  /// Create a new watch
  Future<Watch> createWatch(CreateWatch watch);

  /// Update a watch
  Future<Watch> updateWatch(int watchId, CreateWatch watch);

  /// Delete a watch
  Future<void> deleteWatch(int watchId);
}
