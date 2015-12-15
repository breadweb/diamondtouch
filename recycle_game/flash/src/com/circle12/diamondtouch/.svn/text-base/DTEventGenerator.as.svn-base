package com.circle12.diamondtouch
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	public class DTEventGenerator {
		/**************************************************************************/
		/* Constants                                                              */
		/**************************************************************************/
		public static var MAX_TOUCHERS:Number = 10; 
	
	
		/**************************************************************************/
		/* Class Variables                                                        */
		/**************************************************************************/
		public var boundingBox_MinimumSize:Number = 50;
		public var tapInterval:Number = 500;
		public var hoverInitialDelay:Number = 3000;
		public var hoverRepeatDelay:Number = 1000;
		public var hoverProximityInPixels:Number = 10;
		public var hoverGeneratedForMovePauses:Boolean = false;
		public var aggressiveSegmentCount:Boolean = false;
		public var reverseNotification:Boolean = false;
		private var _stage:Stage = null;
		
		[ArrayElementType(DisplayObject)]
		private var toucher_startToucherDrag:Array;
		[ArrayElementType(Point)]
		private var toucher_startToucherDragRotateTowardsPoint:Array;
		[ArrayElementType(Point)]
		private var toucher_startToucherDragFirstPoint:Array;
		[ArrayElementType(Rectangle)]
		private var toucher_startToucherDragLimitsRectangle:Array;
		[ArrayElementType(DisplayObject)]
		private var toucher_gotDownEvent:Array;
		[ArrayElementType(Boolean)]
		private var toucher_trackAsMenuDuringPress:Array;
		[ArrayElementType(Boolean)]
		private var toucher_draggedOut:Array;
		[ArrayElementType(Number)]
		private var toucher_hoverIntervalPid:Array;
		[ArrayElementType(Point)]
		private var toucher_hoverStartLocation:Array;
		[ArrayElementType(Boolean)]
		private var toucher_secondFingerDown:Array;
		[ArrayElementType(Number)]
		private var toucher_secondFingerTimestamp:Array;
		[ArrayElementType(Number)]
		private var toucher_segmentCountLast:Array;
		[ArrayElementType(Boolean)]
		private var toucher_segmentCountChanged:Array;
		[ArrayElementType(Number)]
		private var toucher_lastClickTimestamp:Array;
		[ArrayElementType(Number)]
		private var toucher_clickCount:Array;
		[ArrayElementType(DisplayObject)]
		private var toucher_gotRollover:Array;


		/**************************************************************************/
		/* Properties                                                             */
		/**************************************************************************/		
		public function get MainStage():Stage {
			return this._stage;
		}
	
	
		/**************************************************************************/
		/* Constructor                                                            */
		/**************************************************************************/
		public function DTEventGenerator( stage:Stage ) {
			if( stage == null )
				throw new Error( "You must provide the DTFlash library with a " +
					"reference to the stage upon instantiation" );
					
			this._stage = stage;
			
			toucher_startToucherDrag = new Array(MAX_TOUCHERS);
			toucher_startToucherDragRotateTowardsPoint = new Array(MAX_TOUCHERS);	
			toucher_startToucherDragFirstPoint = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_startToucherDragLimitsRectangle = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_gotDownEvent = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_trackAsMenuDuringPress = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_draggedOut = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_hoverIntervalPid = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_hoverStartLocation = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_secondFingerDown = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_secondFingerTimestamp = new Array( DiamondTouch.MAX_TOUCHERS );
			toucher_segmentCountLast = new Array(DiamondTouch.MAX_TOUCHERS);		
			toucher_segmentCountChanged = new Array(DiamondTouch.MAX_TOUCHERS);		
			toucher_gotRollover = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_lastClickTimestamp = new Array(DiamondTouch.MAX_TOUCHERS);
			toucher_clickCount = new Array(DiamondTouch.MAX_TOUCHERS);
	
			for (var i:Number=0; i<MAX_TOUCHERS; i++) {
				toucher_gotDownEvent[i] = null;
				toucher_trackAsMenuDuringPress[i] = false;
				toucher_draggedOut[i] = false;
				toucher_clickCount[i] = 0;
				toucher_lastClickTimestamp[i] = 0;
				toucher_hoverIntervalPid[i] = null;
				toucher_hoverStartLocation[i] = null;
				toucher_startToucherDrag[i] = null;
				toucher_startToucherDragFirstPoint[i] = null;
				toucher_startToucherDragRotateTowardsPoint[i] = null;
				toucher_startToucherDragLimitsRectangle[i] = null;
				toucher_secondFingerDown[i] = false;
				toucher_secondFingerTimestamp[i] = 0;
				toucher_segmentCountLast[i] = [ 0, 0 ];
				toucher_segmentCountChanged[i] = false;
			}
		}
	
	
		//*******************************************************************//
		// Protected functions                                               //
		//*******************************************************************//
		protected function notifyObservers( data:TouchEventData ):void {
			if (data == null) return;
	
			// first things first ... move the observer that
			// is being dragged by the toucher
			var receiver:Number = data.receiver;
			if( toucher_startToucherDrag[receiver] != null )
				continueToucherDrag( toucher_startToucherDrag[receiver], data );
	
			// Check for a segment count change
			var oldSegments:Array = toucher_segmentCountLast[data.receiver];
			var maxOldSegments:Number =
				Math.max( oldSegments[0], oldSegments[1] );
			var newSegments:Array = [ data.xSegmentCount, data.ySegmentCount ];
			var maxSegments:Number = 
				Math.max( newSegments[0], newSegments[1] );
			toucher_segmentCountChanged[data.receiver] = false;
			if( aggressiveSegmentCount ) {
				if( oldSegments[0] != newSegments[0]
						|| oldSegments[1] != newSegments[1] )
					toucher_segmentCountChanged[data.receiver] = true;
			}
			else {
				if( maxOldSegments != maxSegments )
					toucher_segmentCountChanged[data.receiver] = true;
			}
			toucher_segmentCountLast[data.receiver] = newSegments;
	
			// find the top object, notify of primitive events
			// and then notify of higher-level events such as onToucherPress
			var top:DisplayObject = findTopObjectAndNotifyAll( data );
			var pressed:DisplayObject = toucher_gotDownEvent[data.receiver];
			dispatchAdvancedEvents( data, top, pressed );
		}
	
	
		//*******************************************************************//
		// Public functions                                                  //
		//*******************************************************************//
		public function debug( obj:Object ):void {
		}
		
		public function startToucherDrag( displayObject:DisplayObject,
				data:TouchEventData, lockCenter:Boolean = false,
				rotateTowardsPoint:Point = null, rect_limits:Object = null ):void {

			var toucher_downPt:Point = data.getReferencePoint();
			var saved_rotation:Number = displayObject.rotation;
			toucher_downPt = displayObject.parent.globalToLocal(toucher_downPt);
			if (lockCenter) {
				toucher_downPt.x = displayObject.x;
				toucher_downPt.y = displayObject.y;
			}
			toucher_startToucherDrag[data.receiver] = displayObject;
			var toucher_downPtOffset:Point = new Point(
				toucher_downPt.x - displayObject.x, toucher_downPt.y - displayObject.y );
			toucher_startToucherDragFirstPoint[data.receiver] = toucher_downPtOffset;
			toucher_startToucherDragRotateTowardsPoint[data.receiver] = rotateTowardsPoint;
			
			//toucher_startToucherDragLimitsRectangle[data.receiver] = {
			//	left:null, top:null, right:null, bottom:null };
		}
	
		public function stopToucherDrag( displayObject:DisplayObject, dtev:TouchEventData ):void {
			toucher_startToucherDrag[dtev.receiver] = null;
			toucher_startToucherDragFirstPoint[dtev.receiver] = null;
			toucher_startToucherDragRotateTowardsPoint[dtev.receiver] = null;
			toucher_startToucherDragLimitsRectangle[dtev.receiver] = null;
		}

		
		/**************************************************************************/
		/* Private functions                                                      */
		/**************************************************************************/
		private function continueToucherDrag(
				displayObject:DisplayObject, data:TouchEventData ):void {
			var saved_rotation:Number = displayObject.rotation;
			var toucher_movePt:Point;
			if( toucher_startToucherDrag[data.receiver] != null ) {
				toucher_movePt = data.getReferencePoint();
				toucher_movePt = displayObject.parent.globalToLocal(toucher_movePt);			
				displayObject.x = toucher_movePt.x -
					toucher_startToucherDragFirstPoint[data.receiver].x;
				displayObject.y = toucher_movePt.y -
					toucher_startToucherDragFirstPoint[data.receiver].y;
				var rect_limits:Rectangle =
					toucher_startToucherDragLimitsRectangle[data.receiver];
				if( rect_limits != null ) {
					if (displayObject.x < rect_limits.left)
						displayObject.x = rect_limits.left;
					if (displayObject.x > rect_limits.right)
						displayObject.x = rect_limits.right;
					if (displayObject.y < rect_limits.top)
						displayObject.y = rect_limits.top;
					if (displayObject.y > rect_limits.bottom)
						displayObject.y = rect_limits.bottom;				
				}
	
				var globalPointObj:Point =
					toucher_startToucherDragRotateTowardsPoint[data.receiver];
				if (globalPointObj != null)
					DiamondTouch.rotateTowardsPoint( displayObject, globalPointObj );
			}
		}

		/**
		 * Identifies the top object under the specified point.
		 */		
		private function topObjectUnderPoint( pt:Point ):DisplayObject
		{
			function _topObjectUnderPoint( obj:DisplayObject, pt:Point ):DisplayObject
			{
				if( obj == null || !obj.visible || obj.alpha == 0 )
					return null;
					
				if( obj is DTTouchCanvas )
					return null;
					
				var container:DisplayObjectContainer = obj as DisplayObjectContainer;
				if( container != null )
				{
					for( var i:Number=container.numChildren-1; i >= 0; i-- )
					{
						var child:DisplayObject = container.getChildAt(i);
						if( child.hitTestPoint( pt.x, pt.y, true ) )
						{
							var top:DisplayObject = _topObjectUnderPoint( child, pt );
							if( top != null )
								return top;
						}
					}
				}
				
				return obj;
			}
			
			var top:DisplayObject = null;
			if( MainStage.hitTestPoint( pt.x, pt.y ) )
				top = _topObjectUnderPoint( MainStage, pt );
			return top;
		}

	
		/**
		 * Identifies the topmost observer under the center of the toucher's
		 * bounding box and notifies ALL observers of the applicable primitive
		 * events.
		 * Primitive events are:
		 *   onToucherEvent, onToucherDown, onToucherMove, onToucherUp,
		 *   onGestureDown, onGestureMove, onGestureUp,
		 *   onToucherSegmentCountChanged.
		 */
		private function findTopObjectAndNotifyAll( data:TouchEventData ):DisplayObject {
			var pt:Point = data.getReferencePoint();
			var top:DisplayObject = topObjectUnderPoint( pt );
			var pressed:DisplayObject = toucher_gotDownEvent[data.receiver];
			dispatchPrimitiveEvents( data, top, pressed );
			
			return top;
		}
		
		protected function dispatchPrimitiveEvents( data:TouchEventData,
				top:DisplayObject, pressed:DisplayObject ):void {
			MainStage.dispatchEvent( new TouchEvent( TouchEvent.TOUCHER_EVENT, data ) );
	
			switch (data.action) {
				case TouchEvent.ACTION_TOUCH_DOWN:
					MainStage.dispatchEvent( new TouchEvent( TouchEvent.TOUCHER_DOWN, data ) );
					break;
				case TouchEvent.ACTION_TOUCH_MOVE:
					MainStage.dispatchEvent( new TouchEvent( TouchEvent.TOUCHER_MOVE, data ) );
					break;			
				case TouchEvent.ACTION_TOUCH_UP:
					MainStage.dispatchEvent( new TouchEvent( TouchEvent.TOUCHER_UP, data ) );
					break;
				default:
					break;
			}
	
			if( toucher_segmentCountChanged[data.receiver] ) {
				MainStage.dispatchEvent( new TouchEvent( TouchEvent.TOUCHER_SEGMENT_COUNT_CHANGED, data ) );
			}
	
			if( data.gestureAction != "None" ) {
				var gestureEvent:String = "gesture"+data.gestureAction;
				MainStage.dispatchEvent( new TouchEvent( gestureEvent, data ) );
			}
		}
		
		private function generateHover( top:DisplayObject, pressed:DisplayObject,
				data:TouchEventData, initialEvent:Boolean=false ):void {
			clearInterval( toucher_hoverIntervalPid[data.receiver] );
			data.initialHoverEvent = initialEvent ? true : false;
			top.dispatchEvent( new TouchEvent(
				TouchEvent.TOUCHER_HOVER, data ) );
			toucher_hoverIntervalPid[data.receiver] = setInterval(
					generateHover, hoverRepeatDelay, top, pressed, data );
		}

		/**
		 * Notification of second finger down/up/tap/move.  A second finger down
		 * happens when the segment count changes from 1 to 2 (or more generally
		 * from 1 to more than 1).  A second finger up happens when the segment
		 * count becomes less than 2.  A second finger tap happens when the following
		 * criteria are met:
		 * 1) The segment count changes from more than 1 to 0 
		 *     - or -
		 *    the segment count changes from more than 1 to 1 and the remaining
		 *      touch is within the original movieclip.
		 * 2) The time from the second finger down event to the second finger up
		 *      event is within the tap time threshold.
		 * @param dtev the event data associated with the event
		 * @param pressed the observer that has received the onToucherPress event
		 *                and has yet to receive the release event
		 * @param topObject the topmost observer that is currently under the center
		 *                  of the toucher's bounding box
		 */
		private function dispatchSecondFingerEvents( data:TouchEventData,
				pressed:DisplayObject, top:DisplayObject ):void {
			if( pressed != null ) {
				var last:Array = toucher_segmentCountLast[ data.receiver ];
				var maxLast:Number = Math.max( last[0], last[1] );
				var cur:Array = [ data.xSegmentCount, data.ySegmentCount ];
				var max:Number = Math.max( cur[0], cur[1] );
		
				var tapEligible:Boolean =
					toucher_secondFingerDown[ data.receiver ] && max < 2;
				if( max > 1 ) {
					if( !toucher_secondFingerDown[ data.receiver ] ) {
						pressed.dispatchEvent( new TouchEvent(
							TouchEvent.TOUCHER_SECOND_FINGER_DOWN, data ) );
						toucher_secondFingerDown[ data.receiver ] = true;
						toucher_secondFingerTimestamp[ data.receiver ] = data.timestamp;
					}
					else
						pressed.dispatchEvent( new TouchEvent(
							TouchEvent.TOUCHER_SECOND_FINGER_MOVE, data ) );
				}
				else
					toucher_secondFingerDown[ data.receiver ] = false;
		
		
				if( tapEligible ) {
					pressed.dispatchEvent( new TouchEvent(
						TouchEvent.TOUCHER_SECOND_FINGER_UP, data ) );
					if( toucher_secondFingerTimestamp[ data.receiver ] >
							data.timestamp-tapInterval && ( max == 0 ||
							top == pressed ) ) {
						pressed.dispatchEvent( new TouchEvent(
							TouchEvent.TOUCHER_SECOND_FINGER_TAP, data ) );
					}
				}
			}
		}
	
		/**
		 * Calls onToucherRollOut on the observer that first got the rollover.
		 * Also clears the state for the rollover.
		 * (ie: toucher_gotRollover[receiver] is cleared)
		 * @param dtev the event data associated with the event
		 */
		private function dispatchRollOut( data:TouchEventData,
				top:DisplayObject, pressed:DisplayObject ):void {
			var gotRollover:DisplayObject = toucher_gotRollover[data.receiver];
			if( gotRollover != null ) {
				//gotRollover.setToucherRolledOver( dtev.receiver, false );
				//dtev.rolledOverCount = gotRollover.rolledOverCount;
				gotRollover.dispatchEvent( new TouchEvent(
					TouchEvent.TOUCHER_ROLL_OUT, data ) );
				toucher_gotRollover[data.receiver] = null;
			}
		}
	
		/**
		 * Notification of rollovers.  A rollover for the table is a press
		 * and then a move over a different observer.
		 * Currently rollovers and rollouts assume that onToucherMove events
		 * happen very frequently.  The reason this is necessary is because when
		 * movieclips move, rollovers and rollouts perhaps need to be triggered.
		 * Since we don't know when movieclips are going to move, we rely on the
		 * fact that toucher moves are triggered very frequently and we will check
		 * for rollovers at that point.
		 * @param dtev the event data associated with the event
		 * @param pressed the observer that has received the onToucherPress event
		 *                and has yet to receive the release event
		 * @param topObject the topmost observer that is currently under the center
		 *                  of the toucher's bounding box
		 */
		private function dispatchRolloverEvents( data:TouchEventData,
				pressed:DisplayObject, top:DisplayObject ):void {
			var gotRollover:DisplayObject = toucher_gotRollover[data.receiver];
			var dragging:DisplayObject = toucher_startToucherDrag[data.receiver];
			if( data.action == 3 )
				// on a release, onToucherRollOut will be called unless there was
				// no observer that originally got the rollover
				dispatchRollOut( data, top, pressed );
			else {
				// First check for an onToucherRollOut event
				if( gotRollover != null ) {
					// Only call a rollout if the toucher is no longer over
					// the observer that already got the rollover AND
					// if the observer that got the rollover isn't now being
					// dragged by the toucher.  The second condition prevents
					// the observer from getting an onToucherRollOut when
					// there is really only a delay dragging of the
					// observer
					if( gotRollover != top && gotRollover != dragging ) {
						dispatchRollOut( data, top, pressed );
						gotRollover = undefined;
					}
				}
	
				// Now check for an onToucherRollOver event
				// onToucherRollOver is sent only if the following criteria are met:
				// 1) if the toucher isn't dragging
				// 2) if there is an observer under the center of the toucher's
				//    bounding box (ie: topObject exists)
				// 3) if the topmost observer under the toucher isn't the one
				//    that was pressed
				// 4) if the topmost observer isn't the observer that already received
				//    the rollover
				if( dragging == null && top != null && top != pressed &&
						top != gotRollover ) {
					gotRollover = top;
					gotRollover.dispatchEvent( new TouchEvent(
						TouchEvent.TOUCHER_ROLL_OVER, data ) );
					toucher_gotRollover[data.receiver] = gotRollover;
				}
			}
		}
	
		/**
		 * Notification of non-primitive events such as onToucherPress, etc.
		 * @param dtev the event data associated with the event
		 * @param top the topmost display object that is currently under the center
		 *                  of the toucher's bounding box
		 * @param pressed the display object that received the down event (if any)
		 */
		private function dispatchAdvancedEvents(
				data:TouchEventData, top:DisplayObject=null, 
				pressed:DisplayObject=null ):void {
			// Keep track of who got the onToucherPress event
			
			switch( data.action ) {
				
				case TouchEvent.ACTION_TOUCH_DOWN:
					clearInterval( toucher_hoverIntervalPid[data.receiver] );
					if( top != null ) {
						// Notify the top observer of the press.
						top.dispatchEvent( new TouchEvent(
							TouchEvent.TOUCHER_PRESS, data, true ) );
						toucher_gotDownEvent[data.receiver] = top;
						
						// Keep track of hover information.
						toucher_hoverStartLocation[data.receiver] = data.getReferencePoint();
						toucher_hoverIntervalPid[data.receiver] = setInterval(
								generateHover, hoverInitialDelay,
								top, pressed, data, true );
	
						// Keep track of menu tracking -- we don't deal with this yet.
						//toucher_trackAsMenuDuringPress[dtev.receiver] =
						//	topObject.data.observer.hasOwnProperty( "trackAsMenu" ) &&
						//	topObject.data.observer.trackAsMenu;
	
						// Keep track of whether the toucher has dragged out
						// of the observer's bounds or not. This is used for
						// onToucherDragOver and onToucherDragOut events.
						toucher_draggedOut[data.receiver] = false;
	
						// Send second finger down if applicable
						dispatchSecondFingerEvents( data, pressed, top );
					}
	
					break;
	
				case TouchEvent.ACTION_TOUCH_MOVE:
					if( top != null ) {
						// Reset the toucher hover
						var start:Point = toucher_hoverStartLocation[data.receiver];
						if( start != null ) {
							var pt:Point = data.getReferencePoint();
							var diffx:Number = Math.abs( pt.x - start.x );
							var diffy:Number = Math.abs( pt.y - start.y );
							if( diffx > hoverProximityInPixels ||
									diffy > hoverProximityInPixels ) {
								clearInterval(toucher_hoverIntervalPid[data.receiver]);
								if (hoverGeneratedForMovePauses) {
									toucher_hoverStartLocation[data.receiver] = pt;
									toucher_hoverIntervalPid[data.receiver] =
										setInterval( generateHover,
												hoverInitialDelay, top, pressed, data, true );
								}
							}
						}
					}
	
					if( pressed != null ) {
						
						// Send second finger down/move/up if applicable
						dispatchSecondFingerEvents( data, pressed, top );
	
						// Check for drag events
						// Drag events only happen when an observer was pressed.
						if( top != null && top == pressed ) {
							if( toucher_draggedOut[data.receiver] ) {
								pressed.dispatchEvent( new TouchEvent(
									TouchEvent.TOUCHER_DRAG_OVER, data ) );
								toucher_draggedOut[data.receiver] = false;
							}
						}
						else {
							if( !toucher_draggedOut[data.receiver] ) {
								pressed.dispatchEvent( new TouchEvent(
									TouchEvent.TOUCHER_DRAG_OUT, data ) );
								toucher_draggedOut[data.receiver] = true;
							}
						}
						
						// Check for rollover/rollout events
						dispatchRolloverEvents( data, pressed, top );
					}
		
					break;
	
				case TouchEvent.ACTION_TOUCH_UP:
					clearInterval( toucher_hoverIntervalPid[data.receiver] );
	
					// Send second finger up if applicable
					dispatchSecondFingerEvents( data, pressed, top );
	
					// Check for a release outside the pressed object
					if( pressed != null && (top == null || pressed != top) ) {
						//debug( "toucherReleaseOutside [" + data.receiver + "]: pressed=" + pressed + "; top=" + top );
						pressed.dispatchEvent( new TouchEvent(
							TouchEvent.TOUCHER_RELEASE_OUTSIDE, data, true ) );
					}
					else {
						// Set the tap values
						var receiver:Number = data.receiver;
						var last:Number = toucher_lastClickTimestamp[receiver];
						var newClickTime:Number = getTimer();
						if( toucher_clickCount[receiver] == 0 ) {
							toucher_clickCount[receiver] = 1;
							toucher_lastClickTimestamp[receiver] = newClickTime;
						}
						else if( (newClickTime-last) < tapInterval ) {
							toucher_clickCount[receiver]++;
							toucher_lastClickTimestamp[receiver] = newClickTime;
						}
						else {
							toucher_clickCount[receiver] = 1;
							toucher_lastClickTimestamp[receiver] = newClickTime;
						}
						data.tapCount = toucher_clickCount[receiver];	
	
						//debug( data.tapCount );
						
						// Notify of the release
						if( pressed != null )
						{
							//debug( "toucherRelease [" + data.receiver + "]: pressed=" + pressed + "; top=" + top );
							pressed.dispatchEvent( new TouchEvent(
								TouchEvent.TOUCHER_RELEASE, data, true ) );
		
							// Notify of taps (if any)
							switch( data.tapCount ) {
								case 1:
									pressed.dispatchEvent( new TouchEvent(
										TouchEvent.TOUCHER_TAP, data, true ) );
									break;
								case 2:
									pressed.dispatchEvent( new TouchEvent(
										TouchEvent.TOUCHER_DOUBLE_TAP, data, true ) );
									break;
								case 3:
									pressed.dispatchEvent( new TouchEvent(
										TouchEvent.TOUCHER_TRIPLE_TAP, data, true ) );
									break;
								case 4:
									pressed.dispatchEvent( new TouchEvent(
										TouchEvent.TOUCHER_QUADRUPLE_TAP, data, true ) );
									break;							
							}
						}
					}
	
					// Reset the tracking variables
					toucher_draggedOut[data.receiver] = false;
					toucher_gotDownEvent[data.receiver] = null;
					toucher_trackAsMenuDuringPress[data.receiver] = false;
					break;
	
				
				
				// SHOULDN'T EVER GET HERE
				default:
					break;			
			}
		}

	}
}