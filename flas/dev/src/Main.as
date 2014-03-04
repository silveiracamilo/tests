package
{
	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.TextField;
	
	public class Main extends Sprite
	{	
	  	protected var nc:NetConnection; 
		protected var ns:NetStream; 
		protected var nsPlayer:NetStream; 
		protected var vid:Video; 
		protected var vidPlayer:Video; 
		protected var cam:Camera; 
		protected var mic:Microphone; 
		protected var log:TextField;
		
		public function Main()
		{
			log = new TextField();
			log.width = 400;
			log.height = 100;
			log.y = 315;
			addChild(log);
			
			nc = new NetConnection(); 
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus); 
			nc.connect("rtmp://107.170.63.197:1935/silveiracamilo_cam_teste");
		}
		
		protected function onNetStatus(event:NetStatusEvent):void{ 
			log.appendText(event.info.code + "\n"); 
			if(event.info.code == "NetConnection.Connect.Success"){ 
				publishCamera(); 
				displayPublishingVideo(); 
				displayPlaybackVideo(); 
			} 
		} 
		
		protected function publishCamera():void { 
			cam = Camera.getCamera(); 
			mic = Microphone.getMicrophone(); 
			ns = new NetStream(nc); 
			ns.attachCamera(cam); 
			ns.attachAudio(mic); 
			ns.publish("teste", "record"); 
		}
		
		protected function displayPublishingVideo():void { 
			vid = new Video(); 
			vid.x = 10; 
			vid.y = 10; 
			vid.attachCamera(cam); 
			addChild(vid);  
		}
		
		protected function displayPlaybackVideo():void{ 
			nsPlayer = new NetStream(nc);  
			nsPlayer.play("teste"); 
			vidPlayer = new Video(); 
			vidPlayer.x = cam.width + 20; 
			vidPlayer.y = 10; 
			vidPlayer.attachNetStream(nsPlayer); 
			addChild(vidPlayer); 
		}
	}
}