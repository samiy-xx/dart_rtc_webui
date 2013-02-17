
import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';

import 'package:dart_rtc_client/rtc_client.dart';
import 'package:dart_rtc_common/rtc_common.dart';
import 'components.dart';


class ChatComponent extends WebComponent {
  List<Tab> tabs = new List<Tab>();
  DivElement chat;
  Element input;
  String channel = "abc";
  String connectionstring = "";
  ChannelClient client;
  bool cansend = false;
  
  Tab activeTab;
  final String INPUT_EDITABLE = "input_editable";
  final String INPUT_UNEDITABLE = "input_uneditable";
  final int MESSAGE_LIMIT = 100;
  
  void add(String identifier, [ChatMessage m]) {
    Tab t;
    if (!tabExists(identifier)) {
      t = new Tab(identifier);
      tabs.add(t);
      setActiveTab(t);
    } else {
      t = findTab(identifier);
    }
    
    if (t != null && ?m)
      t.messages.add(m);
    
    // Hihih.. hax?
    window.setTimeout(() {
      chat.scrollTop = chat.scrollHeight;
    }, 100); 
  }
  
  void created() {
    Tab t = new Tab("SYSTEM");
    tabs.add(t);
    activeTab = t;
    new Logger().setLevel(LogLevel.DEBUG);
  }

  void inserted() {
    //UnkownElement e;
    input = query("#chat_input");
    chat = query("#chat_messages");
    input.focus();
    
    client = new ChannelClient(new WebSocketDataSource(connectionstring))
    .setChannel(channel)
    .setRequireAudio(false)
    .setRequireVideo(false)
    .setRequireDataChannel(true)
    .setAutoCreatePeer(false);
    
    client.onInitializationStateChangeEvent.listen((InitializationStateEvent e) {
      
      if (e.state == InitializationState.REMOTE_READY) {
        client.joinChannel(channel);
      }
      
      if (e.state == InitializationState.CHANNEL_READY) {
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
      if (e.type == PacketType.CHANGENICK) {
        ChangeNickCommand n = e.packet as ChangeNickCommand;
        changeUserId(n.id, n.newId);
      }
      
      if (e.type == PacketType.CHANNELMESSAGE) {
        ChannelMessage cm = e.packet as ChannelMessage;
        add(cm.channelId, new ChatMessage(new DateTime.now(), MessageType.MESSAGE, cm.id, cm.message));
        Tab t = findTab(cm.channelId);
        notifyTab(t);
      }
      
      else if (e.type == PacketType.CHANNEL) {
        ChannelPacket cp = e.packet as ChannelPacket;
        add(cp.channelId, createChannelMessage("Channel has ${cp.users} users and has a limit of ${cp.limit} concurrent users"));
        Tab t = findTab(cp.channelId);
        notifyTab(t);
      }
      
      else if (e.type == PacketType.USERMESSAGE) {
        UserMessage um = e.packet as UserMessage;
        add(um.id, new ChatMessage(new DateTime.now(), MessageType.PRIVATE, um.id, um.message));
        Tab t = findTab(um.id);
        notifyTab(t);
      }
      
      else if (e.type == PacketType.ID) {
        IdPacket id = e.packet as IdPacket;
        print("find channel with id ${id.channelId}");
        add(id.channelId);
        Tab t = findTab(id.channelId);
        if (t != null) {
          t.users.add(new User(id.id));
          print("Adding user ${id.id}");
        }
      }
      else if (e.type == PacketType.JOIN) {
        
        JoinPacket join = e.packet as JoinPacket;
        Tab t = findTab(join.channelId);
        if (t != null)
          t.users.add(new User(join.id));
        add(join.channelId, createChannelMessage("${join.id} joins the channel"));
      }
      
      else if (e.type == PacketType.BYE) {
        ByePacket bye = e.packet as ByePacket;
        
        for (int i = 0; i < tabs.length; i++) {
          Tab t = tabs[i];
          for (int j = 0; j < t.users.length; j++) {
            User u = t.users[j];
            if (u.name == bye.id) {
              t.users.removeAt(j);
              add(t.name, createChannelMessage("${bye.id} leaves the channel"));
            }
          }
          
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
        ChatCommand command = entry.getCommand();
        if (command is PrivMsgCommand) {
          PrivMsgCommand c = command as PrivMsgCommand;
          add(c.to, new ChatMessage(new DateTime.now(), MessageType.PRIVATE, "me", c.msg));
          client.sendPeerUserMessage(c.to, c.msg);
        } else if (command is NickCommand) {
          NickCommand n = command as NickCommand;
          add("SYSTEM", new ChatMessage(new DateTime.now(), MessageType.SYSTEM, "me", "Chaning nick"));
          client.changeId(n.newNick);
        } else {
          
        }
        add(activeTab.name, new ChatMessage(new DateTime.now(), MessageType.MESSAGE, "me", "Issuing command $command"));
      } else {
        add(activeTab.name, new ChatMessage(new DateTime.now(), MessageType.MESSAGE, "me", entry.toString()));
        client.sendChannelMessage(entry.toString());
      }
      i.text = "";
    }
  }
  
  void onUserDoubleClick(MouseEvent e) {
    input.focus();
    Element element = e.target;
    String id = element.text;
    
    add(id);
    if (client.peerManager.findWrapper(id) == null)
      client.createPeerConnection(id);
    
    if (input.text == "")
      input.text = "/msg ${element.text} ";
  }
  
  void onSetTabActive(MouseEvent e) {
    Element el = e.target;
    Tab t = findTab(el.text);
    if (t != null) {
      setActiveTab(t);
    }
    //tabs.where((Tab t) => t.name == activeTab).first.
    dispatch();
  }
  
  void setActiveTab(Tab t) {
    tabs.forEach((Tab t) => t.isActive = false);
    t.isActive = true;
    t.hasUnread = false;
    activeTab = t;
  }
  
  void notifyTab(Tab t) {
    if (t != activeTab)
      t.hasUnread = true;
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
  
  bool isActiveTab(Tab t) {
    return activeTab == t;
  }
  
  Tab createTab(String name) {
    Tab t = new Tab(name);
    tabs.add(t);
    return t;
  }
  
  Tab findTab(String name) {
    for (int i = 0; i < tabs.length; i++) {
      Tab t = tabs[i];
      if (t.name == name)
        return t;
    }
    return null;
  }
  
  void changeUserId(String o, String n) {
    for (int i = 0; i < tabs.length; i++) {
      Tab t = tabs[i];
      for (int j = 0; j < t.users.length; j++) {
        User u = t.users[j];
        if (u.name == o) {
          u.name = n;
          add(t.name, createSystemMessage("User $o has changed nick to $n"));
        }
      }
    }
  }
  ChatMessage createChannelMessage(String m) {
    return new ChatMessage(new DateTime.now(), MessageType.CHANNEL, "CHANNEL", m);
  }
  
  ChatMessage createSystemMessage(String m) {
    return new ChatMessage(new DateTime.now(), MessageType.SYSTEM, "SYSTEM", m);
  }
}


