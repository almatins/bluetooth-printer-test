import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      debugPrint('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                const Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name ?? ''),
                              subtitle: Text(d.address ?? ''),
                              onTap: () async {
                                setState(() {
                                  _device = d;
                                });
                              },
                              trailing: _device != null &&
                                      _device!.address == d.address
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device!.address != null) {
                                      setState(() {
                                        tips = 'connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      debugPrint('please select device');
                                    }
                                  },
                            child: const Text('connect'),
                          ),
                          const SizedBox(width: 10.0),
                          OutlinedButton(
                            onPressed: _connected
                                ? () async {
                                    setState(() {
                                      tips = 'disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                            child: const Text('disconnect'),
                          ),
                        ],
                      ),
                      const Divider(),
                      OutlinedButton(
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = {};
                                List<LineText> list = [];

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Test',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    fontZoom: 2,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Trest Again',
                                    align: LineText.ALIGN_LEFT,
                                    x: 0,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '200',
                                    align: LineText.ALIGN_LEFT,
                                    x: 350,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '1000',
                                    align: LineText.ALIGN_LEFT,
                                    x: 500,
                                    relativeX: 0,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Rp. 10.000',
                                    align: LineText.ALIGN_LEFT,
                                    x: 0,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Rp.',
                                    align: LineText.ALIGN_LEFT,
                                    x: 350,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '12.0',
                                    align: LineText.ALIGN_LEFT,
                                    x: 500,
                                    relativeX: 0,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                // ByteData data = await rootBundle
                                //     .load("assets/images/bluetooth_print.png");
                                // List<int> imageBytes = data.buffer.asUint8List(
                                //     data.offsetInBytes, data.lengthInBytes);
                                // String base64Image = base64Encode(imageBytes);
                                // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                                await bluetoothPrint.printReceipt(config, list);
                              }
                            : null,
                        child: const Text('print receipt(esc)'),
                      ),
                      OutlinedButton(
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = {};
                                config['width'] = 40; // 标签宽度，单位mm
                                config['height'] = 70; // 标签高度，单位mm
                                config['gap'] = 2; // 标签间隔，单位mm

                                // x、y坐标位置，单位dpi，1mm=8dpi
                                List<LineText> list = [];
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 10,
                                    content: 'A Title'));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 40,
                                    content: 'this is content'));
                                list.add(LineText(
                                    type: LineText.TYPE_QRCODE,
                                    x: 10,
                                    y: 70,
                                    content: 'qrcode i\n'));
                                list.add(LineText(
                                    type: LineText.TYPE_BARCODE,
                                    x: 10,
                                    y: 190,
                                    content: 'qrcode i\n'));

                                List<LineText> list1 = [];
                                ByteData data = await rootBundle
                                    .load("assets/images/guide3.png");
                                List<int> imageBytes = data.buffer.asUint8List(
                                    data.offsetInBytes, data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                list1.add(LineText(
                                  type: LineText.TYPE_IMAGE,
                                  x: 10,
                                  y: 10,
                                  content: base64Image,
                                ));

                                await bluetoothPrint.printLabel(config, list);
                                await bluetoothPrint.printLabel(config, list1);
                              }
                            : null,
                        child: const Text('print label(tsc)'),
                      ),
                      OutlinedButton(
                        onPressed: _connected
                            ? () async {
                                await bluetoothPrint.printTest();
                              }
                            : null,
                        child: const Text('print selftest'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              );
            } else {
              return FloatingActionButton(
                  child: const Icon(Icons.search),
                  onPressed: () => bluetoothPrint.startScan(
                      timeout: const Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
