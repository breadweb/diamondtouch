package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameConst;
	import com.breadweb.recycle.GameControl;
	import com.breadweb.recycle.Position;
	import com.breadweb.recycle.SoundControl;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import gs.TweenMax;
	import gs.easing.Bounce;
	
	public class Side
	{
		[Embed(source="/../assets/layout.swf", symbol="side")]
		private const SIDE:Class;			
		
		private var _player:int;
		private var _pos:Position;
		private var _container:MovieClip;
		private var _button:MovieClip;
		private var _introText:MovieClip;
		private var _instructionsText:MovieClip;
		private var _highlight:MovieClip;
		private var _texts:Array;
		private var _currentText:int = -1;
		private var _timer:Timer;
		private var _started:Boolean = false;
		private var _ready:Boolean = false;
		private var _enabled:Boolean = true;
		
		public function Side(player:int, pos:Position, rotation:int, layer:Sprite)
		{
			_player = player;
			_pos = pos;
			
			_container = new SIDE();
			_container.x = _pos.xIn;
			_container.y = _pos.yIn;
			_container.rotation = rotation;
			
			_button = _container.getChildByName("button") as MovieClip;
			_introText = _container.getChildByName("intro") as MovieClip;
			_instructionsText = _container.getChildByName("instructions") as MovieClip;
			_highlight = _container.getChildByName("highlight") as MovieClip;
			
			_texts = GameControl.getInstance().texts;
			
			layer.addChild(_container);
			
			_timer = new Timer(5000);	
			
			setup();
		}
		
		private function setup():void
		{	
			(_button["label"]["txt"] as TextField).text = "START!";	
			TweenMax.to(_button, .1, {autoAlpha:1});
			TweenMax.to(_button["back"], .1, {tint:GameConst.COLORS[_player], autoAlpha:1});
			TweenMax.to(_button["label"], .1, {removeTint:true, autoAlpha:1});
			TweenMax.to(_introText, .1, {tint:GameConst.COLORS[_player], autoAlpha:1});
			TweenMax.to(_highlight, .5, {removeTint:true, alpha:1});
			_instructionsText.alpha = 0;
			_instructionsText.visible = false;	
			if (!_timer.hasEventListener(TimerEvent.TIMER))
			{
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			}
		}
		
		public function moveIn():void
		{
			TweenMax.to(_container, 1, {x:_pos.xIn, y:_pos.yIn});
		}
		
		public function moveOut():void
		{
			TweenMax.to(_container, 1, {x:_pos.xOut, y:_pos.yOut});
		}	
		
		public function removeIntro():void
		{
			TweenMax.to(_button, 1, {autoAlpha:0, overwrite:true});
			TweenMax.to(_highlight, 1, {autoAlpha:0, overwrite:true});
			TweenMax.to(_introText, 1, {autoAlpha:0, overwrite:true});
			TweenMax.to(_instructionsText, 1, {autoAlpha:0, overwrite:true})
		}
		
		public function reset():void
		{
			_enabled = true;
			_started = false;
			_ready = false;
			setup();
			moveIn();			
		}
		
		public function onTouch(player:int):void
		{
			if (!_enabled)
			{
				return;
			}
			
			if (player != _player)
			{
				return;
			}
			
			if (!_started)
			{
				_started = true;
				TweenMax.to(_button["back"], .1, {removeTint:true});
				TweenMax.to(_button["label"], .1, {tint:GameConst.COLORS[_player]});	
				(_button["label"]["txt"] as TextField).text = "PLAY!";
				TweenMax.to(_highlight, .5, {tint:GameConst.COLORS[_player], autoAlpha:.5});
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				TweenMax.to(_introText, .5, {autoAlpha:0});
				TweenMax.to(_instructionsText, 1, {autoAlpha:1});
				SoundControl.getInstance().play("beep1", _player.toString());
				return;
			}
			
			if (!_ready)
			{
				_ready = true;
				_enabled = false;				
				(_button["back"] as MovieClip).visible = false;
				TweenMax.to(_button["label"], .1, {removeTint:true});
				(_button["label"]["txt"] as TextField).text = "READY!";
				(_introText["txt"] as TextField).text = "REMEMBER, STAY SEATED TO PLAY!";
				TweenMax.to(_instructionsText, .5, {autoAlpha:0});
				TweenMax.to(_introText, 1, {autoAlpha:1});
				GameControl.getInstance().registerReady();	
				SoundControl.getInstance().play("beep2", _player.toString());
				return;
			}
		}
		
		// EVENT HANDLERS		
		
		private function onTimer(evt:TimerEvent):void
		{
			_currentText++;
			if (_currentText > _texts.length - 1)
			{
				_currentText = 0;
			}
			(_introText["txt"] as TextField).text = _texts[_currentText];
			TweenMax.to(_introText, 1.5, {
				alpha:1,
				scaleX:1,
				scaleY:1,
				startAt:{alpha:0, scaleX:0, scaleY:0},
				ease:Bounce.easeOut
			});
		}	
		
		// ACCESSORS
		
		public function get player():int
		{
			return _player;
		}
		
		public function get container():MovieClip
		{
			return _container;	
		}
		
		public function get button():MovieClip
		{
			return _button;
		}
		
		public function get ready():Boolean
		{
			return _ready;	
		}	
		
		public function get started():Boolean
		{
			return _started;	
		}			
	}
}