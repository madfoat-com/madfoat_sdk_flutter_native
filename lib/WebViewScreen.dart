import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';
import 'helper/global_utils.dart';
import 'helper/network_helper.dart';
// import 'Glob';
// import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class WebviewScreen extends StatefulWidget {

  static const String id = 'webview_screen';
  // late final String title;
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}
class _WebviewScreenState extends State<WebviewScreen>{

  var random = new Random();
  String _session = '';
  String redirectionurl='';
  String _session2='';
  bool _loadWebView = false;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _con ;
  void _callApi()async{
    var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote_mpi.xml');


    // create xml here..
    String xmlString =  CreateXML();

    print('XML String =  $xmlString');

    var response = await http.post(uri,body: xmlString);
    print('Response =  ${response.statusCode} & ${response.body}');
    {
      final doc = XmlDocument.parse(response.body);
      final redirecthtml = doc.findAllElements('redirecthtml').map((node) => node.text);
      final session = doc.findAllElements('session').map((node) => node.text);

      String url=redirecthtml.toString();
      String url1 = url.replaceRange(0,1, "");
      int leng = url1.length;
      print('Length = $leng');

      redirectionurl = url1.replaceRange(leng - 1,leng, "");
      _session = session.toString();
      String _session1 = _session.replaceRange(0,1, "");
      int sLen = _session1.length;
      _session2=_session1.replaceRange(sLen - 1, sLen,"");
      print(' redirect url = before = ${url.toString()} ');
      print(' redirect url = after =  ${redirectionurl.toString()}');
      print(' session url = $_session2');
      // _callresponseApi(); // ith webview load ayi kazhinj vilikendath alle?
      setState(() {
        _loadWebView = true;
      });
    }
  }

  void _callresponseApi()async{
    String responsexmlString=CreateResponseXML();

    var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote.xml');
    var response = await http.post(uri,body: responsexmlString);
    print('Response 2 =  ${response.statusCode} & ${response.body}');
  }

  void _loadHTML() async {
    _con.loadUrl(Uri.dataFromString(
        setHTML(),
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  String setHTML() {
    return ('''
<html>
<head></head>
<body>
    <script type="text/javascript">

    function show3DSChallenge() {
        var redirect_html = '$redirectionurl';
        var txt = document.createElement("textarea");
        txt.innerHTML = redirect_html;
        redirect_html_new = decodeURIComponent(txt.value);
        document.body.innerHTML = redirect_html_new;
        eval(document.getElementById('authenticate-payer-script').text)

    }
    show3DSChallenge();
    </script>
</body>
</html>


      

    ''');
  }
  String _homeText = 'Webview not loaded';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _callApi();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // appBar: AppBar(
      //
      //   title: Text('Title'),
      // ),
      body: _loadWebView? Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.red,
          width: 500,//MediaQuery.of(context).size.width
          height: 800,//MediaQuery.of(context).size.height
          child: WebView(
            initialUrl: '',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
              _con = webViewController;
              _loadHTML();
            },
            onProgress: (int progress) {
              print("WebView is loading (progress : $progress%)");
            },
            navigationDelegate: (NavigationRequest request) {
              print('Inside navigationDelegate ${request.url}');
              if (request.url.startsWith('telr.com')) {
                print('blocking navigation to $request}');
                setState(() {
                  _loadWebView = false;
                  _homeText = 'Loading second api';
                });
                _callresponseApi();
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
              if (url.contains('telr.com'))
              {
                print('Inside onPageFinished telr.com');
              }
            },
            gestureNavigationEnabled: true,
          ),
        );
      }): Text(_homeText),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,

