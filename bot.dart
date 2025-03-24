library bot;

import 'package:dotenv/dotenv.dart';
import 'package:televerse/televerse.dart';

Future<Bot> botIndex() async {
  final env = DotEnv()..load();
  final botToken =
      env['BOT_TOKEN'] ?? (throw Exception('BOT_TOKEN tidak ditemukan!'));

  final bot = Bot(botToken);

  return bot;
}
