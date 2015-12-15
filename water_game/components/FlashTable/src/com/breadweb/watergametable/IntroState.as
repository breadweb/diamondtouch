package com.breadweb.watergametable
{
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.events.MouseEvent;
	import flash.profiler.showRedrawRegions;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class IntroState extends AbstractState
	{
		public var skips:int = 0;
		private var _view:GameView;
		private var _control:GameControl;
		
		public function IntroState()
		{
			_control = GameControl.getInstance();
			_view = _control.view;				
		}
		
		public override function enter():void
		{
			super.enter();
			
			_view.setSkipButton(true);
			
			if (CONFIG::DTENABLED)
			{
				_control.diamondTouch.addObserver(_view.skipButton);
				_view.skipButton["onToucherPress"] = onButtonTouch;	
			}
			else
			{
				_view.skipButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);	
			}			
	
			
			_view.introClip.visible = true;
			
			for (var i:int = 0; i < _control.playerManager.players.length; i++)
			{
				var bubble:PlayerBubble = _control.playerManager.players[i].bubble; 
				TweenMax.to(bubble.button, .4, {delay:i * .2, scaleX:0, scaleY:0, ease:Back.easeIn});
			}	
			
			_view.changeIntroText("", false);
			_view.changeSubText("", false);
			
			if (_control.settings["enablelcd"].toString() == "true")
			{
				_control.sendGameCue("start_intro");
			}
			else
			{
				_control.showMeters();
				_control.onGameCue("start_game");				
			}
		}
		
		public override function exit():void
		{
			super.exit();
			
			if (CONFIG::DTENABLED)
			{			
				_control.diamondTouch.removeObserver(_view.skipButton);
				_view.skipButton["onToucherPress"] = null;				
			}
			else
			{
				_view.skipButton.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);	
			}
			
			_view.setSkipButton(false);
		}
		
		public override function update(time:int):void
		{
			super.update(time);
		}
		
		private function onButtonTouch(sender:Object, dtev:DTTouchEventData):void
		{
			skipIntro();
		}	
		
		private function onButtonClick(evt:MouseEvent):void
		{
			skipIntro();
		}		
		
		private function skipIntro():void
		{
			if (_view.skipButton.visible && _view.skipButton.enabled)
			{
				skips++;
				_control.soundManager.play("beep1", "beep1-final");				

				if (skips == 1)
				{
					_control.sendGameCue("skip_intro");
					if (_control.settings["allowinstructionsskip"].toString() == "true")
					{
						_view.advanceSkipButton();
					}
					else
					{
						_view.setSkipButton(false);	
					}
				}

				if (skips > 1)
				{
					_control.showMeters();
					_control.fsm.changeState(new StartGameState());
					_control.sendGameCue("skip_instructions");
				}
			}
		}		
	}
}