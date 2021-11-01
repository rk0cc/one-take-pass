///A range from start to end
class TimeRange {
  final String startTime;
  final String endTime;

  TimeRange({this.startTime, this.endTime});

  Map<String, String> get toJson => {"start": startTime, "stop": endTime};

  Map<String, DateTime> get parsedToDateTime {
    Map<String, DateTime> parsed = {};
    toJson.forEach((key, value) {
      var dtSplit = value.split(" ");
      var dateStr = dtSplit[0].split("-"), timeStr = dtSplit[1].split(":");
      parsed[key] = DateTime(
          int.parse(dateStr[0]), //Year
          int.parse(dateStr[1]), //Month
          int.parse(dateStr[2]), //Date
          int.parse(timeStr[0]), //Hour
          int.parse(timeStr[1]), //Minute
          int.parse(timeStr[2])); //Second
    });
    return parsed;
  }
}

///UNified interface for calendar
abstract class ClendarInteraface {
  String get title;
  String get vehicleType;
  List<TimeRange> get courseTime;
  Map<String, dynamic> get toJson;
}

///Detail of course
class CoursesCalendar implements ClendarInteraface {
  String _title, _vehicleType;
  List<TimeRange> _courseTime;
  dynamic _id; //Only available on get from JSON

  CoursesCalendar(String title, String vehicleType, List<TimeRange> courseTime,
      [dynamic id]) {
    this._title = title;
    this._vehicleType = vehicleType;
    this._courseTime = courseTime;
    this._id = id;
  }

  @override
  List<TimeRange> get courseTime => _courseTime;

  @override
  String get title => _title;

  @override
  String get vehicleType => _vehicleType;

  get id => _id;

  List<Map<String, String>> get _courseDateList {
    List<Map<String, String>> dl = [];
    _courseTime.forEach((pair) {
      dl.add(pair.toJson);
    });
    if (dl.isEmpty) {
      throw RangeError("Created event with no date");
    }
    return dl;
  }

  @override
  Map<String, dynamic> get toJson => {
        "id": _id,
        "title": _title,
        "type": _vehicleType,
        "course_time": _courseDateList
      };

  factory CoursesCalendar.fromJson(Map<String, dynamic> json) {
    List<TimeRange> ranges = [];
    (json["course_time"] as List<dynamic>).forEach((r) {
      ranges.add(TimeRange(startTime: r["start"], endTime: r["stop"]));
    });
    return CoursesCalendar(
        json["title"], json["type"], ranges, json["course_id"]);
  }
}

class OwnedCoursesCalendar extends CoursesCalendar {
  String _studentPhone, _teacherPhone, _status;
  OwnedCoursesCalendar(
      String title,
      String vehicleType,
      List<TimeRange> courseTime,
      dynamic id,
      String teacherPhone,
      String studentPhone,
      String status)
      : super(title, vehicleType, courseTime, id) {
    this._studentPhone = studentPhone;
    this._teacherPhone = teacherPhone;
    this._status = status;
  }

  String get teacherPhone => _teacherPhone;

  String get studentPhone => _studentPhone;

  String get status => _status;

  factory OwnedCoursesCalendar.fromJson(Map<String, dynamic> json) {
    List<TimeRange> ranges = [];
    (json["course_time"] as List<dynamic>).forEach((r) {
      ranges.add(TimeRange(startTime: r["start"], endTime: r["stop"]));
    });
    return OwnedCoursesCalendar(
        json["title"],
        json["type"],
        ranges,
        json["course_id"],
        json["teacheer_phone"],
        json["student_phone"],
        json["status"]);
  }
}

class PersonalCourseEvent {
  final dynamic id;
  final TimeRange range;
  final String stdPhono, insPhono, title, status;
  PersonalCourseEvent(
      {this.range,
      this.stdPhono,
      this.insPhono,
      this.title,
      this.id,
      this.status});

  factory PersonalCourseEvent.fromJson(Map<String, dynamic> json) =>
      PersonalCourseEvent(
          range: TimeRange(startTime: json["start"], endTime: json["stop"]),
          //API swapped
          stdPhono: json["holder"],
          insPhono: json["student"],
          title: json["title"],
          id: json["cal_id"],
          status: json["status"]);
}
