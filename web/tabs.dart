part of chatcomponent;

class Tab {
  String name;
  String cssclass;
  
  Tab(this.name) {
    setActive(false);
  }
  
  void setActive(bool b) {
    cssclass = b ? "active" : "notactive";
  }
}

