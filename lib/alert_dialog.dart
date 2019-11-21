import 'package:flutter/material.dart';

/*
* alertdialog
* */
class MyAlertDialog extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          onPressed: () {
            showAlertDialog(context);
          },
          child: Text(
            'AlertDialog',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          color: Colors.green,
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text('this is alertdialog'),
            ),
            title: Center(
                child: Text(
              '标题',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            )),
            
            actions: <Widget>[
              FlatButton(
                color: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消',style: TextStyle(color: Colors.white))),
              FlatButton(
                color: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('确定',style: TextStyle(color: Colors.red),)),
            ],
          );
        });
  }
}
