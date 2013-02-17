part of components;

abstract class ChatCommand {
  bool _valid = false;
  bool get valid => _valid;
 
  static ChatCommand fromInput(List<String> l) {
    String c = l[0];
    c = c.replaceFirst("/", "");
    
    if (c.toLowerCase() == "msg") {
      if (l.length > 2) {
        return new PrivMsgCommand(l[1], l.getRange(2, l.length - 2).join(" "));
      }
    }
    if (c.toLowerCase() == "nick") {
      if (l.length > 1) {
        String s = l[1]; 
        return new NickCommand(s);
      }
    }
    if (c.toLowerCase() == "join") {
      
    }
    if (c.toLowerCase() == "leave") {
      
    }
   
    return null;
  }
} 

class NickCommand extends ChatCommand {
  String newNick;
  
  NickCommand(String nick) : super() {
    newNick = nick;
    if (nick != null) {
      _valid = true;
    }
  }
  
}

class PrivMsgCommand extends ChatCommand {
  String to;
  String msg;
  
  PrivMsgCommand(String t, String m) : super() {
    if (t != null && m != null) {
      _valid = true;
      to = t;
      msg = m;
    }
  }
  
}

class JoinChannelComand extends ChatCommand {
  static JoinChannelComand fromString(List<String> l) {
    
  }
}

class LeaveChannelCommand extends ChatCommand {
  static LeaveChannelCommand fromString(List<String> l) {
    
  }
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
      return ChatCommand.fromInput(split);
    }
    return null;
  }
  
  String toString() => _e;
}

