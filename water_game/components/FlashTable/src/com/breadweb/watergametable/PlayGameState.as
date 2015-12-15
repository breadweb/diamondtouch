package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;
	import com.breadweb.utils.StringUtils;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	
	public class PlayGameState extends AbstractState
	{
		private var _gameTime:Number;
		private var _dropInterval:Number;
		private var _maxDrops:int;
		private var _waterValue:int;
		private var _minSpeed:int;
		private var _maxSpeed:int;
		private var _drainInterval:int;
		private var _drainAmount:Number;
		
		private var _view:GameView;
		private var _control:GameControl;	
		private var _drops:Vector.<Drop>;
		private var _players:Vector.<Player>;
		private var _incrementing:Vector.<Boolean>;	
		private var _incFunctions:Vector.<Function>;
		private var _timePlayed:int;
		private var _timeLastSpawned:int;
		private var _timeLastDrained:Vector.<int>;
		private var _start:Boolean = false;
		
		public function PlayGameState()
		{
			_control = GameControl.getInstance();	
			_view = _control.view;
			
			_players = _control.playerManager.players;
			_drops = new Vector.<Drop>();
			_incrementing = Vector.<Boolean>([false, false, false, false]);
			_incFunctions = Vector.<Function>([setIncrementing0, setIncrementing1, setIncrementing2, setIncrementing3]);
			
			_gameTime = Number(_control.settings["gametime"]) * 1000;
			_dropInterval = Number(_control.settings["dropinterval"]) * 1000;
			_maxDrops = int(_control.settings["maxdrops"]);
			_waterValue = int(_control.settings["watervalue"]);
			_minSpeed = int(_control.settings["minspeed"]);
			_maxSpeed = int(_control.settings["maxspeed"]);
			_drainInterval = int(_control.settings["draininterval"]);
			_drainAmount = Number(_control.settings["drainamount"]);
			
			_timePlayed = 0;
			_timeLastSpawned = 0;
			_timeLastDrained = Vector.<int>([0, 0, 0, 0]);
		}
		
		public override function enter():void
		{
			super.enter();
			
			_view.changeIntroText("Game begins in 3...", true);
			TweenMax.delayedCall(2, _view.changeIntroText, ["Game begins in 2...", false]);
			TweenMax.delayedCall(3, _view.changeIntroText, ["Game begins in 1...", false]);
			TweenMax.delayedCall(4, _view.changeIntroText, ["GO!", false, 1]);
			TweenMax.delayedCall(5, start);
		}
		
		public override function exit():void
		{
			super.exit();
			
			for (var i:int = 0; i < _incFunctions.length; i++)
			{
				TweenMax.killDelayedCallsTo(_incFunctions[i]);
			}	
			
			for (i = _drops.length - 1; i >= 0; i--)
			{
				if (_drops[i].active)
				{
					destroyDrop(_drops[i]);
				}
			}	
			
			_view.showInstructionsText(false); 
		}
		
		public override function update(time:int):void
		{
			super.update(time);
			
			if (!_start)
				return;
			
			//Console.log("Total drops = " + _drops.length);
			
			// Increment time counters
			_timePlayed += time;
			_timeLastSpawned += time;
			for (var i:int = 0; i < _players.length; i++)
			{
				_timeLastDrained[i] += time;				
			}
			
			// If game time has elasped, switch to end game state
			if (_timePlayed >= _gameTime)
			{
				_control.fsm.changeState(new ResultsGameState());
				return;
			}
			
			// If drop spawn time has been exceed, spawn a new one
			if (_timeLastSpawned >= _dropInterval)
			{
				createDrop();
				_timeLastSpawned = 0;
			}
			
			// Animate all active drops
			for (i = _drops.length - 1; i >= 0; i--)
			{
				if (_drops[i].active)
				{
					_drops[i].y += _drops[i].speed * time / 1000;
					
					// If drop is out of bounds, destroy it
					if (_drops[i].y > GameControl.HEIGHT + _drops[i].view.height)
					{
						destroyDrop(_drops[i]);
					}
				}
			}
			
			// Loop through all players and decrement water level and
			// update arrow and water visuals based on levels but not
			// if a player is in the middle of an increment animation
			for (i = 0; i < _players.length; i++)
			{
				if (!_players[i].ready)
					continue;
				
				if (!_incrementing[i])
				{
					// Decrement water level at interval
					if (_timeLastDrained[i] >= _drainInterval)
					{					
						var rangeId:String = _players[i].updateWater(_drainAmount);
						handleRangeChange(i, rangeId);
						_timeLastDrained[i] = 0;
					}
					
					// Update arrow and waves visual on every frame
					var percent:Number = _players[i].getPercentFilled();
					_players[i].bubble.setArrowRotation(percent);
					_players[i].bubble.setWavesLevel(percent);						
				}
				else
				{
					_timeLastDrained[i] = 0;
				}
			}
		}
		
		// Need a unique function for setting each bubble's
		// incrementing state. These functions are used as 
		// callbacks after tween animations happen so the 
		// normal decremting animation can continue.
		
		public function setIncrementing0(value:Boolean):void
		{
			_incrementing[0] = value;
		}
		public function setIncrementing1(value:Boolean):void
		{
			_incrementing[1] = value;
		}
		public function setIncrementing2(value:Boolean):void
		{
			_incrementing[2] = value;
		}
		public function setIncrementing3(value:Boolean):void
		{
			_incrementing[3] = value;
		}		
		
		private function start():void
		{
			_start = true;
			_view.showInstructionsText(); 
		}
		
		private function getDropByView(dropView:DropView):Drop
		{
			for (var i:int = 0; i < _drops.length; i++)
			{
				if (_drops[i].view == dropView)
					return _drops[i];
			}
			return null;
		}
		
		private function destroyDrop(drop:Drop):void
		{
			for (var i:int = _drops.length - 1; i >= 0; i--)
			{
				if (drop == _drops[i] && drop.active)
				{
					if (CONFIG::DTENABLED)
					{
						_control.diamondTouch.removeObserver(drop.view);						
						drop.view["onToucherPress"] = null;
					}
					drop.destroy();	
					_drops.splice(i, 1);				
					break;
				}
			}
		}
		
		private function createDrop():Boolean
		{
			if (_drops.length >= _maxDrops)
				return false;
			
			// Get random x coordinate and place above the app
			var x:int = Math.floor(Math.random() * (GameControl.WIDTH - 400)) + 200;
			var y:int = -100;
			var speed:Number = Math.ceil(Math.random() * (_maxSpeed - _minSpeed)) + _minSpeed;
			
			var drop:Drop = new Drop(_view.dropArea, x, y, speed);
						
			if (CONFIG::DTENABLED)
			{
				_control.diamondTouch.addObserver(drop.view);
				drop.view["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					touchDrop(drop, dtev.receiver);
				};								
			}
			else
			{
				drop.view.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					touchDrop(drop, _control.currentPlayer);		
				});	
			}			
			
			_drops.push(drop);
			
			//Console.log("Spawning a drop at " + x + ", " + y + " Speed:" + speed);
			
			return true;
		}
		
		private function touchDrop(drop:Drop, player:int):void
		{
			Console.log("Drop touched " + drop);
			
			// Mark player as ready just in case joining mid game
			_players[player].ready = true;
			
			_control.soundManager.play("drip1", "drip" + player);
			
			// Destroy the drop
			if (drop != null)
				destroyDrop(drop);
			else
				Console.log("Null drop??!!");
			
			// Increment the water level for the player and update
			var rangeId:String = _players[player].updateWater(_waterValue);
			handleRangeChange(player, rangeId);
			
			// Note that this player will be doing increment animation
			_incrementing[player] = true;
			
			// Perform animation increment
			var percent:Number = _players[player].getPercentFilled();
			_players[player].bubble.setArrowRotation(percent, true);
			_players[player].bubble.setWavesLevel(percent, true);
			
			TweenMax.killDelayedCallsTo(_incFunctions[player]);					
			TweenMax.delayedCall(1, _incFunctions[player], [false]);
		}	
		
		private function handleRangeChange(player:int, range:String):void
		{
			// If the range changed to high or low, play the corresponding Allie
			// script animation. If a script is already playing, this game cue will be ignored
			switch (range)
			{
				case "Low":
					_control.sendGameCue("play_script|GameLow" + StringUtils.toTitleCase(_players[player].shortName));
					//_players[player].bubble.setRangeHighlight(0);
					break;

				case "Good":
					//_players[player].bubble.setRangeHighlight(1);
					break;			
				
				case "High":
					_control.sendGameCue("play_script|GameHigh" + StringUtils.toTitleCase(_players[player].shortName));
					//_players[player].bubble.setRangeHighlight(2);
					break;

				case "NoChange":
					break;
			}			
		}
	}
}