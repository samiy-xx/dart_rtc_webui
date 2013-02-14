part of chatcomponent;

class MessageType {
  static const MessageType MESSAGE = const MessageType("message");
  static const MessageType SYSTEM = const MessageType("system");
  static const MessageType CHANNEL = const MessageType("channel");
  static const MessageType PRIVATE = const MessageType("private");
  final String _type;
  const MessageType(String t) : _type = t;
  String toString() => _type;
}