      // floatingActionButton: Container(
      //   height: 100,
      //   width: 100,
      //   child: MaterialButton(
      //     color: Colors.blueAccent,
      //     onPressed: _callApi,
      //     child:  Center(child:Container(
      //
      //       child: Text('Click Here',),
      //     )),
      //   ),
      //
      // ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  String CreateXML(){
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('remote', nest: () {
      builder.element('store', nest: (){
        builder.text('15996'); //15164
      });
      builder.element('key', nest: (){
        builder.text('BG88b#FBFpX^xSzw');
      });



      //tran
      builder.element('tran', nest: (){

        builder.element('type', nest: (){
          builder.text('sale');
        });
        builder.element('class', nest: (){
          builder.text('ecom');
        });
        builder.element('cartid', nest: (){
          builder.text('atZGs9C762');
        });
        builder.element('description', nest: (){
          builder.text('Test for Mobile API MPI order');
        });

        builder.element('currency', nest: (){
          builder.text('AED');
        });
        builder.element('amount', nest: (){
          builder.text('1');
        });
        builder.element('test', nest: (){
          builder.text('0');
        });
        builder.element('threeds2enabled', nest: (){
          builder.text('1');
        });
        builder.element('firstref', nest: (){
          builder.text('');
        });
      });

      //billing

      // address
      builder.element('card', nest: (){
        builder.element('number', nest: (){
          builder.text(GlobalUtils.cardnumber);
        });
        builder.element('expiry', nest: (){
          builder.element('month', nest: (){
            builder.text(GlobalUtils.cardexpirymonth);
          });
          builder.element('year', nest: (){
            builder.text(GlobalUtils.cardexpiryyr);
          });
        });
        builder.element('savecard', nest: (){
          builder.text(GlobalUtils.keysaved);
        });
        builder.element('cvv', nest: (){
          builder.text(GlobalUtils.cardcvv);
        });
      });
      builder.element('browser', nest: (){
        builder.element('agent', nest: (){
          builder.text('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
        });
        builder.element('accept', nest: (){
          builder.text('*/*');
        });
      });
      builder.element('mpi', nest: (){
        builder.element('returnurl', nest: (){
          builder.text('');
        });
        builder.element('accept', nest: (){
          builder.text('*/*');
        });
      });
    });

    final bookshelfXml = builder.buildDocument();

    print(bookshelfXml);
    return bookshelfXml.toString();
    //  pay(bookshelfXml);
  }


  String CreateResponseXML(){
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('remote', nest: () {
      builder.element('store', nest: (){
        builder.text('15996');
      });
      builder.element('key', nest: (){
        builder.text('BG88b#FBFpX^xSzw');
      });
      //tran
      builder.element('tran', nest: (){

        builder.element('type', nest: (){
          builder.text('sale');
        });
        builder.element('class', nest: (){
          builder.text('ecom');
        });
        builder.element('cartid', nest: (){
          builder.text('atZGs9C762');
        });
        builder.element('description', nest: (){
          builder.text('Test for Mobile API MPI order');
        });

        builder.element('currency', nest: (){
          builder.text('AED');
        });
        builder.element('amount', nest: (){
          builder.text('1');
        });
        builder.element('test', nest: (){
          builder.text('1');
        });


      });

      // card
      // address
      builder.element('card', nest: (){
        builder.element('number', nest: (){
          builder.text(GlobalUtils.cardnumber);
        });
        builder.element('expiry', nest: (){
          builder.element('month', nest: (){
            builder.text(GlobalUtils.cardexpirymonth);
          });
          builder.element('year', nest: (){
            builder.text(GlobalUtils.cardexpiryyr);
          });
        });
        builder.element('savecard', nest: (){
          builder.text(GlobalUtils.keysaved);
        });
        builder.element('cvv', nest: (){
          builder.text(GlobalUtils.cardcvv);
        });
      });
      //billing
      builder.element('billing', nest: (){
        // name
        builder.element('name', nest: (){
          builder.element('title', nest: (){
            builder.text('');
          });
          builder.element('first', nest: (){
            builder.text('Telr');
          });
          builder.element('last', nest: (){
            builder.text('Dev');
          });
        });
        // address
        builder.element('address', nest: (){
          builder.element('line1', nest: (){
            builder.text('SIT Tower');
          });
          builder.element('city', nest: (){
            builder.text('Dubai');
          });
          builder.element('region', nest: (){
            builder.text('Dubai');
          });
          builder.element('country', nest: (){
            builder.text('AE');
          });
        });

        builder.element('email', nest: (){
          builder.text('divya.thampi@telr.com');
        });
        builder.element('ip', nest: (){
          builder.text('106.193.225.18');
        });
      });



      builder.element('mpi', nest: (){

        builder.element('session', nest: (){
          builder.text(_session2);
        });
      });
    });

    final bookshelfXml = builder.buildDocument();

    print(bookshelfXml);
    return bookshelfXml.toString();
    //  pay(bookshelfXml);
  }



}
