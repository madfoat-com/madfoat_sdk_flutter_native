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
import 'package:flutter_dialogs/flutter_dialogs.dart';


import 'main.dart';

class WebviewScreenSavedcards extends StatefulWidget {

  static const String id = 'WebviewScreenSavedcards';
  // late final String title;
  @override
  _WebviewScreenSavedcardsState createState() => _WebviewScreenSavedcardsState();
}
class _WebviewScreenSavedcardsState extends State<WebviewScreenSavedcards>{

  var random = new Random();
  String _session = '';
  String redirectionurl='';
  String _session2='';
  bool _loadWebView = false;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _con ;
  void _callApi()async{
  //  var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote_mpi.xml'); //uat
    var uri = Uri.parse('https://secure.telr.com/gateway/mobile.xml');


    // create xml here..
    String xmlString =  CreateXML();

    print('XML String =  $xmlString');

    var response = await http.post(uri,body: xmlString);
  //  print('ResponseXXXX =  ${response.statusCode} & ${response.body}');
    {
      final doc = XmlDocument.parse(response.body);
      Iterable<String> statusmessage=doc.findAllElements('message').map((node) => node.text);
      print(statusmessage);
      alertShow(statusmessage.toString());
      // Fluttertoast.showToast(
      //     msg: statusmessage.toString(),
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
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
      // _callresponseApi(); //
      setState(() {
        _loadWebView = true;
      });
    }
  }
  void alertShow(String text) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text('$text', style: TextStyle(fontSize: 15),),
        // content: Text('$text Please try again.'),
        actions: <Widget>[
          BasicDialogAction(
              title: Text('Ok'),
              onPressed: () {
                setState(() {
                  // _showLoader = false;
                });
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
  // void _callresponseApi()async{
  //  // String responsexmlString=CreateResponseXML();
  //
  // //  var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote.xml'); //uat
  //   var uri = Uri.parse(' https://secure.telr.com/gateway/remote.xml');
  //   var response = await http.post(uri,body: responsexmlString);
  //   print('Response 2 =  ${response.statusCode} & ${response.body}');
  // }

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
  String _homeText = '';

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
          color: Colors.white,
          width: 800,//MediaQuery.of(context).size.width
          height: 1800,//MediaQuery.of(context).size.height
          child: WebView(
            initialUrl: '',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
              _con = webViewController;
          //    _loadHTML();
            },
            onProgress: (int progress) {
              print("WebView is loading (progress : $progress%)");
            },
            navigationDelegate: (NavigationRequest request) {
              print('Inside navigationDelegate ${request.url}');
              if (request.url.startsWith('telr.com')) {
                print('blocking navigation to $request}');
                // setState(() {
                //   _loadWebView = false;
                //   _homeText = 'Loading second api';
                // });

                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
           //   _callresponseApi();
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
    builder.element('mobile', nest: () {
      builder.element('store', nest: (){
        builder.text('15996');
      });
      builder.element('key', nest: (){
        builder.text('pQ6nP-7rHt@5WRFv');
      });
      builder.element('framed',nest:(){
        builder.text(GlobalUtils.framed);
      });

      builder.element('device', nest: (){
        builder.element('type', nest: (){
          builder.text(GlobalUtils.devicetype);
        });
        builder.element('id', nest: (){
          builder.text(GlobalUtils.deviceid);
        });
      });

      // app
      builder.element('app', nest: (){
        builder.element('name', nest: (){
          builder.text(GlobalUtils.appname);
        });
        builder.element('version', nest: (){
          builder.text(GlobalUtils.version);
        });
        builder.element('user', nest: (){
          builder.text(GlobalUtils.appuser);
        });
        builder.element('id', nest: (){
          builder.text(GlobalUtils.appid);
        });
      });

      //tran
      builder.element('tran', nest: (){
        builder.element('test', nest: (){
          builder.text(GlobalUtils.testmode);
        });
        builder.element('type', nest: (){
          builder.text('sale');
        });
        builder.element('class', nest: (){
          builder.text('cont');
        });
        builder.element('cartid', nest: (){
          builder.text(100000000 + random.nextInt(999999999));
        });
        builder.element('description', nest: (){
          builder.text('Test for Mobile API order');
        });
        builder.element('currency', nest: (){
          builder.text('aed');
        });
        builder.element('amount', nest: (){
          builder.text('2');
        });
        builder.element('language', nest: (){
          builder.text('en');
        });
        // builder.element('firstref', nest: (){
        //   builder.text(GlobalUtils.firstref);
        // });
        builder.element('ref', nest: (){
          builder.text('030029926874');  //transref
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
            builder.text(GlobalUtils.firstname);
          });
          builder.element('last', nest: (){
            builder.text(GlobalUtils.lastname);
          });
        });
        // address
        builder.element('address', nest: (){
          builder.element('line1', nest: (){
            builder.text(GlobalUtils.addressline1);
          });
          builder.element('city', nest: (){
            builder.text(GlobalUtils.city);
          });
          builder.element('region', nest: (){
            builder.text('');
          });
          builder.element('country', nest: (){
            builder.text(GlobalUtils.country);
          });
        });

        builder.element('phone', nest: (){
          builder.text(GlobalUtils.phone);
        });
        builder.element('email', nest: (){
          builder.text(GlobalUtils.emailId);
        });

      });

      builder.element('custref', nest: (){
        builder.text(GlobalUtils.custref);
      });
      builder.element('paymethod', nest: (){
        builder.element('type', nest: (){
          builder.text(GlobalUtils.paymenttype);
        });
        builder.element('cardtoken', nest: (){
          builder.text(GlobalUtils.token);
        });
      });

    });

    final bookshelfXml = builder.buildDocument();

    print(bookshelfXml);
    return bookshelfXml.toString();
   // pay(bookshelfXml);
  }


  // String CreateResponseXML(){
  //   final builder = XmlBuilder();
  //   builder.processing('xml', 'version="1.0"');
  //   builder.element('mobile', nest: () {
  //     builder.element('store', nest: (){
  //       builder.text('15996');
  //     });
  //     builder.element('key', nest: (){
  //       builder.text('pQ6nP-7rHt@5WRFv');
  //     });
  //     //tran
  //     builder.element('tran', nest: (){
  //
  //       builder.element('type', nest: (){
  //         builder.text('sale');
  //       });
  //       builder.element('class', nest: (){
  //         builder.text('ecom');
  //       });
  //       builder.element('cartid', nest: (){
  //         builder.text('atZGs9C762');
  //       });
  //       builder.element('description', nest: (){
  //         builder.text('Test for Mobile API MPI order');
  //       });
  //
  //       builder.element('currency', nest: (){
  //         builder.text('AED');
  //       });
  //       builder.element('amount', nest: (){
  //         builder.text('1');
  //       });
  //       builder.element('test', nest: (){
  //         builder.text('0');
  //       });
  //
  //
  //     });
  //
  //     // card
  //     // address
  //     builder.element('card', nest: (){
  //       builder.element('number', nest: (){
  //         builder.text(GlobalUtils.cardnumber);
  //       });
  //       builder.element('expiry', nest: (){
  //         builder.element('month', nest: (){
  //           builder.text(GlobalUtils.cardexpirymonth);
  //         });
  //         builder.element('year', nest: (){
  //           builder.text(GlobalUtils.cardexpiryyr);
  //         });
  //       });
  //       builder.element('savecard', nest: (){
  //         builder.text(GlobalUtils.keysaved);
  //       });
  //       builder.element('cvv', nest: (){
  //         builder.text(GlobalUtils.cardcvv);
  //       });
  //     });
  //     //billing
  //     builder.element('billing', nest: (){
  //       // name
  //       builder.element('name', nest: (){
  //         builder.element('title', nest: (){
  //           builder.text('');
  //         });
  //         builder.element('first', nest: (){
  //           builder.text('Telr');
  //         });
  //         builder.element('last', nest: (){
  //           builder.text('Dev');
  //         });
  //       });
  //       // address
  //       builder.element('address', nest: (){
  //         builder.element('line1', nest: (){
  //           builder.text('SIT Tower');
  //         });
  //         builder.element('city', nest: (){
  //           builder.text('Dubai');
  //         });
  //         builder.element('region', nest: (){
  //           builder.text('Dubai');
  //         });
  //         builder.element('country', nest: (){
  //           builder.text('AE');
  //         });
  //       });
  //
  //       builder.element('email', nest: (){
  //         builder.text('divya.thampi@telr.com');
  //       });
  //       builder.element('ip', nest: (){
  //         builder.text('106.193.225.18');
  //       });
  //     });
  //
  //
  //
  //     builder.element('mpi', nest: (){
  //
  //       builder.element('session', nest: (){
  //         builder.text(_session2);
  //       });
  //     });
  //   });
  //
  //   final bookshelfXml = builder.buildDocument();
  //
  //   print(bookshelfXml);
  //   return bookshelfXml.toString();
  //   //  pay(bookshelfXml);
  // }



}
