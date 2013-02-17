part of components;

class Tab {
  String name;
  
  String get extraCss => _getExtraCss();
  
  bool isActive = false;
  bool hasUnread = false;
  
  List<ChatMessage> messages;
  List<User> users;
  
  Tab(this.name) {
    messages = new List<ChatMessage>();
    users = new List<User>();
    setActive(false);
  }
  
  void setActive(bool b) {
    isActive = b;
  }
  
  void setHasUnread(bool b) {
    hasUnread = b;
  }
  
  String _getExtraCss() {
    StringBuffer buf = new StringBuffer();
    if (isActive)
      buf.add("active ");
    
    if (hasUnread)
      buf.add("important");
      
    return buf.toString();
  }
}

