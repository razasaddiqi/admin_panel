import 'package:flutter/material.dart';
import 'add_student.dart';
import 'add_batch.dart';
import 'teacher.dart';
import 'add_subjects.dart';
import 'assign_subjects.dart';
class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child:Text("Admin Panel")),
        elevation: .1,
        backgroundColor: Color.fromRGBO(49, 87, 110, 1.0),
      ),
      body: Column(children: [
      Container(
      child: new Card(
        child: Column(
          children: [
            Row(
              children: [
                Text("Welcome ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),),
                Text("Raza",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 50),),
              ],
            )
          ],
        ),
      ),
        decoration: new BoxDecoration(
          boxShadow: [
          new BoxShadow(
          color: Colors.black,
          blurRadius: 20.0,
          ),
          ],
          ),
          ),
        Expanded(child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
          child: GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(3.0),
            children: <Widget>[
              makeDashboardItem("Add Batch", Icons.batch_prediction),
              makeDashboardItem("Add Student", Icons.person_add_alt),
              makeDashboardItem("Add Teacher", Icons.person_add),
              makeDashboardItem("Add Subject", Icons.book_outlined),
              makeDashboardItem("Assign Subjects", Icons.assignment_ind_outlined),

              // makeDashboardItem("Alphabet", Icons.alarm)
            ],
          ),
        ),)

      ],)

    );
  }

  Card makeDashboardItem(String title, IconData icon) {
    return Card(
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
          child: new InkWell(
            onTap: () {
              if(title=='Add Student') {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Add_student()));
              }
              else if(title=='Add Batch') {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Add_batch()));
              }
              else if(title=="Add Teacher"){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Add_teacher()));
              }
              else if(title=="Add Subject"){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Add_subject()));
              }
              else if(title=="Assign Subjects"){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => assign_subject()));
              }

            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 50.0),
                Center(
                    child: Icon(
                  icon,
                  size: 40.0,
                  color: Colors.black,
                )),
                SizedBox(height: 20.0),
                new Center(
                  child: new Text(title,
                      style:
                          new TextStyle(fontSize: 18.0, color: Colors.black)),
                )
              ],
            ),
          ),
        ));
  }
}
