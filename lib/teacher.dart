import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'dashboard.dart';

File _image;
String _uploadedFileURL;
var title="Image not Selected";
var description="Please Select Image";
class WizardFormBloc extends FormBloc<String, String> {


  final databaseReference = FirebaseDatabase.instance.reference();
  // DataSnapshot dataSnapshot =  databaseReference.child('batch').once();
  Future<String> uploadFile(user_id) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('teacher_images/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) async{
      // setState(() {
      // print(fileURL);
      await  databaseReference.child("Teacher/${user_id}").update(
          {
            "address":address.value,
            "cnic":cnic.value,
            "email":email.value,
            "photo":fileURL.toString(),
            "name":firstName.value,
            "dob":birthDate.value.toString(),
            "join_date":DateTime.now().toString(),
            "department":department.value,
            "gender":gender.value,
            "subject_count":0
          }
      ).catchError((e){emitFailure();});
      _uploadedFileURL = fileURL;
      return fileURL;
      // _uploadedFileURL = fileURL;
      // });
    });
  }
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );


  final firstName = TextFieldBloc(
      validators: [FieldBlocValidators.required]
  );

  final department = TextFieldBloc(validators: [FieldBlocValidators.required]);
  final address = TextFieldBloc();
  final cnic = TextFieldBloc(validators: [FieldBlocValidators.required]);

  final gender = SelectFieldBloc(
    items: ['Male', 'Female'],
  );

  final birthDate = InputFieldBloc<DateTime, Object>(
    validators: [FieldBlocValidators.required],
  );

  WizardFormBloc() {

    addFieldBlocs(
      step: 0,
      fieldBlocs: [email, password],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [firstName, address,cnic,department, gender, birthDate],
    );
  }

  bool _showEmailTakenError = true;

  @override
  void onSubmitting() async {
    if (state.currentStep == 0) {

      if(_image==null){
        emitFailure();
      }
      else {
        // password.val("Please select image");
        emitSuccess();
      }
      // }
    } else if (state.currentStep == 1) {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: email.value,
          password: password.value)
          .then((value) async {

        uploadFile(value.user.uid).then((file_url) async{
          emitSuccess();
        }).catchError((e){emitFailure();});
      }).catchError((value) {
        print(value);
        title="Error Occured";
        description=value.toString().contains("ERROR_EMAIL_ALREADY_IN_USE")?"Email Address Already Taken":"Some Error has occurred. Please check your internet connection";
        emitFailure();
      });
    }
  }
}

class Add_teacher extends StatefulWidget {

  @override
  _Add_studentFormState createState() => _Add_studentFormState();

}

class _Add_studentFormState extends State<Add_teacher> {
// _image=null;
  initState() {
    _image=null;
    title="Image not Selected";
    description="Please Select Image";
  }
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image!=null && await image.exists()) {
      // print("image selected");
      setState(() {
        _image = image;
      });
      //other code
    }
    else {
      _image=null;
      print("image not selected");
      //other code
    }
  }
  final databaseReference = FirebaseDatabase.instance.reference();

  @override

  var _type = StepperType.horizontal;
  void _toggleType() {
    setState(() {
      if (_type == StepperType.horizontal) {
        _type = StepperType.vertical;
      } else {
        _type = StepperType.horizontal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => WizardFormBloc(),
      child: Builder(
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text('Add Student'),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(_type == StepperType.horizontal
                          ? Icons.swap_vert
                          : Icons.swap_horiz),
                      onPressed: _toggleType)
                ],
              ),
              body: SafeArea(
                child: FormBlocListener<WizardFormBloc, String, String>(
                  onSubmitting: (context, state) => LoadingDialog.show(context),
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);

                    if (state.stepCompleted == state.lastStep) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => SuccessScreen()));
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                    showAlertDialog(context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    type: _type,
                    physics: ClampingScrollPhysics(),
                    stepsBuilder: (formBloc) {
                      return [
                        _accountStep(formBloc),
                        _personalStep(formBloc),
                        // _socialStep(formBloc),
                      ];
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () { Navigator.pop(context);},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("${title}"),
      content: Text("${description}"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  FormBlocStep _accountStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Account'),

      content: Column(
        children: <Widget>[
          InkWell(
            onTap: getImage,
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 80.0,
              backgroundImage: (_image != null)
                  ? FileImage(_image)
                  : AssetImage('asset/select_image.png'),

            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.password,
            keyboardType: TextInputType.emailAddress,
            suffixButton: SuffixButton.obscureText,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
        ],
      ),
    );
  }

  FormBlocStep _personalStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Personal'),
      content: Column(
        children: <Widget>[

          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.address,
            keyboardType: TextInputType.streetAddress,
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_city),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.department,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.cnic,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'CNIC',
              prefixIcon: Icon(Icons.perm_identity),
            ),
          ),
          RadioButtonGroupFieldBlocBuilder<String>(
            selectFieldBloc: wizardFormBloc.gender,
            itemBuilder: (context, value) => value,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: SizedBox(),
            ),
          ),
          DateTimeFieldBlocBuilder(
            dateTimeFieldBloc: wizardFormBloc.birthDate,
            firstDate: DateTime(1900),
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
            format: DateFormat('yyyy-MM-dd'),
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.cake),
            ),
          ),
        ],
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
                  MaterialPageRoute(builder: (_) => Add_teacher())),
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
