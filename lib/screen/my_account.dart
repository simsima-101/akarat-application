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
                  Padding(padding: const EdgeInsets.only(top: 50,left: 50),
                     child:  Text(("Hi User"),)
                  )

                ]
            )
        )
    );
  }
}