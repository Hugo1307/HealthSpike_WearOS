import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wear/wear.dart';
import 'package:wearable_communicator/wearable_communicator.dart';
import 'package:flutter_android/android_hardware.dart'
    show Sensor, SensorEvent, SensorManager;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Wear App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WatchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WatchScreen extends StatefulWidget {
  const WatchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  double _currentHearthRate = 0;

  @override
  void initState() {
    super.initState();

    // Request permission if it is not granted yet
    Permission.sensors.request();

    SensorManager.getDefaultSensor(Sensor.TYPE_HEART_RATE).then((sensor) => {
          sensor.subscribe().then((event) => {
                event.listen((SensorEvent event) {
                  setState(() {
                    _currentHearthRate = event.values[0];
                  });
                })
              })
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WatchShape(
            builder: (BuildContext context, WearShape shape, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 60,
                      width: 120,
                      child:
                          Image.asset('assets/images/large_healthspike.png')),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset('assets/images/heart_rate.png')),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 10, bottom: 3),
                              child: const Text(
                                'Heart Rate',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              )),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(
                                _currentHearthRate.toString() + ' bpm',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 10),
                              ))
                        ],
                      )
                    ],
                  ),
                ],
              );
            },
            child: AmbientMode(
              builder: (BuildContext context, WearMode mode, Widget? child) {
                return Text(
                  'Mode: ${mode == WearMode.active ? 'Active' : 'Ambient'}',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {

  runApp(const MyApp());
  WearableCommunicator.sendMessage({
    "text": "Some text", 
    "integerValue": 1
  });

}
