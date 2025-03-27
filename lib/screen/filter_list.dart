import 'package:Akarat/screen/product_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/filtermodel.dart';
import 'package:Akarat/screen/blog.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:sliding_switch/sliding_switch.dart';


class FliterList extends StatelessWidget {

  final FilterModel filterModel;

   FliterList({super.key, required this.filterModel});


  int pageIndex = 0;
  final pages = [
    const Page1(),
    const Page2(),
    const Page3(),
    const Page4(),
  ];

  final TextEditingController _searchController = TextEditingController();

/*
  Future<void> fetchProducts() async {
    // you can replace your api link with this link
    final response = await http.get(Uri.parse('https://akarat.com/api/properties'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        products = jsonData.map((data) => Product.fromJson(data)).toList();
      });
    } else {
    }
  }
*/
  bool isFavorited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: buildMyNavBar(context),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
         // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //Searchbar
              Padding(
                padding: const EdgeInsets.only(top: 40,left: 10,right: 10),
                child: Container(
                  width: 400,
                  height: 60,
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(15.0),
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
                    ],),
                  // Use a Material design search bar
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Neighborhood or Building',
                      hintStyle: TextStyle(color: Colors.grey,fontSize: 15,
                          letterSpacing: 0.5),

                      // Add a clear button to the search bar
                      suffixIcon: IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () => _searchController.clear(),
                      ),

                      // Add a search icon or button to the search bar
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search,color: Colors.red,),
                        onPressed: () {
                          // Perform the search here
                        },
                      ),
                    ),
                  ),
                ),
              ),
              //filter
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10,right: 10),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      //text
                      Padding(
                        padding: const EdgeInsets.only(
                            left:0.0,top: 7.0),

                        child: Center(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Icon(
                                  Icons.filter_alt_outlined,color: Colors.red,)
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left:1.0),
                                child: InkWell(
                                    onTap: (){
                                      //   print('hello');
                                    },
                                    child: Text('Filters', style: TextStyle(fontSize: 14, color: Colors.black),)),
                              )
                            ],
                          ),
                        ),

                      ),
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                     child:  Container(
                        width: 70,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(
                              width: 1,
                            ),
                            borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          ],),
                      child: Row(
                        children: [
                          Text(" Buy"),
                          Container(
                            width: 10,
                          ),
                          Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                        ],
                      ),
                      ),
                      ),
                      //all residential
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 130,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                            ],),
                          child: Row(
                            children: [
                              Text(" All Residential"),
                              Container(
                                width: 5,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 120,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                            ],),
                          child: Row(
                            children: [
                              Text(" Price Range"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 70,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                            ],),
                          child: Row(
                            children: [
                              Text(" Buy"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child:  Container(
                          width: 70,
                          height: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 1,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                            ],),
                          child: Row(
                            children: [
                              Text(" Buy"),
                              Container(
                                width: 10,
                              ),
                              Icon(Icons.keyboard_arrow_down,color: Colors.black,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
              //toggle
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 20, bottom: 0),
                child: Container(
                  width: 400,
                  height: 32,
                  padding: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: const Offset(
                          1.5,
                          1.5,
                        ),
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ), //BoxShadow
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 1.5,
                        spreadRadius: 1.5,
                      ), //BoxShadow
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("    Show verified properties first",style: TextStyle(
                        letterSpacing: 0.5
                      ),),
                      Container(
                        width: 80,
                      ),
                      SlidingSwitch(value: true,
                          onChanged: (value) {
                          },
                          onTap: (){},
                          onDoubleTap: (){},
                          onSwipe: (){},
                      height: 20,
                      width: 45,colorOn: Colors.blue,
                      colorOff: Colors.grey,contentSize: 10,textOff: "",textOn: "",)
                    ],
                  ),
                ),
              ),
              //filter
              Padding(
                padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: 10),
                child: Container(
                 // color: Colors.grey,
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  height: 35,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                     //items
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 5,left: 10),
                        child:  Container(
                          width: 100,
                          height: 20,
                          padding: const EdgeInsets.only(top: 5,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          child:
                              Text("All",textAlign: TextAlign.center,style:
                                TextStyle(letterSpacing: 0.5,fontWeight: FontWeight.bold)),

                        ),
                      ),
                      //all residential
                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child:  Container(
                          width: 100,
                          height: 10,
                          padding: const EdgeInsets.only(top: 5,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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

                             child:  Text(" Ready",textAlign: TextAlign.center,
                                 style:
                                 TextStyle(letterSpacing: 0.5,fontWeight: FontWeight.bold)),

                        ),
                      ),

                      Container(
                        width: 10,
                      ),
                      //buy
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child:  Container(
                          width: 100,
                          height: 10,
                          padding: const EdgeInsets.only(top: 5,),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              border: Border.all(
                                width: 0,
                              ),
                              borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          child:
                              Text(" Off-Plan",textAlign: TextAlign.center,
                                  style:
                                  TextStyle(letterSpacing: 0.5,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             ListView.builder(
               scrollDirection: Axis.vertical,
                   physics: const ScrollPhysics(),
                   itemCount: filterModel.data?.length ?? 0,
                    shrinkWrap: true,
                   itemBuilder: (context, index) {
                 return Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Card(
                     elevation: 20,
                     shadowColor: Colors.white,
                     color: Colors.white,
                       child: GestureDetector(
                       onTap: () {
                     String id = filterModel.data![index].id.toString();
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
                         Product_Detail(data: id)));
                     //Navigator.push(context, MaterialPageRoute(builder: (context) => Blog_Detail(data:blogModel!.data![index].id.toString())));
                   },
                     child: Padding(
                       padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5),
                       child: Column(
                         // spacing: 5,// this is the coloumn
                         children: [
                           ClipRRect(
                               borderRadius: BorderRadius.circular(12),
                               child: Stack(
                                   children: [
                                     AspectRatio(
                                       aspectRatio: 1.5,
                                       // this is the ratio
                                       child: CachedNetworkImage( // this is to fetch the image
                                         imageUrl: (filterModel.data![index].media![index].originalUrl.toString()),
                                         fit: BoxFit.cover,
                                         height: 100,
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
                                           //  setState(() {
                                               // property_id=featuredModel!.data![index].id;
                                               /*  if(token == ''){
                                                    Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                                                  }
                                                  else{
                                                    toggledApi(token,property_id);
                                                  }*/
                                               isFavorited = !isFavorited;
                                            // });
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
                                title: Text(filterModel.data![index].title.toString(),
                                  style: TextStyle(
                            fontSize: 16,height: 1.4
                        ),),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('${filterModel.data![index].price} AED',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 22,height: 1.4
                          ),),
                        ),
                             ),
                           ),
                           Row(
                             children: [
                               Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 0),
                                 child:  Image.asset("assets/images/map.png",height: 14,),
                               ),
                               Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                  child: Text(filterModel.data![index].address.toString(),
                                    style: TextStyle(
                                        fontSize: 13,height: 1.4,
                                        overflow: TextOverflow.visible
                          ),),
                               ),
                             ],
                           ),
                          /* Row(
                             children: [
                               Padding(padding: const EdgeInsets.only(left: 15,right: 5,top: 5),
                                 child: Image.asset("assets/images/bed.png",height: 13,),
                               ),
                               Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                   child: Text(filterModel.data![index].bedrooms.toString())
                               ),
                               Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                 child: Image.asset("assets/images/bath.png",height: 13,),
                               ),
                               Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                   child: Text(filterModel.data![index].bathrooms.toString())
                               ),
                               Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 5),
                                 child: Image.asset("assets/images/messure.png",height: 13,),
                               ),
                               Padding(padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                   child: Text(filterModel.data![index].squareFeet.toString())
                               ),
                             ],
                           ),*/
                           Row(
                             children: [
                               Padding(padding: const EdgeInsets.only(left: 30,top: 10,bottom: 15),
                                 child: ElevatedButton.icon(onPressed: (){},
                                     label: Text("call",style: TextStyle(
                                         color: Colors.black
                                     ),),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.grey[50],
                                       alignment: Alignment.center,
                                       elevation: 1,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                       padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 40),
                                       textStyle: TextStyle(letterSpacing: 0.5,
                                           color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold
                                       ),
                                     ),
                                     icon: Icon(Icons.call,color: Colors.red,)),
                               ),
                               // Text(product.description),
                               Padding(padding: const EdgeInsets.only(left: 15,top: 10,bottom: 15),
                                 child: ElevatedButton.icon(onPressed: (){},
                                     label: Text("Watsapp",style: TextStyle(
                                         color: Colors.black
                                     ),),
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.grey[50],
                                       alignment: Alignment.center,
                                       elevation: 1,
                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                       padding: EdgeInsets.symmetric(vertical: 1.0,horizontal: 30),
                                       textStyle: TextStyle(letterSpacing: 0.5,
                                           color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                                       ),
                                     ),
                                     icon: Image.asset("assets/images/whats.png",height: 20,)),
                               ),
                             ],
                           ),

                         ],
                       ),
                     ),
                       ),
                   ),
                 );
                    // return ProductCard(product: products[index]);
                   },
                 ),
            ]),
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
             // setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> MyApp()));
             // });
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
             // setState(() {
                pageIndex = 1;
            //  });
            },
            icon: pageIndex == 1
                ? const Icon(
              Icons.search,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.search_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
            //  setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Blog()));
             // });
            },
            icon: pageIndex == 2
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.favorite_border_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
            //  setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
             // });
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
class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}
class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: Colors.blue,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
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