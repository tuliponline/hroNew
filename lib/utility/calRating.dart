import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/utility/snapshot2list.dart';

Future<double> calRatingRider(String uid) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<RatingListModel> ratingListModel;
  double ratingFinal = 0;
  var rating00 = [];
  await db
      .collection("rating")
      .where("riderId", isEqualTo: uid)
      .get()
      .then((value) {
    var jsonData = setList2Json(value);
    ratingListModel = ratingListModelFromJson(jsonData);
    ratingListModel.forEach((element) {
      rating00.add({'rating': double.parse(element.riderRate)});
    });
  });

  if (rating00.length > 0) {
    ratingFinal = rating00.map((m) => m['rating']).reduce((a, b) => a + b) /
        rating00.length;
  }
  print("ratingRider = " + ratingFinal.toString());
  return ratingFinal;
}
