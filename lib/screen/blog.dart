import 'dart:convert';
import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/blogmodel.dart';
import 'package:Akarat/screen/blog_detail.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/utils/shared_preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  BlogModel? blogModel;

  @override
  void initState() {
    super.initState();
    getFilesApi();
    readData();
  }

  Future<void> getFilesApi() async {
    final response = await http.get(Uri.parse("https://akarat.com/api/blogs"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      BlogModel feature= BlogModel.fromJson(data);

      setState(() {
        blogModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (blogModel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }
   return Scaffold(
       backgroundColor: Colors.white,
     bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
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
                             setState(() {
                               if(token == ''){
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                               }
                               else{
                                 Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                               }
                             });
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
             /* Padding(padding: const EdgeInsets.only(left: 10,top: 0,right: 0),
              child: Icon(Icons.search_rounded,color: Colors.red,size: 40,),
              ),*/ Padding(padding: const EdgeInsets.only(left: 20,top: 0,right: 0),
              child: Image.asset("assets/images/app_icon.png",height: 35,)
              ), Padding(padding: const EdgeInsets.only(left: 5,top: 0,right: 0),
              child: Image.asset("assets/images/logo-text.png",height: 30,)
              ), /*Padding(padding: const EdgeInsets.only(left: 75,top: 0,right: 10),
              child: Icon(Icons.dehaze,color: Colors.red,size: 40,),
              ),*/
            ],
          ),
            ),
       ),
                 ListView.builder(
           scrollDirection: Axis.vertical,
           physics: const ScrollPhysics(),
           // this give th length of item
           itemCount: blogModel?.data?.length ?? 0,
           shrinkWrap: true,
           itemBuilder: (context, index) {
             return SingleChildScrollView(
                 child: GestureDetector(
                   onTap: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
                         Blog_Detail(data:blogModel!.data![index].id.toString())));
                   },
                   child : Padding(
                     padding: const EdgeInsets.only(left: 5.0,right: 4,top: 20,bottom: 5),
                     child: Card(
                       elevation: 20,
                       shadowColor: Colors.white,
                       color: Colors.white,
                       child: Padding(
                         padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5,bottom: 15),
                         child: Column(
                           // spacing: 5,// this is the coloumn
                           children: [
                         ClipRRect(
                         borderRadius: BorderRadius.circular(12),
                         child: Stack(
                           children: [
                             AspectRatio(
                               aspectRatio: 1.6,
                               // this is the ratio
                               child: CachedNetworkImage( // this is to fetch the image
                                 imageUrl: (blogModel!.data![index].image.toString()),
                                 fit: BoxFit.cover,
                                 height: 100,
                               ),
                             ),
                           ]
                         )
                         ),
                             Padding(
                               padding: const EdgeInsets.only(top: 5),
                               child: ListTile(
                                 title: Padding(
                                   padding: const EdgeInsets.only(right: 20.0),
                                   child: Text(blogModel!.data![index].translations!.en!.title.toString(),
                                     style: TextStyle(
                                       fontWeight: FontWeight.bold,fontSize: 18,height: 1.4
                                   ),),
                                 ),
                                 subtitle:  Padding(
                                   padding: const EdgeInsets.only(top: 8.0),
                                   child: Row(
                                     children: [
                                       Padding(padding: const EdgeInsets.only(left: 1,right: 0,top: 0,bottom: 0),
                                           child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                       ),
                                       Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 0,bottom: 0),
                                         child:  Text(blogModel!.data![index].readingTime.toString(),
                                           style: TextStyle(
                                               color: Colors.grey
                                           ),),
                                       ),
                                       Padding(padding: const EdgeInsets.only(left: 20,right: 0,top: 0,bottom: 0),
                                           child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                       ),

                                       Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 0,bottom: 0),
                                         child: Text('Published: ${blogModel!.data![index].publishedDate.toString()}',
                                           style: TextStyle(color: Colors.grey
                                           ),overflow: TextOverflow.visible,maxLines: 2,),
                                       ),
                                     ],
                                   ),
                                 ),
                               ),
                             ),


                           ],
                         ),
                       ),
                     ),
                   ),

                 )

             );
           },
         ),
                ]
              )
            ),
             bottomSheet:  Container(
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
               Padding(padding: const EdgeInsets.only(left: 40,top: 0,right: 0),
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
         ),
         );
    }
  Container buildMyNavBar(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        spacing: screenSize.width*0.7,
       // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {

              Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));

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

          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: IconButton(
              alignment: Alignment.bottomRight,
              enableFeedback: false,
              onPressed: () {

               setState(() {
                 if(token == ''){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                 }
                 else{
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                 }
               });
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