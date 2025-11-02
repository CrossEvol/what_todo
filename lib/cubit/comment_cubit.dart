import 'package:flutter_bloc/flutter_bloc.dart';

/// 一个简单的 Cubit 来管理评论的初始状态。
/// 初始状态是一个空字符串。
class CommentCubit extends Cubit<String> {
  CommentCubit() : super('');  /// 设置初始评论内容。
  void setInitialComment(String comment) {
    emit(comment);
  }

  /// 清除评论内容，重置为空字符串。
  void clearComment() {
    emit('');
  }
}
