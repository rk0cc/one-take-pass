class APISitemap {
  ///URL of API
  static final String _apiUrl = "example.com";
  static Uri get signin => Uri.https(_apiUrl, 'signin');

  static Uri get signup => Uri.https(_apiUrl, 'signup');

  static Uri get deleteUser => Uri.https(_apiUrl, 'deleteuser');

  static Uri get postAns => Uri.https(_apiUrl, 'question/ask');

  static Uri get fetchUserViaToken => Uri.https(_apiUrl, 'getinfo');

  static Uri get submitMockMark => Uri.https(_apiUrl, 'question/result');

  static Uri get findInstructor => Uri.https(_apiUrl, 'search/user/teacher');

  static Uri get recentMockMark => Uri.https(_apiUrl, 'question/getAllResult');

  static Uri get updateInfo => Uri.https(_apiUrl, 'updateInfo');

  static Uri get calendar => Uri.https(_apiUrl, 'calendar/get');

  static Uri get attendEvent => Uri.https(_apiUrl, 'calendar/event');

  static Uri get userComment => Uri.https(_apiUrl, 'getinfo/comment');

  static Uri get submitComment => Uri.https(_apiUrl, 'calendar/comment');

  static Uri courseControl(String action) {
    switch (action.toLowerCase()) {
      case "add":
        return Uri.https(_apiUrl, 'course/avaliable');
      case "get":
        return Uri.https(_apiUrl, 'course/get');
      case "delete":
        return Uri.https(_apiUrl, 'course/manage');
      case "join":
      case "accept":
        return Uri.https(_apiUrl, 'course/join');
    }
  }

  static Uri chatControl(String action) {
    switch (action) {
      case "get_contact":
        return Uri.https(_apiUrl, 'message/users');
      case "get_msg":
        return Uri.https(_apiUrl, 'message/get');
      case "send_msg":
        return Uri.https(_apiUrl, 'message/send');
    }
  }

  static Uri getAns(int mode) {
    switch (mode) {
      case 0:
        return Uri.https(_apiUrl, 'question/get/text');
      case 1:
        return Uri.https(_apiUrl, 'question/get/symbol');
      case 2:
      default:
        return Uri.https(_apiUrl, 'question/get/mock');
    }
  }

  static Uri customPath(String subDir) {
    return Uri.https(_apiUrl, subDir);
  }
}
