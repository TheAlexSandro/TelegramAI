import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';
import 'package:intl/intl.dart';

import 'bot.dart';
import 'components/helper/helper.dart';
import 'components/properties/property.dart';

Future<void> main() async {
  final bot = await botIndex();

  bot.command('start', (ctx) {
    getName(ctx, (data) {
      print(data);
      String pesan =
          'Selamat datang $data! Kirimkan saya pesan apapun, untuk memulai percakapan!';

      ctx.reply(pesan);
    });
  });

  bot.command('uptime', (ctx) {
    property('get', 'uptime', null, (rest) {
      ctx.reply('⏱️ <b>Uptime</b>\nThis bot has been online since $rest',
          parseMode: ParseMode.html);
    });
  });

  bot.command('bot', (ctx) async {
    final text = ctx.message!.text;
    final regex = RegExp(r'^/bot\s+(\w+)', caseSensitive: false);
    final match = regex.firstMatch(text as String);

    if (match != null) {
      String command = match.group(1) ?? '';
      if (command == "down") {
        var tgs = await ctx.reply("Shutdown initiating...");

        property('get', 'active', null, (result) {
          if (result == 'no') {
            property('get', 'downtime', null, (time) {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  '⚠️ <b>Warning!</b>\nThe bot has been down since $time.',
                  parseMode: ParseMode.html);
            });
            return;
          }
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('dd/MM/yy HH:mm').format(now);

          property('set', 'downtime', formattedDate);
          property('set', 'active', 'no', (rest) {
            if (rest == true) {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  '✅ <b>Hurray!</b>\nSuccessfully shutting down this bot.',
                  parseMode: ParseMode.html);
            } else {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  "❌ <b>Upss...!</b>\nFailed to shutdown this bot, there's must be something wrong",
                  parseMode: ParseMode.html);
            }
          });
        });
      } else if (command == "up") {
        var tgs = await ctx.reply("Reactivating this bot...");

        property('get', 'active', null, (result) {
          if (result == 'yes') {
            property('get', 'uptime', null, (time) {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  '⚠️ <b>Warning!</b>\nThe bot has been active since $time.',
                  parseMode: ParseMode.html);
            });
            return;
          }
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('dd/MM/yy HH:mm').format(now);

          property('set', 'uptime', formattedDate);
          property('set', 'active', 'yes', (rest) {
            if (rest == true) {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  '✅ <b>Hurray!</b>\nSuccessfully reactivating this bot.',
                  parseMode: ParseMode.html);
            } else {
              ctx.api.editMessageText(ChatID(tgs.chat.id), tgs.messageId,
                  "❌ <b>Upss...!</b>\nFailed to reactive this bot, there's must be something wrong",
                  parseMode: ParseMode.html);
            }
          });
        });
      } else {
        ctx.reply("⚠️ Metode tidak dikenal.");
      }
    }
    return;
  });

  bot.onMessage((ctx) async {
    property('get', 'active', null, (rest) {
      if (rest == 'no') return;
      final message = ctx.message;
      if (message == null || message.from == null) return;

      var from = message.from!;
      var chat = message.chat;
      int userID = from.id;
      String chatType = chat.type.toString();

      if (chatType != 'ChatType.private') {
        if (message.replyToMessage != null &&
            message.replyToMessage!.from != null &&
            message.replyToMessage!.from!.isBot) {
          ctx.api.sendChatAction(ChatID(userID), ChatAction.typing);
          chatBot(message.text!, (data) async {
            ctx.api.sendMessage(ChatID(chat.id), data,
                replyParameters:
                    ReplyParameters(messageId: ctx.messageId as int));
          });
          return;
        }
      } else {
        ctx.api.sendChatAction(ChatID(userID), ChatAction.typing);
        chatBot(message.text!, (data) async {
          ctx.reply(data);
        });
      }
    });
  });

  bot.onError((err) {
    print(err);
  });

  bot.start();
  print('Bot dimulai!');
}
