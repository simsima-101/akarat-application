import 'package:cached_network_image/cached_network_image.dart';
import 'package:drawerdemo/screen/blog_detail.dart';
import 'package:flutter/material.dart';
import '../model/api2model.dart';

class Blogcardscreen extends StatelessWidget {
  final Product product;

  const Blogcardscreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: GestureDetector(
          onTap: (){
            //Get.to(Product_Detail,arguments: "sxcdvbnm");
            //Get.to(Product_Detail,arguments: '${product.id}');
            Navigator.push(context, MaterialPageRoute(builder: (context) => Blog_Detail()));
            // var snackBar = SnackBar(content: Text("Tapped on ${product.id}"));
            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
            /* var snackBar = SnackBar(content: Text("Tapped on ${product.id}"));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Property_Detail()));*/
          },
          child : Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5,bottom: 15),
                child: Column(
                  // spacing: 5,// this is the coloumn
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      // this is the ratio
                      child: CachedNetworkImage( // this is to fetch the image
                        imageUrl: (product.image),
                        fit: BoxFit.cover,
                        height: 100,
                      ),
                    ),
                    Padding(padding: const EdgeInsets.only(top: 5),
                      child: ListTile(
                        title: Text(product.title,style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 18,height: 1.4
                        ),),
                        subtitle: Text('${product.price}',style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 15,height: 1.8
                        ),),
                      ),
                    ),

                   Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: const EdgeInsets.only(left: 1,right: 5,top: 0,bottom: 0),
                            child:  Image.asset("assets/images/map.png",height: 14,alignment: Alignment.bottomLeft,),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0,bottom: 0),
                            child: Text(product.category,style: TextStyle(
                                fontWeight: FontWeight.bold,fontSize: 13,height: 1.4,
                                overflow: TextOverflow.visible
                            ),),
                          ),
                        ],
                      ),

                  /*  Row(
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
                              icon: Icon(Icons.call,color: Colors.red,)),
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

  }
}
