import 'package:get_version/get_version.dart';
Future<double> checkAppVersion()async{
  double appVersion;
  String app = await GetVersion.projectVersion;
  print('ProjectVersion = $app');
  appVersion= double.parse(app);
return appVersion;
}