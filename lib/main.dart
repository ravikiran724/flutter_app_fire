import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter_app_fire/card.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
class Fire extends StatefulWidget {
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  final lists=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed('/create');
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Projects',
        ),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body:StreamBuilder(
        stream: dbref.onValue,
        builder: (context,AsyncSnapshot<Event> snapshot){
          if(snapshot.hasData){
            lists.clear();
            // Map<dynamic,dynamic> values=snapshot.data.value;
            // values.forEach((key, value) { lists.add(value);});
    DataSnapshot dataValues = snapshot.data.snapshot;
    Map<dynamic, dynamic> values = dataValues.value;
    values.forEach((key, values) {
    lists.add(values);
    });
            return  ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: (BuildContext context,int index){
                 return GestureDetector(
                   onTap: (){
                     print('ok');
                   },
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Container(
                       height: 150,
                       child: Card(
                         shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10.0)
                         ),
                         color: Colors.white70,
                         elevation: 8.0,
                         child: Column(
                           children: <Widget>[
                             ListTile(
                               leading:Text('Project${index+1}'),
                               title: Text(lists[index]['title']),
                               subtitle: Text('ML,AI,Python...'),
                             ),
                             ButtonTheme(
                               child: ButtonBar(
                                 children: <Widget>[
                                   FlatButton(
                                     child: Text('Join'),
                                     onPressed: (){},
                                   ),
                                   FlatButton(
                                     child: Text('Share'),
                                     onPressed: (){},
                                   )
                                 ],
                               ),
                             )
                           ],
                         ),
                       ),
                     ),
                   ),
                 );
                }
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      )
    );
  }
}
// Widget card(BuildContext context,int index){
//   return
// }
class Hom extends StatefulWidget {
  @override
  _HomState createState() => _HomState();
}

class _HomState extends State<Hom> {
  final _formkey=GlobalKey<FormState>();
  String url;
  File resume;
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  TextEditingController pt=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController size=TextEditingController();
  Future<void> uploadFile() async{
    print('ok');
    File file = await FilePicker.getFile(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    print(file.path);
    setState(() {
      resume=file;
    });
    StorageReference storageReference = FirebaseStorage.instance.ref().child('resumes/${Path.basename(file.path)}}');
    StorageUploadTask t=storageReference.putFile(file);
    await t.onComplete;
    print('uploaded');
    storageReference.getDownloadURL().then((value) { url=value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        title: Text(
          'Create Project',
        ),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Builder(
        builder:(context)=>
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key:_formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: pt,
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: 'Project Title',
                            icon: Icon(Icons.input),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (str){
                          if(str.length>4){
                            return null;
                          }
                          return "Length must be grater than 4";
                        },
                        onChanged: (val){
                          print(val);
                        },
                      ),
                      SizedBox(height: 10.0),

                      TextFormField(
                        controller: size,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Size',
                            labelText: 'Group Size',
                            icon: Icon(Icons.group),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (num){
                          if(num.length==0){
                            return "Group Size must be greater than 0";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        maxLines: null,
                        controller: desc,
                        decoration: InputDecoration(

                            labelText: 'Project Description',
                            icon: Icon(Icons.description),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (str){
                          if(str.length>4){
                            return null;
                          }
                          return "Length must be grater than 4";
                        },
                        onChanged: (val){
                          print(val);
                        },
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                              Icons.file_upload
                          ),
                          resume==null?
                          Text('Upload Resume',
                            style: TextStyle(
                                fontSize: 18.0
                            ),):Text('Uploaded Resume', style: TextStyle(
                              fontSize: 18.0
                          )),
                          RaisedButton(
                            child: Text('Upload'),
                            color: Colors.blueGrey,
                            onPressed: uploadFile,
                          )
                        ],
                      ),

                      SizedBox(height: 10.0),
                      RaisedButton(
                        child: Text(
                            'Create'
                        ),
                        onPressed: (){
                          if(_formkey.currentState.validate()){

                            dbref.push().set({
                              'title':pt.text,
                              'description':desc.text,
                              'groupsize':size.text,
                              'resume':url
                            });
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Created Successfully'),));
                            Navigator.of(context).pushNamed('/');
                          }
                        },
                        color: Colors.blueGrey,
                        textColor: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}


