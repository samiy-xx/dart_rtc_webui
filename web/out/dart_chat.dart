// Auto-generated from dart_chat.html.
// DO NOT EDIT.

library dart_chat_html;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;

import 'dart:html';

import 'package:web_ui/web_ui.dart';

import 'chatcomponent.dart';


// Original code
void main() {
  //useShadowDom = true; // to enable use of experimental Shadow DOM in the browser  
}


// Additional generated code
void init_autogenerated() {
  var _root = autogenerated.document.body;
  var __chat, __sample_container_id;

  var __t = new autogenerated.Template(_root);
  __sample_container_id = _root.query('#sample_container_id');
  __chat = __sample_container_id.query('#chat');
  __t.bind(() => (null),  (__e) { __chat.xtag.channel = 'testchannel'; });
  __t.bind(() => (null),  (__e) { __chat.xtag.connectionstring = 'ws://127.0.0.1:8234/ws'; });
  new ChatComponent.forElement(__chat);
  __t.component(__chat);
  

  __t.create();
  __t.insert();
}