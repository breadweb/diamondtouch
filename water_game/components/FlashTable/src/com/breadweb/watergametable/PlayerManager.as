package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;

	/**
	 * Manages player information. Player name, color and bubble vector indexes
	 * correspond to the touch table user numbers.  The following is a map of 
	 * the table user ids and player names
	 *  
	 *             -----------
	 *             |         |
	 *      3      |         |      2
	 * Residential |         | Environment
	 *             |         | 
	 * 			   -----------
	 * 			     1     0
	 *            Farm  Industry
	 * 
	 * 0 = Red, 1 = Blue, 2 = Green, 3 = Yellow 
	 */	
	public class PlayerManager
	{
		public static const RESIDENTIAL:String = "residential";
		public static const FARM:String = "farm";
		public static const INDUSTRY:String = "industry";
		public static const ENVIRONMENT:String = "environment";
		
		public var players:Vector.<Player> = new Vector.<Player>();
		public var types:Vector.<String> = new Vector.<String>();
		public var colors:Vector.<uint> = new Vector.<uint>();
		public var ready:Vector.<int> = new Vector.<int>();
		
		private var _view:GameView;
		private var _control:GameControl;
		
		public function PlayerManager()
		{
			_control = GameControl.getInstance();
			_view = _control.view;
			types.push(INDUSTRY, FARM, ENVIRONMENT, RESIDENTIAL);
			colors.push(0xC74A4A, 0x1D7CBF, 0x5CA347, 0xDECA6D);
		}
		
		public function init():void
		{
			var difficulty:int = int(_control.settings["difficulty"]);
			
			// Initialize player bubbles
			for (var i:int = 0; i < 4; i++)	
			{
				var bubble:PlayerBubble = new PlayerBubble(types[i], _view.getPlayer(types[i]), colors[i]);				
				
				var player:Player = new Player(difficulty);
				player.index = i;
				player.color = colors[i];
				player.type = types[i];
				player.bubble = bubble;
				// Short name is first three letters of type unless four letters or less already				
				player.shortName = (player.type.length > 4) ? player.type.substring(0, 3) : player.type;
				
				players.push(player);
			}
		}
		
		public function setPlayerReady(player:int):int
		{
			players[player].ready = true;
			ready.push(player);
			return ready.length;
		}
		
		public function resetPlayers():void
		{
			ready.splice(0, ready.length);
			for (var i:int = 0; i < players.length; i++)
			{
				players[i].reset();
			}
		}
		
	}
}