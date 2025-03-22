import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:reels/config/app_route.dart';
import 'package:reels/models/notification.dart';
import 'package:reels/models/post.dart';
import 'package:reels/models/user.dart';
import 'package:reels/providers/notification_provider.dart';
import 'package:reels/providers/post_provider.dart';
import 'package:reels/providers/user_provider.dart';
import 'package:reels/services/firebase_service.dart';
import 'package:reels/services/push_notification_service.dart';
import 'package:reels/services/utils_service.dart';
import 'package:reels/widgets/avatar_widget.dart';
import 'package:reels/widgets/icon_button_widget.dart';
import 'package:reels/widgets/loading_widget.dart';
import 'package:reels/widgets/screen_wrapper_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserProvider _userProvider = UserProvider();
  bool _isUser = true;
  late UserModel _profileData;
  bool _initialized = false;
  List<PostModel> _postList = [];
  FriendType friend = FriendType.notFriend;

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _isUser = ModalRoute.of(context)?.settings.arguments == null;
      if (_isUser) {
        _profileData =
            Provider.of<UserProvider>(context, listen: true).userData!;

        _postList = context
            .read<PostProvider>()
            .listPosts
            .where(
              (element) => element.owner.uid == _profileData.uid,
            )
            .toList();
      } else {
        if (!_isUser) {
          final FirebaseService firebaseService = FirebaseService();
          _profileData =
              (ModalRoute.of(context)?.settings.arguments as UserModel?)!;

          if (_profileData.friendRequests
              .contains(context.read<UserProvider>().userData!.uid)) {
            friend = FriendType.friendRequest;
          } else if (_profileData.friends
              .contains(context.read<UserProvider>().userData!.uid)) {
            friend = FriendType.friend;

            _postList = await firebaseService.getListPostFriend(
                uidFriend: _profileData.uid);
          } else {
            friend = FriendType.notFriend;
          }
        }
      }

      setState(() {});
    }
  }

  void _showModal({required BuildContext context}) async {
    final size = MediaQuery.of(context).size;
    final userData = context.read<UserProvider>().userData!;
    final FirebaseService firebaseService = FirebaseService();

    List<UserModel> listFriends =
        await firebaseService.getListUser(userData.friends);
    List<UserModel> listFriendsReq =
        await firebaseService.getListUser(userData.friendRequests);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: size.height * 0.8,
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "${userData.friends.length} Friends",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _buildBadge(
                  icon: HugeIcons.strokeRoundedShare01,
                  title: 'Find friends from other apps',
                  context: context,
                ),
                Container(
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            "assets/icons/messenger.png",
                            height: 64,
                            width: 64,
                          ),
                          Text(
                            'messenger',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            "assets/icons/instagram.png",
                            height: 64,
                            width: 64,
                          ),
                          Text(
                            'instagram',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            "assets/icons/zalo.png",
                            height: 64,
                            width: 64,
                          ),
                          Text(
                            'zalo',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                                color: Colors.amber, shape: BoxShape.circle),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: Colors.black,
                              size: 24.0,
                            ),
                          ),
                          Text('Link'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildBadge(
                    icon: HugeIcons.strokeRoundedUserMultiple02,
                    title: 'Friends',
                    context: context),
                ...List.generate(
                  growable: true,
                  listFriends.length,
                  (index) {
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoute.profile,
                            arguments: listFriends[index]);
                      },
                      leading: AvatarWidget(
                        pathImage: listFriends[index].image,
                      ),
                      title: Text(listFriends[index].name),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildBadge(
                    icon: HugeIcons.strokeRoundedUserAdd02,
                    title: 'Friends request',
                    context: context),
                ...List.generate(
                  growable: true,
                  listFriendsReq.length,
                  (index) {
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoute.profile,
                            arguments: listFriendsReq[index]);
                      },
                      leading: AvatarWidget(
                        pathImage: listFriendsReq[index].image,
                      ),
                      title: Text(listFriendsReq[index].name),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<PostModel>> getPostList() async {
    if (_isUser) {
      return context
          .read<PostProvider>()
          .listPosts
          .where(
            (e) => e.owner.uid == _profileData.uid,
          )
          .toList();
    } else {
      //
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapperWidget(
      showBackButton: true,
      actions: [
        if (_isUser) ...[
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedUserMultiple02,
            onTap: () => _showModal(context: context),
          ),
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedSettings02,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoute.editProfile);
            },
          ),
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedLogout05,
            onTap: () {
              _userProvider.signOut(context);
            },
          ),
        ] else ...[
          IconButtonWidget(
            hugeIcon: HugeIcons.strokeRoundedSent,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoute.chat,
                arguments: _profileData,
              );
            },
          ),
          IconButtonWidget(
            hugeIcon: friend == FriendType.friendRequest
                ? HugeIcons.strokeRoundedMailSend02
                : (friend == FriendType.friend
                    ? HugeIcons.strokeRoundedUserMultiple02
                    : HugeIcons.strokeRoundedAddTeam),
            onTap: () async {
              FirebaseService firebaseService = FirebaseService();

              if (friend == FriendType.friend) {
                //unfriend

                UtilsService.showConfirmationDialog(
                  context: context,
                  title: "Are you sure to unfriend?",
                  onConfirm: () async {
                    // final result =
                    await firebaseService.addOrRemoveFriend(
                      friendType: friend,
                      otherUserId: _profileData.uid,
                    );
                  },
                  onDecline: () async {},
                );
              } else {
                //request- cancel req
                final result = await firebaseService.addOrRemoveFriend(
                  friendType: friend,
                  otherUserId: _profileData.uid,
                );
                if (result) {
                  if (friend == FriendType.notFriend) {
                    final PushNotificationService pushNotificationService =
                        PushNotificationService();
                    pushNotificationService.sendNotificationToSelectedUser(
                      deviceToken: _profileData.token,
                      context: context,
                      title: "Reels",
                      body:
                          "Friend Request from ${_userProvider.userData!.name}",
                      data: {},
                    );
                    context.read<NotificationProvider>().addNotification(
                          sender: _userProvider.userData!,
                          sentTime: DateTime.now(),
                          type: NotificationType.friendRequest,
                          receiverId: _profileData.uid,
                        );
                  }
                }
              }
            },
          ),
        ],
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isUser) ...[
              Consumer<UserProvider>(
                builder: (context, value, child) {
                  if (value.userData == null) {
                    return Center(child: LoadingWidget());
                  }
                  return _buildProfileContent(
                      user: value.userData!, context: context);
                },
              ),
            ] else
              _buildProfileContent(user: _profileData, context: context),
            if (!_initialized)
              CircularProgressIndicator()
            else ...[
              SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...List.generate(
                    _postList.length,
                    (index) {
                      return _buildPost(imagePath: _postList[index].image);
                    },
                  )
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPost({required String imagePath}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRoute.imageView, arguments: imagePath);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            // border: Border.all(color: Colors.black),
            ),
        child: ClipRect(
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      {required UserModel user, required BuildContext context}) {
    return Column(
      children: [
        AvatarWidget(
          pathImage: user.image,
          size: 150,
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButtonWidget(
                hugeIcon: HugeIcons.strokeRoundedTag01,
                size: 20.0,
              ),
              SizedBox(width: 10),
              Text(
                user.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(
      {required IconData icon,
      required String title,
      required BuildContext context}) {
    return Row(
      spacing: 10,
      children: [
        IconButtonWidget(hugeIcon: icon),
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
