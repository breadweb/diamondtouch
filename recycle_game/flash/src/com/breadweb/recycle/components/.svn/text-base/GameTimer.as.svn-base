package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameControl;
	import com.breadweb.utils.Console;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import gs.TweenLite;
	import gs.TweenMax;
	import gs.easing.Linear;
	
	public class GameTimer
	{
		[Embed(source="/../assets/layout.swf", symbol="timer")]
		private const GAME_TIMER:Class;	
		
		private var _container:MovieClip;
		private var _timeClip:MovieClip;
		private var _timeClip2:MovieClip;
		private var _timer:Timer;
		private var _startTime:int;
		private var _gameTime:int;
		private var _spins:int;
		private var _lastState:String;
		private var _onEnd:Function;
		private var _onEndParms:Array;
		
		public function GameTimer(xpos:int, ypos:int, layer:Sprite, onEnd:Function = null, onEndParms:Array = null)
		{
			_container = new GAME_TIMER();
			_container.x = xpos;
			_container.y = ypos;
			_container.visible = false;
			layer.addChild(_container);
			
			_timeClip = _container.getChildByName("text") as MovieClip;
			_timeClip2 = _container.getChildByName("text2") as MovieClip;
			_timeClip.visible = false;
			
			_gameTime = GameControl.getInstance().settings["gametime"];
			_spins = GameControl.getInstance().settings["spins"];
			
			Console.getInstance().log(_gameTime + " " + _spins, this);
			
			_onEnd = onEnd;
			_onEndParms = onEndParms;
			
			_timer =  new Timer(500);
		}
		
		public function init():void
		{
			TweenLite.to(_timeClip, _gameTime * 2, {rotation:_spins * -360, ease:Linear.easeNone});	
			TweenLite.to(_timeClip2, _gameTime * 2, {rotation:_spins * -360, ease:Linear.easeNone});	
			_container.visible = true;
		}
		
		public function set(state:String):void
		{
			if (state == _lastState)
			{
				return;
			}
			
			switch (state)
			{
				case "ready":
					(_timeClip2["txt"] as TextField).text = "Get\nReady!";
					_timeClip2.visible = true;
					_timeClip.visible = false;					
					TweenMax.to(_timeClip2, 1.25, {alpha:1, startAt:{alpha:0}});
					break;
				case "set":
					(_timeClip2["txt"] as TextField).text = "Get\nSet!";
					TweenMax.to(_timeClip2, 1.25, {alpha:1, startAt:{alpha:0}});
					break;
				case "go":
					(_timeClip["txt"] as TextField).text = "GO!";
					_timeClip2.visible = false;
					_timeClip.visible = true;
					TweenMax.to(_timeClip, .25, {alpha:1, yoyo:0, startAt:{alpha:0}});
					break;
			}
			
			_lastState = state;
		}
		
		public function start():void
		{
			(_timeClip["txt"] as TextField).text = _gameTime.toString();
			TweenMax.to(_timeClip, 1.25, {alpha:1, startAt:{alpha:0}});
			
			_startTime = getTimer();
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		public function stop():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.stop();
		}
		
		// EVENT HANDLERS
		
		private function onTimer(evt:TimerEvent):void
		{
			var elapsed:int = (getTimer() - _startTime) / 1000;
			var display:int = _gameTime - elapsed;
			if (display < 0)
			{
				display = 0;
			}
			(_timeClip["txt"] as TextField).text = display.toString();
			
			if (elapsed >= _gameTime)
			{
				stop();
				(_timeClip2["txt"] as TextField).text = "Game\nOver!";
				_timeClip2.visible = true;
				_timeClip.visible = false;				
				if (_onEnd != null)
				{
					_onEnd.apply(null, _onEndParms);
				}
			}
		}
		
		public function get container():MovieClip
		{
			return _container;	
		}
	}
}