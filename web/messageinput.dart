import 'dart:html';
import 'package:web_ui/web_ui.dart';


class MessageInput extends WebComponent {
  String _inputText;
  String get currentMessage => _inputText;
  String get extraCss => _getExtraCss();
  Element _element;
  
  void created() {
    _inputText = "bananas";
  }
  
  void inserted() {
    // There really aint no way to get element?
    _element = parent.children.where((Element e) => e.id == id).single;
    //_element = parent.nodes.where((Element e) => e.id == id).single;
    _element.contentEditable = "true";
  }
  
  String _getExtraCss() {
    StringBuffer buf = new StringBuffer();
    
    return buf.toString();
  }
}

