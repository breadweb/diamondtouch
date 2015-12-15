package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	import gs.easing.Back;

	public class ChoiceComponent
	{
		private var _control:GameControl;
		private var _choice:Choice;
		private var _fnc:Function;
		
		private var aryCoords:Array;
		private var aryCards:Vector.<CardComponent>;	
		private var intShowCards:Number;

		public var intArg:int;		
		public var aryImages:Array;
		public var intIndex:Number;		
		
		public function ChoiceComponent()
		{
			_control = GameControl.getInstance();			
			
			aryCoords = new Array();
			aryCoords[0] = [[-110, -56], [4, -56]];				
			aryCoords[1] = [[-167, -56], [-52, -56], [62, -56]];
			
			_choice = new Choice();
			_control.view.gameLayer.addChild(_choice);
			
			setupButton();
		}
		
		public function init(index:Number, header:String, desc:String, images:Array, showCards:Number, x:Number, y:Number, fnc:Function, arg:int):void
		{			
			intIndex = index;
			aryCards = new Vector.<CardComponent>();
			aryImages = images;
			intShowCards = showCards;
			
			_choice.x = x;
			_choice.y = y;
			_choice.scaleX = _choice.scaleY = 0;
			
			updateInfo(header, desc, images, showCards, fnc, arg);		
			
			toggleTouch(true);
		}
		
		public function updateInfo(header:String, desc:String, images:Array, showCards:Number, fnc:Function, arg:int):void
		{
			_choice.txtHeader.htmlText = "<b>" + header + "</b>";
			_choice.txtDesc.htmlText = "<b>" + desc + "</b>";		
			_fnc = fnc;		
			intArg = arg;
			if (images != null)
			{
				aryImages = images;
				intShowCards = showCards;
				setImages();
			}
			toggleTouch(true);		
		}
		
		private function setImages():void
		{
			// Create card objects for as many image references
			// that are passed. Use the appropriate coordinate
			// array for placement based on 2 or 3 cards
			if (aryImages != null)
			{				
				for (var i:int = 0; i < intShowCards; i++)
				{
					aryCards[i] = new CardComponent();
					aryCards[i].addToChoice(this, "mcCard" + i);
					aryCards[i].init(
						i,
						aryImages[i].@id.toString(),
						aryImages[i].@filename.toString(),
						aryCoords[(intShowCards-2)][i][0],
						aryCoords[(intShowCards-2)][i][1],
						0,
						Number.MAX_VALUE,
						Number.MAX_VALUE,
						Number.MAX_VALUE,
						false,
						_control.view.intCardSide);					
				}			
			}
		}
		
		private function pressSlot():void
		{
			TweenMax.to(_choice, .1, {
				scaleX:.95,
				scaleY:.95,
				glowFilter:{color:0x11C5FE, alpha:100, blurX:50, blurY:50}});
			
			_control.soundManager.play("beep");
		}
		
		private function releaseSlot():void
		{
			TweenMax.to(_choice, .25, {
				scaleX:1,
				scaleY:1,
				glowFilter:{alpha:0, blurX:0, blurY:0, remove:true},
				ease:Back.easeOut});
		}	
		
		public function setupButton():void
		{
			if (CONFIG::DTENABLED)
			{				
				_choice["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressSlot();
				};			
				_choice["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseSlot();
					_fnc.apply(null, [intArg, dtev.receiver, intIndex]);					
				};	
			}
			else
			{
				_choice.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressSlot();		
				});						
				_choice.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseSlot();
					_fnc.apply(null, [intArg, _control.currentPlayer, intIndex]);	
				});
			}						
		}

		public function toggleTouch(boolEnabled:Boolean):void
		{
			if (CONFIG::DTENABLED)
			{
				if (boolEnabled)
					_control.diamondTouch.addObserver(_choice);
				else
					_control.diamondTouch.removeObserver(_choice);
			}
			else
			{			
				_choice.mouseEnabled = boolEnabled;	
				_choice.mouseChildren = boolEnabled;
			}
		}
		
		public function destroy():void
		{
			// TODO: Remove listeners
			
			toggleTouch(false);
			_choice.parent.removeChild(_choice);
			_choice = null;
		}		
		
		public function get choice():Choice
		{
			return _choice;
		}
	}
}