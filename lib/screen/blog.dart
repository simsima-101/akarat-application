import 'package:drawerdemo/screen/home.dart';
import 'package:flutter/material.dart';

class Blog extends StatelessWidget{

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page4(),
  ];

  @override
  Widget build(BuildContext context) {
   return Scaffold(
       backgroundColor: Colors.white,
       bottomNavigationBar: buildMyNavBar(context),
       body: SingleChildScrollView(
       child: Column(
       children: <Widget>[
       Padding(
       padding: EdgeInsets.only(top: 0),
           child: Container(
             height: 50,
             width: double.infinity,
             // color: Color(0xFFEEEEEE),
             child:   Row(
               children: [
                 Container(
                     margin: const EdgeInsets.only(left: 10,top: 5,bottom: 0),
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
                     child: GestureDetector(
                       onTap: (){
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => FliterList()));
                       },
                       child: Image.asset("assets/images/ar-left.png",
                         width: 15,
                         height: 15,
                         fit: BoxFit.contain,),
                     )
                 ),
                 Container(
                   margin: const EdgeInsets.only(left: 10,top: 5,bottom: 0,),
                   height: 35,
                   width: 35,
                   padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                   child: Text("Blog")
                   //child: Image(image: Image.asset("assets/images/share.png")),
                 ),
                
               ],
             ),
           ),),
         ]
        )
       )
   );
  }
  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));

            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_filled,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

             // Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));

            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
        ],
      ),
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