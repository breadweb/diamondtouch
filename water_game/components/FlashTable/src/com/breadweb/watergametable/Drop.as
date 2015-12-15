package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * Drops are meant to be reused to limit the total amount of 
	 * new drop object instantiations
	 */
	public class Drop
	{
		public var view:DropView; 
		private var _active:Boolean = false;
		private var _x:int;
		private var _y:int;
		private var _speed:Number;
		
		public function Drop(parent:Sprite, x:int, y:int, speed:int)
		{
			view = new DropView();
			parent.addChild(view);

			this.x = x;
			this.y = y;
			this.speed = speed;
			this.active = true;
		}
		
		public function destroy():void
		{
			this.active = false;
			view.visible = false;
			remove();
			
//			if (animate)
//			{
//				if (removeObject)
//					TweenMax.to(view, .25, {autoAlpha:0, onComplete:remove});
//				else
//					TweenMax.to(view, .25, {autoAlpha:0});
//			}
//			else
//			{
//				view.visible = false;
//				if (removeObject)
//					remove();
//			}
		}
		
		private function remove():void
		{
			view.parent.removeChild(view);
		}
		
		public function set x(value:int):void
		{
			_x = value;
			view.x = _x;
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set y(value:int):void
		{
			_y = value;
			view.y = _y;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function set active(value:Boolean):void
		{
			_active = value;
			if (_active)
			{
				view.alpha = 1;
				view.visible = true;
			}
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set speed(value:Number):void
		{
			_speed = value;
		}		
		
		public function get speed():Number
		{
			return _speed;
		}
		
	}
}