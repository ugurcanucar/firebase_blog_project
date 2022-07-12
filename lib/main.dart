import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController t1 = TextEditingController();
  final TextEditingController t2 = TextEditingController();

  final CollectionReference _products = FirebaseFirestore.instance.collection("products");

  Future<void> _update([DocumentSnapshot? data]) async {
    if (data != null) {
      t1.text = data["name"];
      t2.text = data["price"].toString();
    }

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: t1,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: t2,
                  decoration: InputDecoration(labelText: "Price"),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = t1.text;
                      final double? price = double.tryParse(t2.text);

                      if (price != null) {
                        await _products.doc(data!.id).update({
                          "name": name,
                          "price": price,
                        });
                        t1.text = "";
                        t2.text = "";
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Update"))
              ],
            ),
          );
        });
  }

  Future<void> _delete(DocumentSnapshot data) async {
    _products.doc(data.id).delete();
  }

  Future<void> _add() async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: t1,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: t2,
                  decoration: InputDecoration(labelText: "Price"),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = t1.text;
                      final double? price = double.tryParse(t2.text);

                      if (price != null) {
                        await _products.add({
                          "name": name,
                          "price": price,
                        });
                        t1.text = "";
                        t2.text = "";
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Update"))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(),
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                  return Card(
                    child: ListTile(
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _update(documentSnapshot),
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => _delete(documentSnapshot),
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                      title: Text(documentSnapshot["name"]),
                      subtitle: Text(documentSnapshot["price"].toString()),
                    ),
                    margin: const EdgeInsets.all(10),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
