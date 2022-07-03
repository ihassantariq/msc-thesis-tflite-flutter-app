import 'package:ecg_arythmias_detection/widgets/pages/dnn-ros-page.dart';
import 'package:ecg_arythmias_detection/widgets/pages/lstm-page.dart';
import 'package:ecg_arythmias_detection/widgets/pages/resnet-page.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text(
              "",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.query_stats),
            title: Text('DNN Model'),
            onTap: () => {//Navigator.of(context).pop(),
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>const DNNPage(title: 'DNN Model')))
            },
          ),
          ListTile(
            leading: Icon(Icons.query_stats),
            title: Text('LSTM Model'),
            onTap: () => {//Navigator.of(context).pop(),
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LSTMPage(title: "LSTM Model")))
            },
          ),
          ListTile(
            leading: Icon(Icons.query_stats),
            title: Text('RESNETSE Model'),
            onTap: () => {
              //Navigator.of(context).pop(),
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RESNETPage(title:"RESNET Model"),)),
            },
          )
        ],
      ),
    );
  }
}