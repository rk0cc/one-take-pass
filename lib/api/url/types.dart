import 'package:url_launcher/url_launcher.dart';

///Enumeration of URL
enum URLType { website, email, phone, message }

extension URLGenerator on URLType {
  String _fullFormat(String path, bool secure) {
    String _site;
    switch (this) {
      case URLType.website:
        _site = (secure ? "https" : "http");
        break;
      case URLType.email:
        _site = "mailto";
        break;
      case URLType.phone:
        _site = "tel";
        break;
      case URLType.message:
        _site = "sms";
        break;
    }
    _site += "://" + path;
    return _site;
  }

  ///Call URL
  void exec(String path, [bool secure = false]) async {
    String _furl = this._fullFormat(path, secure);
    await canLaunch(_furl) ? await launch(_furl) : throw "Failed to launch URL";
  }
}
