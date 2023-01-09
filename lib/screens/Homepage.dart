import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'globals.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  late PullToRefreshController pullToRefreshController;
  String url = "";
  final urlController = TextEditingController();
  late final String web;


  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Row(
          children: [
            Expanded(
              flex: 2,
              child: IconButton(
                onPressed: () {
                  webViewController?.goBack();
                  setState(() {});
                },
                icon: const Icon(Icons.arrow_back,color: Colors.white,),
              ),
            ),
            Spacer(flex: 1,),
            Expanded(
              flex: 2,
              child: IconButton(
                icon: const Icon(Icons.menu_outlined,color: Colors.white,),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Center(
                            child: Text("Bookmarks",
                                style: TextStyle(color: Colors.black))),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: ListView.separated(
                            itemCount: Global.bookMarksList.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  webViewController?.loadUrl(
                                    urlRequest: URLRequest(
                                      url: Uri.parse(Global.bookMarksList[i]),
                                    ),
                                  );
                                },
                                title: Text(
                                  Global.bookMarksList[i],
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                   TextStyle(color: Colors.grey.shade800),
                                ),
                              );
                            },
                            separatorBuilder: (context, i) {
                              return const Divider(
                                color: Colors.white,
                                endIndent: 30,
                                indent: 30,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Global.bookMarksList.add(url);
              Global.bookMarksList = Global.bookMarksList.toSet().toList();
            },
            icon: const Icon(Icons.bookmark,color: Colors.white,),
          ),
          IconButton(
            onPressed: () {
              webViewController?.loadUrl(
                urlRequest: URLRequest(
                  url: Uri.parse(web),
                ),
              );
            },
            icon: const Icon(Icons.home,color: Colors.white,),
          ),
          IconButton(
            onPressed: () {
              webViewController?.goForward();
            },
            icon: const Icon(Icons.arrow_forward,color: Colors.white,),
          ),
        ],
      ),
      body: Center(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(
            url: Uri.parse("https://www.google.com/search?q=physics+wallah+website&rlz=1C1YTUH_enIN993IN993&sxsrf=ALiCzsZXfO1DdBjBMBJXU3r6Cz39-dTGIQ%3A1673259141857&ei=hei7Y7mBNPrY4-EPxLS64Ac&oq=physics+wallah&gs_lcp=Cgxnd3Mtd2l6LXNlcnAQARgEMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgoIABBHENYEELADMgcIABCwAxBDMgcIABCwAxBDMgcIABCwAxBDMgcIABCwAxBDMg0IABDkAhDWBBCwAxgBMg0IABDkAhDWBBCwAxgBMg0IABDkAhDWBBCwAxgBMhIILhDHARDRAxDIAxCwAxBDGAIyEgguEMcBENEDEMgDELADEEMYAkoECEEYAEoECEYYAVAAWABgoiloAXABeACAAQCIAQCSAQCYAQDIARHAAQHaAQYIARABGAnaAQYIAhABGAg&sclient=gws-wiz-serp"),
          ),
          initialOptions: options,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController.endRefreshing();
            setState(
                  () {
                this.url = url.toString();
                urlController.text = this.url;
              },
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     webViewController?.reload();
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
      backgroundColor: Colors.black,
    );
  }
}
