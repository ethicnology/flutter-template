/// An immutable note returned by the collection.
final class Note {
  const Note({required this.id, required this.text, required this.createdAt});

  final int id;
  final String text;
  final DateTime createdAt;
}
