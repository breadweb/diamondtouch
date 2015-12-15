package com.breadweb.watergametable
{
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.events.MouseEvent;
	
	public class EndGameState extends AbstractState
	{
		private var _view:GameView;
		private var _control:GameControl;		
		
		public function EndGameState()
		{
			_control = GameControl.getInstance();	
			_view = _control.view;			
		}
		
		public override function enter():void
		{
			super.enter();
			
			_view.setFinishButton(true);
			
			if (CONFIG::DTENABLED)
			{
				_control.diamondTouch.addObserver(_view.finishButton);
				_view.finishButton["onToucherPress"] = onButtonTouch;					
			}
			else
			{
				_view.finishButton.addEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);	
			}			
		}
		
		public override function exit():void
		{
			super.exit();
			
			if (CONFIG::DTENABLED)
			{			
				_control.diamondTouch.removeObserver(_view.finishButton);
				_view.finishButton["onToucherPress"] = null;				
			}
			else
			{
				_view.finishButton.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonClick);	
			}			
		}
		
		public override function update(time:int):void
		{
			super.update(time);
		}
		
		private function onButtonTouch(sender:Object, dtev:DTTouchEventData):void
		{
			resetGame();
		}	
		
		private function onButtonClick(evt:MouseEvent):void
		{
			resetGame();
		}		
		
		private function resetGame():void
		{
			if (_view.finishButton.visible)
			{
				_control.soundManager.play("beep1", "beep1-final");
				_control.fsm.changeState(new PregameState());
				_control.sendGameCue("reset");
			}
		}		
	}
}