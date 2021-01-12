import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:result_card_management/dashboard.dart';


class AllFieldsFormBloc extends FormBloc<String, String> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final subject_name = TextFieldBloc(    validators: [
    FieldBlocValidators.required,]);
  final subject_credit = TextFieldBloc(    validators: [
    FieldBlocValidators.required,]);
  final subject_code = TextFieldBloc(    validators: [
    FieldBlocValidators.required,]);

  AllFieldsFormBloc() {
    addFieldBlocs(fieldBlocs: [
      subject_name,
      subject_credit,
      subject_code
    ]);
  }
  Future<bool> issubject_added(String subject_name) async{
    DataSnapshot dataSnapshot = await databaseReference.child('subjects/subject_name').child(subject_name).once();
    if(dataSnapshot.value!=null){
     return false;
    }
    else{
      return true;
    }
  }
  @override
  void onSubmitting() async {
    try {
      issubject_added(subject_name.value).then((value) async{
        if(value==true){
          await databaseReference.child("subjects/${subject_name.value}")
              .set({
            "subject_name": subject_name.value,
            "subject_code": subject_code.value,
            "subject_credit": subject_credit.value,
          }).then((value) {
            emitSuccess(canSubmitAgain: true);
          }).catchError((e){
            emitFailure();
          });

        }
        else{
          subject_name.addFieldError('Subject Already Exist');
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
class Add_subject extends StatefulWidget {
  @override
  _Add_subjectFormState createState() => _Add_subjectFormState();
}
class _Add_subjectFormState extends State<Add_subject>  {
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
                          textFieldBloc: formBloc.subject_name,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Subject Name',
                            prefixIcon: Icon(Icons.book_outlined),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.subject_code,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Subject Code',
                            prefixIcon: Icon(Icons.vpn_key_rounded),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.subject_credit,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Subject Credit',
                            prefixIcon: Icon(Icons.format_list_numbered_rounded),
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
                  MaterialPageRoute(builder: (_) => Add_subject())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => Dashboard())),
              icon: Icon(Icons.arrow_back),
              label: Text('Main Page'),
            ),
          ],
        ),
      ),
    );
  }
}


