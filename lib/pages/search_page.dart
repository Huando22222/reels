import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/models/user.dart';
import 'package:reels/pages/profile_page.dart';
import 'package:reels/providers/notification_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/push_notification_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final UserProvider _userProvider = UserProvider();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
  Timer? _debounce;
  List<UserModel> _searchList = [];

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (_searchController.text.trim().isNotEmpty) {
      _debounce = Timer(Duration(milliseconds: 1500), () {
        _onSearch();
      });
    }
  }

  void _onSearch() async {
    if (_searchController.text.trim().isEmpty) return;
    final FirebaseService firebaseService = FirebaseService();
    _searchList.clear();
    _searchList
        .addAll(await firebaseService.searchUser(name: _searchController.text));
    setState(() {});
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Are you sure to unfriend?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapperWidget(
      showBackButton: true,
      title: "User Search",
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Row(
              spacing: 50,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _onSearchChanged(),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _onSearch();
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: "Search  by email",
                      hintStyle: TextStyle(),
                    ),
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: Colors.black,
                  size: 24.0,
                ),
              ],
            ),
          ),

          //
          if (_searchList.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (_searchList[index].uid !=
                      context.read<UserProvider>().userData!.uid) {
                    FriendType friend = FriendType.notFriend;

                    if (_searchList[index]
                        .friendRequests
                        .contains(context.read<UserProvider>().userData!.uid)) {
                      friend = FriendType.friendRequest;
                    } else if (_searchList[index]
                        .friends
                        .contains(context.read<UserProvider>().userData!.uid)) {
                      friend = FriendType.friend;
                    } else {
                      friend = FriendType.notFriend;
                    }

                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoute.profile,
                            arguments: _searchList[index]);
                      },
                      leading:
                          AvatarWidget(pathImage: _searchList[index].image),
                      title: Text(_searchList[index].name),
                      trailing: GestureDetector(
                        onTap: () async {
                          FirebaseService firebaseService = FirebaseService();

                          if (friend == FriendType.friend) {
                            bool confirm =
                                await _showConfirmationDialog(context);
                            if (!confirm) return;

                            final result =
                                await firebaseService.addOrRemoveFriend(
                              friendType: friend,
                              otherUserId: _searchList[index].uid,
                            );

                            if (result) {
                              setState(() {
                                _searchList[index]
                                    .friends
                                    .remove(_userProvider.userData!.uid);
                              });
                            }
                          } else {
                            final result =
                                await firebaseService.addOrRemoveFriend(
                              friendType: friend,
                              otherUserId: _searchList[index].uid,
                            );

                            if (result) {
                              setState(() {
                                if (friend == FriendType.friendRequest) {
                                  _searchList[index]
                                      .friendRequests
                                      .remove(_userProvider.userData!.uid);
                                } else {
                                  context
                                      .read<NotificationProvider>()
                                      .addNotification(
                                        sender: _userProvider.userData!,
                                        sentTime: DateTime.now(),
                                        type: NotificationType.friendRequest,
                                        receiverId: _searchList[index].uid,
                                      );
                                  _searchList[index]
                                      .friendRequests
                                      .add(_userProvider.userData!.uid);
                                  _pushNotificationService
                                      .sendNotificationToSelectedUser(
                                    context: context,
                                    title: "Reels",
                                    body:
                                        "Friend Request from: ${_userProvider.userData!.name}",
                                    data: {},
                                  );
                                }
                              });
                            }
                          }
                        },
                        child: HugeIcon(
                          icon: friend == FriendType.friendRequest
                              ? HugeIcons.strokeRoundedMailSend02
                              : (friend == FriendType.friend
                                  ? HugeIcons.strokeRoundedUserMultiple02
                                  : HugeIcons.strokeRoundedAddTeam),
                          color: Colors.black,
                          size: 24.0,
                        ),
                      ),
                      subtitle: Text(_searchList[index].email),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
                separatorBuilder: (context, index) {
                  return SizedBox.shrink();
                },
                itemCount: _searchList.length,
              ),
            ),
        ],
      ),
    );
  }
}
