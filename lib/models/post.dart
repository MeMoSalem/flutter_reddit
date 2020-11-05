

import 'package:flutter/cupertino.dart';

class Post{
  String title;
  String author;
  String urlByDest;
  String thumbnail;
  String url;
  Map<String, dynamic> scureMedia;
  Post({
    @required this.title,
    @required this.author,
    @required this.url,
    this.urlByDest,
    this.thumbnail,
    this.scureMedia
  });

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      title: json['title'],
      author: json['author'],
      url: "https://www.reddit.com/"+json['url'],
      urlByDest: json['url_overridden_by_dest'],
      thumbnail: json['thumbnail'],
      scureMedia: json['secure_media_embed']
    );
  }
}