package com.circle12.diamondtouch
{

import com.merl.diamondTouch.DTObservable; 
import com.merl.diamondTouch.TouchEventData;

/* DTFlash 1.044 */

/**
 * The interface that ideally should be implemented by all observers of an
 * DTObservable object. In reality, observers can be Objects, for simplicity.
 * A DTObserverData object (which embeds the observer Object along
 * with other metadata) is registered as the DT listener. See DTObservableData.
 */
interface DTObserver {
	/**
	   * Invoked automatically by an observed object when it changes.
	   * 
	   * @param   o   	The observed object (an instance of DTObservable).
	   * @param   dtev       A TouchEventData object sent by 
	   *                    	the observed object.
	   */
	function onTouchEvent(o:DTObservable, dtev:TouchEventData):void;
}
}