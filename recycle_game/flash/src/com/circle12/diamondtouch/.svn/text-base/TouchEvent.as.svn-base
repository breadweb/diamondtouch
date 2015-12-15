package com.circle12.diamondtouch
{
import flash.events.*;
import com.circle12.diamondtouch.TouchEventData;

/** 
 * This class encapsulates the information received in a touch event from a DiamondTouch device.
 */
public class TouchEvent extends Event {
	public static const TOUCHDOWN:String = "TouchDown";
	public static const TOUCHMOVE:String = "TouchMove";
	public static const TOUCHUP:String = "TouchUp";	
	
	public var dtev:TouchEventData = null;
	/**
	   * TouchEventData Constructor
	*/
	  
	public function TouchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, dtev:TouchEventData = null) {
		super(type, bubbles, cancelable);
		this.dtev = dtev;
	}
	
	public override function clone():Event {
		return new TouchEvent(type, bubbles, cancelable, dtev);
	}
	
	public override function toString():String {
		return formatToString("TouchEvent", "type", "bubbles", "cancelable", "eventPhase", "dtev");
	}	
}
}
