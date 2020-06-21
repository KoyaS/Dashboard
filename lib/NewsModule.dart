import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsModule extends StatefulWidget {
  @override
  _NewsModuleState createState() => _NewsModuleState();
}

class _NewsModuleState extends State<NewsModule> {
  final double borderRadius = 10;
  double width = 400;
  double height = 400;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(20),
      width: width,
      height: height,
      // clipBehavior: Clip.antiAlias,
      // constraints: BoxConstraints(maxWidth: 400, maxHeight: 400,minHeight: 400,minWidth: 400),
      child: FutureBuilder(
        future: fetchArticles(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return NewsModuleContainer(
              newsArticleContent: snapshot.data,
              moduleHeight: 400,
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 6),
              color: Colors.grey,
              spreadRadius: 2)
        ],
      ),
    );
  }
}

class NewsModuleContainer extends StatefulWidget {
  final List<NewsArticle> newsArticleContent;
  final double moduleHeight;

  NewsModuleContainer(
      {@required this.newsArticleContent, @required this.moduleHeight});

  @override
  _NewsModuleContainerState createState() => _NewsModuleContainerState();
}

class _NewsModuleContainerState extends State<NewsModuleContainer> {
  final double containerPadding = 20;

  List<ArticleCard> newsArticleCards = new List();

  @override
  Widget build(BuildContext context) {
    widget.newsArticleContent.forEach((article) {
      newsArticleCards.add(new ArticleCard(
        title: article.title,
        urlToImage: article.urlToImage,
        publishedAt: article.publishedAt,
      ));
    });

    // var articleListView = ListView(
    //   shrinkWrap: true,
    //   children: [
    //     Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Container(
    //             margin: EdgeInsets.only(bottom: 3),
    //             child: Text(
    //               'TechCrunch',
    //               style: Theme.of(context).textTheme.headline4,
    //             )),
    //         Container(
    //           height: 0.5,
    //           width: double.infinity,
    //           color: Colors.black,
    //         )
    //       ],
    //     ),
    //     ...newsArticleCards,
    //   ],
    // );

    var _listController = ScrollController();
    var articleListView = ListView.builder(

        controller: _listController,
        itemCount: widget.newsArticleContent.length+1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListHeader(title: 'TechCrunch');
          } else {
            index = index-1;
            return newsArticleCards[index];
          }
        });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      doScrollCycle(articleListView);
      new Timer.periodic(
          Duration(seconds: 20), (Timer t) => doScrollCycle(articleListView));
    });

    return Container(
        // margin: EdgeInsets.all(containerPadding),
        child: Column(
          children: [
            // RaisedButton(onPressed: () => {articleListView.controller.animateTo(articleListView.controller.position.maxScrollExtent, duration: Duration(seconds: 10), curve: Curves.slowMiddle)}),
            Container(
                height: widget.moduleHeight,
                child: articleListView)
          ],
        ));
  }
}

class ArticleCard extends StatelessWidget {
  final String title;
  final String urlToImage;
  final DateTime publishedAt;

  ArticleCard(
      {@required this.title,
      @required this.urlToImage,
      @required this.publishedAt});

  @override
  Widget build(BuildContext context) {
    String agoString = '';
    DateTime currentTime = DateTime.now();
    var timeDifference = currentTime.difference(publishedAt);
    var hourDifference = timeDifference.inHours;
    if (hourDifference < 25) {
      agoString = hourDifference.toString() + 'h';
    } else {
      agoString = timeDifference.inDays.toString() + 'd';
    }
    agoString += ' ago';

    return SizedBox(
        height: 100,
        width: 400,
        child: Container(
          padding: EdgeInsets.only(top: 10, left: 10),
          child: Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 0.3,
                                fontWeight: FontWeight.w200,
                                fontFamily: 'Montserrat'),
                          ),
                        ),
                        Text(agoString,
                            style: Theme.of(context).textTheme.subtitle2),
                      ],
                    )),
              ),
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      urlToImage,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ListHeader extends StatelessWidget {
  final String title;

  ListHeader({@required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(bottom: 3),
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                    )),
                Container(
                  height: 0.5,
                  width: double.infinity,
                  color: Colors.black,
                )
              ],
            ),
    );
  }
}

void doScrollCycle(ListView articleListView) {
  var bottomPos = articleListView.controller.position.maxScrollExtent+40;
  var topPos = articleListView.controller.position.minScrollExtent;
  articleListView.controller
      .animateTo(bottomPos,
          duration: Duration(seconds: 10), curve: Curves.easeInOut)
      .then((value) => articleListView.controller.animateTo(topPos,
          duration: Duration(seconds: 10), curve: Curves.easeInOut));
}

Future<List<NewsArticle>> fetchArticles() async {
  final response = await http.get(
      'https://newsapi.org/v2/top-headlines?apiKey=${DotEnv().env['NEWS_API_KEY']}&sources=techcrunch');
  return parseArticles(response.body);
}

List<NewsArticle> parseArticles(String responseBody) {
  List<NewsArticle> parsedArticles = new List();

  Map<String, dynamic> parsed = json.decode(responseBody);

  // ua short for unconverted article
  for (Map<String, dynamic> ua in parsed['articles']) {
    String sourceName = ua['source']['id'];
    String sourceID = ua['source']['name'];
    String author = ua['author'];
    String title = ua['title'];
    String description = ua['description'];
    String url = ua['url'];
    String urlToImage = ua['urlToImage'];
    DateTime publishedAt = DateTime.parse(ua['publishedAt']);
    String content = ua['content'];

    // print(sourceName + sourceID + author + title + description + url + urlToImage + publishedAt + content);

    NewsArticle newsArticle = new NewsArticle(
        sourceName: sourceName,
        sourceID: sourceID,
        author: author,
        title: title,
        description: description,
        url: url,
        urlToImage: urlToImage,
        publishedAt: publishedAt,
        content: content);

    parsedArticles.add(newsArticle);
  }

  return (parsedArticles);
}

class NewsArticle {
  final String sourceName;
  final String sourceID;

  final String title;
  final String author;
  final String content;
  final String description;
  final String url;
  final String urlToImage;
  final DateTime publishedAt;

  NewsArticle(
      {this.sourceID,
      this.sourceName,
      this.title,
      this.author,
      this.content,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt});
}
