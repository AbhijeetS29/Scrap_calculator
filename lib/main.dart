import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'Add.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,

  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Home"),
              Tab(text: "Materials Type"),
              Tab(text: "Settings"),
            ],
          ),
          title: const Text('Waste Calculator'),
          centerTitle: true,
        ),
        body: const TabBarView(
          children: [
            Center(child: FirstLayout()),
            Center(child: SecondLayout()),
            Center(child: ThirdLayout()),
          ],
        ),
      ),
    );
  }
}

class FirstLayout extends StatefulWidget {
  const FirstLayout({Key? key}) : super(key: key);

  @override
  State<FirstLayout> createState() => _FirstLayoutState();
}

class _FirstLayoutState extends State<FirstLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SecondLayout extends StatefulWidget {
  const SecondLayout({Key? key}) : super(key: key);
  @override
  State<SecondLayout> createState() => _SecondLayoutState();
}

class _SecondLayoutState extends State<SecondLayout> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("wasteMaterial");
  Query dbref = FirebaseDatabase.instance.ref("wasteMaterial");
  // final DatabaseReference newRef = ref.push();

  Widget materialList({required Map Map}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: (){

        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Color(0xffffd7d7),
          ),
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(Map['materialName']),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("INR " + Map['price'].toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FirebaseAnimatedList(
          query: dbref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map? studentList = snapshot.value as Map?;
            if (studentList != null) {
              studentList['key'] = snapshot.key;
              // filtering query
              print(studentList['materialName']);
                return materialList(Map: studentList);
            }
            return Container();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMaterialDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController priceController = TextEditingController();
        return AlertDialog(
          title: Text("Add New Material"),
          content: SingleChildScrollView(
            child: Column(

              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Material Name'
                        ,
                        border: OutlineInputBorder()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price',
                    border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,

                  ),
                ),
                // You can add additional fields for date and time pickers here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String name = nameController.text;
                double price = double.tryParse(priceController.text) ?? 0.0;
                DateTime dateTime = DateTime.now();

                // Show loading screen
                showDialog(
                  context: context,
                  barrierDismissible: false, // Prevent closing dialog by tapping outside
                  builder: (BuildContext context) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                DatabaseReference newRef = ref.push();
                String uniqueId = newRef.key!;

                if (name.isNotEmpty && price > 0) { // Ensure name is not empty and price is valid
                  await ref.child(uniqueId).set({
                    "materialName": name,
                    "price": price, // corrected typo here
                    "dateOf": DateFormat('yyyy-MM-dd').format(dateTime), // Store date formatted
                    "timeOf": DateFormat('HH:mm:ss').format(dateTime), // Store time formatted
                  });
                  Navigator.of(context).pop(); // Close loading screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Material added successfully!')),
                  );
                } else {
                  Navigator.of(context).pop(); // Close loading screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid material name and price!')),
                  );
                }
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class ThirdLayout extends StatefulWidget {
  const ThirdLayout({Key? key}) : super(key: key);

  @override
  State<ThirdLayout> createState() => _ThirdLayoutState();
}
class _ThirdLayoutState extends State<ThirdLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Settings"),
      ),
    );
  }
}
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitDown,
//       DeviceOrientation.portraitUp,
//     ]);
//     super.initState();
//   }
//
//
//
//
//   Widget _firstlayout(){
//     return Scaffold(
//       body: Center(
//         child: Text("Home ah gya"),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (_) => addNewData()),
//           );
//       },
//
//       ),
//     );
//   }
//   Widget _secondlayout(){
//     return Scaffold(
//       body: Center(
//         child: Text("types ah gya"),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () {
//           _showAddMaterialDialog(context);
//         }
//       ),
//     );
//   }
//   Widget _thirdlayout(){
//     return Scaffold(
//       body: Center(
//         child: Text("settings ah gya"),
//       ),
//     );
//   }
//
//   void _showAddMaterialDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         TextEditingController nameController = TextEditingController();
//         TextEditingController priceController = TextEditingController();
//         return AlertDialog(
//           title: Text("Add New Material"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(labelText: 'Material Name'),
//                 ),
//                 TextField(
//                   controller: priceController,
//                   decoration: InputDecoration(labelText: 'Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 // You can add additional fields for date and time pickers here
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String name = nameController.text;
//                 double price = double.tryParse(priceController.text) ?? 0.0;
//                 DateTime dateTime = DateTime.now(); // You can replace this with selected date and time
//                 // _addMaterial(MaterialModel(name: name, price: price, dateTime: dateTime));
//                 Navigator.of(context).pop();
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
//         useMaterial3: true,
//       ),
//       home: DefaultTabController(
//         length: 3,
//         child: Scaffold(
//           appBar: AppBar(
//             bottom: const TabBar(
//               tabs: [
//                 Tab(text: "Home",),
//                 Tab(text: "Materials Type",),
//                 Tab(text: "Settings",),
//               ],
//             ),
//             title: const Text('Waste Calculator'),
//             centerTitle: true,
//           ),
//           body:  TabBarView(
//             children: [
//               Center(
//                 child :_firstlayout()
//               ),Center(
//                 child: _secondlayout()
//               ),Center(
//                 child: _thirdlayout()
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

