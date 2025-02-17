
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  //Kütüphaneden veri al
  final CollectionReference polys = FirebaseFirestore.instance.collection('polys');

  //CREATE: Polygon ekle
  Future<void> addPoly(List<LatLng> pointo, String pstate, String name){
    int nstate = 0;
    if (pstate == 'Hafif hasarli'){
      nstate = 1;
    }
    else if(pstate == 'Orta hasarli'){
      nstate = 2;
    }
    else{
      nstate = 3;
    }
    List<String> latitude = [];
    List<String> longitude = [];
    for (var target in pointo){
      print(target.toString());
      List<String> listform = target.toString().split(':');
      latitude.add (listform[1].split(',')[0]) ;
      longitude.add(listform[2].split(')')[0]);
    }
    return polys.add({
      'latitude': latitude,
      'longitude': longitude,
      'Durum': nstate,
      'Adi': name,
      'timestamp' : Timestamp.now()
    });
  }

  //READ: Polygon oku
  Stream<QuerySnapshot> getpolysStream() {
      final polysStream = polys.orderBy('timestamp', descending: true).snapshots();

      return polysStream;
  }

  //DELETE: Polygon sil
  Future<void> deletePoly(String docID) {
    return polys.doc(docID).delete();
  }



}