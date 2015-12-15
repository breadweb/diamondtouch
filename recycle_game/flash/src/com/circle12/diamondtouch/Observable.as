package com.circle12.diamondtouch
{


/* DTFlash 1.044 */

public class Observable extends MovieClip
{
	private var _observers:Array;
	
	public function Observable() {
		_observers = new Array();
	}
	
	public function addObserver( obs:Object ):Boolean {
		for( var i:Number=0; i < _observers.length; i++ ) {
			if( _observers[i] == obs ) return false;
		}
		_observers.push( obs );
		return true;
	}
	
	public function removeObserver( obs:Object ):Boolean {
		var idx:Number = -1;
		for( var i:Number=0; i < _observers.length; i++ ) {
			if( _observers[i] == obs ) {
				idx = i;
				break;
			}
		}
		if( idx != -1 ) {
			_observers.splice( idx, 1 );
		}
		return idx != -1;
	}
	
	public function notifyObservers( event:String ):void {
		for( var i:Number=0; i < _observers.length; i++ ) {
			_observers[i]["on"+event]();
		}
	}
}
}