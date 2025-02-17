import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';

import 'package:haritaodev/services/firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


List<String> durumlist = ['Hafif hasarli', 'Orta hasarli', 'Agir hasarli'];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 66, 2, 9)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Harita yapılandırma'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  //Firestore servisi
  final FirestoreService firestoreService = FirestoreService();


  //Eski noktaların indeksif dereceleri
  List<int> damageStatus = [3,2];
  //Eski noktaların listesi
  List<List<LatLng>> oldPoint = [
    [LatLng(38.333303, 38.450951),LatLng(38.331222, 38.44775), LatLng(38.33273, 38.44987), LatLng(38.331957, 38.449351)],
    [LatLng(38.331869, 38.4446), LatLng(38.332246, 38.444394), LatLng(38.331916, 38.443141)]];
  //nokta listesi
  List<LatLng> pointo = [];
  //Ekranda tıklanılan noktaları sırası ile alır
  void polygoneMaker(TapPosition tapPosition, LatLng point){
    setState(() {
        pointo.add(point);
    });
    print(point);
  }

  
  String dropdownValue = durumlist.first; //Kullanıcının seçtiği bilgi
  final TextEditingController nameController = TextEditingController();
  //Floatingactionbutton fonksiyonu
  void openStateBox(){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: Column(
          children: [

            //Kullanıcıdan alınacak Binaın adı
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Binanin adi'
              ),
              controller: nameController,
            ),
            const Text(''),


            //Kullanıcıdan alınacak durumun numarası
            DropdownMenu<String>(
              initialSelection: durumlist.first,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              dropdownMenuEntries: durumlist.map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
            ),
          ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              firestoreService.addPoly(pointo, dropdownValue, nameController.text); //Parametreleri ayarlayacağım!
              nameController.clear();
              Navigator.pop(context);

            },
            
            child: const Text('Ekle'))
        ],
    ));
  }




  ////////////////////////// ANA KOD \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(38.3307273, 38.4480158),
              initialZoom: 17,
              onTap: (tapPosition, point) => polygoneMaker(tapPosition, point)
            ),


            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
              ),


              //Yeni polygon oluşturma işlemi
              PolygonLayer(
                polygonCulling: false,
                polygons: [
                  Polygon(
                    points: pointo,
                    color: Colors.blue.withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blue,
                    isFilled: true
                  ),
                ]
                ),

              //Eski polygonları ekrana çıkarttırma işlemi
              PolygonLayer(
                polygonCulling: false,
                polygons: [
                //Az hasarlılar
                for (var ipolo in List.generate(oldPoint.length, (i) => i))
                if (damageStatus[ipolo] == 1)
                  Polygon(points: oldPoint[ipolo],
                    color: const Color.fromARGB(255, 0, 255, 64).withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: const Color.fromARGB(255, 0, 255, 64),
                    isFilled: true),

                //Orta hasarlılar
                for (var ipolo in List.generate(oldPoint.length, (i) => i))
                if (damageStatus[ipolo] == 2)
                  Polygon(points: oldPoint[ipolo],
                    color: const Color.fromARGB(255, 255, 157, 0).withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: const Color.fromARGB(255, 255, 157, 0),
                    isFilled: true),

                //Çok hasarlılar
                for (var ipolo in List.generate(oldPoint.length, (i) => i))
                if (damageStatus[ipolo] == 3)
                  Polygon(points: oldPoint[ipolo],
                    color: const Color.fromARGB(246, 255, 32, 2).withOpacity(0.5),
                    borderStrokeWidth: 2,
                    borderColor: const Color.fromARGB(246, 255, 32, 2),
                    isFilled: true),
                ],
              )

            ],
          ),
        ],
      ),

      //Uçan button
      floatingActionButton: FloatingActionButton(
        onPressed: openStateBox,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
