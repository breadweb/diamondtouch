package com.breadweb.recycle.behaviors
{
	import com.breadweb.utils.Console;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class Movement
	{
		private const DIRECTIONS:Array = ["left", "down", "right", "up"];
		private var _dob:DisplayObject;
		private var _bounds:Rectangle;
		private var _vx:int = 0;
		private var _vy:int = 0;
		private var _direction:int;
		private var _velocity:Number;
		
		/**
		 * Create a new movement behavior for a display object
		 * 
		 * @param dob The display object that should move
		 * @param bounds A rectangle describing the bounds of the movement
		 * @param direction The initial starting direction
		 */
		public function Movement(dob:DisplayObject, bounds:Rectangle, velocity:Number, direction:int = 1)
		{
			_dob = dob;
			_bounds = bounds;
			_direction = direction;
			_velocity = velocity;
		}
		
		public function start():void
		{
			_vx = _vy = 0;
			_dob.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function stop():void
		{
			_dob.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(evt:Event):void
		{
			switch (DIRECTIONS[_direction])
			{
				case "left":
					_vx = -_velocity;
					move();
					if (_dob.x + _vx <= _bounds.x)
					{
						_dob.x = _bounds.x;
						getNextDirection();
					}
					break;
				case "down":
					_vy = _velocity;
					move();
					if (_dob.y + _vy >= _bounds.y + _bounds.height - _dob.height)
					{
						_dob.y = _bounds.y + _bounds.height - _dob.height;
						getNextDirection();
					}					
					break;
				case "right":
					_vx = _velocity;
					move();
					if (_dob.x + _vx >= _bounds.x + _bounds.width - _dob.width)
					{
						_dob.x = _bounds.x + _bounds.width - _dob.width;
						getNextDirection();
					}					
					break;
				case "up":
					_vy = -_velocity;
					move();
					if (_dob.y + _vy <= _bounds.y)
					{
						_dob.y = _bounds.y;
						getNextDirection();
					}					
					break;				
			}
		}
		
		private function move():void
		{
			_dob.x += _vx;
			_dob.y += _vy;
		}
		
		private function getNextDirection():void
		{
			_direction = (_direction + 1 >= DIRECTIONS.length) ? 0 : _direction + 1;
			_vx = _vy = 0;
		}
		
		/**
		 * Set a direction by direction name
		 */
		public function setDirection(direction:String):void
		{
			for (var i:int = 0; i < DIRECTIONS.length; i++)
			{
				if (DIRECTIONS[i] == direction)
				{
					_direction = i;
					return;
				}
			}
		}
	}
}