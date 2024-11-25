abstract class IRepository<T> {
  Future<void> initialize();

  /// Creates an object in the database;
  ///
  /// Call this method to INSERT a new entry into the database. To update an
  /// existing instance, use [update] instead.
  ///
  /// throws [StateError] if an object of the same ID exists.
  Future<void> create(T object);

  /// Retrieves an object from the database of the given [id]. Returns [Null]
  /// if no such objet is found.
  ///
  /// Call this function to SELECT an object of the given [id] from the database.
  /// It is assumed that the given [id] represents the Primary Key in the
  /// database.
  ///
  Future<T?> read(String id);

  /// Searches for an object based on the supplied [query].
  ///
  /// The implementation of this function will depend heavily on the class [T].
  /// In a broader sense, a name search can be expected.
  Future<Iterable<T>> search(String query);

  /// Retrieves all objects from the database.
  ///
  /// As can be guessed, this is an expensive operation and should be used
  /// sparingly. TODO implement pagination.
  Future<Iterable<T>> readAll();

  /// Updates an object in the database;
  ///
  /// Call this function to UPDATE an object in the database.
  ///
  /// throws [StateError] if an object with the same ID does not exist.
  Future<void> update(T object);

  /// Deletes an object of the given [id] from the database;
  ///
  /// Call this function to DELETE an object from the database.
  ///
  /// throws [StateError] if an object of the given [id] does not exist.
  Future<void> delete(String id);
}
