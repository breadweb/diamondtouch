package com.breadweb.recycle
{
	import com.breadweb.recycle.components.Belt;
	import com.breadweb.recycle.components.Building;
	import com.breadweb.recycle.components.Chute;
	import com.breadweb.recycle.components.GameTimer;
	import com.breadweb.recycle.components.Garbage;
	import com.breadweb.recycle.components.Grass;
	import com.breadweb.recycle.components.Score;
	import com.breadweb.recycle.components.Side;
	import com.breadweb.recycle.components.Truck;
	import com.breadweb.utils.Console;
	import com.breadweb.utils.PropertyMonitor;
	import com.circle12.diamondtouch.DiamondTouch;
	import com.circle12.diamondtouch.TouchEvent;
	import com.circle12.diamondtouch.TouchEventData;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class GameControl
	{
		[Embed(source="/../assets/layout.swf", symbol="background")]
		private const BACKGROUND:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="belt")]
		private const BELT:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="logo")]
		private const LOGO:Class;			
		
		private const CONVEYOR_WIDTH:int = 808;
		private const CONVEYOR_HEIGHT:int = 702;
		
		private var _gameLayer:Sprite;
		private var _itemsLayer:Sprite;
		private var _exitLayer:Sprite;
		private var _topLayer:Sprite;
		private var _debugLayer:Sprite;	
		private var _garbageFactory:GarbageFactory;
		private var _garbageItems:Array;
		private var _chutes:Array;
		private var _scores:Array;
		private var _sides:Array;
		private var _grasses:Array;
		private var _trucks:Array;
		private var _buildings:Array;
		private var _belts:Array;
		private var _players:Array;
		private var _conveyor:MovieClip;
		private var _logo:Sprite;
		private var _settings:Dictionary;
		private var _items:Dictionary;
		private var _texts:Array;
		private var _totalToLoad:int;
		private var _totalLoaded:int = 0;
		private var _gameTimer:GameTimer;
		private var _gameStarted:Boolean = false;
		private var _gameEnabled:Boolean = false;
		private var _gameComplete:Boolean = false;
		private var _selectedTruck:int = -1;
		private var _isReloading:Boolean = false;
		private var _reloadTimer:Timer;
		private var _activityTimer:Timer;
		private var _loader:Sprite;
		private var _dt:DiamondTouch = null;
		private static var _instance:GameControl;	
		
		public function GameControl(enforcer:SingletonEnforcer)	{}
		
		public static function getInstance():GameControl
		{
			if (_instance == null)
			{
				_instance = new GameControl(new SingletonEnforcer());
			}
			return _instance;
		}	
		
		private function onDTData(data:String):void
		{	
			_dt.onDTData(data);
		}	
		
		private function onBoundsFromVertical(remoteRectStr:String):void
		{
			// Making sure DTFlash callback function is satisfied
		}
		
		private function onAppClosing(arg:String):void
		{
			// Making sure DTFlash callback function is satisfied
		}
		
		public function init(loader:Sprite):void
		{
			_dt = DiamondTouch.getDiamondTouch();
			loader.addChild(_dt);
			ExternalInterface.addCallback("DTData", onDTData);
			ExternalInterface.addCallback("RemoteTouchWindowBoundsFromVertical", onBoundsFromVertical);
			ExternalInterface.addCallback("AppClosing", onAppClosing);			
			
			loader.stage.addEventListener(TouchEvent.TOUCHDOWN, onTouch);
			loader.stage.addEventListener(TouchEvent.TOUCHUP, onTouch)
			loader.stage.addEventListener(TouchEvent.TOUCHMOVE, onTouch);

			_loader = loader;
			
			_garbageFactory = new GarbageFactory();
			_garbageItems = new Array();
			_players = new Array();
			
			_players.push(new Player(0));
			_players.push(new Player(1));
			_players.push(new Player(2));
			_players.push(new Player(3));
			
			_gameLayer = new Sprite();
			_gameLayer.name = "_gameLayer";		
			_debugLayer = new Sprite();
			_debugLayer.name = "_debugLayer";
			_itemsLayer = new Sprite();
			_itemsLayer.name = "_itemsLayer";
			_exitLayer = new Sprite();
			_exitLayer.name = "_exitLayer";
			_topLayer = new Sprite();
			_topLayer.name = "_topLayer";
			loader.addChild(_gameLayer);
			loader.addChild(_debugLayer);		
			
//			Console.getInstance().init(_debugLayer);
//			PropertyMonitor.getInstance().init(_debugLayer);
			SoundControl.getInstance().init();
			
			loadXML("settings.xml", onSettingsLoaded);
		}
		
		private function loadXML(file:String, onComplete:Function):void	
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest("assets/" + file));
		}
		
		private function setupGame():void
		{
			if (_settings["debug"].toString() == "true")
			{
				_dt.showCursorAndTouchBox(true);
//				_dt.enableTouchEmulation();
			}
			render();
			
			_reloadTimer = new Timer(Number(_settings["dumpspeed"]) * 1000);	
			_reloadTimer.addEventListener(TimerEvent.TIMER, onTimer);
			
			_activityTimer = new Timer(int(_settings["timeout"]) * 1000);
			_activityTimer.addEventListener(TimerEvent.TIMER, onActivityTimer);
			_activityTimer.start();
		}
		
		private function startGame():void
		{
			_gameStarted = true;
			_logo.visible = false;
			_conveyor.visible = true;
			_gameTimer.init();
			
			for (var i:String in _chutes)
			{
				(_chutes[i] as Chute).container.visible = true;
				(_chutes[i] as Chute).start();
				(_buildings[i] as Building).container.visible = true;
				(_belts[i] as Belt).container.visible = true;
			}	
			
			for (var j:int = 0; j < _sides.length; j++)
			{
				(_sides[j] as Side).moveOut();
				(_sides[j] as Side).removeIntro();
				(_grasses[j] as Grass).moveOut();
//				if ((_sides[j] as Side).started)
//				{
					(_scores[j] as Score).moveIn();
//				}
			}
			
			// Get both garbage trucks to come in and start dumping to start off
			_isReloading = true;
			TweenMax.delayedCall(1.5, (_trucks[0] as Truck).driveIn, [startReload]);
			TweenMax.delayedCall(1.5, (_trucks[1] as Truck).driveIn, [startReload]);
			
			// Watch total garbage items for game start countdown
			_loader.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			PropertyMonitor.getInstance().addSubject("Garbage Items", garbageItems, "length"); 			
			PropertyMonitor.getInstance().addSubject("Total Score", (_players[1] as Player), "totalScore"); 			
		}
		
		private function enableGame():void
		{
			Console.getInstance().log("enableGame!", this);
			_gameEnabled = true;
			for (var i:int = 0; i < _garbageItems.length; i++)
			{
				(_garbageItems[i] as Garbage).enabled = true;
			}			
		}
		
		private function startTimer():void
		{
			_loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			_gameTimer.start();
		}
		
		private function stopGame():void
		{
			_gameEnabled = false;	
			_gameComplete = true;
			for (var i:int = 0; i < _garbageItems.length; i++)
			{
				(_garbageItems[i] as Garbage).enabled = false;
			}
			for (i = 0; i < _scores.length; i++)
			{
				var finalText:String = "You didn't sort any items. Try again!";
				var totalScore:int = (_players[i] as Player).totalScore;
				if (totalScore == 1)
				{
					finalText = "You sorted one item. Good work!";
				}
				if (totalScore > 1)
				{
					finalText = "You sorted " + totalScore + " items. Great job!"; 
				}
				Console.getInstance().log("Player " + i + " scored " + totalScore);
				(_scores[i] as Score).toggleFinal(true, finalText);
			}
		}
		
		private function resetGame():void
		{
			Console.getInstance().log("Resetting game. Game started already = " + _gameStarted, this);
			
			SoundControl.getInstance().stopAll();
			
			for (var j:int = 0; j < _sides.length; j++)
			{
				(_sides[j] as Side).reset();
				(_grasses[j] as Grass).moveIn();
				(_scores[j] as Score).reset();
			}	
			
			if (_gameStarted)
			{
				for (var i:String in _chutes)
				{
					(_chutes[i] as Chute).container.visible = false;
					(_chutes[i] as Chute).stop();
					(_buildings[i] as Building).container.visible = false;
					(_buildings[i] as Building).reset();					
					(_belts[i] as Belt).container.visible = false;
				}	
				for (j = _garbageItems.length - 1; j >= 0; j--)
				{
					var garbage:Garbage = (_garbageItems[j] as Garbage);
//					garbage.dragging.enabled = false;
					garbage.cleanup();
					removeGarbage(garbage);
				}
				for (j = 0; j < _trucks.length; j++)
				{
					(_trucks[j] as Truck).reset((_isReloading && j == _selectedTruck));
				}
				for (j = 0; j < _players.length; j++)
				{
					(_players[j] as Player).reset();
				}				
				
				_logo.visible = true;
				_conveyor.visible = false;
				
				if (_loader.hasEventListener(Event.ENTER_FRAME))
				{
					_loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				}
				
				_gameTimer.container.visible = false;
				_gameTimer.stop();
				_gameTimer.set("ready");
				
				_reloadTimer.stop();
				
				TweenMax.killAllDelayedCalls();				
			}
			
			_gameEnabled = false;						
			_gameStarted = false;
			_gameComplete = false;
			_isReloading = false;
			_selectedTruck = -1;	
		}
		
		private function render():void
		{
			_chutes = new Array();
			_scores = new Array();		
			_buildings = new Array();
			_belts = new Array();
			_trucks = new Array();
			_sides = new Array();
			_grasses = new Array();
			
			var bg:Bitmap = new BACKGROUND();
			_gameLayer.addChild(bg);
			
			_sides.push(new Side(0, new Position(205, 835, 145, 915), 0, _gameLayer));
			_sides.push(new Side(1, new Position(1185, 845, 1245, 925), -90, _gameLayer));
			_sides.push(new Side(2, new Position(1195, 215, 1255, 135), 180, _gameLayer));
			_sides.push(new Side(3, new Position(215, 205, 155, 125), 90, _gameLayer));
			
			_grasses.push(new Grass("tall", new Position(1293, 0, 1313, 0), 0, _gameLayer));
			_grasses.push(new Grass("tall", new Position(107, 1050, 87, 1050), 180, _gameLayer));
			_grasses.push(new Grass("wide", new Position(1400, 1050, 1400, 1070), 180, _gameLayer));
			_grasses.push(new Grass("wide", new Position(0, 0, 0, -20), 0, _gameLayer));			

			_logo = new LOGO();
			_logo.x = 700;
			_logo.y = 525;
			_gameLayer.addChild(_logo);			
			
			_conveyor = new BELT();
			_conveyor.name = "conveyor";
			_conveyor.x = 286;
			_conveyor.y = 182;
			_conveyor.visible = false;
			_gameLayer.addChild(_conveyor);
			
			_gameTimer = new GameTimer(700, 525, _gameLayer, stopGame);

			_gameLayer.addChild(_itemsLayer);			
			
			_belts[GameConst.GLASS] = new Belt(GameConst.GLASS, 471, 131, -1, 1, _gameLayer);
			_belts[GameConst.PLASTIC] = new Belt(GameConst.PLASTIC, 928, 131, 1, 1, _gameLayer);
			_belts[GameConst.METAL] = new Belt(GameConst.METAL, 471, 932, -1, -1, _gameLayer);
			_belts[GameConst.PAPER] = new Belt(GameConst.PAPER, 928, 932, 1, -1, _gameLayer);
		
			_gameLayer.addChild(_exitLayer);
			
			_chutes[GameConst.GLASS] = new Chute(GameConst.GLASS, 406, 271, _gameLayer);
			_chutes[GameConst.PLASTIC] = new Chute(GameConst.PLASTIC, 775, 271, _gameLayer);
			_chutes[GameConst.METAL] = new Chute(GameConst.METAL, 406, 560, _gameLayer);
			_chutes[GameConst.PAPER] = new Chute(GameConst.PAPER, 775, 560, _gameLayer);
			
			_trucks.push(new Truck(-272, 501, 94, 2, 1, _gameLayer));
			_trucks.push(new Truck(1548, 501, 1162, 1, 1, _gameLayer));
			
			_scores.push(new Score(0, new Position(700, 964, 700, 1050), 700, 887, 0, _gameLayer));
			_scores.push(new Score(1, new Position(1314, 525, 1400, 525), 1237, 525, 270, _gameLayer));
			_scores.push(new Score(2, new Position(700, 86, 700, -10), 700, 163, 180, _gameLayer));
			_scores.push(new Score(3, new Position(86, 525, 0, 525), 163, 525, 90, _gameLayer));
			
			_buildings[GameConst.GLASS] = new Building(GameConst.GLASS, 193, 160, 180, _gameLayer);
			_buildings[GameConst.PLASTIC] = new Building(GameConst.PLASTIC, 1207, 127, 180, _gameLayer);
			_buildings[GameConst.METAL] = new Building(GameConst.METAL, 214, 906, 0, _gameLayer);
			_buildings[GameConst.PAPER] = new Building(GameConst.PAPER, 1205, 906, 0, _gameLayer);
			
			_gameLayer.addChild(_topLayer);
			

		}	
		
		/**
		 * Get all the initial garbage on the belt
		 */
		private function initGarbage():void
		{
			var itemCount:int = int(_settings["maxitems"]);
			
			for (var i:int = 0; i < itemCount; i++)
			{
				var garbage:Garbage = addGarbage();
				placeGarbage(garbage); // Place on a random spot on the belt
			}			
		}
		
		private function addGarbage():Garbage
		{
			// Get a random garbage type from all loaded types
			var rnd:int = Math.floor(Math.random() * 4);
			var type:String = GameConst.TYPES[rnd];
			
			// Get a random variant of the selected type
			var subTypes:Array = _items[type] as Array;
			rnd = Math.floor(Math.random() * subTypes.length);
			
			var garbageType:GarbageType = (_items[type] as Array)[rnd] as GarbageType;
			var bounds:Rectangle = new Rectangle(_conveyor.x, _conveyor.y, CONVEYOR_WIDTH, CONVEYOR_HEIGHT);
			var garbage:Garbage = _garbageFactory.createGarbage(garbageType);
			
			_garbageItems.push(garbage);
			
			garbage.init(_itemsLayer, bounds);
			
			return garbage;
		}
		
		/**
		 * Places garbage on a random spot on the conveyor belt
		 * 
		 * param garbage The garbage item to place
		 * param side The side of the conveyor belt, or -1 for random
		 * param isCentered Should garbage be put in center of side, or random
		 */
		public function placeGarbage(garbage:Garbage, side:int = -1, isCentered:Boolean = false):void
		{
			if (side == -1)
			{
				side = Math.floor(Math.random() * 4);
			}
			var x:int = 0;
			var y:int = 0;
			
			switch (side) 
			{
				case 0: // Left
					x = _conveyor.x;
					if (isCentered)
					{
						y = CONVEYOR_HEIGHT / 2 - garbage.container.height + _conveyor.y;	
					}
					else
					{
						y =  Math.floor(Math.random() * (CONVEYOR_HEIGHT - garbage.container.height)) + _conveyor.y;
					}
					garbage.movement.setDirection("down");
					break;
				case 1: // Right
					x = _conveyor.x + CONVEYOR_WIDTH - garbage.container.width;
					if (isCentered)
					{
						y = CONVEYOR_HEIGHT / 2 - garbage.container.height + _conveyor.y;
					}
					else
					{
						y =  Math.floor(Math.random() * (CONVEYOR_HEIGHT - garbage.container.height)) + _conveyor.y;
					}
					garbage.movement.setDirection("up");
					break;
				case 2: // Top
					if (isCentered)
					{
						x = CONVEYOR_WIDTH / 2 - garbage.container.width + _conveyor.x;
					}
					else
					{
						x = Math.floor(Math.random() * (CONVEYOR_WIDTH - garbage.container.width)) + _conveyor.x;
					}
					y = _conveyor.y;
					garbage.movement.setDirection("left");
					break;
				case 3: // Bottom
					if (isCentered)
					{
						x = CONVEYOR_WIDTH / 2 - garbage.container.width + _conveyor.x;
					}
					else
					{
						x = Math.floor(Math.random() * (CONVEYOR_WIDTH - garbage.container.width)) + _conveyor.x;
					}					
					y = _conveyor.y + CONVEYOR_HEIGHT - garbage.container.height;
					garbage.movement.setDirection("right");
					break;				
			}
			
			// Adjust for centered offset
			x += garbage.container.width / 2;
			y += garbage.container.height / 2;			

			garbage.moveTo(x, y);
			garbage.startMoving();
		}
		
		public function removeGarbage(garbage:Garbage):void
		{	
			for (var i:int = 0; i < _garbageItems.length; i++)
			{
				if (_garbageItems[i] == garbage)
				{
					_garbageItems.splice(i, 1);
					garbage.container.parent.removeChild(garbage.container);
				}
			}
		}
		
		/**
		 * Move garbage to a specific layer in the display tree or swap
		 * between the top layer and items layer if no layer is specified
		 * 
		 * @param garbage The garbage object
		 * @param layer The layer to move the garbage container to
		 */
		public function restackGarbage(garbage:Garbage, layer:Sprite = null):void
		{
			if (layer == null)
			{
				layer =(garbage.container.parent == _topLayer) ? _itemsLayer : _topLayer;
			}
			layer.addChild(garbage.container);
		}
		
		public function registerHit(garbage:Garbage, chute:Chute):void
		{
			// Put garbage in the chute
			garbage.sendDownChute(chute);
			
			// Show color match on chute
			chute.showMatch(GameConst.COLORS[garbage.collectedBy] as uint);	
			
			// Play sound
			SoundControl.getInstance().play(chute.type);
		}
		
		/**
		 * After a garbage item finishes going down the chute
		 */
		public function completeGarbage(garbage:Garbage, chute:Chute):void
		{	
			var type:String = garbage.garbageType.type;
			var belt:Belt = _belts[type] as Belt;
			
			// Figure out start and ending animation points
			var startClip:MovieClip = belt.container.getChildByName("start") as MovieClip;
			var endClip:MovieClip = belt.container.getChildByName("end") as MovieClip;
			var startPoint:Point = new Point(startClip.x + startClip.width / 2, startClip.y + startClip.height / 2);
			var endPoint:Point = new Point(endClip.x + endClip.width / 2, endClip.y + endClip.height / 2);
			startPoint = startClip.localToGlobal(startPoint);
			endPoint = endClip.localToGlobal(endPoint);

			// Move to exit layer for proper depth
			_exitLayer.addChild(garbage.container);
			
			// Send to factory
			garbage.reset();
			garbage.resize(.75);
			garbage.moveTo(startPoint.x, startPoint.y);
			garbage.sendToBuilding(endPoint.x, endPoint.y);
		}

		/**
		 * After a garbage item gets to the factory building
		 */
		public function collectGarbage(garbage:Garbage):void
		{
			var type:String = garbage.garbageType.type;
			
			// Increment the score for the type matched for the current player
			var player:Player = _players[garbage.collectedBy] as Player;
			var p:Player;
			player.scores[type] += 1;
			
			// Get total for all players for that type
			var total:int = 0;
			for (var i:int = 0; i < _players.length; i++)
			{
				p = _players[i] as Player;
				total += p.scores[type];
			}
			
			// Update all scores with the updated team total for the type
			for (i = 0; i < _players.length; i++)
			{
				p = _players[i] as Player; 
				var output:String = p.scores[type] + "\n" + total;
				(_scores[p.id] as Score).setScore(type, output);
			}		
			
			SoundControl.getInstance().play("collect");			
			
			var building:Building = _buildings[type] as Building;
			TweenMax.to(building.container, .25, {
				scaleX:1.15,
				scaleY:1.15,
				glowFilter:{color:0xFFFFFF, alpha:100, blurX:50, blurY:50}});
			TweenMax.to(building.container, .5, {
				scaleX:1, 
				scaleY:1, 
				glowFilter:{alpha:0, blurX:0, blurY:0, remove:true}, 
				delay:.25, 
				ease:Back.easeOut});
			
			// Stack up finished product
			(_buildings[type] as Building).stackFinished(total);
			
			removeGarbage(garbage);
			checkReload();
		}
		
		/**
		 * Called each time a piece of garbage is removed to see
		 * if we should be reloading garbage on the main belt
		 */
		private function checkReload():void
		{
			// If we're not reloading...
			if (!_isReloading)
			{
				if (_garbageItems.length <=  int(_settings["minitems"]))
				{
					_isReloading = true;
					_selectedTruck = (_selectedTruck == 0) ? 1 : 0;
					(_trucks[_selectedTruck] as Truck).driveIn(startReload);					
				}
			}
		}
		
		private function startReload():void
		{
			Console.getInstance().log("startReload!", this);
			if (!_reloadTimer.running)
			{
				_reloadTimer.start();				
			}
		}
		
		private function stopReload():void
		{
			Console.getInstance().log("stopReload!", this);
			_reloadTimer.stop();
			_isReloading = false;			
			if (_selectedTruck == -1)
			{
				for (var i:int = 0; i < _trucks.length; i++)
				{
					(_trucks[i] as Truck).driveOut();
				}
			}
			else 
			{
				(_trucks[_selectedTruck] as Truck).driveOut();
			}			
		}
		
		private function resetActivityTimer():void
		{
			var bool:Boolean = (_activityTimer == null);
			_activityTimer.reset();
			_activityTimer.start();
		}		
		
		// EVENT HANDLERS
		
		private function onTouch(evt:TouchEvent):void
		{
			Console.getInstance().log(evt.dtev.receiver + " " + evt.type, this);
			
			// Any touch resets the timeout timer
			resetActivityTimer();			
			
			var dtev:TouchEventData = evt.dtev;
			var i:int;
			var point:Point;
			
			// If game hasn't started, touch events should be focused on start/play buttons
			if (!_gameStarted && evt.type == TouchEvent.TOUCHDOWN)
			{
				for (i = 0; i < _sides.length; i++)
				{
					// Sides are rotated and repositioned so need
					// to convert touch coordinates to local
					var side:Side = _sides[i] as Side;
					point = new Point(dtev.x, dtev.y);
					side.button.globalToLocal(point);
					
					Console.getInstance().log(dtev.x + ", " + dtev.y + " " + point.x + ", " + point.y, this);
					
					if (side.button.hitTestPoint(point.x, point.y) && i == dtev.receiver)
					{
						side.onTouch(dtev.receiver);
						return;
					}
				}
				return;
			}
			
			// If game is complete, touch events should be focused on play again buttons
			if (_gameComplete && evt.type == TouchEvent.TOUCHDOWN)
			{
				for (i = 0; i < _scores.length; i++)
				{
					// Scores are rotated and repositioned so need
					// to convert touch coordinates to local
					var score:Score = _scores[i] as Score;
					point = new Point(dtev.x, dtev.y);
					score.button.globalToLocal(point);
					if (score.button.hitTestPoint(point.x, point.y) && score.player == dtev.receiver)
					{
						SoundControl.getInstance().play("beep2", i.toString());
						TweenMax.delayedCall(1, resetGame, []);
						return;
					}
				}
				return;
			}
			
			// If we made it to this point, we're either selecting, 
			// deselecting or moving pieces of garbage
			
			var player:Player = _players[dtev.receiver] as Player;
			
			// On a touch up, we need to release the piece of garbage that
			// we were touching and ask it to test for a match
			if (evt.type == TouchEvent.TOUCHUP)
			{
				player.garbage.onTouchUp(dtev.receiver);
				player.garbage = null;
				return;
			}
			
			// On a touch down, we need to return the top most piece of
			// garabe hit to start dragging
			
			if (evt.type == TouchEvent.TOUCHDOWN && (_players[dtev.receiver] as Player).garbage == null)
			{
				for (i = 0; i < _garbageItems.length; i++)
				{
					var garbage:Garbage = _garbageItems[i] as Garbage;
					
					// Garbage items have global x and y coordinates because
					// their parent shares the same top left origin as the stage
					if (garbage.container.hitTestPoint(dtev.x, dtev.y))
					{
						player.garbage = garbage;
						garbage.onTouchDown();
						return;
					}
				}	
			}
			
			if (evt.type == TouchEvent.TOUCHMOVE)
			{
				for (i = 0; i < _players.length; i++)
				{
					// If a player has a garbage reference, they are dragging
					// one so move it
					player = _players[evt.dtev.receiver] as Player;
					if (player.garbage != null)
					{
//						Console.getInstance().log("DRAG " + evt.dtev.receiver, this);
						player.garbage.moveTo(evt.dtev.x, evt.dtev.y, false);
					}
				}				
			}
//			Console.getInstance().log("TouchEvent: " + evt.toString(), this);
		}		
		
		private function onEnterFrame(evt:Event):void
		{
			var itemChunk:int = int(_settings["maxitems"]) / 3; 
			var totalItems:int = _garbageItems.length;
			if (totalItems < itemChunk)
			{
				_gameTimer.set("ready");
				return;
			}
			if (totalItems < itemChunk * 2)
			{
				_gameTimer.set("set");
				return;
			}	
			if (totalItems < itemChunk * 3)
			{
				_gameTimer.set("go");
				enableGame();
				return;
			}
			startTimer();
			
		}
		
		private function onActivityTimer(evt:TimerEvent):void
		{
			Console.getInstance().log("Activity Timeout!");
			resetGame();
		}
		
		private function onTimer(evt:TimerEvent):void
		{
			var garbage:Garbage;			
			
			// If we don't have a selected truck, all trucks are on screen and should be dumping
			// Otherwise, we only should be dumping from one side at a time
			if (_selectedTruck == -1)
			{
				for (var i:int = 0; i < _trucks.length; i++)
				{
					garbage = addGarbage();
					placeGarbage(garbage, i, true);
				}
			}
			else 
			{
				garbage = addGarbage();
				placeGarbage(garbage, _selectedTruck, true);
			}
			
			if (_garbageItems.length >=  int(_settings["maxitems"]))
			{
				stopReload();
			}
		}
		
		private function onSettingsLoaded(evt:Event):void
		{
			var xml:XML = new XML(evt.target.data);
			
			_settings = new Dictionary();
			for each (var setting:XML in (xml.settings as XMLList).children()) {
				_settings[setting.attribute("name").toString()] = setting.attribute("value").toString();
			}
			
			_texts = new Array();
			for each (var text:XML in (xml.texts as XMLList).children()) {
				_texts.push(text.attribute("value").toString());
			}			
			
			_items = new Dictionary();
			_items["glass"] = new Array();
			_items["metal"] = new Array();
			_items["paper"] = new Array();
			_items["plastic"] = new Array();
			
			var itemList:XMLList = xml.items;
			_totalToLoad = itemList.children().length();
			Console.getInstance().log("Total items to load: " + _totalToLoad, this);
			
			for each (var item:XML in itemList.children()) {
				Console.getInstance().log("Adding " + item.@name + " to " + item.@type, this);
				var type:String = item.@type;
				(_items[type] as Array).push(new GarbageType(item, registerLoaded));
			}			
		}
		
		// CALLBACKS
		
		/**
		 * Called by all garbage types after they have loaded their external
		 * image file
		 */
		private function registerLoaded():void
		{
			_totalLoaded++;
			if (_totalLoaded >= _totalToLoad)
			{
				Console.getInstance().log("Loaded all external items!");
				setupGame();
			}
		}
		
		public function registerReady():void
		{
			var totalReady:int = 0;
			var totalStarted:int = 0;
			for (var i:int = 0; i < _sides.length; i++)
			{
				if ((_sides[i] as Side).ready)
				{
					totalReady++;
				}
				if ((_sides[i] as Side).started)
				{
					totalStarted++;
				}				
			}
			Console.getInstance().log("Players: Started = " + totalStarted + " Ready = " + totalReady, this);
			if (totalStarted >= int(_settings["minplayers"]))
			{
				startGame();
			}
		}
			
		// ACCESSORS
		
		public function get chutes():Array
		{
			return _chutes;
		}
	
		public function get texts():Array
		{
			return _texts;
		}
		
		public function get settings():Dictionary
		{
			return _settings;
		}
		
		public function get garbageItems():Array
		{
			return _garbageItems;
		}	
		
		public function get gameEnabled():Boolean
		{
			return _gameEnabled;
		}		
	}
}

class SingletonEnforcer {}