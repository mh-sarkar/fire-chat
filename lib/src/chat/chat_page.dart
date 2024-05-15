import 'dart:io';

import 'package:fire_chat/src/provider/chat_provider.dart';
import 'package:fire_chat/src/provider/home_provider.dart';
import 'package:fire_chat/src/shared/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mh_ui/mh_ui.dart';

class ChatScreen extends HookWidget {
  final String? chatId;
  final String? chatName;

  const ChatScreen({super.key, this.chatId, this.chatName});

  @override
  Widget build(BuildContext context) {
    final chatTextController = useTextEditingController();
    final scrollController = useScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(chatName ?? 'Untitled'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          StreamBuilder(
              stream: globalRef?.read(chatProvider).getChatList(chatId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading chat'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No chat found'));
                }

                final chat = snapshot.data?.docs;
                final me = globalRef?.read(homeProvider).user!.uid;

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: chat![index]['sender'] != me ? MainAxisAlignment.start : MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0).copyWith(left: chat[index]['sender'] != me ? 64 : 2),
                                  child: Text(
                                    chatTimeAgo(date: chat[index]['timestamp']!.toDate().toString()).replaceAll(' ago', ''),
                                    style: const TextStyle(fontSize: 8),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: chat[index]['sender'] != me ? MainAxisAlignment.start : MainAxisAlignment.end,
                              children: [
                                chat[index]['sender'] != me
                                    ? const Stack(
                                        children: [
                                          CustomNetworkImage(
                                            networkImagePath: '',
                                            border: NetworkImageBorder.Circle,
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Icon(
                                                Icons.circle,
                                                color: Color(0xff09FC5C),
                                                size: 12,
                                              ))
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                space5R,
                                Flexible(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: chat[index]['sender'] != me
                                          ? BorderRadius.circular(26)
                                          : BorderRadius.circular(26).copyWith(
                                              topRight: const Radius.circular(6),
                                            ),
                                      color: chat[index]['sender'] != me ? const Color(0xff8EE6E1).withOpacity(.11) : Colors.orangeAccent,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    margin: EdgeInsets.only(
                                      right: chat[index]['sender'] != me ? 80 : 0,
                                      left: chat[index]['sender'] != me ? 0 : 80,
                                    ),
                                    child: /*Stack(
                                                        children: [*/
                                        Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              chat[index]['message']!,
                                              style: chat[index]['sender'] != me
                                                  ? const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    )
                                                  : const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: chat?.length,
                  ),
                );
              }),
          FittedBox(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  globalRef!.watch(chatProvider).lastImage.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.file(
                                File(globalRef!.watch(chatProvider).lastImage),
                                height: 50,
                                width: 50,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .85,
                              ),
                              GestureDetector(
                                onTap: () {
                                  globalRef!.watch(chatProvider).removeImage();
                                },
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CustomTextField(
                          width: MediaQuery.of(context).size.width,
                          marginHorizontal: 0,
                          marginVertical: 0,
                          controller: chatTextController,
                          hintText: 'Type a message...',
                          suffixIcon: GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(Icons.link),
                            ),
                          ),
                        ),
                        space2C,
                        GestureDetector(
                            onTap: () {
                              if (chatTextController.text.isNotEmpty) {
                                globalRef!.read(chatProvider).addChat(chatId!, chatTextController.text);
                                chatTextController.clear();
                              } else {
                                ToastManager.show('Type something to send');
                              }
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.orange,
                                  size: 30,
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String chatTimeAgo({required String date}) {
  return DateTime.now().difference(DateTime.parse(date)).inDays > 7
      ? "${(DateTime.now().difference(DateTime.parse(date)).inDays / 7).floor()} Weeks ago"
      : DateTime.now().difference(DateTime.parse(date)).inHours > 24
          ? "${DateTime.now().difference(DateTime.parse(date)).inDays} Days ago"
          : DateTime.now().difference(DateTime.parse(date)).inMinutes > 60
              ? "${DateTime.now().difference(DateTime.parse(date)).inHours} Hours ago"
              : DateTime.now().difference(DateTime.parse(date)).inSeconds > 60
                  ? "${DateTime.now().difference(DateTime.parse(date)).inMinutes} Mins ago"
                  : "Just now";
}
