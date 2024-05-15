import 'package:fire_chat/src/provider/auth_provider.dart';
import 'package:fire_chat/src/provider/home_provider.dart';
import 'package:fire_chat/src/shared/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fire_chat/src/provider/chat_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mh_ui/mh_ui.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = globalRef!.read(homeProvider);
    final newChatController = useTextEditingController();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Add Chat'),
                          content: StreamBuilder(
                            stream: globalRef?.read(homeProvider).users,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return const Center(child: Text('Error loading users'));
                              } else if (!snapshot.hasData) {
                                return const Center(child: Text('No users found'));
                              }
                              final users = snapshot.data?.docs.where((element) => element["email"] != globalRef?.read(authProvider).user!.email).toList();

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: users?.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(users?[index]['email']),
                                    onTap: () {
                                      Navigator.pop(context);

                                      globalRef?.read(homeProvider).collection.doc(globalRef?.read(authProvider).user!.uid).collection('chat_list').get().then((value) {
                                        globalLogger.d(value.docs.where((element) => element['chat_name'] == users![index]['email']).isNotEmpty);
                                        if (value.docs.where((element) => element['chat_name'] == users![index]['email']).isNotEmpty) {
                                          return;
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text('New Chat'),
                                                  content: TextField(
                                                    controller: newChatController,
                                                    decoration: const InputDecoration(hintText: 'Enter message'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        await globalRef?.read(homeProvider).collection.doc(globalRef?.read(authProvider).user!.uid).collection('chat_list').add({
                                                          'chat_id': (globalRef?.read(authProvider).user?.uid ?? '-') + users![index].id,
                                                          'user1': globalRef?.read(authProvider).user!.uid,
                                                          'user2': users[index].id,
                                                          'chat_name': users[index]['email'],
                                                        });
                                                        await globalRef?.read(homeProvider).collection.doc(users![index].id).collection('chat_list').add({
                                                          'chat_id': (globalRef?.read(authProvider).user?.uid ?? '-') + users![index].id,
                                                          'user1': globalRef?.read(authProvider).user!.uid,
                                                          'user2': users[index].id,
                                                          'chat_name': globalRef?.read(authProvider).user!.email,
                                                        });
                                                        await globalRef?.read(chatProvider).firstMessage((globalRef?.read(authProvider).user?.uid ?? '-') + users![index].id,
                                                            newChatController.text, users![index].id.toString());
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Send'),
                                                    ),
                                                  ],
                                                );
                                              });
                                        }
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      });
                },
                icon: const Icon(Icons.add)),
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                globalRef?.read(authProvider).signOut();
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: home.collection.doc(globalRef?.read(authProvider).user!.uid).collection('chat_list').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading chats'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No chats found'));
            } else if (snapshot.data == null) {
              return const Center(child: Text('No chats found'));
            } else if (snapshot.data?.docs.isEmpty ?? true) {
              return const Center(child: Text('No chats found'));
            }
            final chats = snapshot.data?.docs;

            return ListView.builder(
              itemCount: chats?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    context.push('/chat', extra: {
                      'chat_id': chats?[index]['chat_id'],
                      'chat_name': chats?[index]['chat_name'],
                    });
                  },
                  title: Text((chats?[index]['chat_name']).toString()),
                  subtitle: Text((chats?[index]['chat_id']).toString()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
