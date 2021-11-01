//import 'package:flutter/material.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:one_take_pass_remake/api/userdata/behaviours.dart';
import 'package:one_take_pass_remake/api/userdata/districts.dart';
//import 'package:one_take_pass_remake/api/userdata/gender.dart';
//import 'package:one_take_pass_remake/themes.dart';

//Integrated those object that required
export 'package:one_take_pass_remake/api/userdata/behaviours.dart';
export 'package:one_take_pass_remake/api/userdata/districts.dart';
export 'package:one_take_pass_remake/api/userdata/gender.dart';

class OTPUsers {
  String name;
  String userPhoneNumber;

  OTPUsers(String name, [String userPhoneNumber = ""]) {
    this.name = name;
    this.userPhoneNumber = userPhoneNumber;
  }
}

class Instructor extends OTPUsers {
  String desc;
  Personality personality;
  HKDistrict hkDistrict;
  String vehicles;

  Instructor(String name, String userPhoneNumber, String desc,
      Personality personality, HKDistrict hkDistrict, String vehicles)
      : super(name, userPhoneNumber) {
    this.desc = desc;
    this.personality = personality;
    this.hkDistrict = hkDistrict;
    this.vehicles = vehicles;
  }

  factory Instructor.fromJSON(Map<String, dynamic> json) {
    return Instructor(
        json["name"],
        json["userPhoneNumber"],
        json["description"],
        PersonalityGetter.getEnumObj(json["instructionStyle"]),
        HKDistrictGetter.getEnumObj(json["location"]),
        json["vechicleType"]);
  }

  static List<Instructor> get dummyInstructor {
    return [
      Instructor(
        "John Siu",
        "12345670",
        "Serious",
        Personality.calm,
        HKDistrict.est,
        "Private Car",
      ),
      Instructor(
        "Polly Chan",
        "09876543",
        "I love cars",
        Personality.easy_going,
        HKDistrict.ssp,
        "Private Car",
      )
    ];
  }
}

//Please uncomment flutter_rating_bar in pubspec.yaml first
/*class InstructorRating extends StatelessWidget {
  final BuildContext context;
  final double rate;

  InstructorRating({@required this.context, @required this.rate});

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rate,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: OTPColour.light2,
      ),
      itemCount: 5,
      itemSize: 24,
      unratedColor: OTPColour.dark2,
    );
  }
}*/