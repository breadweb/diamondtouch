package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;
	
	import flash.geom.Point;

	public class Player
	{
		public var index:int;
		public var type:String;
		public var shortName:String;
		public var color:uint;
		public var waterLevel:Number = 50; // Starts at half
		public var bubble:PlayerBubble;
		public var ready:Boolean = false;
		public var lastRange:int = 1;
		private var _rangeValues:Vector.<Point>;
		private var _rangeTypes:Vector.<String>;
		private var _rangeDescs:Vector.<String>;
		
		public function Player(difficulty:int = 1)
		{
			switch (difficulty)
			{
				case 1:
					_rangeValues = Vector.<Point>([
						new Point(0, 22),
						new Point(23, 77),
						new Point(78, 100)
					]);
					break;
				case 2:
					_rangeValues = Vector.<Point>([
						new Point(0, 32),
						new Point(33, 72),
						new Point(73, 100)
					]);
					break;				
			}	
			_rangeTypes = Vector.<String>([
				"Low",
				"Good",
				"High"
			]);
			_rangeDescs = Vector.<String>([
				"Under-consumption!",
				"Sustainable!",
				"Over-consumption!"
			]);
		}
		
		/**
		 * Updates the water level for a player based on a delta
		 *
		 * @param amount The change in the water level
		 * @return A string identifying if the water level has entered a different range
		 */
		public function updateWater(amount:Number):String
		{
			waterLevel += amount;
			
			if (waterLevel < 0)
				waterLevel = 0;
			
			if (waterLevel > 100)
				waterLevel = 100;
			
			var currentRange:int = getRangeIndex();
			
			// Has the range changed?
			if (currentRange != lastRange)
			{
				Console.log("Range for " + type + " changed to " + currentRange + " " + waterLevel);
				
				lastRange = currentRange;
				
				return getRangeType(currentRange);
			}
			
			return "None";			
		}
		
		public function getPercentFilled():Number
		{
			return waterLevel / 100;
		}
		
		public function getRangeType(index:int = -1):String
		{
			if (index == -1)
				index = getRangeIndex();
			
			return _rangeTypes[index];
		}
		
		public function getRangeDesc(index:int = -1):String
		{
			if (index == -1)
				index = getRangeIndex();
			
			return _rangeDescs[index];
		}	
		
		public function getRangeIndex():int
		{
			for (var i:int = 0; i < _rangeValues.length; i++)
			{
				if (int(waterLevel) >= _rangeValues[i].x && int(waterLevel) <= _rangeValues[i].y)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		public function reset():void
		{
			ready = false;	
			lastRange = 1;
			waterLevel = 50;			
		}
	}
}