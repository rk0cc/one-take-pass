///Enum that define [HKDistrict]
enum HKDistrict {
  ///Central and Western
  caw,

  ///Wan Chai
  wci,

  ///Eastern
  est,

  ///Sothern
  sth,

  ///Yau Tsim Mong
  ytm,

  ///Sham Shui Po
  ssp,

  ///Kowloon City
  klc,

  ///Wong Tai Sin
  wts,

  ///Kwun Tong
  knt,

  ///Kwai Tsing
  kit,

  ///Tsuen Wan
  twa,

  ///Tuen Mun
  twu,

  ///Yuen Long
  ynl,

  ///North
  nth,

  ///Tai Po
  tip,

  ///Sha Tin
  sti,

  ///Sai Kung
  sik,

  ///Islands
  ils
}

extension HKDistrictGetter on HKDistrict {
  String get str {
    switch (this) {
      case HKDistrict.caw:
        return "Central and Western";
      case HKDistrict.wci:
        return "Wan Chai";
      case HKDistrict.est:
        return "Eastern";
      case HKDistrict.sth:
        return "Southern";
      case HKDistrict.ytm:
        return "Yau Tsim Mong";
      case HKDistrict.ssp:
        return "Sham Shui Po";
      case HKDistrict.klc:
        return "Kowloon City";
      case HKDistrict.wts:
        return "Wong Tai Sin";
      case HKDistrict.knt:
        return "Kwun Tong";
      case HKDistrict.kit:
        return "Kwai Tsing";
      case HKDistrict.twa:
        return "Tsuen Wan";
      case HKDistrict.twu:
        return "Tuen Mun";
      case HKDistrict.ynl:
        return "Yuen Long";
      case HKDistrict.nth:
        return "North";
      case HKDistrict.tip:
        return "Tai Po";
      case HKDistrict.sti:
        return "Sha Tin";
      case HKDistrict.sik:
        return "Sai Kung";
      case HKDistrict.ils:
        return "Islands";
      default:
        return "Unknown";
    }
  }

  static HKDistrict getEnumObj(String str) {
    //Return central and western if the short form is not defined
    return HKDistrict.values.firstWhere(
        (e) =>
            e.toString().toLowerCase() == ("HKDistrict." + str).toLowerCase(),
        orElse: () => HKDistrict.caw);
  }
}
