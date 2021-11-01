enum Personality {
  calm,
  considerate,
  easy_going,
  enthusiastic,
  funny,
  gentle,
  patient
}

extension PersonalityGetter on Personality {
  ///Convert enum back to string
  String get str {
    switch (this) {
      case Personality.calm:
        return "Calm";
      case Personality.considerate:
        return "Considerate";
      case Personality.easy_going:
        return "Easy-going";
      case Personality.enthusiastic:
        return "Enthusiastic";
      case Personality.funny:
        return "Funny";
      case Personality.gentle:
        return "Gentle";
      case Personality.patient:
        return "Patient";
      default:
        throw "This personality is undefined!";
    }
  }

  ///Receive enum object
  static Personality getEnumObj(String str) {
    //print(Personality.funny.toString());
    return Personality.values.firstWhere((p) =>
        p.toString().toLowerCase() ==
        ("personality." + str.replaceAll("-", "_")).toLowerCase());
  }
}

///Speaking Language
enum SpeakingLanguage { cantonese, engligh, maindarin }

///Getter of speaking language
extension SpeakingLanguageGetter on SpeakingLanguage {
  String get str {
    switch (this) {
      case SpeakingLanguage.cantonese:
        return "Cantonese";
      case SpeakingLanguage.engligh:
        return "English";
      case SpeakingLanguage.maindarin:
        return "Maindarin";
      default:
        throw "Undefined language!";
    }
  }

  static SpeakingLanguage getEnumObj(String str) {
    return SpeakingLanguage.values
        .firstWhere((l) => l.toString().toLowerCase() == str.toLowerCase());
  }
}
