package com.breadweb.watergamelcd
{
	import com.breadweb.display.MovieClipPlus;
	import com.breadweb.utils.Console;
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import flashx.textLayout.events.ModelChange;
	
	import gs.TweenMax;
	
	public class GameView extends Sprite
	{
		public static const SCENE_NORMAL:String = "scene.normal";
		public static const SCENE_FINAL:String = "scene.final";
		
		private var _container:MovieClip;
		private var _allie:MovieClip;
		private var _alliePositions:Vector.<Point>;
		private var _lastAllieFrame:int;
		private var _isPlaying:Boolean;
		private var _captions:MovieClip;
		private var _results:MovieClip;
		private var _control:GameControl;
		public var gameLayer:Sprite;
		public var debugLayer:Sprite;	
		
		public function GameView()
		{
			_control = GameControl.getInstance();
			
			gameLayer = new Sprite();
			gameLayer.name = "_gameLayer";		
			debugLayer = new Sprite();
			debugLayer.name = "_debugLayer";
			
			addChild(gameLayer);
			addChild(debugLayer);			
			
			_container = new MainView();
			_container.stop();
			gameLayer.addChild(_container);	
			
			_alliePositions = Vector.<Point>([
				new Point(236, 157),
				new Point(886, 45)
			]);
			
			_allie = new Alligator();
			_allie.addEventListener(CaptionEvent.CHANGED, onCaptionChanged);
			_allie.addEventListener(CueEvent.DELIVERED, onCueChanged);
			_allie.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			(_container["allie"] as MovieClip).addChild(_allie);
			_allie.stop();
			
			_captions = _container.getChildByName("captions") as MovieClip;		
			_results = _container.getChildByName("results") as MovieClip;
		}
		
		// Start playing at a specific label marker in the main container clip 
		public function goTo(marker:String):void
		{
			var found:Boolean = false;
			for (var i:int = 0; i < _container.currentLabels.length; i++)
			{
				if ((_container.currentLabels[i] as FrameLabel).name == marker)
				{
					found = true;
					break;
				}
			}
			
			if (found)
				_container.gotoAndPlay(marker);
			else
				Console.log("Frame label not found: " + marker, this);
			
			return;
		}
		
		public function playAllieScript(part:String):void
		{
			_allie.gotoAndPlay(part);
		}
		
		public function stopAllieScript():void
		{
			_allie.gotoAndStop("silence");
		}		
		
		public function isAlliePlaying():Boolean
		{
			return _isPlaying;
		}
		
		public function fadeIn():void
		{
			var fader:MovieClip = _container.getChildByName("fader") as MovieClip;
			TweenMax.to(fader, 1, {autoAlpha:0, startAt:{autoAlpha:1}});
		}
		
		public function setScene(type:String):void
		{
			var bg1:MovieClip = _container.getChildByName("background1") as MovieClip;
			var bg2:MovieClip = _container.getChildByName("background2") as MovieClip;
			
			switch (type)
			{
				case GameView.SCENE_NORMAL:
					
					bg1.visible = true;
					bg2.visible = false;
					_allie.parent.x = _alliePositions[0].x;
					_allie.parent.y = _alliePositions[0].y;
					_results.visible = false;
					break;
				
				case GameView.SCENE_FINAL:
					
					bg1.visible = false;
					bg2.visible = true;
					_allie.parent.x = _alliePositions[1].x;
					_allie.parent.y = _alliePositions[1].y;
					break;
			}
		}
		
		public function setResultsView(name:String, results:String):void
		{
			if (name == "" && results == "")
			{
				if (_results.alpha > 0)
					TweenMax.to(_results, 1, {autoAlpha:0});
				
				return;
			}
			
			(_results["playerName"] as TextField).text = name.toUpperCase();
			(_results["playerResult"] as TextField).text = results;
			(_results["icon"] as MovieClip).gotoAndStop(name);
			(_results["background"] as MovieClip).gotoAndStop(name);
			
			TweenMax.to(_results, 1, {autoAlpha:1, startAt:{autoAlpha:0}});
		}
		
		public function setCaption(caption:String):void
		{
			var captionText:TextField = _captions.getChildByName("captiontext") as TextField;
			if (captionText != null)
			{
				captionText.text = caption;
				TweenMax.to(captionText, 1, {alpha:1, startAt:{alpha:0}});
			}			
		}		
		
		private function onCaptionChanged(evt:CaptionEvent):void
		{
			var xml:XML = GameControl.getInstance().captions;
			if (!xml)
				return;
			
			//var captionId:String = _allie.currentFrameLabel;
			var captionId:String = evt.captionId;
			var caption:String = xml.caption.(@id == captionId);
			
			setCaption(caption);
		}
		
		private function onCueChanged(evt:CueEvent):void
		{
			_control.sendGameCue(evt.cueId);	
		}
		
		private function onEnterFrame(evt:Event):void
		{
			_isPlaying = (_lastAllieFrame != _allie.currentFrame);
			_lastAllieFrame = _allie.currentFrame;			
		}
	}
}