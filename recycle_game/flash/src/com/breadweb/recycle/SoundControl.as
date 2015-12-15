package com.breadweb.recycle
{
	import com.breadweb.utils.Console;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.Dictionary;

	public class SoundControl {
		
		[Embed(source="/../assets/layout.swf", symbol="glass")]
		private const GLASS:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="plastic")]
		private const PLASTIC:Class;
		
		[Embed(source="/../assets/layout.swf", symbol="metal")]
		private const METAL:Class;
		
		[Embed(source="/../assets/layout.swf", symbol="paper")]
		private const PAPER:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="wrong")]
		private const WRONG:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="collect")]
		private const COLLECT:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="truckidle")]
		private const TRUCK_IDLE:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="truckdrive")]
		private const TRUCK_DRIVE:Class;	
		
		[Embed(source="/../assets/layout.swf", symbol="beep1")]
		private const BEEP1:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="beep2")]
		private const BEEP2:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="finished")]
		private const FINISHED:Class;			
		
		private static var _instance:SoundControl;
		private var _sounds:Array;
		private var _channels:Array;
		
		public function SoundControl(enforcer:SingletonEnforcer) {}
		
		public static function getInstance():SoundControl
		{
			if (_instance == null)
			{
				_instance = new SoundControl(new SingletonEnforcer());
			}
			return _instance;
		}
		
		public function init():void
		{
			_sounds = new Array();
			_sounds["glass"] = new GLASS() as Sound;
			_sounds["plastic"] = new PLASTIC() as Sound;
			_sounds["metal"] = new METAL() as Sound;
			_sounds["paper"] = new PAPER() as Sound;
			_sounds["wrong"] = new WRONG() as Sound;
			_sounds["collect"] = new COLLECT() as Sound;
			_sounds["truckidle"] = new TRUCK_IDLE() as Sound;
			_sounds["truckdrive"] = new TRUCK_DRIVE() as Sound;
			_sounds["beep1"] = new BEEP1() as Sound;
			_sounds["beep2"] = new BEEP2() as Sound;
			_sounds["finished"] = new FINISHED() as Sound;
			
			_channels = new Array();
		}
		
		public function play(key:String, id:String = "", repeat:int = 1):void
		{
			if (_sounds[key] != null)
			{			
				var channel:SoundChannel = (_sounds[key] as Sound).play(0, repeat);
				_channels[key + id] = channel;
			} 
			else
			{
				Console.getInstance().log("Sound not found: " + key, this);
			}				
		}
		
		public function stop(key:String, id:String = ""):void
		{
			if (_channels[key + id] != null)
			{			
				Console.getInstance().log("Stopping sound " + key + " (" + id + ")", this);
				(_channels[key + id] as SoundChannel).stop();
			} 
			else
			{
				Console.getInstance().log("Sound channel not found: " + key + id, this);
			}			
		}
		
		public function stopAll():void
		{
			SoundMixer.stopAll();
		}

	}
}

class SingletonEnforcer {}