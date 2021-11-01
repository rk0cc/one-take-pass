enum Genders { male, female, others }

extension GenderHandler on Genders {
  String get str {
    switch (this) {
      case Genders.male:
        return "Male";
      case Genders.female:
        return "Female";
      default:
        return "Others";
    }
  }

  ///Return back to string
  Genders getEnumByString(String str) {
    switch (str) {
      case "M":
      case "Male":
        return Genders.male;
      case "F":
      case "Female":
        return Genders.female;
      default:
        return Genders.others;
    }
  }
}
