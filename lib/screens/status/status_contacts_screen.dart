import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/controllers/status_controller.dart';
import 'package:whatsapp_clone/repositories/auth_repo.dart';
import 'package:whatsapp_clone/screens/status/confirm_text_status.dart';
import 'package:whatsapp_clone/screens/status/status_screen.dart';
import 'package:whatsapp_clone/shared/utils/base/error_screen.dart';
import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/widgets/custom_indicator.dart';

import '../../models/status_model.dart';
import '../../shared/enums/message_enum.dart';
import '../../shared/utils/functions.dart';
import 'confirm_file_status_screen.dart';

class StatusContactsScreen extends ConsumerWidget {
  final List<String> orderedList = [];

  StatusContactsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<List<StatusModel>>(
        stream: ref.read(statusControllerProvider).getStatus,
        builder: (context, snapshot) {
          _removeRedundantName(snapshot);
          if (snapshot.hasError) {
            customSnackBar(snapshot.error.toString(), context);
            return ErrorScreen(
              error: snapshot.error.toString(),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomIndicator();
          } else {
            return ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: orderedList.length,
              padding: const EdgeInsets.only(top: 20),
              itemBuilder: (context, index) {
                var status = _setMyStatusFirst(snapshot, ref)[index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        print(status.status);
                        Navigator.pushNamed(
                          context,
                          StatusScreen.routeName,
                          arguments: {
                            'status': snapshot.data,
                            'uid': snapshot.data![index].uid,
                            'index': index,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            status.username,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              status.profilePic,
                            ),
                            radius: 30,
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: dividerColor, indent: 85),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            onPressed: () => navTo(context, ConfirmTextScreen()),
            elevation: 0,
            backgroundColor: Colors.grey,
            child: const Icon(
              Icons.text_fields_sharp,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          FloatingActionButton(
            heroTag: 'btn2',
            onPressed: () async {
              File? pickedVideo = await pickVideoFromGallery(context);
              if (pickedVideo != null) {
                navTo(
                    context,
                    ConfirmFileStatus(
                        file: pickedVideo, type: MessageEnum.video));
              }
            },
            elevation: 0,
            backgroundColor: Colors.teal,
            child: const Icon(
              Icons.video_camera_back_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'btn3',
            onPressed: () async {
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                navTo(
                    context,
                    ConfirmFileStatus(
                        file: pickedImage, type: MessageEnum.image));
              }
            },
            // elevation: 0,
            // backgroundColor: Colors.teal,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<StatusModel> _setMyStatusFirst(
      AsyncSnapshot<List<StatusModel>> snapshot, WidgetRef ref) {
    List<StatusModel> modifiedList = [];
    List<int> myIndices = [];
    for (int i = 0; i < snapshot.data!.length; i++) {
      if (snapshot.data![i].uid ==
          ref.read(authRepositoryProvider).auth.currentUser!.uid) {
        myIndices.add(i);
      }
    }
    for (int index in myIndices) {
      modifiedList.add(snapshot.data![index]);
    }
    for (int i = 0; i < snapshot.data!.length; i++) {
      if (!myIndices.contains(i)) {
        modifiedList.add(snapshot.data![i]);
      }
    }
    print(modifiedList.length);
    return modifiedList;
  }

  void _removeRedundantName(AsyncSnapshot<List<StatusModel>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return;
    }
    for (var element in snapshot.data!) {
      if (!orderedList.contains(element.username)) {
        orderedList.add(element.username);
      }
    }
  }
}
