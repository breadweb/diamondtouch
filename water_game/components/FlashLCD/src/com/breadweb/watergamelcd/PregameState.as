package com.breadweb.watergamelcd
{
	import com.breadweb.state.IState;
	import com.breadweb.utils.Console;
	
	public class PregameState implements IState
	{
		private var _view:GameView;
		private var _control:GameControl;
		private var _timeToWait:int = 10000;
		private var _timeWaited:int = 0;
		private var _quips:Array;
		private var _availableQuips:Array;
		private var _lastQuip:String;
		
		public function PregameState()
		{
			_control = GameControl.getInstance();
			_view = _control.view;
			_quips = new Array();
			
			var items:XMLList = _control.captions.caption.(@id.indexOf("pregame") > -1);
			_quips = new Array();
			_availableQuips = new Array();
			for each(var item:String in items.@id)
			{
				_quips.push(item);
			}
		}
		
		public function enter():void
		{
			_view.setScene(GameView.SCENE_NORMAL);
			_view.setCaption("");
			_view.fadeIn();
		}
		
		public function exit():void
		{
		}
		
		public function update(time:int):void
		{
			_timeWaited += time;
			if (_timeWaited >= _timeToWait)
			{
				// Repopulate the pick list if it is empty
				if (_availableQuips.length == 0)
				{
					_availableQuips = _availableQuips.concat(_quips);
				}				
				
				// Make sure that we don't play the same twice in a row. This
				// could happen only after repopulating the available array
				var quip:String = _lastQuip;
				while (quip == _lastQuip)
				{
					var random:int = Math.floor(Math.random() * _availableQuips.length);
					quip = _availableQuips[random];
				}
		
				_view.playAllieScript(quip);
				
				_lastQuip = quip;
				_availableQuips.splice(random, 1);
				_timeWaited = 0;				
			}
		}
	}
}