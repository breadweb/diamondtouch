package com.breadweb.watergametable
{
	import com.breadweb.state.StateMachine;
	import com.breadweb.utils.Console;
	import com.breadweb.utils.FPSCounter;
	import com.breadweb.utils.SoundManager;
	import com.circle12.diamondtouch.DTTouchEvent;
	import com.circle12.diamondtouch.DiamondTouch;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.fscommand;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import gs.TweenMax;

	public class GameControl
	{
		private static var _instance:GameControl;
		public static var WIDTH:int = 1400;
		public static var HEIGHT:int = 1050;
		
		private var _loadTasks:int = 1;
		private var _loadedTasks:int = 0;
		private var _lastTime:int;
		private var _totalIdleTime:int;
		private var _metersShown:Boolean = false;
		public var currentPlayer:int = 0; // Only used when DT table not enabled
		public var diamondTouch:DiamondTouch = null;		
		public var settings:Dictionary;		
		public var fsm:StateMachine;		
		public var view:GameView;
		public var config:XML;
		public var loader:Sprite;
		public var playerManager:PlayerManager;	
		public var soundManager:SoundManager;
		
		public function GameControl(enforcer:SingletonEnforcer)	{}
		
		public static function getInstance():GameControl
		{
			if (_instance == null)
			{
				_instance = new GameControl(new SingletonEnforcer());
			}
			return _instance;
		}
		
		public function init(loader:Sprite):void
		{
			this.loader = loader;
			
			// Initialize state machine
			_lastTime = getTimer();
			loader.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			fsm = new StateMachine();
			
			// Initialize managers
			soundManager = new SoundManager();
			soundManager.init("assets/");			
			
			// Load up external configuration xml file
			var configLoader:URLLoader = new URLLoader();
			configLoader.load(new URLRequest("assets/table_config.xml"));
			configLoader.addEventListener(Event.COMPLETE, onConfigLoaded);			
		}
		
		private function initGame():void
		{
			view = new GameView();
			loader.addChild(view);

			if (settings["console"].toString() == "true")
			{			
				Console.attach(view.debugLayer, Console.BLACK, 10);
			}

			if (settings["fpscounter"].toString() == "true")
			{
				var fps:FPSCounter = new FPSCounter();
				fps.init(view.debugLayer);		
			}
			
			playerManager = new PlayerManager();
			playerManager.init();			
			
			// Register external functions
			if (!CONFIG::DEBUG)
			{
				Security.allowDomain("*");			
				ExternalInterface.addCallback("onGameCue", onGameCue);
				ExternalInterface.addCallback("onPlayerSelect", onPlayerSelect);
			}
			else
			{
				loader.stage.displayState = StageDisplayState.FULL_SCREEN;
			}		
			
			// Initialize DiamondTouch surface and event listeners. The current
			// DTFlash library only supports primitive events. Web and debug 
			// deploys will substitute with mouse events 
			if (CONFIG::DTENABLED)
			{
				diamondTouch = DiamondTouch.getDiamondTouch(loader.stage);
				diamondTouch.addEventListener(DTTouchEvent.TOUCHDOWN, onTouch);
				
				if (settings["dtmouse"].toString() == "true")
				{
					Console.log("Enabling DT mouse emulation...", this);
					diamondTouch.enableTouchEmulation(true);
				}				
				
				if (settings["dtboxes"].toString() == "true")
				{
					Console.log("Enabling DT debug touch boxes...", this);
					diamondTouch.showCursorAndTouchBox(true);					
				}				
			}
			else
			{
				loader.stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
			}
						
			loader.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEvent);		
			
			fsm.changeState(new PregameState());	
		}		
		
		private function onConfigLoaded(evt:Event):void
		{
			config = new XML(evt.target.data);
			
			settings = new Dictionary();
			for each (var setting:XML in (config.settings as XMLList).children())
			{
				settings[setting.attribute("name").toString()] = setting.attribute("value").toString();
			}
			
			if (settings["console"].toString() == "true")
			{
				Console.init();			
				new GameCommands();	
			}
			
			for each (var sounds:XML in (config.sounds as XMLList).children()) 
			{
				_loadTasks++;
				var key:String = sounds.attribute("key").toString();
				var file:String = sounds.attribute("file").toString();
				soundManager.loadSound(file, key, setTaskLoaded); 
			}
			
			setTaskLoaded();
		}
		
		private function setTaskLoaded():void
		{
			_loadedTasks++;
			if (_loadedTasks >= _loadTasks)
				initGame();
		}		
		
		private function onPlayerSelect(player:String):void
		{	
			Console.log("Switching player to " + player);
			currentPlayer = int(player);
		}		
		
		public function onGameCue(message:String):void
		{
			Console.log("onGameCue: " + message);
			
			var i:int;
			var parts:Array = message.split("|");
			
			switch (parts[0])			
			{
				case "play_intro":
					var part:String = parts[1];
					view.playIntroPart(part);
					if (part == "part1")
						view.toggleIntroClip(true);
					if (part == "part5")
						view.toggleIntroClip(false);
					break;
				
				case "show_bubbles":
					TweenMax.delayedCall(0, playerManager.players[3].bubble.pulseRing);
					TweenMax.delayedCall(1, playerManager.players[1].bubble.pulseRing);
					TweenMax.delayedCall(2, playerManager.players[0].bubble.pulseRing);
					TweenMax.delayedCall(3, playerManager.players[2].bubble.pulseRing);
					break;
				
				case "instructions_end":
					if (fsm.currentState is IntroState)
					{
						if (settings["allowinstructionsskip"].toString() == "true")
						{
							(fsm.currentState as IntroState).skips = 1;
							view.advanceSkipButton();
						}
						else
						{
							view.setSkipButton(false);
						}
					}
					break;
				
				case "show_meters":
					showMeters();
					break;
				
				case "start_game":
					fsm.changeState(new PlayGameState());
					break;
				
				case "end_game":
					fsm.changeState(new EndGameState());
					break;
				
				default:
					Console.log("Unhandled game cue: " + message, this);
					break;
			}
		}
		
		public function showMeters():void
		{
			if (_metersShown)
				return;
			
			for (var i:int = 0; i < playerManager.players.length; i++)	
			{
				playerManager.players[i].bubble.enablePlayMode(true);
			}	
			_metersShown = true;
		}
		
		public function reset():void
		{
			_metersShown = false;
			currentPlayer = 0;
			view.introClip.visible = false;
			view.setSkipButtonText(view.SKIP_INTRODUCTION);
		}
		
		public function sendExit():void
		{
			if (Capabilities.playerType == "StandAlone")
				fscommand("quit");
			else
				ExternalInterface.call("exit", "");
		}
		
		public function sendGameCue(name:String):void
		{
			Console.log("sendGameCue: " + name);
			
			if (Capabilities.playerType == "StandAlone")
				return;
			
			ExternalInterface.call("gamecue", name, "flashtable");
		}	
		
		private function onEnterFrame(evt:Event):void
		{
			var timePassed:int = getTimer() - _lastTime;
			_lastTime += timePassed;
			
			// Send time passed to state machine
			fsm.update(timePassed);
			
			// If the total time or no user input has been reached reset back to the
			// pregame state. This does not apply to the pregame, intro or results states
			if (fsm.currentState is PregameState ||
				fsm.currentState is IntroState ||
				fsm.currentState is ResultsGameState)
			{
				return
			}
			
			_totalIdleTime += timePassed;
		
			if (settings != null && _totalIdleTime > int(settings["timeout"]) * 1000)
			{
				Console.log(_totalIdleTime + " is greater than timeout value of " + (settings["timeout"] * 1000));
				_totalIdleTime = 0;
				fsm.changeState(new PregameState());
				sendGameCue("reset");
			}
		}	
		
		private function onTouch(evt:Event):void
		{
			Console.log("Resetting timeout");
			_totalIdleTime = 0;			
		}
		
		/**
		 * Only used to manually set the player index in
		 * environments where the DT table is not enabled
		 * such as the web preview or local debugging
		 */
		private function onKeyEvent(evt:KeyboardEvent):void
		{
			var index:int = evt.keyCode - 48;
			if (index > -1 && index < 4 && !Console.isReceivingInput())
			{
				Console.log("Switching player to " + index);
				currentPlayer = index;
				onTouch(evt);				
			}
		}
	}
}

class SingletonEnforcer {}