package com.breadweb.watergametable
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
			_view = _control.view;
			
			Console.registerCommand(
				"exit",
				function():void
				{
					_control.sendExit();
				},
				"Exit the game when runnining in the wrapper executable"
			);
			
			Console.registerCommand(
				"sendCue",
				function(cue:String):void
				{
					_control.sendGameCue(cue);
				},
				"Send a game cue to other flash movies."
			);	
			
			Console.registerCommand(
				"getCue",
				function(cue:String):void
				{
					_control.onGameCue(cue);
				},
				"Simulate receiving a cue from another movie."
			);	
			
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
			
			Console.registerCommand(
				"goTo",
				function(frameLabel:String):void
				{
					_view.goTo(frameLabel);
				},
				"Advance the view to a certain frame label."
			);
			
			Console.registerCommand(
				"rotateArrow",
				function(playerId:int, value:Number):void
				{
					_control.playerManager.players[playerId].bubble.setArrowRotation(value);
				},
				"Set a player bubble arrow to a percent of total rotation value."
			);
			
			Console.registerCommand(
				"reset",
				function():void
				{
					_control.fsm.changeState(new PregameState());
				},
				"Force the inactivity reset timer"
			);
			
			Console.registerCommand(
				"bread",
				function():void
				{
					_control.showMeters();
					_control.onGameCue("start_game");
				},
				"Development shortcut."
			);			
		}
	}
}