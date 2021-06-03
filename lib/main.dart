import 'dart:async';

import 'package:bluetoothadapter/bluetoothadapter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Bluetoothadapter flutterbluetoothadapter = Bluetoothadapter();
  late StreamSubscription _btConnectionStatusListener, _btReceivedMessageListener;
  String _connectionStatus = "NONE";
  List<BtDevice> devices = [];
  String _recievedMessage = "NONE";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterbluetoothadapter
        .initBlutoothConnection("00001101-0000-1000-8000-00805F9B34FB");
    flutterbluetoothadapter
        .checkBluetooth()
        .then((value) => print(value.toString()));
    _startListening();
  }

  _startListening() {
    _btConnectionStatusListener =
        flutterbluetoothadapter.connectionStatus().listen((dynamic status) {
          setState(() {
            _connectionStatus = status.toString();
          });
        });
    _btReceivedMessageListener =
        flutterbluetoothadapter.receiveMessages().listen((dynamic newMessage) {
          setState(() {
            _recievedMessage = newMessage.toString();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        await flutterbluetoothadapter.startServer();
                      },
                      child: Text('LISTEN'),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () async {
                        devices = await flutterbluetoothadapter.getDevices();
                        setState(() {});
                      },
                      child: Text('LIST DEVICES'),
                    ),
                  ),
                )
              ],
            ),
            Text("STATUS - $_connectionStatus"),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 20,
              ),
              child: ListView(
                shrinkWrap: true,
                children: _createDevices(),
              ),
            ),
            Text(
              _recievedMessage ?? "NO MESSAGE",
              style: TextStyle(fontSize: 24),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: "Write message"),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                      onPressed: () {
                        flutterbluetoothadapter.sendMessage(
                            _controller.text ?? "no msg",
                            sendByteByByte: false);
//                        flutterbluetoothadapter.sendMessage(".",
//                            sendByteByByte: true);
                        _controller.text = "";
                      },
                      child: Text('SEND'),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _createDevices() {
    if (devices.isEmpty) {
      return [
        Center(
          child: Text("No Paired Devices listed..."),
        )
      ];
    }
    List<Widget> deviceList = [];
    devices.forEach((element) {
      if(_checkMacRange(element.address.toString())) {
        deviceList.add(
          InkWell(
            key: UniqueKey(),
            onTap: () {
              flutterbluetoothadapter.startClient(
                  devices.indexOf(element), true);
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(border: Border.all()),
              child: Text(
                element.name.toString() + "(" + element.address.toString() +
                    ")",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      }
    });
    return deviceList;
  }

  _checkMacRange(String address){
    var piAddress = <String>{"B8:27:EB", "DC:A6:32", "E4:5F:01",
                             "B8-27-EB", "DC-A6-32", "E4-5F-01",
                             "B827.EB", "DCA6.32", "E45F.01",
                             "b8:27:eb", "dc:a6:32", "e4:5f:01",
                             "b8-27-eb", "dc-a6-32", "E4-5F-01",
                             "b827.eb", "dca6.32", "E45F.01"};

    for (var element in piAddress) {
      if (address.startsWith(element))
        return true;
    }
    return false;
  }
}