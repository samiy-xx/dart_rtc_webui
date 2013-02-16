part of chatcomponent;

abstract class ChatCommand {
  
}

class NickCommand implements ChatCommand {
  final String nick;
  NickCommand(this.nick);
}

class PrivMsgCommand implements ChatCommand {
  
}
class ChatMessage {
  DateTime time;
  MessageType messageType;
  String user;
  String message;
  ChatMessage(this.time, this.messageType, this.user, this.message);
}

class ChatEntry {
  final String _e;
  
  bool get isCommand => _e.startsWith("/");
  ChatCommand get command => getCommand();
  ChatEntry(this._e);
  
  ChatCommand getCommand() {
    if (isCommand) {
      List<String> split = _e.split(" ");
      String first = split[0];
      return first.substring(1);
    }
    
    return "";
  }
  
  String toString() => _e;
}

