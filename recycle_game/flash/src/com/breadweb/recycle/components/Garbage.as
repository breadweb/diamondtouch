package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameControl;
	import com.breadweb.recycle.GarbageType;
	import com.breadweb.recycle.SoundControl;
	import com.breadweb.recycle.behaviors.Dragging;
	import com.breadweb.recycle.behaviors.Movement;
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.TouchEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	
	import gs.TweenMax;
	import gs.easing.Back;
	import gs.easing.Elastic;
	import gs.easing.Linear;

	public class Garbage
	{
		private var _garbageType:GarbageType;
		private var _container:Sprite; // The container for the bitmap content
		private var _bounds:Rectangle;
		private var _movement:Movement;
		private var _enabled:Boolean = false;
		private var _collectedBy:int = -1;
		
		public function Garbage(type:GarbageType)
		{
			Console.getInstance().log("New " + type.name + " (" + type.type + ") garbage created.", this);
			_garbageType = type;
		}
		
		public function init(layer:Sprite, bounds:Rectangle, interactive:Boolean = true):void
		{
			_bounds = bounds;
			
			var bmd:BitmapData = new BitmapData(_garbageType.content.width, _garbageType.content.height, true, 0xFFFFFF);
			bmd.draw(_garbageType.content);
			var bmp:Bitmap = new Bitmap(bmd);
			bmp.smoothing = true;
			_container = new Sprite();
			_container.addChild(bmp);
			
			layer.addChild(_container);			
			
			// Adjust bmp so registration point of parent container will be centered
			bmp.x -= bmp.width / 2;
			bmp.y -= bmp.height / 2;
			
			// Also adjust bounds for this item
			_bounds.x += bmp.width / 2;
			_bounds.y += bmp.height / 2;
			
			// Random rotation
			//_container.rotation = Math.floor(Math.random() * 360) + 1;
			
			if (interactive) 
			{
				// Add behaviors
				_movement = new Movement(_container, _bounds, Number(GameControl.getInstance().settings["speed"]));
				if (GameControl.getInstance().gameEnabled)
				{
					_enabled = true;
				}
			}
		}
		
		public function moveTo(xpos:int, ypos:int, fade:Boolean = true):void
		{
			_container.x = xpos;
			_container.y = ypos;
			if (fade)
			{
				TweenMax.to(_container, .5, {alpha:1, startAt:{alpha:0}});
			}
		}
		
		public function resize(scale:Number):void
		{
			_container.scaleX = _container.scaleY = scale;
		}
		
		public function startMoving():void
		{
			_movement.start();
		}
		
		public function sendDownChute(chute:Chute):void
		{
			TweenMax.to(_container, .75, {
				scaleX:0,
				scaleY:0,
				x:chute.container.x + chute.container.width / 2,
				y:chute.container.y + chute.container.height / 2,
				rotation:360 * 2,
				ease:Back.easeIn,
				onComplete:GameControl.getInstance().completeGarbage,
				onCompleteParams:[this, chute]});				
		}		
		
		public function sendToBuilding(x:int, y:int):void
		{
			TweenMax.to(_container, 2, {
				x:x,
				y:y,
				ease:Linear.easeIn,
				onComplete:GameControl.getInstance().collectGarbage,
				onCompleteParams:[this]});			
		}
		
		public function onTouchDown():void
		{			
			_movement.stop();
			GameControl.getInstance().restackGarbage(this);
		}
		
		public function onTouchUp(player:int):void
		{
			var chutes:Array = GameControl.getInstance().chutes;
			for (var i:String in chutes)
			{
				var chute:Chute = chutes[i] as Chute;
				if (_container.hitTestObject(chute.container["hitBox"]) && _garbageType.type == chute.type )
				{
						_collectedBy = player;
						Console.getInstance().log(_collectedBy + " put " + this + " in " + chute.type, this);
						Console.getInstance().log(_container.x + ", " + _container.y + " | " + chute.container.x + ", " + chute.container.y, this);
						cleanup();
						GameControl.getInstance().registerHit(this, chute);
						return;
				}
			}
			
			SoundControl.getInstance().play("wrong");
			GameControl.getInstance().restackGarbage(this);
			GameControl.getInstance().placeGarbage(this);
		}
		
		public function cleanup():void
		{
			_movement.stop();
		}
		
		public function reset():void
		{
			_container.scaleX = 1;
			_container.scaleY = 1;
			_container.rotation = 0;
		}

		public function get container():Sprite
		{
			return _container;
		}
		
		public function get garbageType():GarbageType
		{
			return _garbageType;
		}		
		
		public function get movement():Movement
		{
			return _movement;
		}	
		
		public function get collectedBy():int
		{
			return _collectedBy;
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(v:Boolean):void
		{
			_enabled = v;
		}
	}
}