library chatcomponent;

import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'package:dart_rtc_common/rtc_common.dart';
import 'package:dart_rtc_client/rtc_client.dart';

part 'messagetype.dart';
part 'chatmessage.dart';
part 'user.dart';
part 'tabs.dart';

class ChatComponent extends WebComponent {
  Map<String, List<ChatMessage>> messages = new Map<String, List<ChatMessage>>();
  //List<ChatMessage> messages = new List<ChatMessage>();
  List<User> users = new List<User>();
  List<Tab> tabs = new List<Tab>();
  DivElement chat;
  DivElement input;
  String channel = "abc";
  String connectionstring = "";
  ChannelClient client;
  bool cansend = false;
  String activetab = "SYSTEM";
  final String INPUT_EDITABLE = "input_editable";
  final String INPUT_UNEDITABLE = "input_uneditable";
  final int MESSAGE_LIMIT = 100;
  
  void add(String identifier, ChatMessage m) {
    if (!messages.containsKey(identifier))
      messages[identifier] = new List<ChatMessage>();
    
    if (!tabExists(identifier)) {
      tabs.add(new Tab(identifier));
      activetab = identifier;
    }
    
    messages[identifier].add(m);
    
    // Hihih.. hax?
    window.setTimeout(() {
      chat.scrollTop = chat.scrollHeight;
    }, 100); 
  }
  
  void created() {
    new Logger().setLevel(LogLevel.WARN);
  }

  void inserted() {
    
    input = query("#chat_input");
    chat = query("#chat_messages");
    input.focus();
    
    client = new ChannelClient(new WebSocketDataSource(connectionstring))
    .setChannel(channel)
    .setRequireAudio(false)
    .setRequireVideo(false)
    .setRequireDataChannel(true);
    
    client.onInitializationStateChangeEvent.listen((InitializationStateEvent e) {
      if (e.state == InitializationState.CHANNEL_READY) {
        //if (client.setChannelLimit(10))
          //add("system", createSystemMessage("Setting channel limit"));
        
        cansend = true;
        setEditable(true);
        dispatch();
      }
    });
    
    client.onSignalingOpenEvent.listen((SignalingOpenEvent e) {                                                         
      add("SYSTEM", createSystemMessage("Connected"));
      dispatch();
    });
    
    client.onSignalingCloseEvent.listen((SignalingCloseEvent e) {
      print("Disconnected");
      add("SYSTEM", createSystemMessage("Disconnected"));
      cansend = false;
      setEditable(false);
      dispatch();
      window.setTimeout(() {
        client.initialize();
      }, 10000);
    });
    
    client.onPacketEvent.listen((PacketEvent e) {
      if (e.type == PacketType.CHANNELMESSAGE) {
        ChannelMessage cm = e.packet as ChannelMessage;
        add(cm.channelId, new ChatMessage(new DateTime.now(), MessageType.MESSAGE, cm.id, cm.message));
      } else if (e.type == PacketType.CHANNEL) {
        ChannelPacket cp = e.packet as ChannelPacket;
        add(cp.channelId, createChannelMessage("Channel has ${cp.users} users and has a limit of ${cp.limit} concurrent users"));
      } else if (e.type == PacketType.USERMESSAGE) {
        UserMessage um = e.packet as UserMessage;
        add(um.id, new ChatMessage(new DateTime.now(), MessageType.PRIVATE, um.id, um.message));
      } else if (e.type == PacketType.ID) {
        
        IdPacket id = e.packet as IdPacket;
        users.add(new User(id.id));
      } else if (e.type == PacketType.JOIN) {
        
        JoinPacket join = e.packet as JoinPacket;
        users.add(new User(join.id));
        add(join.channelId, createChannelMessage("${join.id} joins the channel"));
      } else if (e.type == PacketType.BYE) {
        ByePacket bye = e.packet as ByePacket;
        add("bye", createChannelMessage("${bye.id} leaves the channel"));
        for (int i = 0; i < users.length; i++) {
          User u = users[i];
          if (u.name == bye.id)
            users.removeAt(i);
        }
      }
      dispatch();
    });
    
    client.initialize();
  }
  
  void onInputKeyDown(KeyboardEvent e) {
    if (!cansend)
      return;
    
    DivElement i = e.target as DivElement;
    if (e.keyCode == 13) {
      if (i.text.length == 0) {
        i.text = "";
        return;
      }
      ChatEntry entry = new ChatEntry(i.text);
      if (entry.isCommand)  {
        String command = entry.command;
        add("me", new ChatMessage(new DateTime.now(), MessageType.MESSAGE, "me", "Issuing command $command"));
      } else {
        add("me", new ChatMessage(new DateTime.now(), MessageType.MESSAGE, "me", entry.toString()));
        client.sendChannelMessage(entry.toString());
      }
      i.text = "";
    }
  }
  
  void onUserDoubleClick(MouseEvent e) {
    input.focus();
    Element element = e.target;
    
    if (input.text == "")
      input.text = "/msg ${element.text} ";
    
  }
  
  void onSetTabActive(MouseEvent e) {
    Element el = e.target;
    activetab = el.text;
    //tabs.where((Tab t) => t.name == activeTab).first.
    dispatch();
  }
  
  /** Invoked when this component is removed from the DOM tree. */
  void removed() {
    print("Removed");
  }
  
  void setEditable(bool b) {
    if (b) {
      input.contentEditable = "true";
      input.classes.remove(INPUT_UNEDITABLE);
      input.classes.add(INPUT_EDITABLE);
    } else {
      input.contentEditable = "false";
      input.classes.remove(INPUT_EDITABLE);
      input.classes.add(INPUT_UNEDITABLE);
    }
  }
  
  bool tabExists(identifier) {
    return tabs.any((Tab t) => t.name == identifier);
  }
  
  Tab createTab(String name) {
    Tab t = new Tab(name);
    tabs.add(t);
    return t;
  }
  
  ChatMessage createChannelMessage(String m) {
    return new ChatMessage(new DateTime.now(), MessageType.CHANNEL, "CHANNEL", m);
  }
  
  ChatMessage createSystemMessage(String m) {
    return new ChatMessage(new DateTime.now(), MessageType.SYSTEM, "SYSTEM", m);
  }
}


