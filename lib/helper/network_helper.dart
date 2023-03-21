
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
class NetWorkHelper {
  NetWorkHelper();

  String baseUrl = '';
  String startdate = '';
  String enddate = '';

  Future<dynamic> getsavedcardlist(String storeId, String authKey) async {
    String url = 'https://secure.telr.com/gateway/savedcardslist.json';
    var data = {
      'storeid': '15996',
      'authkey': 'pQ6nP-7rHt@5WRFv',
      'custref': '123',
      'testmode': '1'
    };
    var requestData = {'SavedCardListRequest': data};

    print('Data auth test: $data');
    print('Data auth test: $requestData');

    var body = json.encode(requestData);
    print('body = $body');

    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        "Content-Type": "application/json",
      },
    );
    print("Register email  = $response");

    String dataReturned = response.body;
     dynamic decodedData = jsonDecode(dataReturned);
    //
    return decodedData;
    // } else {
    //   print(response.statusCode);
    //   return response.statusCode;

  }

  Future<dynamic> getcardtoken(String storeId,String number,String month,String year,String cvv) async {
    String url = 'https://secure.telr.com/gateway/cardtoken.json';
    var data = {
      'store': storeId,
      'number': number,
      'expiry_month': month,
      'expiry_year': year,
      'cvv':cvv,
    };
    var requestData = {'CardTokenRequest': data};

    print('Data auth test: $data');
    print('Data auth test: $requestData');

    var body = json.encode(requestData);
    print('body = $body');

    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        "Content-Type": "application/json",
      },
    );
    print("Register email  = $response");

    String dataReturned = response.body;
    dynamic decodedData = jsonDecode(dataReturned);
    //
    return decodedData;
    // } else {
    //   print(response.statusCode);
    //   return response.statusCode;

  }

  Future pay(XmlDocument xml) async {
    String url = 'https://secure.telr.com/gateway/mobile.xml';
    var data = {xml};

    var body = xml.toString();


    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        "Content-Type": "application/xml",
      },
    );
    print("Response = ${response.statusCode}");
    // print("Response body = ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 400) {

      return response.body;
    }
    else
    {
      return 'failed';
    }
  }
  Future getTransactionstatus(XmlDocument xml) async {
    String url = 'https://secure.telr.com/gateway/mobile_complete.xml';
    var data = {xml};

    var body = xml.toString();


    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        "Content-Type": "application/xml",
      },
    );
    print("Response = ${response.statusCode}");
    // print("Response body = ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 400) {

      return response.body;
    }
    else
    {
      return 'failed';
    }
  }
}