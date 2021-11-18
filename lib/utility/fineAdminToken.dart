import 'package:hro/model/UserListMudel.dart';
import 'package:hro/model/adminModel.dart';
import 'package:hro/utility/fireBaseFunction.dart';
import 'package:hro/utility/snapshot2list.dart';

fintAdminToken() async {
  List<AdminListModel> _adminList;
  List<UserListModel> _userList;
  List<String> tokenList;
  var _admindata = await dbGetDataAll("getAdmin", "admin");
  if (_admindata[0]) {
    var _jsonData = setList2Json(_admindata[1]);
    _adminList = adminListModelFromJson(_jsonData);
  }

  var _getAllUsrt = await dbGetDataAll("getUserAll", "users");
  if (_getAllUsrt[0]) {
    var jsonData = setList2Json(_getAllUsrt[1]);
    _userList = userListModelFromJson(jsonData);
  }

  for (var admin in _adminList) {
    for (var user in _userList) {
      if (user.email == admin.email) {
        tokenList.add(user.token);
        break;
      }
    }
  }
  return tokenList;
}
