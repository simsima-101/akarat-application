import 'package:drawerdemo/screen/filter.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeDemo(),
    );
  }
}
class HomeDemo extends StatefulWidget {
  const HomeDemo({super.key});

  @override
  State<HomeDemo> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomeDemo> {
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
        bottomNavigationBar: buildMyNavBar(context),
      //body: pages[pageIndex],
      backgroundColor: Colors.white,
       body:   SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                //logo 1
                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.only(top: 25,left:115),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/app_icon.png'),
                    ),
                  ),
                ),

                //logo2
                Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.only(top: 25),
                  height: 80,
                  width: 120,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo-text.png'),
                    ),
                  ),
                ),
              ],
            ),

            //Searchbar
            Padding(
              padding: const EdgeInsets.only(top: 0,left: 10,right: 10),
              child: Container(
                width: 400,
                height: 60,
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red,
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
                  textAlign: TextAlign.center,
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search for a locality,area or city',
                    hintStyle: TextStyle(color: Colors.grey),

                    // Add a clear button to the search bar
                    suffixIcon: IconButton(
                      alignment: Alignment.center,
                      icon: Icon(Icons.mic),
                      onPressed: () => _searchController.clear(),
                    ),

                    // Add a search icon or button to the search bar
                    prefixIcon: IconButton(
                      alignment: Alignment.center,
                      icon: Icon(Icons.search,color: Colors.red,),
                      onPressed: () {
                        // Perform the search here
                      },
                    ),
                  ),
                ),
              ),
            ),

