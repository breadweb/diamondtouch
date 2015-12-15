package com.circle12.diamondtouch
{

	// NOTE: AN INSTANCE OF THIS CLASS MUST BE ADDED TO THE STAGE
	//  (ie via addChild) BEFORE this.stage WILL BECOME NON-null!
	// SO YOU CANNOT ACCESS this.stage IN THE DiamondTouch CONSTRUCTOR!




	import com.circle12.diamondtouch.DTObservable;
	import com.circle12.diamondtouch.DTObservableSubject;
	import com.circle12.diamondtouch.DTObserver;
	import com.circle12.diamondtouch.TouchEventData;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.*;
	import flash.xml.XMLNode;

	/* DTFlash 1.044 */

	public class DiamondTouch extends MovieClip implements DTObservable {
		/**************************************************************************/
		/* Constants                                                              */
		/**************************************************************************/
		public static var MAX_TOUCHERS:Number=10;
		public static var DEFAULT_TOUCHER_COLORS:Array =
		[ 0xFF0000, 0x0000FF, 0x00FF00, 0xFFCC00, 0x00FFFF ];

		/**************************************************************************/
		/* Class variables                                                        */
		/**************************************************************************/
		private static var mouseReceiver_internal:Number=4;
		private static var numberOfTouchers_internal:Number=5;
		private static var bboxMinSize_internal:Number=50;
		private static var dt:DiamondTouch=null;
		private var subj:DTObservableSubject;
		//private var keyListener:Object;
		private var listenForExit:Boolean;
		private var stageListenerObj:Object;
		private var xAntennaCount_internal:Number=128;
		private var yAntennaCount_internal:Number=96;
		private var antennaPitchUm_internal:Number=5000;
		private var eventSegmentEnable_internal:Boolean=false;
		private var eventSignalEnable_internal:Boolean=false;
		private var screenCoordinatesEnable_internal:Boolean=true;
		private var internal_DtEvent:String;
		private var internal_DtXSignalString:String;
		private var internal_DtYSignalString:String;
		private var internal_DtXSegmentString:String;
		private var internal_DtYSegmentString:String;
		private var toucherRotation_internal:Array=new Array(MAX_TOUCHERS);
		private var toucherColors_internal:Array=new Array(MAX_TOUCHERS);
		private var eventProcessDelay_internal:Number=50;
		private var cursorAndTouchBoxPid:Number;
		private var touchEmulation_dragging:Boolean=false;
		private var touchEmulation_bboxSize:Number=0;
		private var touchEmulation_wheelMover:Object=null;
		public var touchEmulation_bboxMinSize:Number=0;
		public var touchEmulation_bboxWheelDelta:Number=5;
		public var toucherRotationsInitialized:Boolean=false;
		public var player_width:Number;
		public var player_height:Number;
		public var player_ul:Object = new Object();
		public var player_lr:Object = new Object();
		public var player_left:Number;
		public var player_top:Number;
		public var player_right:Number;
		public var player_bottom:Number;
		public var authored_stage_width:Number=-1;
		public var authored_stage_height:Number=-1;
		public var stageDimsPid:Number;
		public var oldStageSize:Point=new Point(0,0);
		private var keysdown:Array;
		private var delayedTimer:Timer;

		/**
		 * EventQueue objects contain the following elements:
		 *    dtev:TouchEventData
		 *    useStageRelativeCoordinates:Boolean
		 */
		private var EventQueue:Array;
		private var queueIntervalID:Number;

		/**************************************************************************/
		/* DiamondTouch constructor                                               */
		/**************************************************************************/
		public function DiamondTouch(usingStageCoordinates:Boolean) {
			flash.system.Security.allowDomain("*");
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			for (var i:Number=0; i < DEFAULT_TOUCHER_COLORS.length; i++) {
				toucherColors_internal[i]=DEFAULT_TOUCHER_COLORS[i];
			}

			for (var ii:Number=0; ii<MAX_TOUCHERS; ii++) {
				toucherRotation_internal[ii] = (ii%4) * 90;
			}
			EventQueue = new Array();
			subj=new DTObservableSubject(this);

			//this.keyListener = { listening:ListenForExit };
			//this.keyListener.onKeyUp = function() {
			//if (this.listening) {
			//if (Key.getCode() == 81 || Key.getCode() == Key.ESCAPE) {
			//// 81= 'q' //Key.ESCAPE)
			//fscommand("STOP", String(Key.getCode()));
			//}
			//}
			//};
			//Key.addListener(this.keyListener);

			this.keysdown = new Array();

			try {
				//ExternalInterface.addCallback("onDTData", onDTData); //try this -- awe
			} catch (e) {
				var text_txt:TextField=TextField(stage.getChildByName("text_txt"));
				text_txt.text = e;
			}

			//stageListenerObj = new Object();
			//stageListenerObj.onResize = function() {
			//if( !this.oldStageSize || this.oldStageSize.width != Stage.width ||
			//this.oldStageSize.height != Stage.height ) {
			//this.oldStageSize = { width:Stage.width, height:Stage.height };
			//stagePropertiesChanged();
			//}
			//};
			//Stage.addListener(stageListenerObj);

			//delayedTimer = new Timer(1000,1);
			//delayedTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayedTimerCompleteHandler);
			//delayedTimer.start();
		}

		//private function delayedTimerCompleteHandler(e:TimerEvent):void {
			////merlcollage_mc.y = (stage.stageHeight - merlcollage_mc.height) / 2;
		//}

		public function addedToStage(e:Event) {
			trace("addedToStage: stage="+stage);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			stage.addEventListener(Event.RESIZE, stageResizeListener);  //only fires for NO_SCALE mode
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			clearInterval(this.stageDimsPid);
			this.stageDimsPid=setInterval(recordStageAndPlayerDimensions,100);
		}

		function stageResizeListener(e:Event) {
			trace("Entering stageResizeListener");
			if (oldStageSize.x!=stage.width||oldStageSize.y!=stage.height) {
				oldStageSize.x=stage.width;
				oldStageSize.y=stage.height;
				stagePropertiesChanged();
				clearInterval(this.stageDimsPid);
				this.stageDimsPid=setInterval(recordStageAndPlayerDimensions,100);
				//this.queueIntervalID=setInterval(processNextEvent,eventProcessDelay);
				trace("in stageResizeListener");
			}
		}

		function keyDownListener(e:KeyboardEvent):void {
			for (var z=0; z<keysdown.length; z++) {
				if (keysdown[z]==e.keyCode) {
					return;
				}
			}
			keysdown.push(e.keyCode);
		}

		function keyUpListener(e:KeyboardEvent) {
			for (var z=0; z<keysdown.length; z++) {
				if (keysdown[z]==e.keyCode) {
					keysdown.splice(z, 1);
				}
			}
			if (this.ListenForExit) {
				if (e.keyCode==81||e.keyCode==Keyboard.ESCAPE) {
					// 81= 'q' //Key.ESCAPE)
					//fscommand("STOP", String(e.keyCode));
					if (ExternalInterface.available) {
						ExternalInterface.marshallExceptions=true;
						//ExternalInterface.addCallback("g", g);
						try {
							ExternalInterface.call("FlashCall", "FlashWantsToQuit");
						} catch (e:Error) {
							trace(e);
						}
					}
				}
			}
		}



		/**************************************************************************/
		/* Class Properties                                                       */
		/**************************************************************************/
		public function get ListenForExit():Boolean {
			//if( listenForExit == undefined )
			//listenForExit = true;
			return listenForExit;
		}
		public function set ListenForExit( value:Boolean ):void {
			listenForExit=value;
			//keyListener.listening = ListenForExit;
		}
		public function get toucherRotationString():String {
			var str:String="";
			for (var i:Number=0; i < numberOfTouchers; i++) {
				str+=","+getToucherRotation(i);
			}
			return str.substring( 1 );
		}
		public function set toucherRotationString(str:String):void {
			var strRotations:Array=str.split(",");
			for (var i=0; i<strRotations.length; i++) {
				setToucherRotation(i,parseInt(strRotations[i]));
			}
		}
		public function setToucherRotation(toucher:Number, rotation:Number):void {
			this.toucherRotation_internal[toucher]=rotation;
		}
		public function getToucherRotation(toucher:Number):Number {
			var rotation:Number=this.toucherRotation_internal[toucher];
			//if( rotation == undefined )
			//rotation = (toucher%4) * 90;
			while ( rotation < 0 ) {
				rotation+=360;
			}
			while ( rotation >= 360 ) {
				rotation-=360;
			}
			return rotation;
		}
		public function set antennaPitchUm(value:Number):void {
			this.antennaPitchUm_internal=value;
		}
		public function get antennaPitchUm():Number {
			return this.antennaPitchUm_internal;
		}
		public function set xAntennaCount(value:Number):void {
			this.xAntennaCount_internal=value;
		}
		public function get xAntennaCount():Number {
			return this.xAntennaCount_internal;
		}
		public function set yAntennaCount(value:Number):void {
			this.yAntennaCount_internal=value;
		}
		public function get yAntennaCount():Number {
			return this.yAntennaCount_internal;
		}
		public function set eventSegmentEnable(value:Boolean):void {
			this.eventSegmentEnable_internal=value;
			if (value.toString().toLowerCase()=="false") {
				this.eventSegmentEnable_internal=false;
			}
			if (value.toString().toLowerCase()=="true") {
				this.eventSegmentEnable_internal=true;
			}
		}
		public function get eventSegmentEnable():Boolean {
			return this.eventSegmentEnable_internal;
		}
		public function set eventSignalEnable(value:Boolean):void {
			this.eventSignalEnable_internal=value;
			if (value.toString().toLowerCase()=="false") {
				this.eventSignalEnable_internal=false;
			}
			if (value.toString().toLowerCase()=="true") {
				this.eventSignalEnable_internal=true;
			}
		}
		public function get eventSignalEnable():Boolean {
			return this.eventSignalEnable_internal;
		}
		public function set screenCoordinatesEnable(value:Boolean):void {
			this.screenCoordinatesEnable_internal=value;
			if (value.toString().toLowerCase()=="false") {
				this.screenCoordinatesEnable_internal=false;
			}
			if (value.toString().toLowerCase()=="true") {
				this.screenCoordinatesEnable_internal=true;
			}
		}
		public function get screenCoordinatesEnable():Boolean {
			return this.screenCoordinatesEnable_internal;
		}
		public function get toucherColorString():String {
			var str:String="";
			for (var i:Number=0; i < numberOfTouchers; i++) {
				str+=",0x"+getToucherColor(i).toString(16);
			}
			return str.substring(1);
		}
		public function set toucherColorString(str:String):void {
			var strColors:Array=str.split(",");
			for (var i=0; i<strColors.length; i++) {
				setToucherColor(i,parseInt(strColors[i]));
			}
		}
		public function getToucherColor( n:Number ):Number {
			var color:Number=toucherColors_internal[n];
			//if( color == undefined )
			//color = 0x000000;
			return color;
		}
		public function setToucherColor( n:Number, c:Number ):void {
			toucherColors_internal[n]=c;
		}
		public static function get mouseReceiver():Number {
			return mouseReceiver_internal;
		}
		public static function set mouseReceiver(o:Number):void {
			mouseReceiver_internal=o;
		}
		public function get numberOfTouchers():Number {
			return numberOfTouchers_internal;
		}
		public function set numberOfTouchers(n:Number):void {
			numberOfTouchers_internal=n;
		}
		public function getTapInterval():Number {
			return subj.tapInterval;
		}
		public function setTapInterval(o:Number):void {
			subj.tapInterval=o;
		}
		public function getHoverInitialDelay():Number {
			return subj.hoverInitialDelay;
		}
		public function setHoverInitialDelay(o:Number):void {
			subj.hoverInitialDelay=o;
		}
		public function getHoverRepeatDelay():Number {
			return subj.hoverRepeatDelay;
		}
		public function setHoverRepeatDelay(o:Number):void {
			subj.hoverRepeatDelay=o;
		}
		public function getHoverProximityInPixels():Number {
			return subj.hoverProximityInPixels;
		}
		public function setHoverProximityInPixels(o:Number):void {
			subj.hoverProximityInPixels=o;
		}
		public function getHoverGeneratedForMovePauses():Boolean {
			return subj.hoverGeneratedForMovePauses;
		}
		public function setHoverGeneratedForMovePauses(o:Boolean):void {
			subj.hoverGeneratedForMovePauses=o;
		}
		public function get DtEvent():String {
			return this.internal_DtEvent;
		}
		public function set DtEvent(value:String):void {			
			//var text_txt:TextField=TextField(stage.getChildByName("text_txt"));
			//trace("set DtEvent: text_txt="+text_txt);			
			this.internal_DtEvent=value;
			//this.onDTData("DTData", "oldval", value, "userData");
			this.onDTData(value);
		}
		public function get DtXSignalString():String {
			return this.internal_DtXSignalString;
		}
		public function set DtXSignalString(value:String):void {
			this.internal_DtXSignalString=value;
		}
		public function get DtYSignalString():String {
			return this.internal_DtYSignalString;
		}
		public function set DtYSignalString(value:String):void {
			this.internal_DtYSignalString=value;
		}
		public function get DtXSegmentString():String {
			return this.internal_DtXSegmentString;
		}
		public function set DtXSegmentString(value:String):void {
			this.internal_DtXSegmentString=value;
		}
		public function get DtYSegmentString():String {
			return this.internal_DtYSegmentString;
		}
		public function set DtYSegmentString(value:String):void {
			this.internal_DtYSegmentString=value;
		}
		public function get eventProcessDelay():Number {
			return eventProcessDelay_internal;
		}
		public function set eventProcessDelay( value:Number ):void {
			//if( value == undefined || value < 0 ) value = 0;
			if (value<0) {
				value=0;
			}
			eventProcessDelay_internal=value;
		}
		public function get aggressiveSegmentCount():Boolean {
			return subj.aggressiveSegmentCount;
		}
		public function set aggressiveSegmentCount( value:Boolean ):void {
			subj.aggressiveSegmentCount=value;
		}
		public function get reverseNotification():Boolean {
			return subj.reverseNotification;
		}
		public function set reverseNotification( value:Boolean ):void {
			subj.reverseNotification=value;
		}
		/**
		 * Returns a reference to the dt instance.
		 * If no dt instance exists yet, creates one.
		 * @return A DiamondTouch instance.
		 */
		public static function getDiamondTouch():DiamondTouch {
			if (dt==null) {
				dt=new DiamondTouch(true);
			}
			return dt;
		}


		/**************************************************************************/
		/* Useful functions                                                       */
		/**************************************************************************/
		public static function swapToTop(clip:MovieClip):Number {
			//var clipDepth:Number = clip.getDepth();
			//var highestDepth:Number = clip._parent.getNextHighestDepth() -1;
			//if (clipDepth != highestDepth) { 
			//clip.swapDepths(highestDepth+1);
			//}
			//return clipDepth;
			clip.parent.addChild(clip);
			return clip.parent.getChildIndex(clip);
		}

		public static function rotateTowardsPoint( obj_mc:MovieClip,
		globalPointObj:Point ) {
			var point:Point=new Point(obj_mc.x,obj_mc.y);
			obj_mc.parent.localToGlobal(point);
			var deltaX:Number=globalPointObj.x-point.x;
			var deltaY:Number=globalPointObj.y-point.y;
			var rotationRadian:Number=Math.atan2(deltaY,deltaX);
			var rotationAngle:Number=radiansToDegrees(rotationRadian);
			var parentRotation:Number=0;
			var parent:DisplayObject=DisplayObject(obj_mc.parent);
			while ( parent != null ) {
				parentRotation+=parent.rotation;
				parent=DisplayObject(parent.parent);
			}
			obj_mc.rotation=rotationAngle+90-parentRotation;
		}

		public static function radiansToDegrees(radians:Number):Number {
			return (radians/Math.PI)*180;
		}

		public static function rotateTowardsCenter(
		obj_mc:MovieClip, usePlayerCenter:Boolean ) {
			var pt:Point = new Point();
			if (usePlayerCenter) {
				pt.x=dt.player_width/2;
				pt.y=dt.player_height/2;
			} else {
				pt.x=dt.authored_stage_width/2;
				pt.y=dt.authored_stage_height/2;
			}
			rotateTowardsPoint(obj_mc, pt);
		}

		public static function angleBetweenTwoPoints(
		obj_mc:MovieClip, globalPointObj:Object ):Number {
			var point:Point=new Point(obj_mc.x,obj_mc.y);
			obj_mc.parent.localToGlobal(point);
			var deltaX:Number=globalPointObj.x-point.x;
			var deltaY:Number=globalPointObj.y-point.y;
			var rotationRadian:Number=Math.atan2(deltaY,deltaX);
			var rotationAngle:Number=radiansToDegrees(rotationRadian);
			return rotationAngle;
		}


		/**************************************************************************/
		/* Public functions                                                       */
		/**************************************************************************/
		public function loadConfig( path:String ):void {
			//var config_xml:XML = new XML();
			//config_xml.ignoreWhite = true;
			//config_xml.onLoad = function( success:Boolean ):void {
			//if( success )
			//dt.parseConfig( this );
			//};
			//addEventListener("load", config_xml.onLoad);
			//config_xml.load( path );

			var loader:URLLoader = new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onXmlLoad);
			loader.load(new URLRequest(path));
		}

		public function onXmlLoad(e:Event) {
			try {
				var config_xml:XML=new XML(e.target.data);
				dt.parseConfig(config_xml);
			} catch (e:TypeError) {
				trace("onXmlLoad TypeError: " + e.message);
			}

		}

		public function addObserver( o:DisplayObject, tag:Object=null ):Boolean {
			return subj.addObserver(o, tag);
		}
		public function removeObserver(o:DisplayObject):Boolean {
			return subj.removeObserver(o);
		}
		public function notifyObservers(dtev:TouchEventData):void {
			subj.notifyObservers(dtev);
		}
		public function clearObservers():void {
			subj.clearObservers();
		}
		public function countObservers():Number {
			return subj.countObservers();
		}

		public function setChanged():void {
			subj.setChanged();
		}
		public function clearChanged():void {
			subj.clearChanged();
		}
		public function hasChanged():Boolean {
			return subj.hasChanged();
		}

		//public function onDTData(prop, oldval, newval, userData) {
		public function onDTData(newval:String):void {
			//var text_txt:TextField = MovieClip(parent).text_txt;
			//text_txt.text = "onDTData:: str=" + newval;
			
			var lv:URLVariables = new URLVariables();
			//var lv = new LoadVars();
			lv.decode(newval);
			if (lv.valid!="true") {
				return;
			}
			
			if (lv.resize!=undefined && lv.resize=="true") {
				//text_txt.text = "recordStageAndPlayerDimensions about to be scheduled";
				clearInterval(dt.stageDimsPid);
				dt.stageDimsPid=setInterval(recordStageAndPlayerDimensions,100,false);
				//text_txt.text = "recordStageAndPlayerDimensions scheduled";
				return;
			}
			var dtev=new TouchEventData(Number(lv.receiver),Number(lv.action),0,0,Number(lv.ulx),Number(lv.uly),Number(lv.lrx),Number(lv.lry));
			dtev.x = dtev.ulx + Math.round((dtev.lrx -dtev.ulx)/2);
			dtev.y = dtev.uly + Math.round((dtev.lry -dtev.uly)/2);
			dtev.timestamp=Number(lv.timestamp);
			dtev.xSegmentCount=Number(lv.xSegmentCount);
			dtev.ySegmentCount=Number(lv.ySegmentCount);
/*
			// Use mx.utils.Base64Decoder class here
			dtev.setXSignals(dt.DtXSignalString);
			dtev.setYSignals(dt.DtYSignalString);
			dtev.setXSegments(dt.DtXSegmentString);
			dtev.setYSegments(dt.DtYSegmentString);
*/			
			dtev.valid="valid"+dtev.receiver.toString();
			dtev.gestureAction=lv.gestureAction;
			if (lv.gestureAction != undefined &&
			lv.gestureAction.length > 0 &&
			lv.gestureAction != "None") {
				dtev.gestureAction=lv.gestureAction;
				dtev.gesturePosture=lv.gesturePosture;
				dtev.gestureMovement=lv.gestureMovement;
				dtev.gestureSizing=lv.gestureSizing;
			} else {
				dtev.gestureAction="None";
			}

			// This is a bug fix from dt scanning ...
			//  - if the action is a toucher up or one of the two 
			//    segment counts is zero, both should be zero
			if ( dtev.eventType == 3 || dtev.xSegmentCount==0 || dtev.ySegmentCount==0 ) {
				dtev.xSegmentCount=0;
				dtev.ySegmentCount=0;
			}
			
			if (dtev.eventType==1) {
				trace("DISPATCHING TouchDown");
				dispatchEvent(new TouchEvent(TouchEvent.TOUCHDOWN, true, true, dtev));
			} else if (dtev.eventType == 2) {
				dispatchEvent(new TouchEvent(TouchEvent.TOUCHMOVE, true, true, dtev));
			} else if (dtev.eventType == 3) {
				trace("DISPATCHING TouchUp");
				dispatchEvent(new TouchEvent(TouchEvent.TOUCHUP, true, true, dtev));
			}

			/*
			
			//if (dtev.eventType+dtev.receiver+dtev.x+dtev.y+
			//dtev.ulx+dtev.uly+dtev.lrx+dtev.lry == NaN) {
			//return;
			//}
			
			var relative:Boolean=(lv.useStageRelativeCoordinates=="true");
			var event:Object={dtev:dtev,useStageRelativeCoordinates:relative};
			EventQueue.push( event );
			
			return;
			*/
		}

		public function stagePropertiesChanged() {
			clearInterval(dt.stageDimsPid);
			dt.stageDimsPid=setInterval(dt.recordStageAndPlayerDimensions,100);
		}

		public function startToucherDrag(observer:DisplayObject, dtev:TouchEventData,
		lockCenter:Boolean, rotateTowardsPoint:Point=null, rect_limits:Object=null) {
			subj.startToucherDrag(observer, dtev, lockCenter, rotateTowardsPoint, rect_limits);
		}

		public function stopToucherDrag(observer:DisplayObject, dtev:TouchEventData) {
			subj.stopToucherDrag(observer, dtev);
		}

		public function showCursorAndTouchBox(activated:Boolean=true, mode:Number=0) {
			//if (activated == null) activated = true;
			if (activated) {
				enableCursorAndTouchBox(mode);
			} else {
				disableCursorAndTouchBox(mode);
			}
		}

		public function enableTouchEmulation(activated:Boolean=true, receiver:Number=-2, bboxMinSize:Number=50, wheelDelta:Number=20):Boolean {
			//if (activated == null) {
			//activated = true;
			//}
			if (arguments.length<2||! isNaN(receiver)) {
				mouseReceiver=receiver;
			}
			if (arguments.length<3||! isNaN(bboxMinSize)) {
				dt.touchEmulation_bboxMinSize=bboxMinSize;
			}
			if (arguments.length<4||! isNaN(wheelDelta)) {
				dt.touchEmulation_bboxWheelDelta=wheelDelta;
			}
			if (! activated) {
				//delete _root.onMouseDown;
				//delete _root.onMouseMove;
				//delete _root.onMouseUp;
				//Mouse.removeEventListener(dt.touchEmulation_wheelMover);
				try {					
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseEmulation_onMouseDown);					
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseEmulation_onMouseUp);	
					stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseEmulation_onMouseWheel);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseEmulation_onMouseMove);
				} catch (e:Error) {
					;
				}
				//delete dt.touchEmulation_wheelMover;
				//delete dt.touchEmulation_wheelMover.onMouseWheel = onMouseWheel;
				dt.touchEmulation_dragging=false;
				return false;
			}

			//var text_txt:TextField=TextField(stage.getChildByName("text_txt"));
			//trace("text_txt="+text_txt);
			//text_txt.text = "Entering enableTouchEmulation";
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseEmulation_onMouseDown);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEmulation_onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseEmulation_onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseEmulation_onMouseWheel);
			//
			//dt.touchEmulation_wheelMover = new Object();
			////dt.touchEmulation_wheelMover.onMouseWheel = function( delta ) {
			//dt.touchEmulation_wheelMover.onMouseWheel;
			////Mouse.addListener(dt.touchEmulation_wheelMover);
			
			return true;
		}

		function mouseEmulation_onMouseWheel(e:MouseEvent) {
			var delta:Number = e.delta;
			var x:Number = e.stageX; //_root._xmouse;
			var y:Number = e.stageY; // _root._ymouse;
			var bboxMinSize:Number = 51;
			if (dt.touchEmulation_dragging) {
				if (delta<0) {
					dt.touchEmulation_bboxSize += dt.touchEmulation_bboxWheelDelta;
					if (dt.touchEmulation_bboxMinSize > 0) {
						bboxMinSize = dt.touchEmulation_bboxMinSize;
					}
					if (dt.touchEmulation_bboxSize<bboxMinSize) {
						dt.touchEmulation_bboxSize = bboxMinSize;
					}
					//generateDTEventFromMouseEvent(2, x, y, x, y, x+dt.touchEmulation_bboxSize*4, y+dt.touchEmulation_bboxSize);
					generateDTEventFromMouseEvent(2, x, y, x, y, x+dt.touchEmulation_bboxSize, y+dt.touchEmulation_bboxSize*4);
				} else {
					dt.touchEmulation_bboxSize -= dt.touchEmulation_bboxWheelDelta;
					if (dt.touchEmulation_bboxSize<0) {
						dt.touchEmulation_bboxSize = dt.touchEmulation_bboxMinSize;
					}
					//generateDTEventFromMouseEvent(2, x, y, x, y,x+dt.touchEmulation_bboxSize*4,y+dt.touchEmulation_bboxSize);
					generateDTEventFromMouseEvent(2, x, y, x, y,x+dt.touchEmulation_bboxSize,y+dt.touchEmulation_bboxSize*4);
				}
			}
		}
			
		function generateDTEventFromMouseEvent(action:Number, x:Number, y:Number, ulx:Number=0, uly:Number=0, lrx:Number=0, lry:Number=0) {
			var gestureAction:String="None";
			var gesturePosture:String="";
			var gestureMovement:String="";
			var gestureSizing:String="";
			var segments:Number=2;		// FOR TOUCH ZOOM VIEWER, WE NEED SEGMENT COUNT OF 2!
			if (arguments.length<4) {
				ulx=x;
				uly=y;
				lrx=x+Math.max(dt.touchEmulation_bboxSize*4,dt.touchEmulation_bboxMinSize*4);
				lry=y+Math.max(dt.touchEmulation_bboxSize,dt.touchEmulation_bboxMinSize);
			}
			var receiver:Number=-2;
			for (var ky:int=0; ky<keysdown.length; ky++) {
				var val:Number=Number(keysdown[ky]);
				if (val==48) {// NUMBER_0
					receiver=0;
				}
				if (val==49) {
					receiver=1;
				}
				if (val==50) {
					receiver=2;
				}
				if (val==51) {
					receiver=3;
				}
				if (val==52) {
					receiver=4;
				}
				if (receiver==-2) {
					continue;
				}

				//if (Key.isToggled(Key.CAPSLOCK))
				//segments = 2;

				var dtev:TouchEventData=new TouchEventData(receiver,action,x,y,ulx,uly,lrx,lry);
				var xSeg = Math.round((dtev.ulx + dtev.lrx)/2);
				var ySeg = Math.round((dtev.uly + dtev.lry)/2);
				dt.DtXSegmentString=String.fromCharCode(xSeg) +
				String.fromCharCode(xSeg) + String.fromCharCode(xSeg);
				dt.DtYSegmentString=String.fromCharCode(ySeg) +
				String.fromCharCode(ySeg) + String.fromCharCode(ySeg) ;
				dt.DtXSignalString="";
				dt.DtYSignalString="";

				if (action==3) {
					segments=1;
				}
				dt.DtEvent = "receiver="+dtev.receiver+"&action="+dtev.eventType+
				"&x="+dtev.x+"&y="+dtev.y+"&ulx="+dtev.ulx+"&uly="+dtev.uly+
				"&lrx="+dtev.lrx+"&lry="+dtev.lry+
				"&valid=true&useStageRelativeCoordinates=true" +
				"&xSegmentCount="+segments+"&ySegmentCount="+segments+
				"&timestamp=" + (new Date()).time+
				"&gestureAction="+gestureAction+
				"&gesturePosture="+gesturePosture+
				"&gestureMovement="+gestureMovement+
				"&gestureSizing="+gestureSizing;
			}
		}

		function mouseEmulation_onMouseDown(e:MouseEvent) {
			dt.touchEmulation_dragging=true;
			generateDTEventFromMouseEvent(1, e.stageX, e.stageY);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseEmulation_onMouseMove);
		}
			
		function mouseEmulation_onMouseMove(e:MouseEvent) {
			if (dt.touchEmulation_dragging) {
				generateDTEventFromMouseEvent(2, e.stageX, e.stageY);
			}
		}
			
		function mouseEmulation_onMouseUp(e:MouseEvent) {
			generateDTEventFromMouseEvent(3, e.stageX, e.stageY);
			dt.touchEmulation_dragging=false;
			dt.touchEmulation_bboxSize=0;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseEmulation_onMouseMove);
		}		


		/**************************************************************************/
		/* Private functions                                                      */
		/**************************************************************************/
		private function recordStageAndPlayerDimensions(forceAuthoredDimensionsReload:Boolean=true):void {
			trace("recordStageAndPlayerDimensions");
			clearInterval(dt.stageDimsPid);
			var originalScaleMode=stage.scaleMode;
			
//			var text_txt:TextField = MovieClip(parent).text_txt;
			
			
			//stage.scaleMode="noScale";
			//dt.player_width=stage.width;
			//dt.player_height=stage.height;
			//if (dt.authored_stage_width==-1||forceAuthoredDimensionsReload) {
				//stage.scaleMode="showAll";
				//dt.authored_stage_width=stage.width;
				//dt.authored_stage_height=stage.height;
			//}
			//stage.scaleMode=originalScaleMode;
			dt.player_width=stage.stageWidth;  // varies with stage size
			dt.player_height=stage.stageHeight; // varies with stage size
			dt.authored_stage_width=stage.width; // never changes -- authored value?
			dt.authored_stage_height=stage.height;// never changes -- authored value?
			
			//text_txt.text = ":: player_width=" + dt.player_width+","+dt.player_height+"  authored_stage_width=" + dt.authored_stage_width+","+dt.authored_stage_height;
			
			switch (stage.align) {
				case "" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width)/2;
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height)/2;
					dt.player_lr.x = dt.authored_stage_width + (dt.player_width-dt.authored_stage_width)/2;
					dt.player_lr.y = dt.authored_stage_height + (dt.player_height-dt.authored_stage_height)/2;
					break;
				case "B" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width)/2;
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height);
					dt.player_lr.x = dt.authored_stage_width +
					(dt.player_width-dt.authored_stage_width)/2;
					dt.player_lr.y=dt.authored_stage_height;
					break;
				case "T" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width)/2;
					dt.player_ul.y=0;
					dt.player_lr.x = dt.authored_stage_width +
					(dt.player_width-dt.authored_stage_width)/2;
					dt.player_lr.y = dt.authored_stage_height +
					(dt.player_height-dt.authored_stage_height);
					break;
				case "L" :
					dt.player_ul.x=0;
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height)/2;
					dt.player_lr.x = dt.authored_stage_width +
					(dt.player_width-dt.authored_stage_width);
					dt.player_lr.y = dt.authored_stage_height +
					(dt.player_height-dt.authored_stage_height)/2;
					break;
				case "LB" :
					dt.player_ul.x=0;
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height);
					dt.player_lr.x = dt.authored_stage_width +
					(dt.player_width-dt.authored_stage_width);
					dt.player_lr.y=dt.authored_stage_height;
					break;
				case "LT" :
					dt.player_ul={x:0,y:0};
					dt.player_lr.x = dt.authored_stage_width +
					(dt.player_width-dt.authored_stage_width);
					dt.player_lr.y = dt.authored_stage_height +
					(dt.player_height-dt.authored_stage_height);
					break;
				case "R" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width);
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height)/2;
					dt.player_lr.x=dt.authored_stage_width;
					dt.player_lr.y = dt.authored_stage_height +
					(dt.player_height-dt.authored_stage_height)/2;
					break;
				case "RB" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width);
					dt.player_ul.y = 0-(dt.player_height-dt.authored_stage_height);
					dt.player_lr.x=dt.authored_stage_width;
					dt.player_lr.y=dt.authored_stage_height;
					break;
				case "RT" :
				case "TR" :
					dt.player_ul.x = 0-(dt.player_width-dt.authored_stage_width);
					dt.player_ul.y=0;
					dt.player_lr.x=dt.authored_stage_width;
					dt.player_lr.y = dt.authored_stage_height +
					(dt.player_height-dt.authored_stage_height);
					break;
			}
			dt.player_left=dt.player_ul.x;
			dt.player_top=dt.player_ul.y;
			dt.player_right=dt.player_lr.x;
			dt.player_bottom=dt.player_lr.y;
			//text_txt.text = ":: player_width=" + dt.player_width+","+dt.player_height+"  authored_stage_width=" + dt.authored_stage_width+","+dt.authored_stage_height+
			//"   player_left/top/right/bottom=" + dt.player_left+","+dt.player_top+","+ dt.player_right+","+dt.player_bottom;
		}

		private function enableCursorAndTouchBox(mode:Number) {
			//root.createEmptyMovieClip("cursor_container_mc", 1009000);
			var cursor_container_mc:MovieClip = new MovieClip();
			cursor_container_mc.name="cursor_container_mc";
			stage.addChild(cursor_container_mc);
			if (mode==0||mode==2) {
				for (var i:Number=0; i < MAX_TOUCHERS; i++) {
					var cursor_child_mc:MovieClip = new MovieClip();
					cursor_child_mc.name="bbox"+i+"_mc";
					cursor_container_mc.addChild(cursor_child_mc);
					//root.cursor_container_mc.createEmptyMovieClip(
					//"bbox"+i+"_mc", i*2+1 );
				}
			}
			if (mode==0||mode==1) {
				for (var i2:Number=0; i2 < MAX_TOUCHERS; i2++) {
					var cursor_child_mc2:MovieClip = new MovieClip();
					cursor_child_mc2.name="cursor"+i2+"_mc";
					cursor_container_mc.addChild(cursor_child_mc2);
					//root.cursor_container_mc.createEmptyMovieClip(
					//"cursor"+i2+"_mc", (i2+1)*2 );
				}
			}
			dt.addObserver(cursor_container_mc, null);//, true);
			clearInterval(dt.cursorAndTouchBoxPid);
			dt.cursorAndTouchBoxPid=setInterval(dt.callCursorAndTouchBoxContainerResize,200);
			cursor_container_mc.onResize = function(e:Event) {
			trace("Got cursor_container_mc.onResize");
			clearInterval(dt.cursorAndTouchBoxPid);
			dt.cursorAndTouchBoxPid = setInterval(dt.callCursorAndTouchBoxContainerResize, 200 );
			};
			stage.addEventListener(Event.RESIZE, cursor_container_mc.onResize);
			cursor_container_mc.onToucherDown=dt.cursorToucherDown;
			cursor_container_mc.onToucherUp=dt.cursorToucherUp;
			this.addEventListener(TouchEvent.TOUCHDOWN, cursor_container_mc.onToucherDown);
			this.addEventListener(TouchEvent.TOUCHUP, cursor_container_mc.onToucherUp);
		}

		private function disableCursorAndTouchBox(mode:Number) {
			clearInterval(dt.cursorAndTouchBoxPid);
			//Stage.removeListener(_root.cursor_container_mc);
			var cursor_container_mc:MovieClip=MovieClip(stage.getChildByName("cursor_container_mc"));
			stage.removeEventListener(Event.RESIZE, cursor_container_mc.onResize);
			for (var i:Number=0; i < MAX_TOUCHERS; i++) {
				var cursorChild_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("cursor"+i+"_mc"));
				cursor_container_mc.removeChild(cursorChild_mc);
				var bboxChild_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("bbox"+i+"_mc"));
				cursor_container_mc.removeChild(bboxChild_mc);
				//cursor_container_mc.removeMovieClip( "cursor"+i+"_mc" );
				//cursor_container_mc.removeMovieClip( "bbox"+i+"_mc" );
			}
			delete cursor_container_mc.onToucherMove;
			delete cursor_container_mc.onToucherDown;
			delete cursor_container_mc.onToucherUp;
			stage.removeChild(cursor_container_mc);
		}

		private function callCursorAndTouchBoxContainerResize() {
			clearInterval(dt.cursorAndTouchBoxPid);
			dt.cursorAndTouchBoxContainerResize();
		}

		private function cursorAndTouchBoxContainerResize() {
			var cursor_container_mc:MovieClip=MovieClip(stage.getChildByName("cursor_container_mc"));
			cursor_container_mc.graphics.clear();
		}

		private function cursorToucherDown(e:TouchEvent) {
			var dtev:TouchEventData=e.dtev;
			var cursor_container_mc:MovieClip=MovieClip(stage.getChildByName("cursor_container_mc"));
			//trace("Entering cursorToucherDown(): cursor_container_mc="+cursor_container_mc);
			if (cursor_container_mc.touchersDown==undefined) {
				cursor_container_mc.touchersDown=0;
			}//swapToTop( _root.cursor_container_mc );
			stage.addChild(cursor_container_mc);//swap to top
			cursor_container_mc.touchersDown++;
			cursor_container_mc.onToucherMove=dt.cursorToucherMove;
			this.addEventListener(TouchEvent.TOUCHMOVE, cursor_container_mc.onToucherMove);
			//cursor_container_mc.onToucherMove(obj, dtev);
			cursor_container_mc.onToucherMove(e);
		}

		private function cursorToucherMove(e:TouchEvent) {
			var dtev:TouchEventData=e.dtev;
			//swapToTop( _root.cursor_container_mc );
			var cursor_container_mc:MovieClip=MovieClip(stage.getChildByName("cursor_container_mc"));
			stage.addChild(cursor_container_mc);// swap to top
			var cursor_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("cursor"+dtev.receiver+"_mc"));
			//trace("Entering cursorToucherMove(): cursor_mc="+cursor_mc);
			cursor_mc.graphics.clear();
			cursor_mc.graphics.lineStyle( 0, dt.getToucherColor( dtev.receiver ) );
			cursor_mc.graphics.moveTo(dtev.x-4, dtev.y);
			cursor_mc.graphics.lineTo(dtev.x+5, dtev.y);
			cursor_mc.graphics.moveTo(dtev.x, dtev.y-4);
			cursor_mc.graphics.lineTo(dtev.x, dtev.y+5);

			//var bbox_mc:MovieClip =
			//_root.cursor_container_mc["bbox"+dtev.receiver+"_mc"];
			var bbox_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("bbox"+dtev.receiver+"_mc"));
			bbox_mc.graphics.clear();
			bbox_mc.graphics.lineStyle( 0, dt.getToucherColor( dtev.receiver ) );
			bbox_mc.graphics.moveTo(dtev.ulx, dtev.uly);
			bbox_mc.graphics.lineTo(dtev.ulx, dtev.lry);
			bbox_mc.graphics.lineTo(dtev.lrx, dtev.lry);
			bbox_mc.graphics.lineTo(dtev.lrx, dtev.uly);
			bbox_mc.graphics.lineTo(dtev.ulx, dtev.uly);
		}

		private function cursorToucherUp(e:TouchEvent) {
			var dtev:TouchEventData=e.dtev;
			var cursor_container_mc:MovieClip=MovieClip(stage.getChildByName("cursor_container_mc"));
			//cursor_container_mc["cursor"+dtev.receiver+"_mc"].clear();
			var cursor_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("cursor"+dtev.receiver+"_mc"));
			cursor_mc.graphics.clear();
			//_root.cursor_container_mc["bbox"+dtev.receiver+"_mc"].clear();
			var bbox_mc:MovieClip=MovieClip(cursor_container_mc.getChildByName("bbox"+dtev.receiver+"_mc"));
			//trace("Entering cursorToucherUp(): cursor_container_mc.onToucherMove="+cursor_container_mc.onToucherMove);
			bbox_mc.graphics.clear();
			cursor_container_mc.touchersDown--;
			if (cursor_container_mc.touchersDown==0) {
				cursor_container_mc.removeEventListener(TouchEvent.TOUCHMOVE, cursor_container_mc.onToucherMove);
				delete cursor_container_mc.onToucherMove;
			}
		}

		private function adjustForStageAlignAndScaleMode(dtev:TouchEventData) {
			switch (stage.scaleMode) {
				case "noScale" :
					switch (stage.align) {
						case "" :
						case "B" :
						case "T" :
							dtev.x = dtev.x -
							(dt.player_width-dt.authored_stage_width)/2;
							dtev.ulx = dtev.ulx -
							(dt.player_width-dt.authored_stage_width)/2;
							dtev.lrx = dtev.lrx -
							(dt.player_width-dt.authored_stage_width)/2;
							if (dt.eventSegmentEnable) {
								for (var i=0; i<dtev.xSegments.length; i++) {
									var pw:Number=dt.player_width;
									var aw:Number=dt.authored_stage_width;
									dtev.xSegmentsIdx( i,
									dtev.xSegments[i] - (pw-aw)/2 );
								}
							}
							break;
						case "L" :
						case "LB" :
						case "LT" :
							break;
						case "R" :
						case "RB" :
						case "RT" :
						case "TR" :
							dtev.x = dtev.x -
							(dt.player_width-dt.authored_stage_width);
							dtev.ulx = dtev.ulx -
							(dt.player_width-dt.authored_stage_width);
							dtev.lrx = dtev.lrx -
							(dt.player_width-dt.authored_stage_width);
							if (dt.eventSegmentEnable) {
								for (var i2=0; i2<dtev.xSegments.length; i2++) {
									var pw2:Number=dt.player_width;
									var aw2:Number=dt.authored_stage_width;
									dtev.xSegmentsIdx( i2,
									dtev.xSegments[i2]-(pw2-aw2) );
								}
							}
							break;
					}
					switch (stage.align) {
						case "" :
						case "L" :
						case "R" :
							dtev.y = dtev.y -
							(dt.player_height-dt.authored_stage_height)/2;
							dtev.uly = dtev.uly -
							(dt.player_height-dt.authored_stage_height)/2;
							dtev.lry = dtev.lry -
							(dt.player_height-dt.authored_stage_height)/2;
							if (dt.eventSegmentEnable) {
								for (var i3=0; i3<dtev.ySegments.length; i3++) {
									var ph8:Number=dt.player_height;
									var ah8:Number=dt.authored_stage_height;
									dtev.ySegmentsIdx( i3,
									dtev.ySegments[i3]-(ph8-ah8)/2 );
								}
							}
							break;
						case "B" :
						case "LB" :
						case "RB" :
							dtev.y = dtev.y -
							(dt.player_height-dt.authored_stage_height);
							dtev.uly = dtev.uly -
							(dt.player_height-dt.authored_stage_height);
							dtev.lry = dtev.lry -
							(dt.player_height-dt.authored_stage_height);
							if (dt.eventSegmentEnable) {
								for (var i4=0; i4<dtev.ySegments.length; i4++) {
									var ph4:Number=dt.player_height;
									var ah4:Number=dt.authored_stage_height;
									dtev.ySegmentsIdx( i4,
									dtev.ySegments[i4]-(ph4-ah4));
								}
							}
							break;
						case "T" :
						case "LT" :
						case "RT" :
						case "TR" :
							break;
					}
					break;
				case "exactFit" :
					dtev.x = Math.round(dtev.x *
					(dt.authored_stage_width / dt.player_width));
					dtev.y = Math.round(dtev.y *
					(dt.authored_stage_height / dt.player_height));
					dtev.ulx = Math.round(dtev.ulx *
					(dt.authored_stage_width / dt.player_width));
					dtev.uly = Math.round(dtev.uly *
					(dt.authored_stage_height / dt.player_height));
					dtev.lrx = Math.round(dtev.lrx *
					(dt.authored_stage_width / dt.player_width));
					dtev.lry = Math.round(dtev.lry *
					(dt.authored_stage_height / dt.player_height));
					if (dt.eventSegmentEnable) {
						for (var i5=0; i5<dtev.xSegments.length; i5++) {
							var aw3:Number=dt.authored_stage_width;
							var pw3:Number=dt.player_width;
							dtev.xSegmentsIdx( i5,
							Math.round( dtev.xSegments[i5] * (aw3/pw3) ) );
						}
						for (var i6=0; i6<dtev.ySegments.length; i6++) {
							var ah5:Number=dt.authored_stage_height;
							var ph5:Number=dt.player_height;
							dtev.ySegmentsIdx( i6,
							Math.round( dtev.ySegments[i6] * (ah5/ph5) ) );
						}
					}
					break;
				case "showAll" :
					if ((dt.player_width/dt.player_height) >
					(dt.authored_stage_width/dt.authored_stage_height)) {
						dtev.y = Math.round(dtev.y *
						(dt.authored_stage_height/dt.player_height));
						dtev.uly = Math.round(dtev.uly *
						(dt.authored_stage_height/dt.player_height));
						dtev.lry = Math.round(dtev.lry *
						(dt.authored_stage_height/dt.player_height));
						if (dt.eventSegmentEnable) {
							for (var i7=0; i7<dtev.ySegments.length; i7++) {
								var ah2:Number=dt.authored_stage_height;
								var ph2:Number=dt.player_height;
								dtev.ySegmentsIdx( i7,
								Math.round( dtev.ySegments[i7] * (ah2/ph2) ) );
							}
						}
						var resized_stage_width =
						((dt.authored_stage_width / dt.authored_stage_height) *
						 dt.player_height);
						var offset_x=0;
						switch (stage.align) {
							case "L" :
							case "LB" :
							case "LT" :
								break;
							case "" :
							case "B" :
							case "T" :
								offset_x = (dt.player_width-resized_stage_width)/2;
								break;
							case "R" :
							case "RB" :
							case "RT" :
							case "TR" :
								offset_x = (dt.player_width - resized_stage_width);
								break;
						}
						dtev.x = Math.round((dtev.x - offset_x) *
						(dt.authored_stage_width / resized_stage_width));
						dtev.ulx = Math.round((dtev.ulx - offset_x) *
						(dt.authored_stage_width / resized_stage_width));
						dtev.lrx = Math.round((dtev.lrx - offset_x) *
						(dt.authored_stage_width / resized_stage_width));
						if (dt.eventSegmentEnable) {
							for (var i8=0; i8<dtev.xSegments.length; i8++) {
								var aw4:Number=dt.authored_stage_width;
								dtev.xSegmentsIdx( i8,
								Math.round((dtev.xSegments[i8] - offset_x) *
								(aw4 / resized_stage_width)));
							}
						}
					} else {
						dtev.x = Math.round(dtev.x *
						(dt.authored_stage_width/dt.player_width));
						dtev.ulx = Math.round(dtev.ulx *
						(dt.authored_stage_width/dt.player_width));
						dtev.lrx = Math.round(dtev.lrx *
						(dt.authored_stage_width/dt.player_width));
						var resized_stage_height =
						((dt.authored_stage_height / dt.authored_stage_width) *
						 dt.player_width);
						if (dt.eventSegmentEnable) {
							for (var i9=0; i9<dtev.xSegments.length; i9++) {
								var aw5:Number=dt.authored_stage_width;
								var pw5:Number=dt.player_width;
								dtev.xSegmentsIdx( i9,
								Math.round( dtev.xSegments[i9] * (aw5/pw5) ) );
							}
						}
						var offset_y=0;
						switch (stage.align) {
							case "LT" :
							case "T" :
							case "RT" :
							case "TR" :
								break;
							case "L" :
							case "" :
							case "R" :
								offset_y =
								(dt.player_height - resized_stage_height) / 2;
								break;
							case "LB" :
							case "B" :
							case "RB" :
								offset_y =
								(dt.player_height - resized_stage_height);
								break;
						}
						dtev.y = Math.round((dtev.y - offset_y) *
						(dt.authored_stage_height / resized_stage_height));
						dtev.uly = Math.round((dtev.uly - offset_y) *
						(dt.authored_stage_height / resized_stage_height));
						dtev.lry = Math.round((dtev.lry - offset_y) *
						(dt.authored_stage_height / resized_stage_height));
						if (dt.eventSegmentEnable) {
							for (var i10=0; i10<dtev.ySegments.length; i10++) {
								var ah6:Number=dt.authored_stage_height;
								dtev.ySegmentsIdx( i10,
								Math.round((dtev.ySegments[i10] - offset_y) *
								(ah6 / resized_stage_height)));
							}
						}
					}
					break;
				case "noBorder" :
					if ((dt.player_width/dt.player_height) >
					(dt.authored_stage_width/dt.authored_stage_height)) {
						dtev.x = Math.round(dtev.x *
						(dt.authored_stage_width/dt.player_width));
						dtev.ulx = Math.round(dtev.ulx *
						(dt.authored_stage_width/dt.player_width));
						dtev.lrx = Math.round(dtev.lrx *
						(dt.authored_stage_width/dt.player_width));
						var resized_stage_height2 =
						(dt.authored_stage_height / dt.authored_stage_width) *
						dt.player_width;
						if (dt.eventSegmentEnable) {
							for (var i11=0; i11<dtev.xSegments.length; i11++) {
								var aw6:Number=dt.authored_stage_width;
								var pw6:Number=dt.player_width;
								dtev.xSegmentsIdx( i11,
								Math.round(dtev.xSegments[i11] * (aw6/pw6) ) );
							}
						}
						var offset_y2=0;
						switch (stage.align) {
							case "LT" :
							case "T" :
							case "RT" :
							case "TR" :
								break;
							case "L" :
							case "" :
							case "R" :
								offset_y2 =
								(resized_stage_height2 - dt.player_height) / 2;
								break;
							case "LB" :
							case "B" :
							case "RB" :
								offset_y2 =
								(resized_stage_height2 - dt.player_height);
								break;
						}
						dtev.y = Math.round((dtev.y + offset_y2) *
						(dt.authored_stage_height / resized_stage_height2));
						dtev.uly = Math.round((dtev.uly + offset_y2) *
						(dt.authored_stage_height / resized_stage_height2));
						dtev.lry = Math.round((dtev.lry + offset_y2) *
						(dt.authored_stage_height / resized_stage_height2));
						if (dt.eventSegmentEnable) {
							for (var i12=0; i12<dtev.ySegments.length; i12++) {
								var ah3:Number=dt.authored_stage_height;
								dtev.ySegmentsIdx( i12,
								Math.round((dtev.ySegments[i12] + offset_y2) *
								(ah3 / resized_stage_height2)));
							}
						}
					} else {
						dtev.y = Math.round(dtev.y *
						(dt.authored_stage_height/dt.player_height));
						dtev.uly = Math.round(dtev.uly *
						(dt.authored_stage_height/dt.player_height));
						dtev.lry = Math.round(dtev.lry *
						(dt.authored_stage_height/dt.player_height));
						var resized_stage_width2 =
						(dt.authored_stage_width / dt.authored_stage_height) *
						dt.player_height;
						if (dt.eventSegmentEnable) {
							for (var i13=0; i13<dtev.ySegments.length; i13++) {
								var ah7:Number=dt.authored_stage_height;
								var ph7:Number=dt.player_height;
								dtev.ySegmentsIdx( i13,
								Math.round( dtev.ySegments[i13] * (ah7/ph7) ) );
							}
						}
						var offset_x2=0;
						switch (stage.align) {
							case "L" :
							case "LB" :
							case "LT" :
								break;
							case "" :
							case "B" :
							case "T" :
								offset_x2 =
								(resized_stage_width2 - dt.player_width) / 2;
								break;
							case "R" :
							case "RB" :
							case "RT" :
							case "TR" :
								offset_x2 =
								(resized_stage_width2 - dt.player_width);
								break;
						}
						dtev.x = Math.round((dtev.x + offset_x2) *
						(dt.authored_stage_width / resized_stage_width2));
						dtev.ulx = Math.round((dtev.ulx + offset_x2) *
						(dt.authored_stage_width / resized_stage_width2));
						dtev.lrx = Math.round((dtev.lrx + offset_x2) *
						(dt.authored_stage_width / resized_stage_width2));
						if (dt.eventSegmentEnable) {
							for (var i14=0; i14<dtev.xSegments.length; i14++) {
								var aw7:Number=dt.authored_stage_width;
								dtev.xSegmentsIdx( i14,
								Math.round((dtev.xSegments[i14] + offset_x2) *
								(aw7 / resized_stage_width2)));
							}
						}
					}
					break;
			}
		}

		private function processNextEvent():void {
			if (EventQueue.length==0) {
				return;
			}
			clearInterval( queueIntervalID );

			var queue:Array=EventQueue;
			EventQueue = new Array();

			while ( queue.length != 0 ) {
				var event:Object=queue.shift();
				if (! event.processed) {
					if (event.dtev.eventType==2) {
						var receiver:Number=event.dtev.receiver;
						var len:Number=queue.length;
						for (var i:Number=0; i < len; i++) {
							if (queue[i].dtev.receiver!=receiver) {
								continue;
							}
							if (queue[i].dtev.eventType!=2) {
								break;
							}
							event=queue[i];
							event.processed=true;
						}
					}

					if (! event.useStageRelativeCoordinates) {
						dt.adjustForStageAlignAndScaleMode(event.dtev);
					}

					dt.setChanged();
					dt.notifyObservers(event.dtev);
				}
			}

			var delay:Number=EventQueue.length>0?0:eventProcessDelay;
			queueIntervalID=setInterval(processNextEvent,delay);
		}

		private function parseConfig( config_xml:XML ):void {
			var document:XMLNode=config_xml.firstChild;
			var properties:Array=document.childNodes;
			for (var i:Number=0; i < properties.length; i++) {
				var node:XMLNode=properties[i];
				var property:String=node.nodeName.toLowerCase();
				var value:String=node.firstChild.nodeValue;

				var n:Number=parseInt(value);
				var b:Boolean;
				if (value.toLowerCase()=="true") {
					b=true;
				} else if ( value.toLowerCase() == "false" ) {
					b=false;

				}
				switch ( property ) {
					case "numberoftouchers" :
						if (! isNaN(n)) {
							numberOfTouchers=n;
						}
						break;
					case "mousereceiver" :
						if (! isNaN(n)) {
							mouseReceiver=n;
						}
						break;
					case "toucherrotationstring" :
						toucherRotationString=value;
						break;
					case "antennapitchum" :
						if (! isNaN(n)) {
							antennaPitchUm=n;
						}
						break;
					case "xantennacount" :
						if (! isNaN(n)) {
							xAntennaCount=n;
						}
						break;
					case "yantennacount" :
						if (! isNaN(n)) {
							yAntennaCount=n;
						}
						break;
					case "eventsegmentenable" :
						eventSegmentEnable=b;
						break;
					case "eventsignalenable" :
						eventSignalEnable=b;
						break;
					case "screencoordinatesenable" :
						screenCoordinatesEnable=b;
						break;
					case "touchercolorstring" :
						toucherColorString=value;
						break;
					case "tapinterval" :
						if (! isNaN(n)) {
							setTapInterval( n );
						}
						break;
					case "hoverinitialdelay" :
						if (! isNaN(n)) {
							setHoverInitialDelay( n );
						}
						break;
					case "hoverrepeatdelay" :
						if (! isNaN(n)) {
							setHoverRepeatDelay( n );
						}
						break;
					case "hoverproximityinpixels" :
						if (! isNaN(n)) {
							setHoverProximityInPixels( n );
						}
						break;
					case "hovergeneratedformovepauses" :
						setHoverGeneratedForMovePauses( b );
						break;
					case "eventprocessdelay" :
						if (! isNaN(n)) {
							eventProcessDelay=n;
						}
						break;
					case "aggressivesegmentcount" :
						aggressiveSegmentCount=b;
						break;
					case "reversenotification" :
						reverseNotification=b;
						break;
					case "listenforexit" :
						ListenForExit=b;
						break;
				}
			}

			// Debugging output for loading properties
			//        _root.debug_txt.msg( "numberOfTouchers="+numberOfTouchers );
			//        _root.debug_txt.msg( "mouseReceiver="+mouseReceiver );
			//        _root.debug_txt.msg( "toucherRotationString="+toucherRotationString );
			//        _root.debug_txt.msg( "antennaPitchUm="+antennaPitchUm );
			//        _root.debug_txt.msg( "xAntennaCount="+xAntennaCount );
			//        _root.debug_txt.msg( "yAntennaCount="+yAntennaCount );
			//        _root.debug_txt.msg( "eventSegmentEnable="+eventSegmentEnable );
			//        _root.debug_txt.msg( "eventSignalEnable="+eventSignalEnable );
			//        _root.debug_txt.msg( "screenCoordinatesEnable="+screenCoordinatesEnable );
			//        _root.debug_txt.msg( "toucherColorString="+toucherColorString );
			//        _root.debug_txt.msg( "tapInterval="+getTapInterval() );
			//        _root.debug_txt.msg( "hoverInitialDelay="+getHoverInitialDelay() );
			//        _root.debug_txt.msg( "hoverRepeatDelay="+getHoverRepeatDelay() );
			//        _root.debug_txt.msg( "hoverProximityInPixels="+getHoverProximityInPixels() );
			//        _root.debug_txt.msg( "hoverGeneratedForMovePauses="+getHoverGeneratedForMovePauses() );
			//        _root.debug_txt.msg( "eventProcessDelay="+eventProcessDelay );
		}
	}
}