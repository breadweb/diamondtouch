package com.breadweb.watergametable
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	import gs.TweenMax;
	import gs.easing.Back;

	public class PlayerBubble
	{
		private const WAVES_START:int = -384;
		private const WAVES_DISTANCE:int = 200;
		private const ARROW_START:int = 30;
		private const ARROW_DISTANCE:int = 120;
		
		public var clip:MovieClip;
		public var button:MovieClip;
		private var _playerName:String;
		private var _ring:MovieClip;
		private var _arrow:MovieClip;
		private var _waves:MovieClip;
		private var _under:MovieClip;
		private var _ideal:MovieClip;
		private var _over:MovieClip;
		private var _tf:TextField;
		private var _speed:int = 5;
		private var _lastTime:int = 0;
		private var _ranges:Vector.<MovieClip>;	
		private var _control:GameControl;
		
		public function PlayerBubble(playerName:String, clip:MovieClip, color:uint)
		{
			_control = GameControl.getInstance();
			this.clip = clip;
			_playerName = playerName;
			
			_ring = clip.getChildByName("ring") as MovieClip;
			_arrow = clip.getChildByName("arrow") as MovieClip;
			button = clip.getChildByName("startButton") as MovieClip;
			_tf = button.getChildByName("buttonText") as TextField;	
			_waves = clip.getChildByName("waves") as MovieClip;
			
			_ranges = Vector.<MovieClip>([
				clip.getChildByName("under") as MovieClip,
				clip.getChildByName("ideal") as MovieClip,
				clip.getChildByName("over") as MovieClip
			]);		

			var difficulty:int = int(_control.settings["difficulty"]);			
			_ranges[1].gotoAndStop(difficulty);
			
			(clip["playerName"] as TextField).text = _playerName.toUpperCase();
			(clip["icon"] as MovieClip).gotoAndStop(_playerName);
			(clip["land"] as MovieClip).gotoAndStop(_playerName);

			TweenMax.to(_arrow, .1, {tint:0x009900});			
			
			// Set bubble item colors to player color
			TweenMax.to(button["back"], .1, {tint:color});
//			for (var i:int = 0; i < _ranges.length; i++)
//			{
//				TweenMax.to(_ranges[i]["back"], .1, {tint:color});
//			}

		}
		
		public function pulseRing():void
		{
			TweenMax.to(_ring, 1, {alpha:.25, startAt:{alpha:1}});
		}
		
		public function setButtonReady(ready:Boolean):void
		{
			if (ready)
			{
				_tf.text = "READY!";			
				TweenMax.to(button, 1, {colorTransform:{tint:0xFFFFFF, tintAmount:0}});
			}
			else
			{
				_tf.text = "START";
				TweenMax.to(button, 1, {colorTransform:{tint:0xFFFFFF, tintAmount:.3}});
			}
		}
		
		public function enablePlayMode(enabled:Boolean):void
		{
			var i:int;
			if (enabled)
			{
				for (i = 0; i < _ranges.length; i++)
				{
					// Fade in highlights
					TweenMax.to(_ranges[i], 1, {alpha:1, delay:i * .5});					
				}				
				
				// Animate waves and arrow to sustainable range to start
				TweenMax.to(_arrow, 2.5, {rotation:ARROW_START + ARROW_DISTANCE * .5, ease:Back.easeOut});
				TweenMax.to(_waves, 2.5, {y:WAVES_START - WAVES_DISTANCE * .5, ease:Back.easeOut});
				TweenMax.to(_ranges[1]["back"], 2.5, {alpha:1});				
			}
			else
			{
				for (i = 0; i < _ranges.length; i++)
				{
					_ranges[i].alpha = 0;
					_ranges[i]["back"].alpha = 0;
				}					

				_waves.y = WAVES_START;
				_arrow.rotation = 0;
			}
		}
		
		/**
		 * Sets the arrow postion based on percentage of final rotation
		 * value and also changes which range marker is highlighted
		 */
		public function setArrowRotation(percent:Number, animate:Boolean = false, callback:Function = null, args:Array = null):void
		{
			var value:Number = ARROW_START + ARROW_DISTANCE * percent;
			if (animate)
			{
				if (callback != null)
					TweenMax.to(_arrow, .75, {rotation:value, onComplete:callback, onCompleteParams:args});
				else
					TweenMax.to(_arrow, .75, {rotation:value});
			}
			else
			{
				_arrow.rotation = value;
			}
		}
		
		/**
		 * Sets the waves y position based on percentage
		 * of final position value
		 */
		public function setWavesLevel(percent:Number, animate:Boolean = false):void
		{
			var value:Number = WAVES_START - WAVES_DISTANCE * percent;
			if (animate)
				TweenMax.to(_waves, .75, {y:value});
			else
				_waves.y = value;
		}
		
		public function setRangeHighlight(range:int):void
		{
			for (var i:int = 0; i < _ranges.length; i++)
			{
				var back:MovieClip = _ranges[i]["back"];
				
				if (i == range)
				{
					TweenMax.to(back, .5, {alpha:1});
				}
				else
				{
					if (back.alpha > 0)
						TweenMax.to(back, .5, {alpha:0});
				}
			}			
		}
		
		public function start():void
		{
			_lastTime = getTimer();
			clip.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function stop():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(evt:Event):void
		{
			if (_arrow.rotation <= 0)
				return;
			
			var timePassed:int = getTimer() - _lastTime;
			_lastTime += timePassed;
			_arrow.rotation -= _speed * timePassed / 1000;
		}
		
		
	}
}