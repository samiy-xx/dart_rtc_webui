part of chatcomponent;

class Tab {
  String name;
  String cssclass;
  List<ChatMessage> messages;
  List<User> users;
  
  Tab(this.name) {
    messages = new List<ChatMessage>();
    users = new List<User>();
    setActive(false);
  }
  
  void setActive(bool b) {
    cssclass = b ? "active" : "notactive";
  }
}

