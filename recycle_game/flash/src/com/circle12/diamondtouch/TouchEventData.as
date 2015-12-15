package com.circle12.diamondtouch
{

import com.circle12.diamondtouch.DiamondTouch;
import flash.display.MovieClip;
import flash.geom.Point;

/* DTFlash 1.044 */

/** 
 * This class encapsulates the information received in a touch event from a DiamondTouch device.
 */
public class TouchEventData {
	private var xSignals_internal:Array;
	private var ySignals_internal:Array;
	private var xSegments_internal:Array;
	private var ySegments_internal:Array;
	private var tapCount_internal:Number;
	private var rolledOverCount_internal:Number;

	public var receiver:Number;
	public var eventType:Number;
	public var x:Number;
	public var y:Number;
	public var ulx:Number;
	public var uly:Number;
	public var lrx:Number;
	public var lry:Number;
	public var timestamp:Number;
	public var xSegmentCount:Number;
	public var ySegmentCount:Number;
	public var tag:Object;
	public var initialHoverEvent:Boolean;
	public var valid:String;

	//experimental Gesture Engine support
	public var gestureAction:String = "None"; //None, Down, Move, Up
	public var gesturePosture:String; //One Finger, Two Finger, Five Finger, One Hand, One Arm, One Fist, One Chop
	public var gestureMovement:String; //None, North, South, East, West
	public var gestureSizing:String; // None, Shrink, Expand
	
	public static var EVENTTYPE_TOUCH_DOWN:Number = 1;
	public static var EVENTTYPE_TOUCH_MOVE:Number = 2;
	public static var EVENTTYPE_TOUCH_UP:Number = 3;
	
	
	/**
	   * TouchEventData Constructor
	   */
	public function TouchEventData(receiver:Number, eventType:Number, x:Number, y:Number,
							ulx:Number=0, uly:Number=0, lrx:Number=0, lry:Number=0) {
		if (arguments.length >= 4) {
			if (receiver <-1) { //null) {
				this.receiver = DiamondTouch.mouseReceiver;
			} else {
				this.receiver = receiver; // receiver: -1 means table-unplugged event, -2 means mouse event
			}
			this.eventType = eventType;
			this.x = x;
			this.y = y;
			this.ulx = x;
			this.uly = y;
			this.lrx = x;
			this.lry = y;		
		}
		if (arguments.length == 8) {
			this.ulx = ulx;
			this.uly = uly;
			this.lrx = lrx;
			this.lry = lry;
		}
		this.timestamp = (new Date()).time;
		this.tapCount_internal = 0;
		this.gestureAction = "None";
	}
	
	// Some calling code passes no params. I added "LeftTop" as a default param --awe
	public function getReferencePoint( type:String="LeftTop" ):Point {
		var pt:Point;
		if( type == "MidTop" ) {
			pt.x = (this.lrx+this.ulx) / 2;
			pt.y = this.uly;
		}
		else if( type == "Center" || type.length == 0 ) {
			pt.x = (this.lrx+this.ulx) / 2;
			pt.y = (this.lry+this.uly) / 2;
		} 
		//else if( type == "MaxContact" ) {
			//pt = {x:x,y:y};
		//}
		else { //awe
			pt.x = this.ulx;
			pt.y = this.uly;
		}
		return pt;
	}
	public function convertToLocal(mc:MovieClip):Point {
		var pt:Point = getReferencePoint(); 
		mc.globalToLocal(pt);
		return pt;
	}

	/**
	 * Creates TouchEventData from the current mouse point.
	 * The action can be one of three strings:
	 *  - Down
	 *  - Move
	 *  - Up
	 */ 
	public static function fromMouse( eventType:String ):TouchEventData {
		var actionID:Number;
		eventType = eventType.toLowerCase();
		if( eventType == "down" )
			actionID = EVENTTYPE_TOUCH_DOWN;
		else if( eventType == "up" )
			actionID = EVENTTYPE_TOUCH_UP;
		else if( eventType == "move" )
			actionID = EVENTTYPE_TOUCH_MOVE;
		else
			return null;
		trace("TouchEventData.as: fromMouse IS NOT IMPLEMENTED. _root is not available -- rewrite this to pass in mouse location");			
		return new TouchEventData(-2, actionID, 0,0);
		//return new TouchEventData( null, actionID, _root._xmouse, _root._ymouse );
	}	
	/**
	   * Sets the tap count. 
	   */
	public function set tapCount (tapCount:Number):void {
		this.tapCount_internal = tapCount;
	}
	/**
	   * Returns the tap count.
	   */
	public function get tapCount ():Number {
		return this.tapCount_internal;
	}
	/**
	   * Sets the rolledOver count. 
	   */
	public function set rolledOverCount (rolledOverCount:Number):void {
		this.rolledOverCount_internal = rolledOverCount;
	}
	/**
	   * Returns the rolledOver count.
	   */
	public function get rolledOverCount ():Number {
		return this.rolledOverCount_internal;
	}
	/**
	   * Returns the x Signals array.
	   */
	public function get xSignals ():Array {
		return this.xSignals_internal;
	}
	/**
	   * Sets the xSignal data from a string. 
	   */
	public function setXSignals (xSignalString:String):void {
		this.xSignals_internal = new Array(xSignalString.length);
		for (var i=0; i<this.xSignals_internal.length; i++) {
			this.xSignals_internal[i] = xSignalString.charCodeAt(i);
		}
	}
	/**
	   * Returns the y Signals array.
	   */
	public function get ySignals ():Array {
		return this.ySignals_internal;
	}	
	/**
	   * Sets the ySignal data from a string. 
	   */
	public function setYSignals (ySignalString:String):void {
		this.ySignals_internal = new Array(ySignalString.length);
		for (var i=0; i<this.ySignals_internal.length; i++) {
			this.ySignals_internal[i] = ySignalString.charCodeAt(i);
		}
	}		
	
	/**
	   * Returns the x Segments array.
	   */
	public function get xSegments ():Array {
		return this.xSegments_internal;
	}
	/**
	   * Sets the xSignal data from a string. 
	   */
	public function setXSegments (xSegmentsString:String):void {
		this.xSegments_internal = new Array(xSegmentsString.length);
		for (var i=0; i<this.xSegments_internal.length; i++) {
			var val = xSegmentsString.charCodeAt(i);
			this.xSegments_internal[i] = val;			
			if (val > 0x7fff) {
				this.xSegments_internal[i] = -((val ^ 0xffff) + 1);
			}
		}
	}	
	
	public function xSegmentsIdx(idx:Number, value:Number) {
		this.xSegments_internal[idx] = value;
	}
	
	/**
	   * Returns the y Segments array.
	   */
	public function get ySegments ():Array {
		return this.ySegments_internal;
	}
	/**
	   * Sets the ySegments data from a string. 
	   */
	public function setYSegments (ySegmentsString:String):void {
		this.ySegments_internal = new Array(ySegmentsString.length);
		for (var i=0; i<this.ySegments_internal.length; i++) {
			this.ySegments_internal[i] = ySegmentsString.charCodeAt(i);
		}
	}
	
	public function ySegmentsIdx(idx:Number, value:Number) {
		this.ySegments_internal[idx] = value;
	}
}
}
