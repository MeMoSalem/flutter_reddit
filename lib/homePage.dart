import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_reddit/provider/dataProvider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget{

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    Provider.of<DataProvider>(context,listen: false).fetchPosts();
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 1000));
    await  Provider.of<DataProvider>(context,listen: false).fetchPosts();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {

    final media = MediaQuery.of(context).size;
    var postData = Provider.of<DataProvider>(context);
    final _postsList = postData.getPosts;
    final PostLoadingStage _stage = postData.stage;

    return SafeArea(
      child: WillPopScope(
        onWillPop: (){
          return Future.value(false);
        },
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleSpacing: 0.0,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
              child: Text("Flutter Reddit Posts",
              style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          ),
          body: _stage == PostLoadingStage.LOADING ?
          Center(
              child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation(Color(0xff2A4972)))):
          _stage == PostLoadingStage.ERROR?
          Center(child: Text(postData.errorMessage),):
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              controller: _refreshController,
              onRefresh: _onRefresh,
              // the onLoading will be null in this case as all of the data is in one page so
              // there will be no pagination
              onLoading: null,
              footer: CustomFooter(
                builder: (BuildContext context,LoadStatus mode){
                  return Container();
                },
              ),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                  itemCount:  _postsList.isEmpty ? 1 :_postsList.length,
                  itemBuilder: (context, index){
                  // if(_postsList[index].scureMedia.isNotEmpty)
                  //  print("here is video link ${_postsList[index].scureMedia['media_domain_url']}");
                    return   _postsList.isEmpty ?
                    Center(child: Padding(
                      padding: EdgeInsets.only(top: media.height * 0.4),
                      child: Text("No Posts to show !"),),):
                      InkWell(
                        onTap: ()async{
                            try{
                              await launch(_postsList[index].url,
                                  forceWebView: true);
                            } catch(e){
                              print(e);
                              showAlertDialog(context,
                                  alertTitle: Text("URL could't launch !!!"),
                                  content: "");
                            }
                        },
                        child: postCard(context, title: _postsList[index].title,
                        urlByDest: _postsList[index].urlByDest,
                        thumbnail: _postsList[index].thumbnail,
                        author: _postsList[index].author
                        ),
                      );
                  }
              ),
            ),
          ),
        ),
      ),
    );
  }
}


Widget postCard(BuildContext context, {var title, var urlByDest, var thumbnail, String author}) =>

    Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 15.0, right: 15.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:5.0),
                child: Text("Posted by u/$author",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black26,
                      fontSize: 10.0),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$title",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold,
                              color: Colors.black, fontSize: 16.0),),
                       urlByDest != null ?
                        InkWell(
                          onTap: ()async{
                            try{
                              await launch(urlByDest.toString(),
                                  forceWebView: true);

                            } catch(e){
                              print(e);
                              showAlertDialog(context,
                              alertTitle: Text("URL could't launch !!!"),
                                  content: "");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top:8.0, bottom: 5.0),
                            child: Text(urlByDest.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                              color: Colors.blue,
                            ),),
                          ),
                        ):Container()
                      ],
                    ),
                  ),
                  thumbnail != "self" ?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image.network(thumbnail, height: 100, width: 100,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                    ),
                  ):Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );


showAlertDialog(BuildContext context, {Widget alertTitle, String content}) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text(
      "OK",
      style: TextStyle(color: Color(0xff2A4972),
          fontWeight: FontWeight.bold),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: alertTitle ?? SizedBox(),
    content: Text(content),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}