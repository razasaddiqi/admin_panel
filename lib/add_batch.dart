import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:firebase_database/firebase_database.dart';


class AllFieldsFormBloc extends FormBloc<String, String> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final text1 = TextFieldBloc(    validators: [
    FieldBlocValidators.required,]);

  final boolean1 = BooleanFieldBloc();

  final boolean2 = BooleanFieldBloc();

  final select1 = SelectFieldBloc(
    items: ['BCS', 'BSE',"BBA","MCS","BES"],
      validators: [FieldBlocValidators.required]
  );

  final select2 = SelectFieldBloc(
    items: ['Spring', 'Fall'],
      validators: [FieldBlocValidators.required]
  );


  final date1 = InputFieldBloc<DateTime, Object>(validators: [FieldBlocValidators.required]);


  AllFieldsFormBloc() {
    addFieldBlocs(fieldBlocs: [
      text1,
      boolean1,
      boolean2,
      select1,
      select2,
      date1,
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
      isUserRegistered(text1.value,select1.value).then((value) async{
        print(value);
        if(value==true){
          await databaseReference.child("batch/${text1.value}")
              .set({
            "program": select1.value,
            "semester": select2.value,
            "date":date1.value.toString(),
            "year":date1.value.year.toString().substring(2),
            "student_count":0
          }).then((value) {
            emitSuccess(canSubmitAgain: true);
          }).catchError((e){
            print(e);
            emitFailure();
          });

        }
        else{
          text1.addFieldError('Batch Already Exist');
          emitFailure();
        }
      });

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
class Add_batch extends StatefulWidget {
  @override
  _Add_batchFormState createState() => _Add_batchFormState();
}
class _Add_batchFormState extends State<Add_batch>  {
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
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.text1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Batch Number',
                            prefixIcon: Icon(Icons.batch_prediction),
                          ),
                        ),
                        DropdownFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.select1,
                          decoration: InputDecoration(
                            labelText: 'Program',
                            prefixIcon: Icon(Icons.school),
                          ),
                          itemBuilder: (context, value) => value,
                        ),
                        RadioButtonGroupFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.select2,
                          decoration: InputDecoration(
                            labelText: 'Semester',
                            prefixIcon: SizedBox(),
                          ),
                          itemBuilder: (context, item) => item,
                        ),

                        DateTimeFieldBlocBuilder(
                          dateTimeFieldBloc: formBloc.date1,
                          format: DateFormat('dd-MM-yyyy'),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          showClearIcon: false,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
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
                  MaterialPageRoute(builder: (_) => Add_batch())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}


