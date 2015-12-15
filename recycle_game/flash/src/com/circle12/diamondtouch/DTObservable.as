package com.circle12.diamondtouch
{

import com.circle12.diamondtouch.DTObserver; 
import com.circle12.diamondtouch.TouchEventData;
import flash.display.DisplayObject;

/* DTFlash 1.044 */

/**
 * Defines the methods required by any class that wants to be the "subject"
 * in the Observer design pattern. 
 */
interface DTObservable {
	// NOTE: Use Object instead of DTObserver so that listeners can be created simply via:
	//  var listener = new Object();
	//  listener.onTouchEvent = function(o:DTObservable, dtev:TouchEventData):void {
	//	...do something
	// }
	//public function addObserver(o:DTObserver):Boolean;
	//public function removeObserver(o:DTObserver):Boolean
	function addObserver(o:DisplayObject, tag:Object=null):Boolean;
	function removeObserver(o:DisplayObject):Boolean;
	function notifyObservers(dtev:TouchEventData):void;
	function clearObservers():void;
	function hasChanged():Boolean;
	function setChanged():void;
	function clearChanged():void;
	function countObservers():Number;
}
}