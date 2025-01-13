import 'post_dto.dart';

class PostsDto {
  final List<PostDto> posts;

  PostsDto({required this.posts});

  factory PostsDto.fromJson(Map<String, dynamic> json) {
    return PostsDto(
      posts: (json['posts'] as List).map((post) => PostDto.fromJson(post)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => post.toJson()).toList(),
    };
  }
}
