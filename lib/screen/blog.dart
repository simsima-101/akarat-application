import 'dart:convert';
import 'package:drawerdemo/model/api2model.dart';
import 'package:drawerdemo/screen/home.dart';
import 'package:drawerdemo/utils/blogcardscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/api2cardscreen.dart';

void main(){
  runApp(const Blog());

}

class Blog extends StatelessWidget {
  const Blog({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlogDemo(),
    );
  }
}
class BlogDemo extends StatefulWidget {
  @override
  _BlogDemoState createState() => _BlogDemoState();
}
class _BlogDemoState extends State<BlogDemo> {

  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page4(),
  ];



  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/properties'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        products = jsonData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      // Handle error if needed
    }
  }





  @override
  Widget build(BuildContext context) {
   return Scaffold(
       backgroundColor: Colors.white,
       bottomNavigationBar: buildMyNavBar(context),
       body: SingleChildScrollView(
       child: Column(
       children: <Widget>[
       Padding(
       padding: EdgeInsets.only(top: 10),
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
                   width: 80,
                   padding: const EdgeInsets.only(top: 7,left: 7,right: 7,bottom: 7),
                   child: Text("Blog",style: TextStyle(
                     fontSize: 17,fontWeight: FontWeight.bold,letterSpacing: 0.5
                   ),)
                   //child: Image(image: Image.asset("assets/images/share.png")),
                 ),
                
               ],
             ),
           ),),
       Padding(
         padding: const EdgeInsets.only(top: 10.0),
         child: Container(
           height: 50,
           width: double.infinity,
           decoration: BoxDecoration(
               shape: BoxShape.rectangle,
               borderRadius: BorderRadiusDirectional.circular(6.0),
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
               ]),
          child: Row(
            children: [
              Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
              child: Icon(Icons.search_rounded,color: Colors.red,size: 40,),
              ), Padding(padding: const EdgeInsets.only(left: 55,top: 0,right: 0),
              child: Image.asset("assets/images/app_icon.png",height: 35,)
              ), Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
              child: Image.asset("assets/images/logo-text.png",height: 30,)
              ), Padding(padding: const EdgeInsets.only(left: 75,top: 0,right: 10),
              child: Icon(Icons.dehaze,color: Colors.red,size: 40,),
              ),
            ],
          ),
            ),
       ),
         Padding(
           padding: const EdgeInsets.only(top: 10),
           child: Container(
             height: 30,
             width: double.infinity,
             child: Row(
               children: [
              Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
              child: Image.asset("assets/images/map.png",height: 15,),
              ),
                 Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
              child: Text("Dubai")
              ),
                 Padding(padding: const EdgeInsets.only(left: 220,top: 0,right: 0),
              child: Image.asset("assets/images/calender.png",height: 20,),
              ),
                 Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
              child: Text("30.01.2025"),
              ),
               ],
             ),
           ),
         ),
         ListView.builder(
           scrollDirection: Axis.vertical,
           physics: const ScrollPhysics(),
           // this give th length of item
           itemCount: products.length,
           shrinkWrap: true,
           itemBuilder: (context, index) {
             // here we card the card widget
             // which is in utils folder
             return Blogcardscreen(product: products[index]);
           },
         ),
         Container(
           height: 50,
           width: double.infinity,
           margin: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
           decoration: BoxDecoration(
               shape: BoxShape.rectangle,
               borderRadius: BorderRadiusDirectional.circular(6.0),
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
               ]),
           child: Row(
             children: [
               Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
           child: Image.asset("assets/images/app_icon.png",height: 25,)
         ),
               Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
             child: Image.asset("assets/images/logo-text.png",height: 22,)
         ),
               Padding(padding: const EdgeInsets.only(left: 70,top: 0,right: 0),
                 child: SizedBox(
                   height: 30,
                   width: 80,
                   child: ElevatedButton(onPressed: (){},style:
                   ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFF59D),
                     shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
                       child: Text("Rent",style: TextStyle(color: Colors.black,))
                   ),
                 ),
               ),
               Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
             child: SizedBox(
               height: 30,
               width: 80,
               child: ElevatedButton(onPressed: (){},style:
               ElevatedButton.styleFrom(backgroundColor: Color(0xFFF5F5F5),
               shape: RoundedRectangleBorder(borderRadius:  BorderRadius.all(Radius.circular(10)),),),
                   child: Text("Sale",style: TextStyle(color: Colors.black,))
                        ),
             ),
               )
             ],
           ),
         )
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