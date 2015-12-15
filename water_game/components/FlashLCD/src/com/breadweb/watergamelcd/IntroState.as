package com.breadweb.watergamelcd
{
	import com.breadweb.state.IState;
	import com.breadweb.utils.Console;
	
	import flash.events.Event;
	
	public class IntroState implements IState
	{
		private var _view:GameView;
		private var _control:GameControl;		
		
		public function IntroState()
		{
			_control = GameControl.getInstance();
			_view = _control.view;		
		}
		
		public function enter():void
		{
			_control.loader.addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}
		
		public function exit():void
		{
			if (_control.loader.hasEventListener(Event.ENTER_FRAME))
				_control.loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function update(time:int):void
		{
		}
		
		private function onEnterFrame(evt:Event):void
		{
			// Wait for current alligator animation to complete
			if (_view.isAlliePlaying())
				return;
			
			_control.loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_view.playAllieScript("gameintro1");
		}
	}
}