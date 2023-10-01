part of 'scope_item.dart';

/// [comment] - Comment
class Comment extends ScopeItem {
  const Comment({required this.comment});

  final String comment;

  @override
  operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.comment == comment;
  }

  @override
  int get hashCode => comment.hashCode;
}
