package com.breadweb.watergametable
{
	import com.breadweb.state.IState;
	import com.breadweb.utils.StringUtils;
	
	public class ResultsGameState extends AbstractState
	{
		private var _view:GameView;
		private var _control:GameControl;		
		
		public function ResultsGameState()
		{
			_control = GameControl.getInstance();
			_view = _control.view;			
		}
		
		public override function enter():void
		{
			super.enter();
			
			_view.changeIntroText("Game Over!", false);
			
			if (_control.settings["enablelcd"].toString() != "true")
			{
				_control.onGameCue("end_game");
				return;
			}
			
			// Compile the end game stats and send in the game cue
			var players:Vector.<Player> = _control.playerManager.players;
			var cue:String = "show_results";
			var totalBad:int = 0;
			var totalGood:int = 0;
			var totalReady:int = 0;
			for (var i:int = 0; i < players.length; i++)
			{
				if (players[i].ready == true)
				{
					totalReady++;
					var index:int = players[i].getRangeIndex();
					
					if (index == 0 || index == 2)
						totalBad++;
					
					if (index == 1)
						totalGood++;
					
					cue += "|" + players[i].type +
						"|" + players[i].getRangeDesc(index) +
						"|Post" + players[i].getRangeType(index) + StringUtils.toTitleCase(players[i].shortName);
				}
			}
			
			var final:String = "PostOKAll";
			if (totalBad == totalReady)
				final = "PostBadAll";
			if (totalGood == totalReady)
				final = "PostGoodAll";
			
			cue += "|" + final;
			
			_control.sendGameCue(cue);
		}
		
		public override function exit():void
		{
			super.exit();
		}
		
		public override function update(time:int):void
		{
			super.update(time);
		}
	}
}