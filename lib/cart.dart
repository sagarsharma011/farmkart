import 'package:farmkart/home.dart';
import 'package:farmkart/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:firebase_database/firebase_database.dart';
import 'package:toast/toast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart'; //For creating the SMTP Server
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final databaseReference = Firestore.instance;

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  decrement(index) async{
      globals.cartArray.removeAt(index);

      globals.count --;

      setState(() {

      });

      await databaseReference.collection("users")
          .document('${globals.user}')
          .setData({
        'array': globals.cartArray,
        'count': globals.count,
      });



  }

  back() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
    setState(() {

    });
  }


  sendOrder() async {

    Toast.show("Order details sent to the registered email address.", context, duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER);

    var now = new DateTime.now();

    String username = 'farmkart10@gmail.com' ;
    String password = 'farmkart1234';

    // ignore: deprecated_member_use
    final smtpServer = gmail(username, password);
    // Creating the Gmail server
    String text = "";


    for(int i=0; i<globals.cartArray.length; i++){

      text = text + globals.cartArray[i] + "\n";

    }

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add('${globals.user}') //recipent email
      ..subject = 'Greetings from farmkart !!!' //subject of the email
      ..text = 'Dear ${globals.name}, \n\n'  'Your order has been placed on '
          '${new DateFormat("dd-MM-yyyy").format(now)} at ${new DateFormat("H:m:s").format(now)}'
          + '\n\n' + 'Order details : \n\n' + '$text' + '\n\n' + 'Shipping Address : '
          '${globals.address}' + '\n\n' + 'Registered contact : '
          '${globals.contact}' + '\n\n' + 'Expected date of delivery : '
          'Within 7 days from the date of order' + '\n\n' +  'Thank you for renting with us' +
          '\n\n\n' + 'Regards,' + '\n' + 'Team Farmkart'; //body of the email


    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n'+ e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Your Cart"),
            centerTitle: true,
          ),
          // body:
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: globals.cartArray.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.shopping_cart_outlined),
                                title: Text('${globals.cartArray[index]}'),
                                subtitle: Text('Item added'),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    child: const Text('Remove'),
                                    onPressed: () {
                                      decrement(index);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    child: Text('Back', style: TextStyle(
                      color: Colors.white,
                    ),),
                    color: Theme
                        .of(context)
                        .accentColor,
                    elevation: 0.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      back();
                    },
                  ),
                  RaisedButton(
                    child: Text('Confirm', style: TextStyle(
                      color: Colors.white,
                    ),),
                    color: Theme
                        .of(context)
                        .accentColor,
                    elevation: 0.0,
                    splashColor: Colors.blueGrey,
                    onPressed: () {
                      sendOrder();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
