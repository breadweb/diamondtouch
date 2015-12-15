package com.breadweb.watergamelcd
{
	import flash.events.Event;
	
	public class CueEvent extends Event
	{
		public static const DELIVERED:String = "delivered";
		public var cueId:String;		
		
		public function CueEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}