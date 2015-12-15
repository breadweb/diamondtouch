/*
 * Author: Richard Lord
 * Copyright (c) Big Room Ventures Ltd. 2007
 * Version: 1.0.3
 *
 * Modified by: Aaron Pace for the purposes of DTFlash
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.circle12.diamondtouch
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	
	/**
	 * <p>Games often need to get the current state of various keys in order to respond to user input. 
	 * This is not the same as responding to key down and key up events, but is rather a case of discovering 
	 * if a particular key is currently pressed.</p>
	 * 
	 * <p>In Actionscript 2 this was a simple matter of calling Key.isDown() with the appropriate key code. 
	 * But in Actionscript 3 Key.isDown no longer exists and the only intrinsic way to react to the keyboard 
	 * is via the keyUp and keyDown events.</p>
	 * 
	 * <p>The KeyPoll class rectifies this. It has isDown and isUp methods, each taking a key code as a 
	 * parameter and returning a Boolean.</p>
	 */
	public class KeyPoll extends Sprite
	{
		private static var keyStates:Object = null;
		private static var dispObj:DisplayObject = null;
		
		public static function listen( stage:Stage ):void {
			new KeyPoll( stage );
		}
		
		/**
		 * Constructor
		 * 
		 * @param displayObj a display object on which to test listen for keyboard events. To catch all key events use the stage.
		 */
		public function KeyPoll( stage:Stage )
		{
			if( dispObj == null && stage != null )
			{
				keyStates = new ByteArray();
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				keyStates.writeUnsignedInt( 0 );
				
				dispObj = stage;
				dispObj.addEventListener( KeyboardEvent.KEY_DOWN, keyDownListener );
				dispObj.addEventListener( KeyboardEvent.KEY_UP, keyUpListener );
			}
		}
		
		private function keyDownListener( ev:KeyboardEvent ):void
		{
			keyStates[ ev.keyCode ] = true;
		}
		
		private function keyUpListener( ev:KeyboardEvent ):void
		{
			keyStates[ ev.keyCode ] = false;
		}
		
		/**
		 * To test whether a key is down.
		 *
		 * @param keyCode code for the key to test.
		 *
		 * @return true if the key is down, false otherwise.
		 *
		 * @see isUp
		 */
		public static function isDown( keyCode:uint ):Boolean
		{
			return keyStates[ keyCode ] == true;
		}
		
		/**
		 * To test whether a key is up.
		 *
		 * @param keyCode code for the key to test.
		 *
		 * @return true if the key is up, false otherwise.
		 *
		 * @see isDown
		 */
		public static function isUp( keyCode:uint ):Boolean
		{
			return !isDown( keyCode );
		}
	}
}