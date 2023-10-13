abstract interface class IRepository<T> {
  /// Initializes the Repository
  /// This is a mandatory call, without which a repository is almost certainly
  /// not going to function as expected.
  Future<void> initialize();

  /// Adds [T] to the Database.
  /// Analogous to the "CREATE" operation.
  Future<void> add(T object);

  /// Retrieves [T] of the given ID.
  /// Analogous to the "READ" operation.
  Future<T> get(String id);

  /// Retrieves all records of [T]
  /// This is an expensive operation that should be used cautiously.
  Future<List<T>> getAll();

  /// Updates [T] of the matching ID to the Database.
  /// Analogous to the "UPDATE" operation.
  Future<void> update(T object); //TODO remove this?

  /// Removes [T] of the given ID from the Database.
  /// Analogous to the "DELETE" operation.
  Future<void> delete(String id);
}
