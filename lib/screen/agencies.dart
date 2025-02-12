import 'package:flutter/material.dart';

void main(){
  runApp(const Agencies());

}

class Agencies extends StatelessWidget {
  const Agencies({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AgenciesDemo(),
    );
  }
}
class AgenciesDemo extends StatefulWidget {
  @override
  _AgenciesDemoState createState() => _AgenciesDemoState();
}
class _AgenciesDemoState extends State<AgenciesDemo> {

  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40, left: 20),
                        height: 30,
                        width: 30,
                        padding: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: const Offset(
                                0.5,
                                0.5,
                              ),
                              blurRadius: 1.0,
                              spreadRadius: 0.5,
                            ), //BoxShadow
                            BoxShadow(
                              color: Colors.white,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ), //BoxShadow
                          ],
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.red,
                        ),
                      ),
                      //logo 1
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 40, left: 8),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/app_icon.png'),
                          ),
                        ),
                      ),

                      //logo2
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 50, left: 1),
                        height: 30,
                        width: 125,
                        decoration: BoxDecoration(

                        ),
                        child: Text("Find My Agent", style: TextStyle(
                            color: Colors.black,
                            letterSpacing: 0.5,
                            fontSize: 18
                        ),),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 130,top: 40,),
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
                        child: Image.asset("assets/images/share.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,),
                        //child: Image(image: Image.asset("assets/images/share.png")),
                      ),
                    ],
                  ),
                ]
            )
        )
    );
  }
}
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 1",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 2",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 3",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Page4 extends StatelessWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 4",
          style: TextStyle(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}