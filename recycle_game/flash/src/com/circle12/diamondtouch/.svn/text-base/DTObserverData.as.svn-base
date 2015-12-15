package com.circle12.diamondtouch
{

import com.circle12.diamondtouch.DTObservableSubject; 

/* DTFlash 1.044 */

/**
 * This class encapsulates the information about an Object that is registering to receive events from an DTObservable DiamondTouch device.
 */
public class DTObserverData {
  private var observer_internal:Object;
  private var tag_internal:Object;	
  private var toucher_rolledOver:Array;// = new Array(DTObservableSubject.MAX_TOUCHERS);	Don't call new in an initializer or all instances will have a unique var, but pointing to the same array!
  private var rolledOverCount_internal:Number;
//	
  /**
   * DTObserverData Constructor
   */
  public function DTObserverData(observer:Object, tag:Object) {
    this.observer = observer;
    this.tag = tag;
    this.rolledOverCount = 0;
    this.toucher_rolledOver = new Array(DTObservableSubject.MAX_TOUCHERS);
    for (var i:Number=0; i<DTObservableSubject.MAX_TOUCHERS; i++) {
	this.toucher_rolledOver[i] = false;
    }
  }  
  public function isRolledOver():Boolean {
	return (this.rolledOverCount > 0);
  }

  public function setToucherRolledOver(receiver:Number, rolledOver:Boolean):Boolean {
	if (isNaN(receiver) || receiver < 0 || receiver >= DTObservableSubject.MAX_TOUCHERS) {
		return false;
	}
	if (this.toucher_rolledOver[receiver] != rolledOver) {
		if (rolledOver) {
			this.rolledOverCount++;
		} else {
			this.rolledOverCount--;
		}
	}
	this.toucher_rolledOver[receiver] = rolledOver;
	return true;
  }
  public function getToucherRolledOver(receiver:Number):Boolean {
	  return this.toucher_rolledOver[receiver];
  }
  
  /**
   * Getter/Setter functions
   */
  public function get rolledOverCount ():Number {
	  return this.rolledOverCount_internal;
  }
  public function set rolledOverCount (cnt:Number):void {
	  this.rolledOverCount_internal = cnt;
  }
  public function get observer ():Object {
	  return observer_internal;
  }
  public function set observer (o:Object):void {
	  observer_internal = o;
  }
  public function get tag ():Object {
	  return tag_internal;
  }
  public function set tag (t:Object):void {
	  tag_internal = t;
  }
}
}