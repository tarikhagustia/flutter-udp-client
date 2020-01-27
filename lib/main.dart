import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Send Message',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Palindrom Checker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  String _message = "";
  String rcvMessage = "";
  final myController = TextEditingController();

  void _sendMessage() {
    setState(() {
      String message = myController.text;
      var codec = new Utf8Codec();
      List<int> dataToSend = codec.encode(message);
      var addressesIListenFrom = InternetAddress.anyIPv4;
      int portIListenOn = 8008; //0 is random
      RawDatagramSocket.bind(addressesIListenFrom, portIListenOn)
        .then((RawDatagramSocket udpSocket) {
        udpSocket.forEach((RawSocketEvent event) {
          if(event == RawSocketEvent.read) {
            Datagram dg = udpSocket.receive();
            dg.data.forEach((x) => print(x));
            rcvMessage = codec.decode(dg.data);
          }
        });
        udpSocket.send(dataToSend, new InternetAddress('192.168.8.101'), 8008);
        print('Did send data on the stream..');
      });
      _message = rcvMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: 
        Container(
          margin: EdgeInsets.fromLTRB(30, 40, 30, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: myController,
                decoration: InputDecoration(
                  labelText: 'Enter your Word'
                ),
              ),
              Text(
                '$_message',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Sending Message through UDP Port',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}