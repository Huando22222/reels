import 'package:reels/pages/chat_list_page.dart';
import 'package:reels/pages/chat_page.dart';
import 'package:reels/pages/edit_profile_page.dart';
import 'package:reels/pages/image_view_page.dart';
import 'package:reels/pages/noitfication_page.dart';
import 'package:reels/pages/profile_page.dart';
import 'package:reels/pages/recover_email_page.dart';
import 'package:reels/pages/main_page.dart';
import 'package:reels/pages/register_page.dart';
import 'package:reels/pages/login_page.dart';
import 'package:reels/pages/search_page.dart';

class AppRoute {
  static final welcome = '/welcome';
  static final search = '/search';
  static final main = '/main';
  static final profile = '/profile';
  static final notification = '/notification';
  static final chat = '/chat';
  static final chatList = '/chat-list';
  static final login = '/auth/login';
  static final register = '/auth/register';
  static final recoverEmail = '/auth/recover-email';
  static final editProfile = '/auth/edit-profile';
  static final imageView = '/image-view';

  static final pages = {
    main: (context) => const MainPage(),
    search: (context) => const SearchPage(),
    login: (context) => const LoginPage(),
    profile: (context) => const ProfilePage(),
    notification: (context) => const NotificationPage(),
    register: (context) => const RegisterPage(),
    recoverEmail: (context) => const RecoverEmailPage(),
    editProfile: (context) => const EditProfilePage(),
    chat: (context) => const ChatPage(),
    chatList: (context) => const ChatListPage(),
    imageView: (context) => const ImageViewPage(),
  };
}
