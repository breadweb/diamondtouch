package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class GameData
	{
		private var _settings:Dictionary;
		private var _totalLoaded:Number = 0;			
		
		public var boolPlayerSelect:Boolean = false;
		public var boolSwirl:Boolean = false;
		public var boolJail:Boolean = false;
		public var intPlayerConfig:Number;
		public var intCols:int = 0;
		public var intRows:int = 0;
		
		public var aryDiffs:Array;
		public var aryModes:Array;	
		public var aryCards:Array;
		public var aryPositions:Array;
		
		public function GameData(xmlData:XML)
		{
			_settings = new Dictionary();
			for each (var setting:XML in (xmlData.settings as XMLList).children())
			{
				_settings[setting.name().toString()] = setting.valueOf().toString();
			}			
						
			// Game settings
			boolPlayerSelect = getSetting("playerselect") == "true" ? true : false;
			boolSwirl = getSetting("enableswirl") == "true" ? true : false;
			boolJail = getSetting("enablejail") == "true" ? true : false;
			intRows = int(getSetting("rows"));
			intCols = int(getSetting("cols"));
			
			// Game difficulties
			aryDiffs = new Array();
			for each (var difficulty:XML in (xmlData.settings.difficulties as XMLList).children())
			{
				aryDiffs.push(new Array(
					int(difficulty.attribute("id").toString()),
					difficulty.attribute("title").toString(),
					difficulty.attribute("desc").toString()
				));
			}
			
			// Game modes
			aryModes = new Array();
			for each (var mode:XML in (xmlData.settings.modes as XMLList).children())
			{
				aryModes.push(new Array(
					mode.attribute("id").toString(),
					mode.attribute("title").toString(),
					mode.attribute("desc").toString(),
					int(mode.attribute("difficulties").toString())					
				));
			}
			
			// Player locations
			aryPositions = new Array();
			for each (var position:XML in (xmlData.settings.touchers as XMLList).children())
			{
				aryPositions[int(position.attribute("id").toString()) - 1] = position.attribute("location").toString();					
			}			
			
			Console.log("Finished parsing config data.");
		}
		
		public function loadAllCardData():void
		{
			aryCards = new Array();
			loadCardData();
		}
		
		private function loadCardData():void
		{
			var loader:URLLoader = new URLLoader();				
			var request:URLRequest = new URLRequest("assets/xml/matches_" + aryModes[_totalLoaded][0] + ".xml");
			loader.load(request);				
			loader.addEventListener(Event.COMPLETE, onCardDataLoaded, false, 0, true);									
		}
		
		private function onCardDataLoaded(evt:Event):void
		{
			var cards:XML = new XML(evt.target.data);
			aryCards.push(cards.children());
			
			GameControl.getInstance().setTaskLoaded();
			
			_totalLoaded++;
			if (_totalLoaded < aryModes.length)
				loadCardData();
		}
		
		public function getSetting(key:String):String
		{
			if (_settings[key] != null)
				return _settings[key];
			else
			{
				Console.log("A setting with key " + key + " does not exist.");
				return "";
			}
		}
	}
}