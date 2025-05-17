/// 徒步攻略数据模型
class GuideModel {
  /// 攻略ID
  final String id;
  
  /// 攻略标题
  final String title;
  
  /// 攻略内容
  final String content;
  
  /// 作者
  final String author;
  
  /// 作者ID
  final String authorId;
  
  /// 作者头像URL
  final String? authorAvatarUrl;

  /// 点赞数
  final int likes;
  
  /// 阅读数
  final int views;
  
  /// 发布时间
  final DateTime publishDate;
  
  /// 更新时间
  final DateTime updateDate;
  
  /// 封面图标（图标代码）
  final String iconCode;
  
  /// 封面图片URL
  final String? coverUrl;
  
  /// 标签列表
  final List<String> tags;

  /// 是否已点赞
  final bool isLiked;

  /// 构造函数
  GuideModel({
    required this.id,
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

  /// 从JSON创建模型
  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      authorId: json['author_id'] as String,
      authorAvatarUrl: json['author_avatar_url'] as String?,
      likes: json['likes'] as int,
      views: json['views'] as int,
      publishDate: DateTime.parse(json['publish_date'] as String),
      updateDate: DateTime.parse(json['update_date'] as String),
      iconCode: json['icon_code'] as String,
      coverUrl: json['cover_url'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'author_id': authorId,
      'author_avatar_url': authorAvatarUrl,
      'likes': likes,
      'views': views,
      'publish_date': publishDate.toIso8601String(),
      'update_date': updateDate.toIso8601String(),
      'icon_code': iconCode,
      'cover_url': coverUrl,
      'tags': tags,
      'is_liked': isLiked,
    };
  }
  
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
      likes: isLiked == null ? likes : (isLiked ? likes + (this.isLiked ? 0 : 1) : likes - (this.isLiked ? 1 : 0)),
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