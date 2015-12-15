package com.circle12.diamondtouch
{

import com.circle12.diamondtouch.DiamondTouch;
import com.circle12.diamondtouch.DTObserver; 
import com.circle12.diamondtouch.DTObservable;
import com.circle12.diamondtouch.DTObserverData;
import com.circle12.diamondtouch.TouchEventData;
import flash.display.MovieClip;
import flash.display.DisplayObject;
import flash.utils.*;
import flash.geom.Point;

/* DTFlash 1.044 */

/**
 * A Java-style Observable class used to represent the "subject"
 * of the Observer design pattern. DTObservers must implement the DTObserver
 * interface, and register to observe the subject via addObserver().
 *
 * The events of DTObservableSubject are:
 *   onToucherEvent, onToucherDown, onToucherMove, onToucherUp,
 *   onToucherSegmentCountChanged, onToucherPress, onToucherRelease,
 *   onToucherReleaseOutside, onToucherDragOut, onToucherDragOver,
 *   onToucherRollOver, onToucherRollOut, onToucherTap,
 *   onToucherDoubleTap, onToucherTripleTap, onToucherQuadrupleTap,
 *   onToucherHover, onGestureDown, onGestureMove, onGestureUp,
 *   onToucherSecondFingerDown, onToucherSecondFingerUp,
 *   onToucherSecondFingerMove, onToucherSecondFingerTap
 *
 * CHANGE: We don't require listeners to implement DTObservable.
 *         This way, a simple Object with an
 *         onTouchEvent(o:DTObservable, dtev:TouchEventData):void 
 *         function added to it can listen to events (no .as files, needed).
 *         Every observer must have:
 *            - _parent
 *                we assume all observers are descendants of _root
 *            - _name
 *                this is used for an identifier in the tree
 *            - getDepth():Number
 *                the depth in the parent used to determine which
 *                object is on top
 *            - hitTest( x:Number, y:Number ):Boolean
 *                hit tests against a global point
 *         - OR -
 *            if _parent isn't defined, we assume that the observer is
 *            just a listener for DT events and will only receive
 *            the low-level events (onToucherEvent, etc).  These objects
 *            will be notified BEFORE any non-primitive events such
 *            as onToucherPress, but AFTER all typical observers have
 *            been notified of the primitive events.
 */
public class DTObservableSubject implements DTObservable {
	/**************************************************************************/
	/* Constants                                                              */
	/**************************************************************************/
	public static var MAX_TOUCHERS:Number = DiamondTouch.MAX_TOUCHERS; 


	/**************************************************************************/
	/* Class Variables                                                        */
	/**************************************************************************/
	public var boundingBox_MinimumSize:Number = 50;
	public var tapInterval = 250;
	public var hoverInitialDelay:Number = 3000;
	public var hoverRepeatDelay:Number = 1000;
	public var hoverProximityInPixels:Number = 10;
	public var hoverGeneratedForMovePauses:Boolean = false;
	public var aggressiveSegmentCount:Boolean = false;
	public var reverseNotification:Boolean = false;
	private var toucher_startToucherDrag:Array;
	private var toucher_startToucherDragRotateTowardsPoint:Array;
	private var toucher_startToucherDragFirstPoint:Array;
	private var toucher_startToucherDragLimitsRectangle:Array;
	private var toucher_gotDownEvent:Array;
	private var toucher_trackAsMenuDuringPress:Array;
	private var toucher_draggedOut:Array;
	private var toucher_hoverIntervalPid:Array;
	private var toucher_hoverStartLocation:Array;
	private var toucher_secondFingerDown:Array;
	private var toucher_secondFingerTimestamp:Array;
	private var toucher_thirdFingerDown:Array;
	private var toucher_thirdFingerTimestamp:Array;
	private var toucher_thirdFingerTap_eligible:Array;
	private var toucher_segmentCountLast:Array;
	private var toucher_segmentCountChanged:Array;
	// Rollovers are actually tracked by each DTObserverData object,
	// but for our purposes, there is only one object that is "rolled over"
	// for any given user. This array will then help us determine who has
	// been rolled over without traversing the entire tree.
	private var toucher_gotRollover:Array;
	private var changed:Boolean = false;
	private var toucher_lastClickTimestamp:Array;
	private var toucher_clickCount:Array;
	private var dt:DiamondTouch;

	// observerTree nodes are objects with the following variables:
	//    clip:Object (most likely a movieclip or textfield)
	//        the object associated with the particular level of the tree
	//    children:Object
	//        an array containing a list of the children of the object
	//    isObserver:Boolean
	//        true if the clip has been added as an observer
	//    data:DTObserverData
	//        the observer info
	private var observerTree:Object;
	private var treeChanged:Boolean = false;
	// The observerList is just for simplicity in determining if a given
	// object is a dt observer.
	private var observerList:Array;
	// This list is to hold the observers that are not movieclips (or
	// objects without _parent, _name, hitTest, and getDepth
	private var unattachedObserverList:Array;


	/**************************************************************************/
	/* DTObservableSubject constructor                                        */
	/**************************************************************************/
	public function DTObservableSubject(dt:DiamondTouch) {
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
		toucher_thirdFingerDown = new Array(DiamondTouch.MAX_TOUCHERS);
		toucher_thirdFingerTimestamp = new Array( DiamondTouch.MAX_TOUCHERS );
		toucher_thirdFingerTap_eligible = new Array( DiamondTouch.MAX_TOUCHERS );
		toucher_segmentCountLast = new Array(DiamondTouch.MAX_TOUCHERS);		
		toucher_segmentCountChanged = new Array(DiamondTouch.MAX_TOUCHERS);		
		toucher_gotRollover = new Array(DiamondTouch.MAX_TOUCHERS);
		toucher_lastClickTimestamp = new Array(DiamondTouch.MAX_TOUCHERS);
		toucher_clickCount = new Array(DiamondTouch.MAX_TOUCHERS);
		observerTree = new Object();
		observerList = new Array();
		unattachedObserverList = new Array();

		this.dt = dt;
		for (var i:Number=0; i<MAX_TOUCHERS; i++) {
			toucher_gotDownEvent[i] = null;
			toucher_trackAsMenuDuringPress[i] = false;
			toucher_draggedOut[i] = false;
			toucher_clickCount[i] = 0;
			toucher_lastClickTimestamp[i] = 0;
			toucher_hoverIntervalPid[i] = null;
			toucher_hoverStartLocation[i] = new Array(-500, -500);
			toucher_startToucherDrag[i] = null;
			toucher_startToucherDragFirstPoint[i] = null;
			toucher_startToucherDragRotateTowardsPoint[i] = null;
			toucher_startToucherDragLimitsRectangle[i] = null;
			toucher_secondFingerDown[i] = false;
			toucher_secondFingerTimestamp[i] = 0;
			toucher_thirdFingerDown[i] = false;
			toucher_thirdFingerTimestamp[i] = 0;
			toucher_thirdFingerTap_eligible[i] = false;
			toucher_segmentCountLast[i] = [ 0, 0 ];
			toucher_segmentCountChanged[i] = false;
		}

		observerTree = createNewTreeNode( dt.stage ); // was _root, before --awe
	}


	/**************************************************************************/
	/* Public functions                                                       */
	/**************************************************************************/
	public function addObserver( o:DisplayObject, tag:Object=null):Boolean {
		if (!o) return false;
		var i:Number = 0;
		if( o.parent == null && o != dt.stage ) { // was _root before -- awe
			var idx:Number = -1;
			for( i=0; i < unattachedObserverList.length; i++ ) {
				if( unattachedObserverList[i] == o )
					return false;
			}
			unattachedObserverList.push( o );
			return true;
		}

		else {
			if (tag == null)
				tag = o.name;

			for( i=0; i < observerList.length; i++ )
				if( observerList[i] == o )
					return false;

			var obsData:DTObserverData = new DTObserverData(o, tag);

			// Put the object in the tree (the first treenode is _root)
			var treeNode:Object = observerTree;
			if( o != dt.stage ) { // was _root before -- awe
				var ancestors:Array = getAncestors( o );
				// example of the ancestor array:
				//     movieclip=_level0.button0_mc.test_mc
				//     ancestors=[ _level0.button0.test_mc, _level0.button0_mc ]
				// (_level0 is identical to _root)
				for( i=ancestors.length-1; i >= 0; i-- ) {
					var children:Object = treeNode.children;
					var child:Object = children[ancestors[i].name];
					if( !child ) {
						child = createNewTreeNode( ancestors[i] );
						child.parent = treeNode;
					}
					treeNode.children[ ancestors[i].name ] = child;
					treeNode = child;
				}
			}
			treeNode.isObserver = true;
			treeNode.data = obsData;
			observerList.push( treeNode );

			return true;
		}
	}

	public function removeObserver(o:DisplayObject):Boolean {
		var idx:Number = -1;
		var i:Number;
		if( o.parent == null ) {
			for( i=0; i < unattachedObserverList.length; i++ ) {
				if( unattachedObserverList[i] == o ) {
					idx = i;
					break;
				}
			}
			if( idx < 0 )
				return false;

			unattachedObserverList.splice( idx, 1 );
			return true;
		}
		else {
			// Check to see that the object is really an observer
			for( i=0; i < observerList.length; i++ ) {
				if( observerList[i].clip == o ) {
					idx = i;
					break;
				}
			}
			if( idx < 0 )
				return false;

			observerList.splice( idx, 1 );

			// Remove the object from our tree
			var treeNode:Object = observerTree;
			var remove:Boolean = false;
			if( o == dt.stage ) { // was _root before -- awe
				if( observerTree.isObserver )
					remove = true;
			}
			else {
				var ancestors:Array = getAncestors( o );
				var treeNode2:Object = observerTree;
				for( var i2:Number=ancestors.length-1; treeNode2 && i2 >= 0; i2-- ) {
					var children:Object = treeNode2.children;
					treeNode2 = children[ancestors[i2].name];
				}

				remove = treeNode2 && treeNode2.isObserver;
			}

			if( remove ) {
				treeNode.isObserver = false;
				treeChanged = true;
			}

			return remove;
		}
	}

	public function notifyObservers(dtev:TouchEventData):void {
		if (!changed) return;

		//if (dtev == undefined) dtev = null;

		if( treeChanged ) {
			cleanTree( observerTree );
			treeChanged = false;
		}

		// first things first ... move the observer that
		// is being dragged by the toucher
		var receiver:Number = dtev.receiver;
		if( toucher_startToucherDrag[receiver] )
			continueToucherDrag( toucher_startToucherDrag[receiver], dtev );

		// Check for a segment count change
		var oldSegments:Array = toucher_segmentCountLast[dtev.receiver];
		var maxOldSegments:Number =
			Math.max( oldSegments[0], oldSegments[1] );
		var newSegments:Array = [ dtev.xSegmentCount, dtev.ySegmentCount ];
		var maxSegments:Number = 
			Math.max( newSegments[0], newSegments[1] );
		toucher_segmentCountChanged[dtev.receiver] = false;
		if( aggressiveSegmentCount ) {
			if( oldSegments[0] != newSegments[0]
					|| oldSegments[1] != newSegments[1] )
				toucher_segmentCountChanged[dtev.receiver] = true;
		}
		else {
			if( maxOldSegments != maxSegments )
				toucher_segmentCountChanged[dtev.receiver] = true;
		}

		// find the top object, notify of primitive events
		// and then notify of higher-level events such as onToucherPress
		var topObject:Object = findTopObjectAndNotifyAll(
				observerTree, dtev, true );
		topObjectNotification( topObject, dtev );
		
		toucher_segmentCountLast[dtev.receiver] = newSegments;
	}

	/**
	 * Removes all observers from the observer list.
	 */
	public function clearObservers():void {
		observerList = new Array();
		observerTree = createNewTreeNode( dt.stage ); // was _root before -- awe
		unattachedObserverList = new Array();
	}

	/**
	 * Returns the number of observers in the observer list.
	 * @return the number of observers for this subject.
	 */
	public function countObservers():Number {
		return observerList.length + unattachedObserverList.length;
	}

	public function hasChanged():Boolean {
		return changed;
	}

	public function setChanged():void {
		changed = true;
	}

	public function clearChanged():void {
		changed = false;
	}

	public function startToucherDrag( observer_mc:DisplayObject, dtev:TouchEventData,
			lockCenter:Boolean, rotateTowardsPoint:Point, rect_limits:Object ) {

		var toucher_downPt:Point = dtev.getReferencePoint();
		var saved_rotation:Number = observer_mc.rotation;
		observer_mc.parent.globalToLocal(toucher_downPt);
		if (lockCenter) {
			toucher_downPt.x = observer_mc.x;
			toucher_downPt.y = observer_mc.y;
		}
		toucher_startToucherDrag[dtev.receiver] = observer_mc;
		var toucher_downPtOffset = new Point();
		toucher_downPtOffset.x = toucher_downPt.x - observer_mc.x;
		toucher_downPtOffset.y = toucher_downPt.y - observer_mc.y;
		toucher_startToucherDragFirstPoint[dtev.receiver] = toucher_downPtOffset;
		toucher_startToucherDragRotateTowardsPoint[dtev.receiver] = rotateTowardsPoint;
		var rect_limits:Object = new Object();				
		toucher_startToucherDragLimitsRectangle[dtev.receiver] = new Object();
		toucher_startToucherDragLimitsRectangle[dtev.receiver].left = rect_limits.left;
		toucher_startToucherDragLimitsRectangle[dtev.receiver].top = rect_limits.top;
		toucher_startToucherDragLimitsRectangle[dtev.receiver].right = rect_limits.right;
		toucher_startToucherDragLimitsRectangle[dtev.receiver].bottom = rect_limits.bottom;
	}

	public function stopToucherDrag(observer_mc:Object, dtev:TouchEventData) {
		toucher_startToucherDrag[dtev.receiver] = null;
		toucher_startToucherDragFirstPoint[dtev.receiver] = null;
		toucher_startToucherDragRotateTowardsPoint[dtev.receiver] = null;
		toucher_startToucherDragLimitsRectangle = null;
	}


	/**************************************************************************/
	/* Private functions                                                      */
	/**************************************************************************/
	private function continueToucherDrag(
			observer_mc:DisplayObject, dtev:TouchEventData ) {
		var saved_rotation:Number = observer_mc.rotation;
		var toucher_movePt:Point;
		if( toucher_startToucherDrag[dtev.receiver] != null ) {
			toucher_movePt = dtev.getReferencePoint();
			observer_mc.parent.globalToLocal(toucher_movePt);			
			observer_mc.x = toucher_movePt.x -
				toucher_startToucherDragFirstPoint[dtev.receiver].x;
			observer_mc.y = toucher_movePt.y -
				toucher_startToucherDragFirstPoint[dtev.receiver].y;
			var rect_limits:Object =
				toucher_startToucherDragLimitsRectangle[dtev.receiver];
			if( rect_limits != null ) {
				if (observer_mc.x < rect_limits.left)
					observer_mc.x = rect_limits.left;
				if (observer_mc.x > rect_limits.right)
					observer_mc.x = rect_limits.right;
				if (observer_mc.y < rect_limits.top)
					observer_mc.y = rect_limits.top;
				if (observer_mc.y > rect_limits.bottom)
					observer_mc.y = rect_limits.bottom;				
			}

			var globalPointObj:Point =
				toucher_startToucherDragRotateTowardsPoint[dtev.receiver];
			if (globalPointObj != null)
				DiamondTouch.rotateTowardsPoint(
						MovieClip(observer_mc), globalPointObj );
		}
	}

	private function createNewTreeNode(clip:Object):Object {
		return { clip:clip, children:new Object(), isObserver:false };
	}

	/**
	 * Gets a list of the ancestors of a given object (using _parent).
	 * example:
	 *   o=_level0.button0_mc.test_mc
	 *   ancestors=[ _level0.button0.test_mc, _level0.button0_mc ]
	 * (_level0 is identical to _root)
	 *
	 * @param o the object for which the array is desired
	 * @return an array containing the ancestors starting with the object itself
	 */
	private function getAncestors( o:DisplayObject ):Array {
		var ancestors:Array = new Array();
		var node:Object = o;
		//while( node != null && node != undefined && node != dt.stage ) { // was _root before -awe
		while( node != null && node != dt.stage ) { // was _root before -awe
			ancestors.push( node );
			node = node.parent;
		}
		return ancestors;
	}

	/**
	 * Recursively deletes all child branches that no longer contain observers
	 * @param root the root of the tree to clean
	 * @return true if the root of the tree is a dead branch
	 *         (doesn't contain any observers)
	 */
	private function cleanTree( root:Object ):Boolean {
		var deadBranch:Boolean = !root.isObserver;
		for( var id:String in root.children ) {
			if( !cleanTree( root.children[id] ) )
				deadBranch = false;
			else
				delete root.children[id];
		}

		return deadBranch;
	}

	/**
	 * Calls onToucherRollOut on the observer that first got the rollover.
	 * Also clears the state for the rollover.
	 * (ie: toucher_gotRollover[receiver] is cleared)
	 * @param dtev the event data associated with the event
	 */
	private function callRollOut( dtev:TouchEventData ):void {
		var gotRollover:Object = toucher_gotRollover[dtev.receiver];
		if( gotRollover ) {
			gotRollover.setToucherRolledOver( dtev.receiver, false );
			dtev.rolledOverCount = gotRollover.rolledOverCount;
			if( gotRollover.observer.onToucherRollOut )
				gotRollover.observer.onToucherRollOut( this, dtev );
			toucher_gotRollover[dtev.receiver] = undefined;
		}
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
	private function secondFingerNotification( dtev:TouchEventData,
			pressed:Object, topObject:Object ):void {

		var last:Array = toucher_segmentCountLast[ dtev.receiver ];
		var maxLast:Number = Math.max( last[0], last[1] );
		var cur:Array = [ dtev.xSegmentCount, dtev.ySegmentCount ];
		var max:Number = Math.max( cur[0], cur[1] );

		var tapEligible:Boolean =
			toucher_secondFingerDown[ dtev.receiver ] && max < 2;
		if( max > 1 ) {
			if( !toucher_secondFingerDown[ dtev.receiver ] ) {
				pressed.observer.onToucherSecondFingerDown( this, dtev );
				toucher_secondFingerDown[ dtev.receiver ] = true;
				toucher_secondFingerTimestamp[ dtev.receiver ] = dtev.timestamp;
			}
			else {
				pressed.observer.onToucherSecondFingerMove( this, dtev );
				// As written, thirdFingerDown will only occur if secondFingerDown already happened.
				// Also a 3rd finger down followed quickly by additional fingers down will still trigger the primitive onToucherThirdFingerDown
				if (max ==3 && maxLast == 2) {
					if( !toucher_thirdFingerDown[ dtev.receiver ] ) {
						pressed.observer.onToucherThirdFingerDown(this, dtev);
						toucher_thirdFingerDown[ dtev.receiver ] = true;
						toucher_thirdFingerTimestamp[ dtev.receiver ] = dtev.timestamp;
						toucher_thirdFingerTap_eligible[ dtev.receiver ] = true;
					}
				} else if (max ==2 && maxLast ==3) {
					// As written, thirdFingerUp/Tap may only work if 3rd up is before 2nd up -- check
					if( toucher_thirdFingerDown[ dtev.receiver ] ) {
						pressed.observer.onToucherThirdFingerUp(this, dtev);
						toucher_thirdFingerDown[ dtev.receiver ] = false;
						if( toucher_thirdFingerTimestamp[ dtev.receiver ] >
								dtev.timestamp-tapInterval && ( max == 0 ||
								topObject.data == pressed || max == 2) ) {
							pressed.observer.onToucherThirdFingerTap( this, dtev );							
						}						
					}
				} else  if (max > 3) {
					if( toucher_thirdFingerDown[ dtev.receiver ] ) {
						toucher_thirdFingerTap_eligible[ dtev.receiver ] = false;
					}
				}
			}
		}
		else
			toucher_secondFingerDown[ dtev.receiver ] = false;


		if( tapEligible ) {
			pressed.observer.onToucherSecondFingerUp( this, dtev );
			if( toucher_secondFingerTimestamp[ dtev.receiver ] >
					dtev.timestamp-tapInterval && ( max == 0 ||
					topObject.data == pressed ) ) {
				pressed.observer.onToucherSecondFingerTap( this, dtev );				
			}
			if( toucher_thirdFingerDown[ dtev.receiver ] ) {
				pressed.observer.onToucherThirdFingerUp(this, dtev);
				toucher_thirdFingerDown[ dtev.receiver ] = false;
				if(toucher_thirdFingerTap_eligible[ dtev.receiver ] && toucher_thirdFingerTimestamp[ dtev.receiver ] >
						dtev.timestamp-tapInterval && ( max == 0 ||
						topObject.data == pressed || max == 2) ) {
					pressed.observer.onToucherThirdFingerTap( this, dtev );							
				}	
				toucher_thirdFingerTap_eligible[ dtev.receiver ] = false;				
			}
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
	private function rolloverNotification( dtev:TouchEventData,
			pressed:Object, topObject:Object ):void {
		var gotRollover:Object = toucher_gotRollover[dtev.receiver];
		var dragging:Object = toucher_startToucherDrag[dtev.receiver];
		if( dtev.eventType == 3 )
			// on a release, onToucherRollOut will be called unless there was
			// no observer that originally got the rollover
			callRollOut( dtev );
		else {
			// First check for an onToucherRollOut event
			if( gotRollover ) {
				// Only call a rollout if the toucher is no longer over
				// the observer that already got the rollover AND
				// if the observer that got the rollover isn't now being
				// dragged by the toucher.  The second condition prevents
				// the observer from getting an onToucherRollOut when
				// there is really only a delay dragging of the
				// observer
				if( gotRollover != topObject.data &&
						gotRollover.observer != dragging ) {
					callRollOut( dtev );
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
			if( !dragging && topObject && topObject.data != pressed &&
					topObject.data != gotRollover ) {
				gotRollover = topObject.data;
				gotRollover.setToucherRolledOver( dtev.receiver, true );
				dtev.rolledOverCount = gotRollover.rolledOverCount;
				if( gotRollover.observer.onToucherRollOver )
					gotRollover.observer.onToucherRollOver( this, dtev );
				toucher_gotRollover[dtev.receiver] = gotRollover;
			}
		}
	}

	/**
	 * Notification of non-primitive events such as onToucherPress, etc.
	 * @param topObject the topmost observer that is currently under the center
	 *                  of the toucher's bounding box
	 * @param dtev the event data associated with the event
	 */
	private function topObjectNotification( topObject:Object,
			dtev:TouchEventData ):void {
		// Keep track of who got the onToucherPress event
		var pressed:Object = toucher_gotDownEvent[dtev.receiver];
		switch( dtev.eventType ) {
			// TOUCHER DOWN
			case 1:
				clearInterval( toucher_hoverIntervalPid[dtev.receiver] );
				if( topObject ) {
					// Notify the top observer of the press.
					if( topObject.data.observer.onToucherPress )
						topObject.data.observer.onToucherPress(this, dtev);
					toucher_gotDownEvent[dtev.receiver] = topObject.data;

					// Keep track of hover information.
					toucher_hoverStartLocation[dtev.receiver] =
						[ dtev.x, dtev.y ];
					toucher_hoverIntervalPid[dtev.receiver] = setInterval(
							generateHover, hoverInitialDelay,
							topObject.data, dtev, true );

					// Keep track of menu tracking -- we don't deal with this yet.
					toucher_trackAsMenuDuringPress[dtev.receiver] =
						topObject.data.observer.trackAsMenu;

					// Keep track of whether the toucher has dragged out
					// of the observer's bounds or not. This is used for
					// onToucherDragOver and onToucherDragOut events.
					toucher_draggedOut[dtev.receiver] = false;

					// Send second finger down if applicable
					secondFingerNotification( dtev, topObject.data, topObject );
				}

				break;

			// TOUCHER MOVE
			case 2:
				if( topObject ) {
					// Reset the toucher hover
					var start:Array = toucher_hoverStartLocation[dtev.receiver];
					var diffx:Number = Math.abs( dtev.x - start[0] );
					var diffy:Number = Math.abs( dtev.y - start[1] );
					if( diffx > hoverProximityInPixels ||
							diffy > hoverProximityInPixels ) {
						clearInterval(toucher_hoverIntervalPid[dtev.receiver]);
						if (hoverGeneratedForMovePauses) {
							toucher_hoverStartLocation[dtev.receiver] =
								[ dtev.x, dtev.y ];
							toucher_hoverIntervalPid[dtev.receiver] =
								setInterval(generateHover,
										hoverInitialDelay, topObject.data,
										dtev, true );
						}
					}
				}

				// Send second finger down/move/up if applicable
				secondFingerNotification( dtev, pressed, topObject );

				// Check for drag events
				// Drag events only happen when an observer was pressed.
				if( pressed ) {
					if( topObject.data == pressed ) {
						if( toucher_draggedOut[dtev.receiver] ) {
							pressed.observer.onToucherDragOver( this, dtev );
							toucher_draggedOut[dtev.receiver] = false;
						}
					}
					else {
						if( !toucher_draggedOut[dtev.receiver] ) {
							pressed.observer.onToucherDragOut( this, dtev );
							toucher_draggedOut[dtev.receiver] = true;
						}
					}
				}

				// Check for rollover/rollout events
				rolloverNotification( dtev, pressed, topObject );

				break;

			// TOUCHER UP
			case 3:
				clearInterval( toucher_hoverIntervalPid[dtev.receiver] );

				// Send second finger up if applicable
				secondFingerNotification( dtev, pressed, topObject );

				// Check for a release outside the pressed object
				if( !topObject || pressed != topObject.data )
					pressed.observer.onToucherReleaseOutside( this, dtev );
				else {
					// Set the tap values
					var receiver:Number = dtev.receiver;
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
						toucher_clickCount[dtev.receiver] = 1;
						toucher_lastClickTimestamp[receiver] = newClickTime;
					}
					dtev.tapCount = toucher_clickCount[receiver];	

					// Notify of the release
					pressed.observer.onToucherRelease(this, dtev);

					// Notify of taps (if any)
					switch( dtev.tapCount ) {
						case 1:
							pressed.observer.onToucherTap(this, dtev);
							break;
						case 2:
							pressed.observer.onToucherDoubleTap(this, dtev);
							break;
						case 3:
							pressed.observer.onToucherTripleTap(this, dtev);
							break;
						case 4:
							pressed.observer.onToucherQuadrupleTap(this, dtev);
							break;							
					}
				}

				// Check for rollover/rollout events
				rolloverNotification( dtev, pressed, topObject );

				// Reset the tracking variables
				toucher_draggedOut[dtev.receiver] = false;
				toucher_gotDownEvent[dtev.receiver] = null;
				toucher_trackAsMenuDuringPress[dtev.receiver] = false;
				break;

			// SHOULDN'T EVER GET HERE
			default:
				break;			
		}
	}

	/**
	 * Identifies the topmost observer under the center of the toucher's
	 * bounding box and notifies ALL observers of the applicable primitive
	 * events.
	 * Primitive events are:
	 *   onToucherEvent, onToucherDown, onToucherMove, onToucherUp,
	 *   onGestureDown, onGestureMove, onGestureUp,
	 *   onToucherSegmentCountChanged.
	 *
	 * NOTE: There are a few important things to know about how this all works
	 *       -- this was patterned after how flash mouse events work.
	 *       1) The topmost object that gets an event is not necessarily
	 *          visible to the toucher.
	 *          a) Another movieclip (or something else) could be blocking the
	 *             topmost object from view -- but the movieclip causing the
	 *             obstruction isn't listening for events.
	 *          b) The object could be completely transparent (ie: _alpha=0).
	 *             This doesn't apply if the object is set to invisible
	 *             (ie: _visible=false).
	 *       2) The top object is defined as the object which fits
	 *          the following criteria:
	 *          a) it is visible
	 *          b) it is the closest observer to the root which passes hitTest
	 *       3) The order of notification is from child to parent (so all
	 *          children of an observer get notified first, then the observer).
	 *          In other words, notification is depth first.  The order in which
	 *          children are notified is arbitrary.  Children are NOT
	 *          necessarily notified in order of depth.
	 *       4) ALL observers are notified of the primitive events even if
	 *          they are not visible.
	 *
	 * @param root the root of the subtree since this is a recursive function
	 * @param dtev the event data for this event
	 * @param candidate true if we're still looking for a top object
	 */
	private function findTopObjectAndNotifyAll( root:Object,
			dtev:TouchEventData, candidate:Boolean ):Object {
		var pt:Object = dtev.getReferencePoint();
		var hitNode:Object;

		// If the clip is not visible, it cannot possibly be the topmost object,
		// so mark it as not being a candidate anymore.
		candidate = candidate && root.clip._visible;

		// If this observer passes the hit test, none of its children
		// are candidates anymore -- save the object as being the one
		// to return as the top object.
		if( candidate && root.isObserver && root.clip.hitTest &&
		   // CHANGE cursor_container_mc to only draw graphics so that they can't intercept mouse or finger...
				root.clip.hitTestPoint( pt.x, pt.y, true ) ) { //&& root.clip !=
				//dt.stage.cursor_container_mc ) { // was _root -- awe
			hitNode = root;

			// Only continue looking if we are reversing the notification
			candidate = reverseNotification;
		}

		// save the depth of the topmost hit child (if we're still looking
		// for the top observer)
		var maxDepth:Number = Number.NEGATIVE_INFINITY;
		for( var id:String in root.children ) {
			var node:Object = root.children[id];
			var depth:Number = Number.NEGATIVE_INFINITY;
			if( node.clip.getDepth )
				depth = node.clip.getDepth();

			// The current child is a candidate only if we're still
			// looking for a top observer and the child's depth is
			// higher than the topmost hit child we've seen so far
			var childCandidate:Boolean = candidate && depth > maxDepth;
			var childHit:Object = findTopObjectAndNotifyAll(
					node, dtev, childCandidate );
			if( childCandidate && childHit ) {
				maxDepth = depth;
				hitNode = childHit;
			}
		}

		// Notify the observer of the primitive events
		if( root.isObserver ) {
			dtev.tag = root.data.tag;
			callPrimitiveEvents( dtev, root.data.observer );
		}

		if( root == observerTree ) {
			for( var i:Number=0; i < unattachedObserverList.length; i++ ) {
				var obs:Object = unattachedObserverList[i];
				dtev.tag = obs.name;
				callPrimitiveEvents( dtev, obs );
			}
		}

		return hitNode;
	}

	function callPrimitiveEvents( dtev:TouchEventData, obs:Object ) {
		if( obs.onToucherEvent )
			obs.onToucherEvent( this, dtev );

		switch (dtev.eventType) {
			case 1:
				if( obs.onToucherDown )
					obs.onToucherDown(this, dtev);
				break;
			case 2:
				if( obs.onToucherMove )
					obs.onToucherMove(this, dtev);
				break;			
			case 3:
				if( obs.onToucherUp )
					obs.onToucherUp(this, dtev);	
				break;
			default:
				break;
		}

		if( toucher_segmentCountChanged[dtev.receiver] &&
				obs.onToucherSegmentCountChanged )
			obs.onToucherSegmentCountChanged( this, dtev );

		if( dtev.gestureAction != "None" ) {
			var func:String = "onGesture"+dtev.gestureAction;
			if( obs[func] )
				obs[func]( this, dtev );
		}
	}

	function generateHover( o:Object, dtev:TouchEventData,
			initialEvent:Boolean ) {
		clearInterval( toucher_hoverIntervalPid[dtev.receiver] );
		dtev.initialHoverEvent = initialEvent ? true : false;
		o.observer.onToucherHover(this, dtev);
		toucher_hoverIntervalPid[dtev.receiver] = setInterval(
				generateHover, hoverRepeatDelay, o, dtev );
	}
}
}