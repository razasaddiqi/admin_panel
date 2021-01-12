import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:firebase_database/firebase_database.dart';


class AllFieldsFormBloc extends FormBloc<String, String> {
  Map dic_={};
  final databaseReference = FirebaseDatabase.instance.reference();
  final text1 = TextFieldBloc(    validators: [
    FieldBlocValidators.required,]);
  final batch_select = SelectFieldBloc(
      items: ['a'],
      validators: [FieldBlocValidators.required]
  );

  final teacher_select = SelectFieldBloc(
      items: ['a'],
      validators: [FieldBlocValidators.required]
  );

  final subject_select = SelectFieldBloc(
      items: ['a'],
      validators: [FieldBlocValidators.required]
  );
  Future<List> get_batch() async{
    DataSnapshot dataSnapshot = await databaseReference.child('batch').once();
    // print(dataSnapshot.value.keys);
    return dataSnapshot.value.keys.toList();
  }
  Future<List> get_subjects() async{
    DataSnapshot dataSnapshot = await databaseReference.child('subjects').once();
    // print(dataSnapshot.value.keys);
    return dataSnapshot.value.keys.toList();
  }

  Future<List> get_teachers() async{
    var snapshot = await databaseReference.child('Teacher/');
    List teachers=[];
    // print(dataSnapshot.value.keys);
    await snapshot.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      var total_objects=values.length;
      var index=0;
      values.forEach((key,values) {
       // print(key);
       // print(values['name']);
       dic_[values['name']]=key;
       teachers.add(values['name']);
      });
    });
    return teachers;
  }



  AllFieldsFormBloc() {
    get_subjects().then((value) {
      // setState(() {

      subject_select.removeItem("a");
      for(int i=0; i<value.length;i++){
        subject_select.addItem(value[i]);
      }
      // batch_select.updateItems(items) value);
      //   batch=value;
      // });
    });
    get_batch().then((value) {
      // setState(() {
      batch_select.removeItem("a");
      for(int i=0; i<value.length;i++){
        batch_select.addItem(value[i]);
      }
      // batch_select.updateItems(items) value);
      //   batch=value;
      // });
    });
    get_teachers().then((value) {
      // setState(() {
      print(value);
      teacher_select.removeItem("a");
      for(int i=0; i<value.length;i++){
        teacher_select.addItem(value[i]);
      }
      // batch_select.updateItems(items) value);
      //   batch=value;
      // });
    });
    addFieldBlocs(fieldBlocs: [
      subject_select,
      batch_select,
      teacher_select,
    ]);
  }
  Future<bool> isUserRegistered(String id_batch,String dept_name) async{
    DataSnapshot dataSnapshot = await databaseReference.child('batch').child(id_batch).child("program").once();
    if(dataSnapshot.value!=null){
      if(dataSnapshot.value==dept_name){
        return false;
      }
      else{
        return true;
      }
    }
    else{
      return true;
    }
  }
  @override
  void onSubmitting() async {
    try {
      // DataSnapshot dataSnapshot = await databaseReference.child('subjects/${subject_select.value}/subject_name').once();
      // var total_stud=dataSnapshot.value;
      var subject_id=UniqueKey().toString();
      DataSnapshot dataSnapshot2 = await databaseReference.child('subjects/${subject_select.value}/subject_code').once();
      var subject_code=dataSnapshot2.value;
      DataSnapshot dataSnapshot3 = await databaseReference.child('subjects/${subject_select.value}/subject_credit').once();
      var subject_credit=dataSnapshot3.value;
      DataSnapshot dataSnapshot4 = await databaseReference.child('Teacher/${dic_[teacher_select.value]}/subject_count').once();
      var subject_count_teacher=dataSnapshot4.value;
      await databaseReference.child("Teacher/${dic_[teacher_select.value]}/subjects/${subject_count_teacher}").update({
        "batch":batch_select.value,
        "course_code":subject_code,
        "credit":subject_credit,
        "subject_id":subject_id.substring(1,subject_id.length-1),
        "subject_name":subject_select.value
      });
      await databaseReference.child("Teacher/${dic_[teacher_select.value]}").update(
          {"subject_count":subject_count_teacher+1});
      DataSnapshot dataSnapshot5 = await databaseReference.child('batch/${batch_select.value}/students').once();
      var students=dataSnapshot5.value;
      for(int i=0;i<students.length;i++){
        print("key");
        print(subject_id.substring(1,subject_id.length-1));
        print(students[i]);
        DataSnapshot dataSnapshot6 = await databaseReference.child('student/${students[i]}/subjects').once();
        var students_subject=dataSnapshot6.value;
        if(students_subject==null){
          students_subject=0;
        }
        else{
          students_subject=students_subject.length;
        }
        print(students_subject);
        await databaseReference.child("student/${students[i]}/subjects/${students_subject}").update({
        // "batch":batch_select.value,
        "course_code":subject_code,
        "credit":subject_credit,
        "subject_id":subject_id.substring(1,subject_id.length-1),
        "subject_name":subject_select.value,
          "teacher_name":teacher_select.value
        });

      }
      emitSuccess();
      // emitFailure();
      // await databaseReference.child("Student/${dic_[teacher_select.value]}/subjects/${subject_count_teacher}").update({
      // "batch":batch_select.value,
      // "course_code":subject_code,
      // "credit":subject_credit,
      // "subject_id":subject_count_teacher,
      // "subject_name":subject_select.value;
      // });
      // emitSuccess();
      // isUserRegistered(text1.value,select1.value).then((value) async{
        // if(value==true){
        //   await databaseReference.child("batch/${text1.value}")
        //       .set({
        //     "program": select1.value,
        //     "semester": select2.value,
        //     "date":date1.value,
        //     "year":date1.value.year.toString().substring(2),
        //     "student_count":0
        //   }).then((value) {
        //     emitSuccess(canSubmitAgain: true);
        //   }).catchError((e){
        //     emitFailure();
        //   });
        //
        // }
        // else{
        //   text1.addFieldError('Batch Already Exist');
        //   emitFailure();
        // }
      // });

      // await Future<void>.delayed(Duration(milliseconds: 500));
      //   print(text1.value);
      // print(select1.value);
      // print(select2.value);
      // print(date1.value);
      // emitSuccess(canSubmitAgain: true);
    } catch (e) {
      print("errors");
      print(e);
      emitFailure();
    }
  }
}
class assign_subject extends StatefulWidget {
  @override
  _assign_subjectFormState createState() => _assign_subjectFormState();
}
class _assign_subjectFormState extends State<assign_subject>  {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllFieldsFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<AllFieldsFormBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(title: Text('Add Batch')),
              floatingActionButton: FloatingActionButton(
                onPressed: formBloc.submit,
                child: Icon(Icons.send),
              ),
              body: FormBlocListener<AllFieldsFormBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SuccessScreen()));
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);
                  //
                  // Scaffold.of(context).showSnackBar(
                  //     SnackBar(content: Text(state.failureResponse)));
                },
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.subject_select,
                          decoration: InputDecoration(
                            labelText: 'Select Subject',
                            prefixIcon: Icon(Icons.school),
                          ),
                          itemBuilder: (context, value) => value,
                        ),
                        DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.teacher_select,
                          decoration: InputDecoration(
                            labelText: 'Select Teacher',
                            prefixIcon: Icon(Icons.school),
                          ),
                          itemBuilder: (context, value) => value,
                        ),
                        DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.batch_select,
                          decoration: InputDecoration(
                            labelText: 'Select Batch',
                            prefixIcon: Icon(Icons.school),
                          ),
                          itemBuilder: (context, value) => value,
                        ),




                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(key: key),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => assign_subject())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}


