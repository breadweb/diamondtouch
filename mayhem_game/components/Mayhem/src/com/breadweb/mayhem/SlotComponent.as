package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	import gs.easing.Back;

	public class SlotComponent
	{
		private var _control:GameControl;
		private var _index:int = 0;
		private var _slot:Slot;		
		
		public var toucher:int = -1;
		public var slotName:String = "";
		public var isReady:Boolean = false;
		
		public const NUMBER_LABELS:Array = ["one", "two", "three", "four"];
		
		public function SlotComponent()
		{
			_control = GameControl.getInstance();
			
			_slot = new Slot();
			_slot.mcStatus.mcCheck.scaleX = _slot.mcStatus.mcCheck.scaleY = 0;		
			_slot.mcStatus.mcCheck.alpha = 0;
			
			_control.view.gameLayer.addChild(_slot);
			
			setupButtons();
		}
		
		// Initialize the slot
		public function init(index:int, x:Number, y:Number):void
		{	
			_index = index;
			
			setSlotName("");
			setReady(false);
			setHeader("Player " + NUMBER_LABELS[_index]);
			
			_slot.x = x;		
			_slot.y = y;
			
			toggleTouch(true);
		}
		
		// Select this slot for a player or deselect it
		public function selectPlayerSlot(isSelected:Boolean, toucherId:int):void
		{
			var playerSlots:Vector.<SlotComponent> = _control.view.arySlots;
			
			if (isSelected)
			{
				// Only select the slot if another player hasn't selected it
				if (toucher == -1)
				{
					toucher = toucherId;
					setSlotColor();
					setReady(true);
					
					// Reset any other slot that might have been set by the same player
					for (var i:int = 0; i < playerSlots.length; i++)
					{
						if (playerSlots[i] != this && playerSlots[i].toucher == toucher)
						{
							playerSlots[i].selectPlayerSlot(false, -1);
						}
					}				
					pressSlot(toucher);				
				}
				else if (toucherId == toucher)
				{
					toucher = -1;
					pressSlot(toucher);
					setSlotColor();
					setReady(false);
				}				
			}
			else
			{
				toucher = -1;
				setSlotColor();
				setReady(false);
			}
			
			for (var i:int = 0; i < playerSlots.length; i++)
			{
				Console.log(i + ": " + playerSlots[i].toucher + " " + playerSlots[i].isReady);
			}
						
		}
		
		private function pressSlot(toucherId:Number):void
		{
			TweenMax.to(_slot, .1, {
				scaleX:.95,
				scaleY:.95,
				glowFilter:{color:0x11C5FE, alpha:1, blurX:.5, blurY:.5}});
			
			_control.soundManager.play("beep1-" + (toucherId + 1));
		}
		
		private function releaseSlot():void
		{
			TweenMax.to(_slot, .25, {
				scaleX:1,
				scaleY:1,
				glowFilter:{alpha:0, blurX:0, blurY:0, remove:true},
				ease:Back.easeOut});
		}
		
		public function setHeader(name:String):void
		{
			_slot.txtHeader.htmlText = "<b>" + name + ":</b>";
		}
		
		// Set the player name of the slot
		public function setSlotName(name:String):void
		{
			if (name != "")
				slotName = name;
			else
				slotName = "Player " + (_index + 1);

			_slot.mcName.txtName.text = slotName;		
		}
		
		// Toggle ready state of the slot
		public function setReady(ready:Boolean):void
		{
			isReady = ready;
			if (isReady)
			{
				_slot.mcStatus.mcText.txtStatus.htmlText = "<b>Ready!</b>";
				TweenMax.to(_slot.mcStatus.mcCheck, .5, {
					scaleX:1,
					scaleY:1,
					alpha:1,
					ease:Back.easeOut});
			}
			else
			{
				_slot.mcStatus.mcText.txtStatus.htmlText = "<b>Waiting...</b>";
				TweenMax.to(_slot.mcStatus.mcCheck, .5, {
					scaleX:.05,
					scaleY:.05,
					alpha:0,
					ease:Back.easeOut});
			}
		}
		
		// Set the slot color based on the DT player index
		public function setSlotColor():void
		{
			if (toucher == -1)
			{
				TweenMax.to(_slot.mcName, .5, {removeTint:true});
				TweenMax.to(_slot.mcStatus.mcBack, .5, {removeTint:true});
				TweenMax.to(_slot.mcStatus.mcText, .5, {removeTint:true});
			}
			else
			{
				TweenMax.to(_slot.mcName, .5, {tint:_control.view.aryColors[toucher]});	
				TweenMax.to(_slot.mcStatus.mcBack, .5, {tint:_control.view.aryColors[toucher]});
				TweenMax.to(_slot.mcStatus.mcText, .5, {tint:0xFFFFFF});			
			}
		}
		
		public function resetSlot():void
		{
			selectPlayerSlot(false, -1);
			setReady(false);
			setSlotName("");
		}
		
		public function setupButtons():void
		{
			if (CONFIG::DTENABLED)
			{				
				_slot["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					selectPlayerSlot(true, dtev.receiver);
				};			
				_slot["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseSlot();
				}			
			}
			else
			{
				_slot.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					selectPlayerSlot(true, _control.currentPlayer);		
				});						
				_slot.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseSlot();
				});
			}			
		}
		
		public function toggleTouch(boolEnabled:Boolean):void
		{
			if (CONFIG::DTENABLED)
			{
				if (boolEnabled)
					_control.diamondTouch.addObserver(slot);
				else
					_control.diamondTouch.removeObserver(slot);
			}
			else
			{			
				(_slot as MovieClip).mouseEnabled = boolEnabled;	
				(_slot as MovieClip).mouseChildren = boolEnabled;
			}
		}	
		
		public function destroy():void
		{
			// TODO: Remove listeners
			
			toggleTouch(false);
			_slot.parent.removeChild(_slot);
			_slot = null;
		}	
		
		public function get slot():Slot
		{
			return _slot;
		}		
	}
}