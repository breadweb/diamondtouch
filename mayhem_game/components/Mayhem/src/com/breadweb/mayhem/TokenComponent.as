package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class TokenComponent
	{
		private var _control:GameControl;
		private var _token:Token;
	
		public var boolActive:Boolean = true;
		
		public function TokenComponent()
		{
			Console.log("Constructing token...");
			_control = GameControl.getInstance();
			
			_token = new Token();
			_token.visible = false;
			_control.view.gameLayer.addChild(_token);
			
			setupButton();
		}
		
		// Initialize the token
		public function init(card:CardComponent):void
		{
			trace("Initializing token..." + card.intX + ", " + card.intY);

			// Place token underneath the random card picked
			_token.x = card.intX;
			_token.y = card.intY;
		}
		
		public function activateToken():void
		{
			_token.visible = true;
			toggleTouch(true);
		}
		
		public function setupButton():void
		{
			if (CONFIG::DTENABLED)
			{				
				_token["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData)
				{
					_control.onTokenTouch(dtev.receiver);
				};			
			}
			else
			{
				_token.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					_control.onTokenTouch(_control.currentPlayer);	
				});						
			}			
		}
		
		public function toggleTouch(boolEnabled:Boolean):void
		{
			if (CONFIG::DTENABLED)
			{
				if (boolEnabled)
					_control.diamondTouch.addObserver(_token);
				else
					_control.diamondTouch.removeObserver(_token);
			}
			else
			{			
				(_token as MovieClip).mouseEnabled = boolEnabled;	
				(_token as MovieClip).mouseChildren = boolEnabled;
			}
		}
		
		public function destroy():void
		{
			// TODO: Remove listeners
			
			if (_token != null)
			{
				toggleTouch(false);
				_token.parent.removeChild(_token);
				_token = null;
			}
		}
		
		public function get token():Token
		{
			return _token;		
		}
	}
}