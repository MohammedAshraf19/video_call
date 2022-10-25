
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'dart:async';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_call/page/call.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  var channelController = TextEditingController();
  ClientRole role = ClientRole.Broadcaster;
  bool validatorError = false;
  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Lottie.network('https://assets3.lottiefiles.com/packages/lf20_pghdouhq.json'),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  controller: channelController,
                  decoration:  InputDecoration(
                    hintText: 'Channel Text',
                    errorText:
                    validatorError? 'Channel Is Mandatory':null
                    ,
                  ),
                ),
                RadioListTile(
                  title:  const Text(
                      'BroadCast'
                  ),
                    value: ClientRole.Broadcaster,
                    groupValue: role,
                    onChanged: (ClientRole? value){
                    setState(() {
                      role = value!;
                    });
                    }
                ),
                RadioListTile(
                    title:  const Text(
                        'Audience'
                    ),
                    value: ClientRole.Audience,
                    groupValue: role,
                    onChanged: (ClientRole? value){
                      setState(() {
                        role = value!;
                      });
                    }
                ),
                ElevatedButton(
                    onPressed: onJoin,
                    child: const Text('Join'),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> onJoin()async{
    if(channelController.text.isEmpty){
      setState(() {
        validatorError = true;
      });
    }
    if(channelController.text.isNotEmpty){
        validatorError  = false;
      await _HandleCameraAndMic(Permission.camera);
      await _HandleCameraAndMic(Permission.microphone);
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>CallScreen(channelName: channelController.text,role: role,))
      );
    }
  }
}

Future<void> _HandleCameraAndMic(Permission permission)async {
  final status =await permission.request();
  log(status.toString());
}
