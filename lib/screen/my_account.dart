import 'package:flutter/material.dart';

void main(){
  runApp(const My_Account());

}

class My_Account extends StatelessWidget {
  const My_Account({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: My_AccountDemo(),
    );
  }
}
class My_AccountDemo extends StatefulWidget {
  @override
  _My_AccountDemoState createState() => _My_AccountDemoState();
}
class _My_AccountDemoState extends State<My_AccountDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    color: Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 20,top: 30,bottom: 0),
                              height: 35,
                              width: 35,
                              padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(20.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: const Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    blurRadius: 0.1,
                                    spreadRadius: 0.1,
                                  ), //BoxShadow
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ), //BoxShadow
                                ],
                              ),
                              child: Image.asset("assets/images/ar-left.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 20,top: 30),
                            child: Text("My Account",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                            ) ,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 65,top: 8,bottom: 0),
                              height: 110,
                              width: 110,
                              padding: const EdgeInsets.only(top: 0,left: 0,right: 0,bottom: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.circular(60.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: const Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    blurRadius: 0.1,
                                    spreadRadius: 0.1,
                                  ), //BoxShadow
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: const Offset(0.0, 0.0),
                                    blurRadius: 0.0,
                                    spreadRadius: 0.0,
                                  ), //BoxShadow
                                ],
                              ),
                              child: Image.asset("assets/images/ag.png",
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,),
                            ),
                            Container(
                                margin: const EdgeInsets.only(left: 5),
                                height: 70,
                                width: 170,
                                // color: Colors.grey,
                                padding: const EdgeInsets.only(left: 0,top: 10),
                                child:   Column(
                                  children: [
                                    Padding(padding: const EdgeInsets.only(top: 0,left: 0,right: 20),
                                      child: Text("Profile Name,",style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),textAlign: TextAlign.left,),
                                    ),
                                    Padding(padding: const EdgeInsets.only(top: 0,left: 10,right: 15),
                                      child: Text("profilename@gmail.com",style: TextStyle(
                                        fontSize: 12,
                                        // fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),textAlign: TextAlign.left,),
                                    ),
                                  ],
                                )
                            ),

                          ],
                        ),
                      ],
                    ),

                  ),
                  Padding(padding: const EdgeInsets.only(top: 0,left: 15),
                    child:  ListView.builder(
                        shrinkWrap: true,
                        itemCount: 7,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              leading: const Icon(Icons.list),
                              trailing: const Text(
                                "GFG",
                                style: TextStyle(color: Colors.green, fontSize: 15),
                              ),
                              title: Text("List item $index"));
                        }),
                  ),

                ]
            )
        )
    );
  }
}