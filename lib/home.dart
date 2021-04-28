import 'package:farmkart/main.dart';
import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:toast/toast.dart';
import 'cart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final databaseReference = Firestore.instance;  //// instance to connect to firestore database

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int itemCount = 0;
  var itemsClicked = [];


  var items = [
    {"name": "Leveller", "path": "images/farm1.jpeg"},
    {"name": "Pick Axe", "path": "images/farm2.jpeg"},
    {"name": "Plough", "path": "images/farm3.jpeg"},
    {"name": "Sewing Machine", "path": "images/farm4.jpeg"},
    {"name": "Shovel", "path": "images/farm5.jpeg"},
    {"name": "Trolley", "path": "images/farm6.jpeg"},
    {"name": "Tractor", "path": "images/farm7.jpeg"},
  ]; ////// we defined an array of items for the dashboard  @sagarcoder

  @override
  void initState() {

    super.initState();

    setState(() {

    });
  }

  refreshData(){
    setState(() {

    });
  }



  @override
  Widget build(BuildContext context) {

    print(globals.count);

    rent(index) async{


      Toast.show("Added to the cart..", context, duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);

      globals.cartArray.add(items[index]["name"]);

      globals.count ++;

      //// to let app know the updated value of cartArray and count
      setState(() {
      });

      /////  to add data in database at firestore

      await databaseReference.collection("users")
          .document('${globals.user}')
          .setData({
        'array': globals.cartArray,
        'count': globals.count,
      });

    }


    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Farmkart"),
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.shopping_cart_outlined)),
                Tab(icon: Icon(Icons.person)),
              ],
            ),
            actions: <Widget>[
              Builder(builder: (BuildContext context) {
//5
                return IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                    // resetUser();
                  },
                );
              })
            ],
          ),
          body: Center(
            child: Container(
              child: TabBarView(
                children: [
                  ///////////////////////////// first tab

                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GridView.builder(
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  itemCount: items.length,
                                  itemBuilder: (BuildContext context,
                                      int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Card(
                                        color: Colors.white,
                                        child: Column(
                                          children: [
                                            Text(
                                              items[index]["name"],
                                              style:
                                              TextStyle(color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Image.asset(
                                              'images/farm${index + 1}.jpeg',
                                              fit: BoxFit.fill,
                                              height: 100,
                                              width: 100,
                                            ),
                                            ButtonTheme(
                                              minWidth: 50,
                                              height: 20,
                                              child: RaisedButton(
                                                child: Text(
                                                  'Rent It', style: TextStyle(
                                                  color: Colors.white,
                                                ),),
                                                color: Theme
                                                    .of(context)
                                                    .accentColor,
                                                elevation: 0.0,
                                                splashColor: Colors.blueGrey,
                                                onPressed: () {
                                                  rent(index);
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),

                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("items count :", style: TextStyle(fontWeight: FontWeight.bold)),

                                    (globals.count == 0)
                                        ?
                                    RawMaterialButton(
                                      onPressed: () {
                                        refreshData();
                                      },
                                      elevation: 2.0,
                                      child: Icon(
                                        Icons.refresh,
                                        // size: 30,
                                        color: Color(0xFF536872),
                                      ),
                                      padding:
                                      EdgeInsets.all(15.0),
                                      shape: CircleBorder(),
                                    )
                                        :
                                    Text("${globals.count}", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                RaisedButton(
                                  child: Text('View Cart', style: TextStyle(
                                    color: Colors.white,
                                  ),),
                                  color: Theme
                                      .of(context)
                                      .accentColor,
                                  elevation: 0.0,
                                  splashColor: Colors.blueGrey,
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => Cart()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  /////////////////////////////////

                  Padding(
                      padding:  EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.people_outline),
                              title: Text('Customer'),
                              subtitle: Text('${globals.name}'),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.card_travel),
                              title: Text('Total Items'),
                              subtitle: Text('${globals.count}'),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.shopping_cart_outlined),
                              title: Text('Current items to rent'),
                              subtitle: Text('${globals.cartArray}'.replaceAll("[", "").replaceAll("]", "")),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.location_on),
                              title: Text('Address'),
                              subtitle: Text('${globals.address}'),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.phone),
                              title: Text('Contact'),
                              subtitle: Text('${globals.contact}'),
                            ),
                          ),

                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

        ));
  }
}
