import 'package:flutter/material.dart';
import 'package:health_spike_wear_os/events/heart_rate_changed.dart';
import 'package:health_spike_wear_os/handlers/rabbit_mq_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wear/wear.dart';
import 'package:flutter_android/android_hardware.dart'
    show Sensor, SensorEvent, SensorManager;

late RabbitMQHandler _rabbitMQHandler;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Spike',
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
                    // Todo: Send a Json string instead. This JSON should be obtained from a object.
                    HeartRateChangedEvent heartRateChangedEvent =
                        HeartRateChangedEvent(event.values[0], DateTime.now());

                    if (!_rabbitMQHandler.isConnected) return;

                    try {
                      _rabbitMQHandler
                          .publishMessage(heartRateChangedEvent.toJsonString());
                    } catch (e) {
                      _rabbitMQHandler.disconnect();
                      _rabbitMQHandler.connect();
                      print('Queue channel closed. Re-opening it.');
                    }
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
              return child!;
            },
            child: AmbientMode(
              builder: (BuildContext context, WearMode mode, Widget? child) {
                return mode == WearMode.active
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height: 60,
                              width: 120,
                              child: Image.asset(
                                  'assets/images/large_healthspike.png')),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset(
                                      'assets/images/heart_rate.png')),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.only(
                                          left: 10, bottom: 3),
                                      child: const Text(
                                        'Heart Rate',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        _currentHearthRate.toString() + ' bpm',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 10),
                                      ))
                                ],
                              )
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height: 60,
                              width: 120,
                              child: Image.asset(
                                  'assets/images/large_healthspike.png')),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: Image.asset(
                                      'assets/images/heart_rate.png')),
                            ],
                          ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  _rabbitMQHandler = RabbitMQHandler("139.59.174.157", "guest", "guest");
  await _rabbitMQHandler.connect();

  runApp(const MyApp());
}
