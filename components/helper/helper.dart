import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:televerse/televerse.dart';

Future<String> getName(Context ctx, Function callback) async {
  final user = ctx.message?.from;
  if (user == null) return "Pengguna";

  var name = user.firstName;
  var username = user.username;
  var id = user.id;

  var format = (username != null)
      ? "@$username"
      : "<a href='tg://user?id=$id'>$name</a>";
  callback(format);
  return Future.value('');
}

Future<String> clearHTML(dynamic s) {
  if (s == null) return s;
  return s.replaceAll(RegExp(r'<'), '').replaceAll(RegExp(r'>'), '');
}

Future<String> chatBot(String query, Function callback) async {
  final env = DotEnv()..load();
  final url = Uri.parse('${env['REQUEST_URL']!}?q=$query');
  http.get(url).then((res) {
    var response = jsonDecode(res.body);
    var result = response['data']['answer'];

    callback(result);
  }).catchError((error) {
    print(error);
    List response = ['Apasih', 'Ya oke', 'memeg', 'sok asik', 'pergi lo'];
    var random = Random();

    String pick = response[random.nextInt(response.length)];
    callback(pick);
  });

  return Future.value('');
}
