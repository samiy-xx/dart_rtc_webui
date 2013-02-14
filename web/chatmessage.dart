part of chatcomponent;

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
  String get command => getCommand();
  ChatEntry(this._e);
  
  String getCommand() {
    if (isCommand) {
      List<String> split = _e.split(" ");
      String first = split[0];
      return first.substring(1);
    }
    
    return "";
  }
  
  String toString() => _e;
}

