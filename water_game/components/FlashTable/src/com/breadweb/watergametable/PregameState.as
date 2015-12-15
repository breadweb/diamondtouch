package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class PregameState extends AbstractState
	{
		private var _view:GameView;
		private var _control:GameControl;
		private var _timeToWait:int = 8000;
		private var _timeWaited:int = 0;
		private var _introTexts:Array;
		private var _availableTexts:Array;
		private var _lastText:String;
		private var _started:Boolean = false;
		
		public function PregameState()
		{
			_control = GameControl.getInstance();
			_control.reset();
			_view = _control.view;
			_introTexts = new Array();
			
			var items:XMLList = _control.config.introTexts.introText;
			_introTexts = new Array();
			_availableTexts = new Array();
			for each(var item:String in items.@value)
			{
				_introTexts.push(item);
			}
		}
		
		public override function enter():void
		{
			super.enter();
			
			_control.playerManager.resetPlayers();
			_view.introClip.visible = false;
			
			for (var i:int = 0; i < _control.playerManager.players.length; i++)
			{
				var bubble:PlayerBubble = _control.playerManager.players[i].bubble;
				bubble.setButtonReady(false);
				bubble.enablePlayMode(false);
				TweenMax.to(bubble.button, .4, {delay:i * .2, scaleX:1, scaleY:1, ease:Back.easeOut});
				
				if (CONFIG::DTENABLED)
				{
					_control.diamondTouch.addObserver(bubble.button);
					bubble.button["onToucherPress"] = onBubbleTouch;
				}
				else
				{
					bubble.button.addEventListener(MouseEvent.MOUSE_DOWN, onBubbleClick);	
				}
			}
			
			_view.changeIntroText("Welcome", true);	
			_view.changeSubText("", false);	
			_view.setFinishButton(false);
			_view.setSkipButton(false);
		}
		
		public override function exit():void
		{
			super.exit();
			
			for (var i:int = 0; i < _control.playerManager.players.length; i++)
			{
				var bubble:PlayerBubble = _control.playerManager.players[i].bubble;
				if (CONFIG::DTENABLED)
				{				
					_control.diamondTouch.removeObserver(bubble.button);
					bubble.button["onToucherPress"] = null;
				}
				else
				{
					bubble.button.removeEventListener(MouseEvent.MOUSE_DOWN, onBubbleClick);	
				}
			}			
		}
		
		public override function update(time:int):void
		{
			super.update(time);
			
			_timeWaited += time;
			
			// Have any of the players clicked the START button?
			var totalReady:int = _control.playerManager.ready.length;
			if (totalReady > 0)
			{
				_control.fsm.changeState(new IntroState());
				return;
			}
			
			// If no players are ready, cycle through attraction messages
			if (_timeWaited >= _timeToWait)
			{
				// Repopulate the pick list if it is empty
				if (_availableTexts.length == 0)
				{
					_availableTexts = _availableTexts.concat(_introTexts);
				}
				
				// Make sure that we don't play the same twice in a row. This
				// could happen only after repopulating the available array
				var introText:String = _lastText;
				while (introText == _lastText)				
				{
					var random:int = Math.floor(Math.random() * _availableTexts.length);
					introText = _availableTexts[random];
				}
				
				_view.changeIntroText(introText);

				_lastText = introText;
				_availableTexts.splice(random, 1);
				_timeWaited = 0;
			}
		}
		
		private function onBubbleTouch(sender:Object, dtev:DTTouchEventData):void
		{
			Console.log("Bubble button touched! " + dtev);
			var player:int = dtev.receiver;
			activatePlayer(player);
		}	
		
		private function onBubbleClick(evt:MouseEvent):void
		{
			Console.log("Bubble button clicked! " + _control.currentPlayer);
			activatePlayer(_control.currentPlayer);
		}

		private function activatePlayer(player:int):void
		{
			// Stop if player is already ready
			if (_control.playerManager.players[player].ready)
				return;
			
			var bubble:PlayerBubble = _control.playerManager.players[player].bubble;			
			
			bubble.setButtonReady(true);
			bubble.pulseRing();
			_control.soundManager.play("beep1", "beep1-" + player);
			var totalReady:int = _control.playerManager.setPlayerReady(player);
			
			// Once minimum number of players is ready, start the countdown
			if (totalReady >= int(_control.settings["minplayers"]))
			{
				if (!_started)
					_timeWaited = 0;
				_started = true;
			}			
		}
		
	}
}