package com.breadweb.recycle.components
{
	import com.breadweb.recycle.SoundControl;
	import com.breadweb.utils.Console;
	import com.breadweb.utils.PropertyMonitor;
	
	import flash.display.Sprite;
	
	import gs.TweenMax;
	import gs.easing.Linear;
	
	public class Truck
	{
		[Embed(source="/../assets/layout.swf", symbol="truck")]
		private const TRUCK:Class;	
		
		[Embed(source="/../assets/layout.swf", symbol="truck2")]
		private const TRUCK2:Class;			
		
		private var _container:Sprite;
		private var _startX:int;
		private var _endX:int;
		
		public function Truck(startX:int, startY:int, endX:int, truck:int, scaleX:int, layer:Sprite)
		{
			_container = (truck == 2) ? new TRUCK2() : new TRUCK();
			_container.x = startX;
			_container.y = startY;
			_container.scaleX = scaleX;
			
			_startX = startX;
			_endX = endX;
			
			layer.addChild(_container);
			
			PropertyMonitor.getInstance().addSubject(_container.name + " x ", container, "x");
		}
		
		public function driveIn(onComplete:Function = null):void
		{
			if (onComplete != null)
			{
				TweenMax.to(_container, 3, {x:_endX, onComplete:onComplete});
			}
			else
			{
				TweenMax.to(_container, 3, {x:_endX});
			}
				
			SoundControl.getInstance().play("truckidle", _container.name, 100);
		}
		
		public function driveOut():void
		{
			TweenMax.to(_container, 4, {x:_startX, ease:Linear.easeIn});
			SoundControl.getInstance().stop("truckidle", _container.name);
			SoundControl.getInstance().play("truckdrive");
		}	
		
		public function reset(drive:Boolean = false):void
		{
			Console.getInstance().log("Resetting truck, driving = " + drive, this);
			TweenMax.killTweensOf(_container);
			if (drive)
			{
				driveOut();
			}
		}
		
		public function get container():Sprite
		{
			return _container;	
		}
		
	}
}