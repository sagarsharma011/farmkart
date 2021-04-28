import 'dart:io';

import 'package:farmkart/home.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:toast/toast.dart';
import 'cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final databaseReference = Firestore.instance;  //// instance to connect to firestore database

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'FarmKart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String user;


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return

            _EmailPasswordForm();

      }),
    );
  }
}


////////////////////  code to register  ////////////////////////////////

class _RegisterEmailSection extends StatefulWidget {

  @override
  State<StatefulWidget> createState() =>
      _RegisterEmailSectionState();
}


class _RegisterEmailSectionState extends State<_RegisterEmailSection> {


/////////////////////

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  bool _success;
  String _userEmail;

  //////////////////////////

  void _register() async {

    print(_emailController.text);

    ////// checks for user at login page

    final FirebaseUser user = (await
    _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )
    ).user;

    globals.name = _nameController.text.trim();
    globals.address = _addressController.text.trim();
    globals.contact = _contactController.text.trim();


    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
      });

      globals.user = user.email;

      //// resetting array and count for a new user

      globals.count = 0;
      globals.cartArray = [];

    } else {
      setState(() {
        _success = true;
      });
    }

    ///////////////////// database call ///////////////////////

    await databaseReference.collection("users")
        .document('${globals.user}').collection("detail").document("info")
        .setData({
      'name': globals.name,
      'address': globals.address,
      'contact': globals.contact,

    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );

  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(

        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              Text("Farmkart",
                style: GoogleFonts.pacifico(
                  textStyle: TextStyle(color: Colors.blue, letterSpacing: .5, fontSize: 45),
                ),
              ),
              SizedBox(height: 20,),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText:
                        'Password'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Contact'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        alignment: Alignment.center,
                        child: RaisedButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _register();
                            }
                          },
                          child: const Text('Submit'),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => _EmailPasswordForm()),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Already a user ? Login",style: TextStyle(decoration:TextDecoration.underline,),),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(_success == null
                            ? ''
                            : (_success
                            ? 'Successfully registered ' + _userEmail
                            : 'Registration failed')),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////



///////////////////////// code to login ///////////////////////

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}


class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  bool load = false;
  bool _success;
  String _userEmail;

  //// check for correct user

  void _signInWithEmailAndPassword() async {

    final FirebaseUser user = (await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    )).user;

    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email;
        globals.user = user.email;  // current user in globals.user
        globals.count = 0;
      });



      /// code to fetch data of the user from database
      /// read data from database

      var document = await databaseReference.collection('users').document('${globals.user}');
      var document2 = await databaseReference.collection('users').document('${globals.user}').collection('detail').document('info');

      await document.get().then((value) => globals.cartArray = value.data["array"]);


      setState(() {
        document.get().then((value) =>
        globals.count = value.data["count"]
        ); // 1 second late
      });

      setState(() {
        document2.get().then((value) =>
        globals.name = value.data["name"]
        ); // 1 second late
      });

      setState(() {
        document2.get().then((value) =>
            globals.address = value.data["address"]
        ); // 1 second late
      });

      setState(() {
        document2.get().then((value) =>
            globals.contact = value.data["contact"]
        ); // 1 second late
      });

      await new Future.delayed(const Duration(seconds : 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );

    } else {

      setState(() {
        _success = false;
      });


    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Farmkart",
            style: GoogleFonts.pacifico(
              textStyle: TextStyle(color: Colors.blue, letterSpacing: .5, fontSize: 45),
            ),
          ),
          SizedBox(height: 20,),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20,),


                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    alignment: Alignment.center,
                    child: RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _signInWithEmailAndPassword();  /// function call on login
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => _RegisterEmailSection()),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("New user ? Register",style: TextStyle(decoration:TextDecoration.underline,),),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _success == null
                          ? ''
                          : (_success
                          ? 'Successfully signed in ' + _userEmail
                          : 'Sign in failed'),
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

}