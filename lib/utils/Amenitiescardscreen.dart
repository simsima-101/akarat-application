import 'package:Akarat/model/amenities.dart';
import 'package:flutter/material.dart';

class Amenitiescardscreen extends StatelessWidget {
  final Amenities amenities;

  const Amenitiescardscreen({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (amenities == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading state
      );
    }
    return SingleChildScrollView(
        child: GestureDetector(
            onTap: () {
             // Navigator.push(context, MaterialPageRoute(builder: (context) => AboutAgent(data: '${agentsModel.id}')));
            },
            child: Card(
              color: Colors.grey,
              child: Row(
                children: [
              Container(
              // color: selectedIndex == index ? Colors.amber : Colors.transparent,
              margin: const EdgeInsets.only(left: 5,right: 10,top: 5,bottom: 5),
                // width: screenSize.width * 0.25,
                // height: 20,
                padding: const EdgeInsets.only(top: 0,left: 5,right: 5),
                decoration: BoxDecoration(
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
                      //color:myData == index ? Colors.amber : Colors.transparent,
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ),
                child: Row(
                  children: [
                    Image.network(amenities.icon.toString()),
                    Text(amenities.title.toString()),
                  ],
                ),
            ),
                ],
              ),
            )
        )
    );
  }
}