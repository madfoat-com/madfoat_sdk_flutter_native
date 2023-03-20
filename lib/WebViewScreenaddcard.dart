import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:sdk/screens/webview_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xml/xml.dart';

import 'helper/global_utils.dart';
import 'helper/network_helper.dart';
class WebviewScreenaddcard extends StatefulWidget {

  static const String id = 'webviewaddcard_screen';
  // late final String title;
  @override
  _WebviewScreenaddcardState createState() => _WebviewScreenaddcardState();
}
class _WebviewScreenaddcardState extends State<WebviewScreenaddcard>{
  var _url = '';
  var random = new Random();
  String _session = '';
  String redirectionurl='';
  String _session2='';
  bool _loadWebView = false;
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late WebViewController _con ;
  //_cardgetcardtokenapi();

  void _cardgetcardtokenapi()async{
    NetWorkHelper netWorkHelper = NetWorkHelper();
    dynamic response = await netWorkHelper.getcardtoken(GlobalUtils.storeid,GlobalUtils.cardnumber,GlobalUtils.cardexpirymonth,GlobalUtils.cardexpiryyr,GlobalUtils.cardcvv);
    print(response);
    if (response == null) {
      // no data show error message.
    } else {
      if (response.toString().contains('Failure')) {
        // _showLoader = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No data to show"),
        ));
      }
      else {
        print(response);
        // List<dynamic> list = <dynamic>[];
        // flutter: {SavedCardListResponse: {Code: 200, Status: Success, data: [{Transaction_ID: 040029158825, Name: Visa Credit ending with 0002, Expiry: 4/25}, {Transaction_ID: 040029158777, Name: MasterCard Credit ending with 0560, Expiry: 4/24}]}}
        var token = response['CardTokenResponse']['Token'].toString();
      GlobalUtils.token=token;
        if(GlobalUtils.token.length>3){
          createXMLAfterGetCard();
        }

      }
    }
  }
  void _callApi()async{
     //var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote_mpi.xml'); //uat
     var uri = Uri.parse('https://secure.telr.com/gateway/remote_mpi.xml');
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
    //_callresponseApi(); //
      setState(() {
        _loadWebView = true;
      });
    }
  }

 //  void _callresponseApi()async{
 //    String responsexmlString=CreateResponseXML();
 // // var uri = Uri.parse('https://uat-secure.telrdev.com/gateway/remote.xml'); //uat
 //    var uri = Uri.parse(' https://secure.telr.com/gateway/remote.xml');
 //    var response = await http.post(uri,body: responsexmlString);
 //    print('Response 2 =  ${response.statusCode} & ${response.body}');
 //    SnackBar snackBar = SnackBar(
 //        content: Text('${response.statusCode} & ${response.body}')
 //    );
 //    ScaffoldMessenger.of(context).showSnackBar(snackBar);
 //  }

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
    _cardgetcardtokenapi();
    //_callApi();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('New Card'),
        backgroundColor: Color(0xff00A887),
      ),
      body: _loadWebView? Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          width: 800,//MediaQuery.of(context).size.width
          height: 1800,//MediaQuery.of(context).size.height
          child: WebView(
            initialUrl: _url, //ooooo
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              // _controller.complete(webViewController);
              _con = webViewController;
            //  _loadHTML();
            },
            onProgress: (int progress) {
              print("WebView is loading (progress : $progress%)");
            },
            navigationDelegate: (NavigationRequest request) {
              print('Inside navigationDelegate ${request.url}');
              if (request.url.contains('telr.com')) {
                print('blocking navigation to $request}');
                // setState(() {
                //   _loadWebView = false;
                //   _homeText = 'Loading second api';
                //
                // });
               //_callresponseApi();
               //  return NavigationDecision.prevent;
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
        builder.text('26143'); //15996
      });
      builder.element('key', nest: (){
        builder.text('SRq6D-2L52z#xDRW'); // BG88b#FBFpX^xSzw
      });



      //tran
      builder.element('tran', nest: (){

        builder.element('type', nest: (){
          builder.text('verify');
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
          builder.text('https://www.telr.com');
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
        builder.text('26143'); //15996
      });
      builder.element('key', nest: (){
        builder.text('SRq6D-2L52z#xDRW'); // BG88b#FBFpX^xSzw
      });
      //tran
      builder.element('tran', nest: (){

        builder.element('type', nest: (){
          builder.text('verify');
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

  void createXMLAfterGetCard(){
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
          builder.text(GlobalUtils.transtype);
        });
        builder.element('class', nest: (){
          builder.text(GlobalUtils.transclass);
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
        // builder.element('ref', nest: (){
        //   builder.text('null');
        // });

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
    pay(bookshelfXml);
  }
  void pay(XmlDocument xml)async{

    NetWorkHelper netWorkHelper = NetWorkHelper();
    print('DIV1: $xml');
    final response =  await netWorkHelper.pay(xml);
    print(response);
    if(response == 'failed' || response == null){
      // failed
     // alertShow('Failed');
    }
    else
    {
      final doc = XmlDocument.parse(response);
      final url = doc.findAllElements('start').map((node) => node.text);
      final code = doc.findAllElements('code').map((node) => node.text);
      print(url); // ee url webview il load cheyanam
      _url = url.toString();
      String _code = code.toString();
      if(_url.length>2){
        _url =  _url.replaceAll('(', '');
        _url = _url.replaceAll(')', '');
        _code = _code.replaceAll('(', '');
        _code = _code.replaceAll(')', '');
        //_launchURL(_url,_code);
      }
      print('[WEBVIEW] print url $_url' );
      final message = doc.findAllElements('message').map((node) => node.text);
      setState(() {
       // if
        _loadWebView = true;
      });
      print('Message =  $message');
      if(message.toString().length>2){
        String msg = message.toString();
        msg = msg.replaceAll('(', '');
        msg = msg.replaceAll(')', '');
       // alertShow(msg);
      }
    }
  }

  // void _launchURL(String url, String code) async {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (BuildContext context) => WebviewScreenaddcard(
  //             url : url,
  //             code: code,
  //           )));
  //
  //
  // }

  void
  getCards()async{
    // NetWorkHelper _networkhelper = NetWorkHelper();
    // var response = await _networkhelper.getSavedcards();
    //
    // print('Response : $response');
    // var SavedCardListResponse = response['SavedCardListResponse'];
    // print('Saved card esponse =  $SavedCardListResponse');
    // if(SavedCardListResponse['Status'] == 'Success')
    // {
    //   //urlString = "https://secure.telr.com/jssdk/v2/token_frame.html?sdk=ios&store_id=\(self.STOREID)&currency=\(currency)&test_mode=\ (mode)&saved_cards=\(cardDetails.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) ?? "")"
    //   String currency = _currency.text;
    //   String storeId = GlobalUtils.storeId; //'15996'
    //   var data =  SavedCardListResponse['data'];
    //   String nameString = jsonEncode(data);
    //   print('data: $data');
    //   print('nameString: $nameString');
    //   String url = 'https://secure.telr.com/jssdk/v2/token_frame.html?sdk=ios&store_id=${GlobalUtils.storeId}&currency=${GlobalUtils.currency}&test_mode=${GlobalUtils.testmode}&saved_cards=${encodeQueryString(nameString.toString())}';
    //   // String url = 'https://secure.telr.com/jssdk/v2/token_frame.html?sdk=ios&store_id=15996&currency=aed&test_mode=1&saved_cards=${encodeQueryString(data.toString())}';
    //   print('url rl =  $url');
    //   _url = url;
    //
    //   setState(() {
    //     _apiLoaded = true;
    //   });
    // }
  }
}
