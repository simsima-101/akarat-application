import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/about_agent.dart';
import 'package:flutter/material.dart';

class Agentcardscreen extends StatelessWidget {
  final AgentsModel agentsModel;

  const Agentcardscreen({super.key, required this.agentsModel});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if(agentsModel == null){
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show loading state
      );
    }
    return SingleChildScrollView(
        child: GestureDetector(
        onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutAgent(data: '${agentsModel.id}')));
        },
          child : Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 8,top: 0,bottom: 5),
            child: Card(
              color: Colors.white,
              shadowColor: Colors.white,
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0,top: 0,right: 0,bottom: 5),
                child: Column(
                  // spacing: 5,// this is the coloumn
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 0,left: 5),
                          width: screenSize.width*0.25,
                          height: screenSize.height*0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(63.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                                blurRadius: 0.0,
                                spreadRadius: 0.0,
                              ), //BoxShadow
                              BoxShadow(
                                color: Colors.white,
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 0.5,
                                spreadRadius: 0.5,
                              ), //BoxShadow
                            ],
                          ),
                         child: CircleAvatar(
                           backgroundImage: NetworkImage(agentsModel.image),
                         )
                        ),
                            Container(
                              margin: const EdgeInsets.only(left: 10,right: 0,top: 10),
                              height: screenSize.height*0.13,
                              width: screenSize.width*0.65,
                              //color: Colors.grey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 10),
                                        child: Text(agentsModel.name,style: TextStyle(
                                          fontSize: 17,letterSpacing: 0.5,fontWeight: FontWeight.bold
                                        ),),
                                      ),
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text(""),),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                      child: Text("Service Area:",style: TextStyle(
                                        fontSize: 12,letterSpacing: 0.5
                                      ),),),
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text("",style: TextStyle(
                                            fontSize: 12,letterSpacing: 0.5
                                        ),),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text("Speaks:",style: TextStyle(
                                            fontSize: 12,letterSpacing: 0.5
                                        ),),),
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 0),
                                        child: Text(agentsModel.languages,style: TextStyle(
                                            fontSize: 12,letterSpacing: 0.5
                                        ),),),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(padding: const EdgeInsets.only(left: 0,right: 0,top: 10),
                                        child: Container(
                                            width: screenSize.width*0.14,
                                            height: screenSize.height*0.027,
                                            padding: const EdgeInsets.only(top: 2,),
                                            decoration: BoxDecoration(
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
                                            child:
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Text(agentsModel.sale.toString(),textAlign: TextAlign.center,style:
                                                  TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5.0),
                                                  child: Text("Sale",textAlign: TextAlign.center,style:
                                                  TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                                ),
                                              ],
                                            ),

                                          ),
                                      ),
                                      Padding(padding: const EdgeInsets.only(left: 10,right: 0,top: 10),
                                        child: Container(
                                          width: screenSize.width*0.15,
                                          height: screenSize.height*0.027,
                                          padding: const EdgeInsets.only(top: 2,),
                                          decoration: BoxDecoration(
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
                                          child:
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0),
                                                child: Text(agentsModel.rent.toString(),textAlign: TextAlign.center,style:
                                                TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5.0),
                                                child: Text("Rent",textAlign: TextAlign.center,style:
                                                TextStyle(letterSpacing: 0.5,color: Colors.blueAccent)),
                                              ),
                                            ],
                                          ),

                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 45.0),
                                        child: Column(
                                          children: [
                                            Text("McCone ",style: TextStyle(
                                            overflow: TextOverflow.visible,fontWeight: FontWeight.bold
                                            ),textAlign: TextAlign.right,maxLines: 2,
                                              softWrap: true,),
                                            Text(" Properties",style: TextStyle(
                                              overflow: TextOverflow.visible,fontWeight: FontWeight.bold
                                            ),textAlign: TextAlign.right,maxLines: 2,
                                              softWrap: true,),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )
                      ],
                    ),
                  ],
                ),
              ),

            ),
          ),
        ),
    );
  }
}