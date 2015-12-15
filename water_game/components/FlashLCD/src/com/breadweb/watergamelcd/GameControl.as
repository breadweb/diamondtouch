package com.breadweb.watergamelcd
{
	import com.breadweb.state.StateMachine;
	import com.breadweb.utils.Console;
	import com.breadweb.utils.FPSCounter;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class GameControl
	{
		private static var _instance:GameControl;
		private var _loadTasks:int = 2;
		private var _loadedTasks:int = 0;
		private var _lastTime:int;
		public var fsm:StateMachine;
		public var view:GameView;
		public var captions:XML;
		public var config:XML;
		public var settings:Dictionary;
		public var loader:Sprite;		
		
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
			
			// Load up external captions xml file
			var captionsLoader:URLLoader = new URLLoader();
			captionsLoader.load(new URLRequest("assets/captions.xml"));
			captionsLoader.addEventListener(Event.COMPLETE, onCaptionsLoaded);
			
			// Load up external configuration xml file
			var configLoader:URLLoader = new URLLoader();
			configLoader.load(new URLRequest("assets/lcd_config.xml"));
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
			
			if (Capabilities.playerType != "StandAlone")
			{
				Security.allowDomain("*");
				ExternalInterface.addCallback("onGameCue", onGameCue);
			}
			else
			{
				loader.stage.displayState = StageDisplayState.FULL_SCREEN;	
			}			
			
			fsm.changeState(new PregameState());	
		}		
		
		private function onCaptionsLoaded(evt:Event):void
		{
			captions = new XML(evt.target.data);
			setTaskLoaded();
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
				Console.init((settings["debug"].toString() == "true"));			
				new GameCommands();
			}
			
			setTaskLoaded();
		}		
		
		private function setTaskLoaded():void
		{
			_loadedTasks++;
			if (_loadedTasks >= _loadTasks)
				initGame();
		}
		
		public function onGameCue(message:String):void
		{
			Console.log("onGameCue: " + message);			
			
			var parts:Array = message.split("|");
			
			switch (parts[0])
			{
				case "start_intro":
					
					fsm.changeState(new IntroState());
					break;
				
				case "reset":
					
					fsm.changeState(new PregameState());
					break;
							
				case "play_script":
					
					if (!view.isAlliePlaying())
					{
						Console.log("Playing Allie script " + parts[1]);
						view.playAllieScript(parts[1]);
					}
					else
					{
						Console.log("Not playing Allie script " + parts[1] + ": a script is already playing.");
					}
						
					break;
				
				case "show_results":
					
					// Remove cue name so there is just an array
					// of results for the end game state to process
					parts.shift();
					
					fsm.changeState(new ResultsGameState(parts));
					break;
				
				case "skip_intro":
					
					view.playAllieScript("gameintro3");
					break;
				
				case "skip_instructions":
					
					view.playAllieScript("gameintro5");
					break;				
				
				default:
					Console.log("Unhandled game cue: " + message, this);
					break;				
			}

			Console.log("onGameCue: " + message);			
		}
		
		public function sendExit():void
		{
			if (Capabilities.playerType == "StandAlone")
				return;			
			
			ExternalInterface.call("exit", "");
		}		
		
		public function sendGameCue(name:String):void
		{
			Console.log("sendGAmeCue: " + name);
			
			if (Capabilities.playerType == "StandAlone")
				return;			
			
			ExternalInterface.call("gamecue", name, "flashlcd");
		}
		
		private function onEnterFrame(evt:Event):void
		{
			var timePassed:int = getTimer() - _lastTime;
			_lastTime += timePassed;
			fsm.update(timePassed);
		}
	}
}

class SingletonEnforcer {}