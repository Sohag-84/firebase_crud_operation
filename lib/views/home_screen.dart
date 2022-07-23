// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/add_new_course_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _addNewCourse() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => AddNewCourseScreen(),
    );
  }

  final Stream<QuerySnapshot> _courseStream =
      FirebaseFirestore.instance.collection("Courses").snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _addNewCourse(),
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _courseStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(top: 20.0,left: 15,right: 15),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(child: Image.network(data['image'],fit: BoxFit.cover,)),
                        SizedBox(height: 5),
                        Text(data['course_title'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,),),
                        SizedBox(height: 5),
                        Text(data['course_description'],style: TextStyle(color: Colors.black.withOpacity(.50)),),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