//images gridview
            Row(
             // spacing: 0.05,
              children: [
                //logo 1
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                 child:  Padding(
                    padding: const EdgeInsets.only(
                        left: 12.0, right: 5.0, top: 10, bottom: 0),

                    child: Container(
                      width: 115,
                      height: 100,
                      padding: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        // image: DecorationImage(
                        //   image: AssetImage("assets/images/01.png"),
                        // ),
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
                        ],
                      ),
                    child:   Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/ak-rent-red.png"
                            ,height: 40,),
                          Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                             child:  Text("Property For Rent",style:
                              TextStyle(height: 1.2,
                                  letterSpacing: 0.5,
                                  fontSize: 12,fontWeight: FontWeight.bold
                              ),),
                          )

                        ],
                      )
                    ),
                  ),
                                  ),


                //logo2
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                  child:
                  Padding(
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 13.0, bottom: 0),
                  child: Container(
                    width: 115,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(

                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/02.png"),
                      // ),
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
                      ],
                    ),
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/ak-sale.png",height: 40,),
                      Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                            child:  Text("Property For Sale",style:
                            TextStyle(height: 1.2,
                                letterSpacing: 0.5,
                                fontSize: 12,fontWeight: FontWeight.bold
                            ),),
                          )

                        ],
                      )
                  ),
                  ),
                ),
                //logo2
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                  child:
                  Padding(
                  padding: const EdgeInsets.only(
                      left: 4.0, right: 5.0, top: 13.0, bottom: 0),
                  child: Container(
                    width: 120,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(

                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/03.png"),
                      // ),
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
                      ],
                    ),
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/ak-off-plan.png",height: 40,),
                          Padding(padding: const EdgeInsets.only(left: 30,right: 20,top: 5),
                            child:  Text("Off-Plan-Properties",style:
                            TextStyle(height: 1.2,
                                letterSpacing: 0.5,
                                fontSize: 12,fontWeight: FontWeight.bold
                            ),),
                          )

                        ],
                      )
                  ),
                ),
                ),
              ],
            ),


            Row(
              children: [
                //logo 1
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                  child:
                  Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 5.0, top: 8, bottom: 0),
                  child: Container(
                    width: 115,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(

                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/04.png"),
                      // ),
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
                      ],
                    ),
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/commercial_new.png",height: 40,),
                          Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                            child:  Text("Commercial",style:
                            TextStyle(height: 1.2,
                                letterSpacing: 0.5,
                                fontSize: 12,fontWeight: FontWeight.bold
                            ),),
                          )

                        ],
                      )
                  ),
                ),
                ),

                //logo2
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                  child:
                  Padding(
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 8, bottom: 0),
                  child: Container(
                    width: 115,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(

                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/05.png"),
                      // ),
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
                      ],
                    ),
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/city.png",height: 40,),
                          Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                            child:  Text("Apartments",style:
                            TextStyle(height: 1.2,
                                letterSpacing: 0.5,
                                fontSize: 12,fontWeight: FontWeight.bold
                            ),),
                          )

                        ],
                      )
                  ),
                ),
                ),
                //logo2
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Filter()));
                  },
                  child:
                  Padding(
                  padding: const EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 8, bottom: 0),
                  child: Container(
                    width: 120,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(

                      // image: DecorationImage(
                      //   image: AssetImage("assets/images/06.png"),
                      // ),
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
                      ],
                    ),
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/villa-new.png",height: 40,),
                          Padding(padding: const EdgeInsets.only(left: 25,right: 20,top: 5),
                            child:  Text("Villas",style:
                            TextStyle(height: 1.2,
                                letterSpacing: 0.5,
                                fontSize: 12,fontWeight: FontWeight.bold
                            ),),
                          )

                        ],
                      )
                  ),
                ),
                ),
              ],
            ),
            //banner
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 12.0, bottom: 0),
                  child:
                  Container(
                  width: 405,
                  height: 150,
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
                ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                      Padding(
                          padding: const EdgeInsets.only(
                          top: 10,left: 00,right: 5),
                    child: Container(
                    width: 200,
                    height: 100,
                    padding: const EdgeInsets.only(top: 10,left: 10,right: 00),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("New Projects            ",style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,fontWeight: FontWeight.bold
                      ),textAlign: TextAlign.left,),
                  Text("Discover more about the UAE "
                      "real estate market",style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      ),
                    softWrap: true,)
                     ],
                   ),
                )
                            ),
                Image.asset('assets/images/02.png',height: 145,width: 140,),
                           SizedBox(
                             width: 20,
                             height: 20,
                           )
              ],
            ),),),

            //  Text
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 10, bottom: 0),
                          child:  Text("1,738 Projects",style: TextStyle(
                            color: Colors.black,fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),textAlign: TextAlign.left,),
                        ),
                        Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 140.0, right: 10.0, top: 10, bottom: 0),
                            child:  Image.asset("assets/images/arrows 1.png")
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                left: 2.0, right: 10.0, top: 10, bottom: 0),
                            child:  Text("Featured",style: TextStyle(
                              color: Colors.black,fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),textAlign: TextAlign.right,),
                          ),
                        ],
                        )

                      ],
                    ),
            //Slider
            ListView(
              padding: const EdgeInsets.only(top: 10),
                shrinkWrap: true,
                children: [
                  CarouselSlider(
                    items: [

                      //1st Image of Slider
                      Container(
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage('http://photo.16pic.com/00/38/88/16pic_3888084_b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      //2nd Image of Slider
                      Container(
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage('http://photo.16pic.com/00/38/88/16pic_3888084_b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      //3rd Image of Slider
                      Container(
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage('http://photo.16pic.com/00/38/88/16pic_3888084_b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      //4th Image of Slider
                      Container(
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage('http://photo.16pic.com/00/38/88/16pic_3888084_b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      //5th Image of Slider
                      Container(
                        margin: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage('http://photo.16pic.com/00/38/88/16pic_3888084_b.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    ],
                    //Slider Container properties
                    options: CarouselOptions(
                      height: 250.0,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enableInfiniteScroll: true,
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      viewportFraction: 0.9,
                    ),
                  ),
                ],
              ),

            //buttons
            Padding(
              padding: const EdgeInsets.only(top: 12,left: 10,right: 10),
              child: Container(
                width: 400,
                height: 55,
                padding: const EdgeInsets.only(top: 0),
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
                  ],),

                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                        width: 25,
                      ),
                      Expanded(flex:1,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Button onPressed action
                          }, label: Text("call",style: TextStyle(color: Colors.black),),
                          icon: Icon(Icons.call,color: Colors.red,),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0))),

                        ),),
                      SizedBox(
                        height: 10,
                        width: 25,
                      ),
                      Expanded(flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Button onPressed action
                          },
                          label: Text("Whatsapp",style: TextStyle(color: Colors.black),),
                          icon: Icon(Icons.call,color: Colors.red,),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0))),

                        ),
                      ),
                      SizedBox(
                        height: 10,
                        width: 25,
                      ),
                    ],
                  ),
              ),
            ),
          //tab
            SizedBox(
              height: 15,
              width: 25,
            ),
            ],
        ),
        ),
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
                pageIndex = 0;
              });
            },
            icon: pageIndex == 0
                ? const Icon(
              Icons.home_filled,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.home_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 1;
              });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.search,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.search_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 2;
              });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.favorite_border_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              setState(() {
                pageIndex = 3;
              });
            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 30,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}
class Page1 extends StatelessWidget {
  const Page1({super.key});

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
  const Page2({super.key});

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
  const Page3({super.key});

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
  const Page4({super.key});

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