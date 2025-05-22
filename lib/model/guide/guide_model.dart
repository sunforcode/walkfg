import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'guide_model.g.dart';

/// 徒步攻略数据模型
@JsonSerializable()
class GuideModel extends BaseModel {
  /// 攻略标题
  final String title;

  /// 攻略内容
  final String content;

  /// 作者
  final String author;

  /// 作者ID
  @JsonKey(name: 'author_id')
  final String authorId;

  /// 作者头像URL
  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;

  /// 点赞数
  final int likes;

  /// 阅读数
  final int views;

  /// 发布时间
  @JsonKey(name: 'publish_date')
  final DateTime publishDate;

  /// 更新时间
  @JsonKey(name: 'update_date')
  final DateTime updateDate;

  /// 封面图标（图标代码）
  @JsonKey(name: 'icon_code')
  final String iconCode;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 标签列表
  final List<String> tags;

  /// 是否已点赞
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  /// 默认作者头像
  static const String defaultAuthorAvatar =
      'assets/images/placeholders/default_avatar.png';

  /// 默认封面图片
  static const String defaultCoverImage =
      'assets/images/placeholders/default_cover.png';

  /// 构造函数
  GuideModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    this.authorAvatarUrl,
    required this.likes,
    required this.views,
    required this.publishDate,
    required this.updateDate,
    required this.iconCode,
    this.coverUrl,
    required this.tags,
    this.isLiked = false,
  });

  /// 从JSON创建
  factory GuideModel.fromJson(Map<String, dynamic> json) =>
      _$GuideModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$GuideModelToJson(this);

  /// 获取格式化的发布日期
  String getFormattedPublishDate() {
    return '${publishDate.year}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}';
  }

  /// 创建带有点赞状态的副本
  GuideModel copyWith({bool? isLiked}) {
    return GuideModel(
      id: id,
      title: title,
      content: content,
      author: author,
      authorId: authorId,
      authorAvatarUrl: authorAvatarUrl,
      likes: isLiked == null
          ? likes
          : (isLiked
              ? likes + (this.isLiked ? 0 : 1)
              : likes - (this.isLiked ? 1 : 0)),
      views: views,
      publishDate: publishDate,
      updateDate: updateDate,
      iconCode: iconCode,
      coverUrl: coverUrl,
      tags: tags,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
