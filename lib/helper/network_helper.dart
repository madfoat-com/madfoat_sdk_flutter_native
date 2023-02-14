
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
      'custref': '789',
      'testmode': '0'
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
}