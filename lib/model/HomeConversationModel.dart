import 'ConversationModel.dart';
import 'User.dart';

class HomeConversationModel {
  List<User> members;
  ConversationModel? conversationModel = ConversationModel();

  HomeConversationModel({this.members = const [], this.conversationModel});
}
