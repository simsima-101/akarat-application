import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/agencymodel.dart';
import 'package:Akarat/screen/about_agency.dart';
import 'package:flutter/material.dart';

class Agencycardscreen extends StatelessWidget {
  final Agency agencyModel;

  const Agencycardscreen({super.key, required this.agencyModel});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if(agencyModel == null){
      return Scaffold(
        body: Center(
            child: ShimmerCard()), // Show loading state
      );
    }
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => About_Agency(data: '${agencyModel.id}')));
        },
        child : Padding(
          padding: const EdgeInsets.only(left: 5.0,right: 4,top: 0,bottom: 5),
          child: Card(
            color: Colors.white,
            elevation: 10,
            shadowColor: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left image
                  Container(
                    width: screenSize.width * 0.25,
                    height: screenSize.height * 0.12,
                    child: CachedNetworkImage(
                      imageUrl: agencyModel.image.toString(),
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 10), // spacing between image and text

                  // Right content
                  Expanded( // ✅ Fixes overflow
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agencyModel.name.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          agencyModel.email.toString(),
                          style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          agencyModel.location.toString(),
                          style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            border: Border.all(width: 1,color: Color(0xFFE0E0E0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                offset: Offset(4, 4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: Offset(-4, -4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${agencyModel.propertiesCount}  Properties",
                            style: TextStyle(letterSpacing: 0.5, color: Colors.black,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}