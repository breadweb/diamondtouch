package com.breadweb.recycle
{
	import com.breadweb.recycle.components.Garbage;

	public class Player
	{
		private var _scores:Array;
		private var _id:int;
		private var _garbage:Garbage = null;
		
		public function Player(toucher:int)
		{
			_id = toucher;
			_scores = new Array();
			_scores[GameConst.METAL] = 0;
			_scores[GameConst.PAPER] = 0;
			_scores[GameConst.PLASTIC] = 0;
			_scores[GameConst.GLASS] = 0;
		}
		
		public function reset():void
		{
			_scores[GameConst.METAL] = 0;
			_scores[GameConst.PAPER] = 0;
			_scores[GameConst.PLASTIC] = 0;
			_scores[GameConst.GLASS] = 0;
			_garbage = null;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get scores():Array
		{
			return _scores;
		}
		
		public function get totalScore():int
		{
			var totalScore:int = _scores[GameConst.METAL] + _scores[GameConst.PAPER] + _scores[GameConst.PLASTIC] + _scores[GameConst.GLASS];
			return totalScore;
		}
		
		public function get garbage():Garbage
		{
			return _garbage;
		}
		public function set garbage(v:Garbage):void
		{
			_garbage = v;
		}
	}
}