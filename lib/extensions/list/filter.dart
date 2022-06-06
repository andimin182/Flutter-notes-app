/* We create an extension that allows us to filter a Stream of something.
   T is a generic type.
  1. We create a function name filter where we grab another function
     to make a testing called 'where' and it returns a bool
  2. We map the stream to a list of the items that pass the test
*/

extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
