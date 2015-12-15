package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import gs.TweenMax;
	import gs.easing.Back;
	import gs.easing.Cubic;

	public class CardComponent
	{
		private var _control:GameControl;
		private var _card:Card;
		private var aryCoordsOn:Array;
		private var aryCoordsOff:Array;
		
		public var intIndex:Number;
		public var strID:String;
		public var strSide:String = "front";
		public var intX:Number;
		public var intY:Number;
		public var intRotation:Number;
		public var intCardSide:Number;
		public var boolActive:Boolean = true;
		
		public function CardComponent(choice:ChoiceComponent = null)
		{
			_control = GameControl.getInstance();			
			_card = new Card();
		}
		
		public function addToChoice(comp:ChoiceComponent, name:String):void
		{
			comp.choice.addChild(_card);	
			_card.name = name;
		}
		
		public function addToView():void
		{
			_control.view.gameLayer.addChild(_card);
		}
		
		public function init(index:int, id:String, image:String, startX:Number, startY:Number, startRotation:Number, x:Number, y:Number, rotation:Number, active:Boolean, cardSide:Number):void
		{			
			intIndex = index;
			strID = id;
			intX = (x == Number.MAX_VALUE) ? startX + _card.width / 2 : x + _card.width / 2;
			intY = (y == Number.MAX_VALUE) ? startY + _card.height / 2 : y + _card.height / 2;
			intRotation = (rotation == Number.MAX_VALUE) ? startRotation : rotation;
			intCardSide = cardSide;
			
			_card.width = _card.height = intCardSide;
			
			loadThumb("assets/cards/" + image);
			
			_card.x = startX + _card.width / 2;
			_card.y = startY + _card.height / 2;
			_card.rotation = startRotation;
			
			aryCoordsOn = [[-57, -57], [0, -57], [-57, 0], [0, 0]];
			aryCoordsOff = [[0, 0], [-57, 0], [0, -57], [-57, -57]];
			
			// Set highlight colors
			for (var i:int = 0; i < _control.view.aryColors.length; i++)
			{
				TweenMax.to(_card["mcHigh" + i], .1, {alpha:.4, tint:_control.view.aryColors[i]});
				_card["mcHigh" + i].x = aryCoordsOff[i][0];
				_card["mcHigh" + i].y = aryCoordsOff[i][1];
			}
			
			// If card is not clickable, show it right away
			if (!active)
				_card.mcFront.visible = false;
			else
				setupButton();			
		}
		
		private function loadThumb(strPath:String):void
		{	
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, function(evt:ErrorEvent):void
			{
				Console.log("There was an error loading " + strPath + evt.text);		
			});						
			
			var request:URLRequest = new URLRequest(strPath);
			loader.load(request);
			
			_card.mcBack.addChild(loader);
		}
					
		public function dealCard(intDelay:Number):void
		{
			_control.view.setToTop(_card);
			TweenMax.to(_card, .75, {rotation:intRotation, x:intX, y:intY, delay:intDelay});
			// Play a random deal sound to make it sound more human
			TweenMax.delayedCall(intDelay, _control.soundManager.play, ["deal" + (Math.floor(Math.random() * 3) + 1)]);
		}
		
		public function activateCard(intDelay:Number):void
		{
			var intScaleY:Number = intCardSide / 114;
			TweenMax.to(_card, .20, {scaleY:.1 * intScaleY, blurFilter:{blurY:5}, delay:intDelay, onComplete:showSide, onCompleteParams:[_card.mcFront, false]});
			TweenMax.to(_card, .25, {scaleY:intScaleY, blurFilter:{blurY:0, remove:true}, delay:intDelay + .3});		
			// Play a random card sound to make it sound more human
			TweenMax.delayedCall(intDelay, _control.soundManager.play, ["deal" + (Math.floor(Math.random() * 3) + 1)]);			
			TweenMax.delayedCall(intDelay + .3, toggleTouch, [true]);
		}
		
		public function spinTo(intRotation:Number):void
		{
			TweenMax.to(_card, .65, {shortRotation:{rotation:intRotation}, ease:Back.easeOut});
		}
		
		public function shakeOff(intIndex:Number, boolState:Boolean):void
		{
			var intAlpha:Number = (boolState) ? 40 : 0;
			TweenMax.to(_card, .05, {shortRotation:{rotation:intRotation + 5}});
			TweenMax.to(_card, .05, {shortRotation:{rotation:intRotation - 10}, delay:.05});
			TweenMax.to(_card, .05, {shortRotation:{rotation:intRotation + 10}, delay:.1});
			TweenMax.to(_card, .05, {shortRotation:{rotation:intRotation - 10}, delay:.15});
			TweenMax.to(_card, .05, {shortRotation:{rotation:intRotation + 10}, delay:.2});		
			TweenMax.to(_card, .35, {shortRotation:{rotation:intRotation}, delay:.28});
			toggleHigh(intIndex, boolState);
		}	
		
		public function toggleHigh(intIndex:Number, boolState:Boolean):void
		{
			var aryCoords:Array = (boolState) ? aryCoordsOn : aryCoordsOff;
			TweenMax.to(_card["mcHigh" + intIndex], .75, {x:aryCoords[intIndex][0], y:aryCoords[intIndex][1], ease:Cubic.easeOut});
		}
		
		public function resetAllHigh():void
		{
			for (var i:int = 0; i < _control.view.aryColors.length; i++)
			{
				toggleHigh(i, false);
			}
		}
		
		public function showSide(mcSide:MovieClip, boolVisible:Boolean):void
		{
			mcSide.visible = boolVisible;
		}
		
		public function setupButton():void
		{
			if (CONFIG::DTENABLED)
			{				
				_card["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					_control.onCardTouch(intIndex, dtev.receiver);
				};			
			}
			else
			{
				_card.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					_control.onCardTouch(intIndex, _control.currentPlayer);	
				});						
			}			
		}
		
		public function toggleTouch(boolEnabled:Boolean):void
		{
			if (CONFIG::DTENABLED)
			{
				if (boolEnabled)
					_control.diamondTouch.addObserver(_card);
				else
					_control.diamondTouch.removeObserver(_card);
			}
			else
			{			
				(_card as MovieClip).mouseEnabled = boolEnabled;	
				(_card as MovieClip).mouseChildren = boolEnabled;
			}
		}
		
		public function destroy():void
		{
			// TODO: Remove listeners
			
			toggleTouch(false);
			_card.parent.removeChild(_card);
			_card = null;
		}		
		
		public function get card():Card
		{
			return _card;
		}
	}
}