

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reddit/models/post.dart';
import 'package:http/http.dart' as http;

enum PostLoadingStage {ERROR, LOADING, DONE}

class DataProvider extends ChangeNotifier{
  String errorMessage = "Network Error";
  PostLoadingStage stage;
  List<Post> _posts = [];
  List<Post> get getPosts => this._posts;

  void setPostsList(List<Post> posts) {
    _posts = posts;
  }

  Future fetchPosts() async{
    this.stage = PostLoadingStage.LOADING;
    try{
       http.Response response = await http.get(
         'https://www.reddit.com/r/FlutterDev.json'
       );
       final List<dynamic> responseData = (jsonDecode(response.body))["data"]["children"];
       List<Post> posts = [];

        if(responseData.isNotEmpty)
         responseData.forEach((postData) {
           final Post post = Post.fromJson(postData["data"]);
           posts.add(post);
         });

       setPostsList(posts);
       stage = PostLoadingStage.DONE;
    }catch(e){
      print(e);
      stage = PostLoadingStage.ERROR;
    }
    notifyListeners();
  }

}