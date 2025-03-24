import 'package:hive/hive.dart';

Future<String> property(String method, String key,
    [String? value, Function? callback]) {
  Hive.init('../../property');

  if (method == 'set') {
    Hive.openBox('bot').then((box) {
      box.put(key, value);
      callback?.call(true);
    }).catchError((error) {
      print(error);
      callback?.call(false);
    });
  } else if (method == 'get') {
    Hive.openBox('bot').then((box) {
      callback?.call(box.get(key));
    }).catchError((error) {
      print(error);
      callback?.call(false);
    });
  } else if (method == 'del') {
    Hive.openBox('bot').then((box) {
      box.delete(key);
      callback?.call(true);
    }).catchError((error) {
      print(error);
      callback?.call(false);
    });
  } else {
    throw "Unknown method";
  }
  return Future.value('');
}
