package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.NetDataEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class Main extends Sprite
	{	
		protected var urlRequest:URLRequest;
		protected var urlLoader:URLLoader;
		protected var token:String;
		
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
			log.height = 300;
			log.border = true;
			log.y = 315;
			addChild(log);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.BEST;
			
			getToken();
		}
		
		protected function getToken():void
		{
			urlRequest = new URLRequest("get_token.php");
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT; // default
			urlLoader.addEventListener(Event.COMPLETE, urlLoader_complete);
			urlLoader.load(urlRequest);
		}		
		
		
		protected function connectNetConnection():void {
			nc = new NetConnection();
			nc.client = this;
			nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus); 
			//nc.connect("rtmp://107.170.63.197:1935/silveiracamilo_cam_teste_stream?password=sabixao", "sabixao");
			nc.connect("rtmp://107.170.63.197:1935/silveiracamilo_cam_teste_live?password=sabixao&token="+token);
			//nc.connect("rtmp://107.170.63.197:1935/teste_live");
			//nc.connect("rtmp://107.170.63.197:1935/vod");
		}
		
		protected function publishCamera():void { 
			cam = Camera.getCamera(); 
			mic = Microphone.getMicrophone(); 
			ns = new NetStream(nc);
			ns.client = this;
			ns.addEventListener(NetDataEvent.MEDIA_TYPE_DATA, netdataHandler);
			ns.addEventListener(NetStatusEvent.NET_STATUS, netstreamHandler);
			ns.attachCamera(cam); 
			ns.attachAudio(mic); 
			ns.publish("stream1", "live"); 
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
		
		protected function urlLoader_complete(evt:Event):void {
			token = urlLoader.data;
			token = token.substr(1);
			
			log.appendText("token:"+token+"\n");
			connectNetConnection();
		}
		
		protected function onNetStatus(event:NetStatusEvent):void{ 
			log.appendText(event.info.code + "\n");
			if(event.info.code == "NetConnection.Connect.Success"){ 
				publishCamera(); 
				displayPublishingVideo(); 
				//displayPlaybackVideo(); 
			} 
		} 
		
		protected function netstreamHandler(event:NetStatusEvent):void
		{
			for(var prop:String in event.info) {
				log.appendText("netstreamHandler: "+ prop + ":"  +event.info[prop] + "\n");	
			}
			
		}
		
		protected function netdataHandler(event:NetDataEvent):void
		{
			for(var prop:String in event.info) {
				log.appendText("netdataHandler: "+ prop + ":"  +event.info[prop] + "\n");	
			}
						
		}
	}
}