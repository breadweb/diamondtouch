package com.breadweb.watergametable
{
	import flash.events.Event;
	
	/**
	 * This event is used for both mouse or touch input
	 */
	public class InputEvent extends Event
	{
		public static const INPUT_DOWN:String = "input.down";
		public static const INPUT_UP:String = "input.up";
		public var x:int;
		public var y:int;
		public var player:int;
		
		public function InputEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}