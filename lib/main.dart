import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './models/book.dart';

void main() => runApp(BookApp());


class BookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
    debugShowCheckedModeBanner: false,
     title: 'test',
     home:BookFirebaseDemo(),

   );
  }
}

class BookFirebaseDemo extends StatefulWidget {

  BookFirebaseDemo() : super();
  final String appTitle = " Book DB";


  @override
  _BookFirebaseDemoState createState() => _BookFirebaseDemoState();
}

class _BookFirebaseDemoState extends State<BookFirebaseDemo> {

  TextEditingController bookNameController = TextEditingController();
  TextEditingController bookAuthorController = TextEditingController();

  bool isEditing = false;
  bool textFieldVisibility = false;

  String firestoreCollectionName = "Books";
  Book currentBook;

  getAllBooks (){

    return Firestore.instance.collection(firestoreCollectionName).snapshots();
  }
  addBook () async {
    Book book = Book(bookName: bookNameController.text, authorName: bookAuthorController.text);
    try{
      Firestore.instance.runTransaction(
          (Transaction transaction) async {

        await Firestore.instance.collection(firestoreCollectionName).document().setData(book.toJson());

          });
    } catch(e){

    print(e.toString());

    }


  }

  updateBook(Book book, String bookName, String authorName){


      try{
      
        Firestore.instance.runTransaction((transaction) async{
          await transaction.update(book.documentReference, {'bookName': bookName, 'authorName' : authorName});


        });
      }catch(e){
        print(e.toString());
      
      }

  }
   updateEditing (){

    if(isEditing){

      updateBook(currentBook, bookNameController.text, bookAuthorController.text);
      setState(() {
        isEditing = false;
      });
    }

   }

   deleteBook (Book book){

    Firestore.instance.runTransaction(
        (Transaction transaction) async {

          await transaction.delete(book.documentReference);

        }
    );
   }

Widget buildBody (BuildContext context){

    return StreamBuilder<QuerySnapshot>(
      stream:  getAllBooks(),
      builder: (context,snapshot){
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.hasData){
          print("Documents -> ${snapshot.data.documents.length}");
          return buildList(context,snapshot.data.documents);

        }


      },
    );



    }

Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){


    return ListView(

      children: snapshot.map((data) => listItemBuild(context,data)).toList(),
      );


}

Widget listItemBuild(BuildContext context, DocumentSnapshot data){
  final book = Book.fromSnapshot(data);
  return Padding (
    key:  ValueKey(book.bookName),
    padding: EdgeInsets.symmetric(vertical: 19, horizontal: 1),
    child: Container(

     decoration: BoxDecoration(
       border: Border.all(color: Colors.blue),
       borderRadius: BorderRadius.circular(4),

     ),
      child: SingleChildScrollView(

        child: ListTile(
          title: Column (
            children: <Widget>[

              Row(
                children: <Widget>[
                  Icon(Icons.book, color:Colors.yellow ,),
                  Text(book.bookName),

                ],

              ), Divider(),
              Row(
            children: <Widget>[
              Icon(Icons.person, color:Colors.purple ,),
              Text(book.authorName),

            ],
                  )
            ],

          ),

          trailing: IconButton(

          icon: Icon(Icons.delete, color: Colors.red),
            onPressed: (){
            deleteBook(book);
            },
         ),

          onTap: (){
            setUpdateUI(book);

          },
        ),

      ),

    ),


  );

  }

  setUpdateUI(Book book){
    bookNameController.text = book.bookName;
    bookAuthorController.text = book.authorName;
    setState(() {
      textFieldVisibility = true;
      isEditing = true;
      currentBook = book;
    });

  }


  button(){
    return SizedBox(

   width: double.infinity,
      child: OutlineButton(
        child: Text(isEditing? "UPDATE":  "ADD"),
        onPressed: (){

          if(isEditing == true){
           updateEditing();

          }else{
            addBook();

          }

          setState(() {
           textFieldVisibility = false;
          });

        },
      ),

    );
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding:false ,
      appBar: AppBar(

        title: Text(widget.appTitle),
        actions: <Widget>[
          IconButton(

            icon: Icon(Icons.add),
            onPressed: (){
              setState(() {
                textFieldVisibility = !textFieldVisibility;
              });


            },
          )

        ],
      ),
      body: Container(
        padding: EdgeInsets.all(19),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget> [

            textFieldVisibility ? Column (
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Column(
                  children: <Widget>[
                    TextFormField(
                      controller: bookNameController,
                      decoration: InputDecoration(
                        labelText:  "Book Name",
                        hintText: "Enter Book Name"
                      ),

                    ),
                    TextFormField(
                      controller: bookAuthorController,
                      decoration: InputDecoration(
                        labelText: "Book Author",
                        hintText: "Enter Author Name",

                      ),

                    ),
                  ],
                ),
                SizedBox (
                  height: 10,


                ),
                button()
              ],

            ):Container (),
            SizedBox (
              height: 20,

            ),
            Text("BOOKS", style: TextStyle(
              fontSize: 18,
               fontWeight: FontWeight.w800

            ),),
            SizedBox(
                height: 20,
                ),
                Flexible(child: buildBody(context),)
          ],

        ) ,

        ),

    );
  }
}

