import 'package:example/WebViewScreen.dart';
import 'package:example/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'helper/network_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MySample());

class MySample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MySampleState();
  }
}

class MySampleState extends State<MySample> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String store = '';
  String keyy = '';
  bool _showLoader = true;
  List<dynamic> _list = <dynamic>[];
  List<TextEditingController> _textEditController = <TextEditingController>[];
  List<bool> _checkBoxValue = <bool>[];
  List<FocusNode> _focusNodes = <FocusNode>[];

  @override
  void initState() {
    getPref();
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  void getPref() async {
    getRepeatBillingList();
  }

  void getRepeatBillingList() async {
    NetWorkHelper netWorkHelper = NetWorkHelper();
    dynamic response = await netWorkHelper.getsavedcardlist(store, keyy);
    print(response);
    if (response == null) {
      // no data show error message.
    } else {
      if (response.toString().contains('Failure')) {
        _showLoader = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No data to show"),
        ));
      }
      else {
        print(response);
        List<dynamic> list = <dynamic>[];
        // flutter: {SavedCardListResponse: {Code: 200, Status: Success, data: [{Transaction_ID: 040029158825, Name: Visa Credit ending with 0002, Expiry: 4/25}, {Transaction_ID: 040029158777, Name: MasterCard Credit ending with 0560, Expiry: 4/24}]}}
        list = response['SavedCardListResponse']['data'];
        print(list); // list get printed
        setState(() {
          _list = list;
          _textEditController.clear();
          _checkBoxValue.clear();
          _focusNodes.clear();
          for (int i = 0; i < _list.length; i++) {
            _textEditController.add(new TextEditingController());
            _checkBoxValue.add(false);
            _focusNodes.add(new FocusNode());
          }
          _showLoader = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Credit Card View Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(

            color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                _list.length == 0 ? Container() : Container(
                  height: 100,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _list.length,
                      itemBuilder: (context, int index) {
                        return Container(

                            child: Row(
                              children: [
                                Checkbox(value: _checkBoxValue[index],
                                    onChanged: (value) {
                                      if (value!) {
                                        _focusNodes[index].requestFocus();
                                      }
                                      else {
                                        _focusNodes[index].unfocus();
                                      }
                                      setState(() {
                                        _checkBoxValue[index] = value!;

                                        for (int i = 0; i < _list.length; i++) {
                                          if (i != index) {
                                            _checkBoxValue[i] = false;
                                          }
                                        }
                                      });
                                    }
                                ),
                                // Image.asset(""),
                                Column(

                                  children: [

                                    Text('${_list[index]['Name']}',
                                        style: TextStyle(color: Colors.black)),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(' ' + '${_list[index]['Expiry']}',
                                        style: TextStyle(color: Colors.black)),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    // Text('${_list[index]['Expiry']}')
                                  ],
                                ),
                                Container(
                                  width: 40,
                                  child: TextField(
                                    focusNode: _focusNodes[index],
                                    controller: _textEditController[index],
                                  ),
                                )

                              ],
                            )
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 7,
                ),
                CreditCardWidget(
                  glassmorphismConfig:
                  useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  bankName: 'Bank Name',
                  frontCardBorder:
                  !useGlassMorphism
                      ? Border.all(color: Color(0xff00A887))
                      : null,
                  backCardBorder:
                  !useGlassMorphism
                      ? Border.all(color: Color(0xff00A887))
                      : null,
                  showBackView: isCvvFocused,
                  obscureCardNumber: true,
                  obscureCardCvv: true,
                  isHolderNameVisible: true,
                  cardBgColor: AppColors.cardBgColor,
                  backgroundImage:
                  useBackgroundImage ? 'assets/bg.png' : null,
                  isSwipeGestureEnabled: true,
                  onCreditCardWidgetChange:
                      (CreditCardBrand creditCardBrand) {},
                  customCardTypeIcons: <CustomCardTypeIcon>[
                    CustomCardTypeIcon(
                      cardType: CardType.mastercard,
                      cardImage: Image.asset(
                        'assets/mastercard.png',
                        height: 48,
                        width: 48,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        // _list.length == 0? Container(): Container(
                        //   height: 200,
                        //   child: ListView.builder(
                        //       physics: NeverScrollableScrollPhysics(),
                        //       itemCount: _list.length,
                        //       itemBuilder: (context, int index){
                        //         return Container(
                        //             child:  Row(
                        //               children: [
                        //                 Checkbox(value: _checkBoxValue[index], onChanged: ( value){
                        //                   if(value!){
                        //                     _focusNodes[index].requestFocus();
                        //                   }
                        //                   else{
                        //                     _focusNodes[index].unfocus();
                        //                   }
                        //                   setState(() {
                        //                     _checkBoxValue[index] = value!;
                        //
                        //                     for(int i = 0 ; i< _list.length; i++)
                        //                     {
                        //                       if(i != index){
                        //                         _checkBoxValue[i] = false;
                        //                       }
                        //                     }
                        //                   });
                        //                 }
                        //                 ),
                        //                 // Image.asset(""),
                        //                 Column(
                        //                   children: [
                        //                     Text('${_list[index]['Name']}'),
                        //                     Text('${_list[index]['Expiry']}')
                        //                   ],
                        //                 ),
                        //                 Container(
                        //                   width: 100,
                        //                   child: TextField(
                        //                     focusNode: _focusNodes[index],
                        //                     controller: _textEditController[index],
                        //                   ),
                        //                 )
                        //
                        //               ],
                        //             )
                        //         );
                        //       }),
                        // ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: true,
                          obscureNumber: true,
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: cardHolderName,
                          expiryDate: expiryDate,
                          themeColor: Colors.blue,
                          textColor: Color(0xff00A887),
                          cardNumberDecoration: InputDecoration(
                            labelText: 'Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            hintStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            labelStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            focusedBorder: border,
                            enabledBorder: border,
                          ),
                          expiryDateDecoration: InputDecoration(
                            hintStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            labelStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Expired Date',
                            hintText: 'XX/XX',
                          ),
                          cvvCodeDecoration: InputDecoration(
                            hintStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            labelStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'CVV',
                            hintText: 'XXX',
                          ),
                          cardHolderDecoration: InputDecoration(
                            hintStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            labelStyle: const TextStyle(
                                color: Color(0xff00A887)),
                            focusedBorder: border,
                            enabledBorder: border,
                            labelText: 'Card Holder',
                          ),
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: _onValidate,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const Text(
                              'Validate',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'halter',
                                fontSize: 14,
                                package: 'flutter_credit_card',
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onValidate() {
    // _
    if (formKey.currentState!.validate()) {
      print('valid!');
      launchURL();
    } else {
      print('invalid!');
    }
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void launchURL() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> WebviewScreen()));//(context, LoginScreen.id);
  }

// void _launchURL(String url, String code) async {
//   Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (BuildContext context) => WebViewScreen(
//             url : url,
//             code: code,
//           ))).then((value) => getCards());
// }
}
