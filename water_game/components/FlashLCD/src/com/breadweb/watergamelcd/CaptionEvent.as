package com.breadweb.watergamelcd
{
	import flash.events.Event;
	
	public class CaptionEvent extends Event
	{
		public static const CHANGED:String = "changed";
		public var captionId:String;
		
		public function CaptionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}