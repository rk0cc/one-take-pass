import 'package:one_take_pass_remake/api/userdata/login_request.dart';

class IdentityWidget {
  UserREST _userREST;
  set currentIdentity(UserREST userREST) {
    this._userREST = userREST;
  }

  UserREST get identity => _userREST;

  String get roleName => _userREST.roles;

  String get phoneNumber => _userREST.phoneNo;

  String get fullName => _userREST.fullName;
}
