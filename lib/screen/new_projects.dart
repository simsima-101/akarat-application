import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/projectmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(const New_Projects());
}
class New_Projects extends StatelessWidget {
  const New_Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: New_ProjectsDemo(),
    );
  }
}

class New_ProjectsDemo extends StatefulWidget {
  @override
  _New_ProjectsDemoState createState() => _New_ProjectsDemoState();
}
class _New_ProjectsDemoState extends State<New_ProjectsDemo> {
  final TextEditingController _searchController = TextEditingController();
  int pageIndex = 0;

  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  bool isFavorited = false;
  ProjectModel? projectModel;

  @override
  void initState() {
    super.initState();
    getFilesApi();
  }

  Future<void> getFilesApi() async {
    final response = await http.get(Uri.parse("https://akarat.com/api/new-projects"));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ProjectModel feature= ProjectModel.fromJson(data);

      setState(() {
        projectModel = feature ;

      });

    } else {
      //return FeaturedModel.fromJson(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: buildMyNavBar(context),
        body: SingleChildScrollView(
        child: Column(
        children: <Widget>[
          Row(
            children: [
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 50,left:15),
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

                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
                  },
                  child:  Icon(Icons.arrow_back,color: Colors.red,
                )

                ),
              ),
              //logo2
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 52,left: 80),
                height: 30,
                width: 125,
                decoration: BoxDecoration(

                ),
                child: Text("New Projects",style: TextStyle(
                    color: Colors.black,letterSpacing: 0.5,fontSize: 18,
                    fontWeight: FontWeight.bold,
                ),textAlign: TextAlign.center,),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 15,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 20,right: 15),
                child: Container(
                  width: screenSize.width*0.9,
                  height: 50,
                 // color: Colors.grey,
                  padding: const EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(10.0),
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
                    ],),
                  // Use a Material design search bar
                  child: TextField(
                    textAlign: TextAlign.left,
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search new projects by location ',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                          letterSpacing: 0.5),
                      // Add a search icon or button to the search bar
                      prefixIcon: IconButton(
                        alignment: Alignment.topLeft,
                        icon: Icon(Icons.location_on,color: Colors.red,),
                        onPressed: () {
                          // Perform the search here
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
         Padding(padding: const EdgeInsets.only(top: 20,left: 10,right: 190),
           child: Text("Latest Projects in Dubai",textAlign: TextAlign.left,
           style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
         ),
          Container(
            margin: const EdgeInsets.only(top: 15,left: 20,right: 15),
            padding: const EdgeInsets.only(top: 5,left: 5,right: 10),
            height: 50,
            width: double.infinity,
            //color: Colors.grey,
            child: Text("Find off-plan development and everything you need to "
                "know to invest in UAE's real estate market",style: TextStyle(letterSpacing: 0.5,),),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            // this give th length of item
            itemCount: projectModel?.data?.length  ?? 0,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          Property_Detail(data:projectModel!.data![index].id.toString())));
                    },
                    child : Padding(
                      padding: const EdgeInsets.only(left: 5.0,right: 5,top: 0,bottom: 5),
                      child: Card(
                        color: Colors.white,
                        elevation: 20,
                        shadowColor: Colors.white,
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
                                          aspectRatio: 1.8,
                                          // this is the ratio
                                          child: CachedNetworkImage( // this is to fetch the image
                                            imageUrl: (projectModel!.data![index].media![index].originalUrl.toString()),
                                            fit: BoxFit.fill,

                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 10,
                                          child: Container(
                                            margin: const EdgeInsets.only(left: 320,top: 10,bottom: 0),
                                            height: 35,
                                            width: 35,
                                            padding: const EdgeInsets.only(top: 0,left: 0,right: 5,bottom: 5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadiusDirectional.circular(20.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset: const Offset(
                                                    0.3,
                                                    0.3,
                                                  ),
                                                  blurRadius: 0.3,
                                                  spreadRadius: 0.3,
                                                ), //BoxShadow
                                                BoxShadow(
                                                  color: Colors.white,
                                                  offset: const Offset(0.0, 0.0),
                                                  blurRadius: 0.0,
                                                  spreadRadius: 0.0,
                                                ), //BoxShadow
                                              ],
                                            ),
                                            // child: Positioned(
                                            // child: Icon(Icons.favorite_border,color: Colors.red,),)
                                            child: IconButton(
                                              padding: EdgeInsets.only(left: 5,top: 7),
                                              alignment: Alignment.center,
                                              icon: Icon(
                                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                                color: isFavorited ? Colors.red : Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  // property_id=featuredModel!.data![index].id;
                                                  /*  if(token == ''){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                                  }
                                                  else{
                                                    toggledApi(token,property_id);
                                                  }*/
                                                  isFavorited = !isFavorited;
                                                });
                                              },
                                            ),
                                            //)
                                          ),
                                        ),
                            ]
                          )
                        ),
                              Padding(padding: const EdgeInsets.only(top: 5),
                                child: ListTile(
                                  title: Text(projectModel!.data![index].title.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize: 18,height: 1.4
                                    ),),
                                  /* subtitle: Text('${product.price}',style: TextStyle(
                                     fontWeight: FontWeight.bold,fontSize: 15,height: 1.8
                                 ),),*/
                                ),
                              ),

                            /*  Row(

                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 1,right: 0,top: 0,bottom: 0),
                                      child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 0),
                                    child:  Text(blogModel!.data![index].readingTime.toString(),
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),),
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 0,bottom: 0),
                                      child:  Icon(Icons.circle,color: Colors.red,size: 12,)
                                  ),

                                  Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                                    child: Text("Published:"+blogModel!.data![index].publishedDate.toString(),
                                      style: TextStyle(color: Colors.grey
                                      ),),
                                  ),
                                ],
                              ),*/
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
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
              });
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
          Container(
              margin: const EdgeInsets.only(left: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.call_outlined,color: Colors.red,)
          ),

          Container(
              margin: const EdgeInsets.only(left: 1),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Image.asset("assets/images/whats.png",height: 20,)

          ),
          Container(
              margin: const EdgeInsets.only(left: 1,right: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
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
              child: Icon(Icons.mail,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
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