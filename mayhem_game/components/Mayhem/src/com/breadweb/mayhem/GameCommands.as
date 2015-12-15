package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.breadweb.utils.FPSCounter;

	public class GameCommands
	{
		private var _control:GameControl;
		private var _view:GameView;
		
		public function GameCommands()
		{
			_control = GameControl.getInstance();

			Console.registerCommand(
				"exit",
				function():void
				{
					_control.sendExit();
				},
				"Exit the game when runnining in the wrapper executable"
			);
			
			Console.registerCommand(
				"showMessage",
				function(message:String):void
				{
					_control.view.showMessage(message);
				},
				"Test showing the popup message"
			);	
			
			Console.registerCommand(
				"hideMessage",
				function():void
				{
					_control.view.hideMessage();
				},
				"Test hiding the popup message"
			);			
			
			/*
			Console.registerCommand(
				"showFPS",
				function(show:int):void
				{
					var fps:FPSCounter;
					if (show == 1)
					{
						fps = _view.getChildByName("fpscounter") as FPSCounter;
						if (fps == null)
						{
							fps = new FPSCounter();
							fps.init(_view.debugLayer);
						}
					}
					else
					{
						fps = _view.getChildByName("fpscounter") as FPSCounter;
						if (fps != null)
							fps.exit();
					}
				},
				"Show or hide the FPS counter"
			);
			*/
		}
	}
}