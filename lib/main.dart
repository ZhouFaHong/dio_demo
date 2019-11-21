import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'http_util.dart';
import 'alert_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    MyAlertDialog().showAlertDialog(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Function success = (data) {
      print('data=$data');
    };
    Function error = (error) {
      print('error=$error');
    };
    CancelToken _cancelToken = new CancelToken();
    HttpUtil.getInstance()
        .get('/topics', {}, success, error, cancelToken: _cancelToken);
    
    // 延迟一秒执行
    Future.delayed(Duration(seconds: 1), () {
      print('$_cancelToken');
      // 成功
      // _cancelToken.cancel('取消请求'); 
      // HttpUtil.getInstance().cancelRequests(_cancelToken);
      print('延时1s执行');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
