import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/filtermodel.dart';
import 'package:Akarat/screen/product_detail.dart';
import 'package:flutter/material.dart';
import '../model/api2model.dart';

class ProductCard extends StatelessWidget {
  final FilterModel filterModel;
  const ProductCard({super.key, required this.filterModel});

  @override
  Widget build(BuildContext context) {
    if(filterModel == null){
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading state
      );
    }
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: (){
         // Navigator.push(context, MaterialPageRoute(builder: (context) => Product_Detail(data: '${product.id}')));
        },
       child : Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0,top: 1,right: 5),
              child: Column(
                // spacing: 5,// this is the coloumn
                children: [
                  AspectRatio(
                    aspectRatio: 1.5,
                    // this is the ratio
                   /* child: CachedNetworkImage( // this is to fetch the image
                      imageUrl: (product.image),
                      fit: BoxFit.cover,
                      height: 100,
                    ),*/
                  ),
                  Padding(padding: const EdgeInsets.only(top: 5),
                    child: ListTile(
                     /* title: Text(product.title,style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 18,height: 1.4
                      ),),
                      subtitle: Text('${product.price}',style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 15,height: 1.8
                      ),),*/
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(padding: const EdgeInsets.only(left: 10,right: 5,top: 0),
                        child:  Image.asset("assets/images/map.png",height: 14,),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                       /* child: Text(product.category,style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 13,height: 1.4,
                            overflow: TextOverflow.visible
                        ),),*/
                      ),
                    ],
                  ),
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
                            icon: Icon(Icons.call,color: Colors.red,)),
                      ),
                    ],
                  ),

                ],
              ),
            ),

          ),

      )

    );

  }
}
