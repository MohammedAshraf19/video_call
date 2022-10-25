import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
 import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_reomte_view;

import 'package:video_call/utils/setting.dart';

class CallScreen extends StatefulWidget {
  String? channelName;
  ClientRole? role;
   CallScreen({Key? key, this.role, this.channelName}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final users =<int>[];
  final infoString = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }
  Future<void> initialize() async{
    if(appId.isEmpty){
      setState(() {
        infoString.add(
          'App_Id Missing, Please Provide Your App In setting,dart',
        );
        infoString.add(
          'Agora Engine Is Not Starting'
        );
      });
      return ;
    }
    _engine =await RtcEngine.create(appId) ;
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920,height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName!, null, 0);
  }
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
          error: (e){
      setState(() {
        final info = 'error $e';
        infoString.add(info);
      });
    },
      joinChannelSuccess: (channel,uid,elapsed){
      setState(() {
        final info = 'join Channel $channel , uId $uid';
        infoString.add(info);
      });
      },
      leaveChannel: (states){
      setState(() {
        infoString.add('Leave Channel');
        users.clear();
      });
      },
      userJoined: (uid,elapsed){
      final info = 'User Uid $uid';
      infoString.add(info);
      users.add(uid);
      },
      userOffline: (uid,elapsed){
        final info = 'User Offline $uid';
        infoString.add(info);
        users.remove(uid);
      },
      firstRemoteVideoFrame: (uid,width,height,elapsed){
        final info = 'First Remote Video $uid $width x $height';
        infoString.add(info);
      }
    ),
    );
  }
  @override
  void dispose() {
    users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Widget _viewRow(){
    final List<StatefulWidget> list =[];
    if(widget.role == ClientRole.Broadcaster){
      list.add(rtc_local_view.SurfaceView());
    }
    for(var uid in users){
      list.add( rtc_reomte_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName,
      ));
    }
    final view =list;

    return Column(
      children: List.generate(
          view.length,
              (index)=>Expanded(
              child: view[index]
          ),
      ),
    );

  }

  Widget _toolbar(){
    if(widget.role == ClientRole.Audience) {
      return SizedBox();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
              onPressed: (){
                setState(() {
                  muted = !muted;
                });
              },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white :Colors.blueAccent,
              size: 20,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: muted? Colors.blueAccent:Colors.white,
            padding: EdgeInsets.all(12),
          ),
          RawMaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.call_end,
              color:  Colors.white,
              size: 35,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor: Colors.redAccent,
            padding: EdgeInsets.all(15),
          ),
          RawMaterialButton(
            onPressed: (){
              _engine.switchCamera();
            },
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20,
            ),
            shape: CircleBorder(),
            elevation: 2,
            fillColor:Colors.white,
            padding: EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  Widget _panel(){
    return Visibility(
      visible: viewPanel,
        child:Container(
          padding: EdgeInsets.symmetric(vertical: 48),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: ListView.builder(
                reverse:  true,
                  itemBuilder:(context,index){
                  if(infoString.isEmpty)
                    return Text('null');
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 10
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                            child:Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                infoString[index],
                                style: TextStyle(
                                  color: Colors.blueGrey
                                ),
                              ),
                            ),
                        ),
                      ],
                    ),
                  );
                  },
                itemCount: infoString.length,

              ),
            ),
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Hallo'),
        actions: [
          IconButton(
              onPressed: (){
                setState(() {
                  viewPanel = !viewPanel;
                });
              },
              icon: Icon(
                Icons.info_outline,
              ),
          ),

        ],

      ),
      body: Center(
        child: Stack(
          children: [
            _viewRow(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }


}
