package com.breadweb.watergamelcd
{
	import com.breadweb.utils.Console;
	import com.breadweb.utils.FPSCounter;
	
	import flash.system.Capabilities;
	import flash.system.fscommand;

	public class GameCommands
	{
		private var _control:GameControl;
		private var _view:GameView;
		
		public function GameCommands()
		{
			_control = GameControl.getInstance();
			_view = _control.view;
			
			Console.registerCommand(
				"playScript",
				function(name:String):void
				{
					_view.playAllieScript(name);
				},
				"Play one of allie's script animations."
			);
			
			Console.registerCommand(
				"exit",
				function():void
				{
					if (Capabilities.playerType != "StandAlone")
						_control.sendExit();
					else
						fscommand("quit");
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
				"results",
				function(test:String = ""):void
				{
					if (test == "")
					{
						var test:String = "" +
							"industry|Under-consumption!|PostLowInd" + 
							"|farm|Over-consumption!|PostHighFarm" +
							"|environment|Sustainable!|PostGoodEnv" + 
							"|residential|Sustainable!|PostGoodRes" + 
							"|PostOKAll";
					}
					_control.fsm.changeState(new ResultsGameState(test.split("|")));
				},
				"Test the results screen"
			);
		}
	}
}