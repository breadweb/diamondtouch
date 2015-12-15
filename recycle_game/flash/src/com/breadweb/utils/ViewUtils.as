package com.breadweb.utils
{
	import flash.display.DisplayObject;

	public class ViewUtils
	{
		public static const CENTER:String = "center";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const MIDDLE:String = "middle";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		public function ViewUtils() {}
		
		public static function align(object:DisplayObject, subject:DisplayObject, horizontal:String = CENTER, vertical:String = MIDDLE):void
		{
			var x:int;
			var y:int;
			
			switch (horizontal)
			{
				case CENTER:
					x = (subject.width - object.width) / 2 + subject.x;
					break;
				case LEFT:
					x = subject.x;
					break;
				case RIGHT:
					x = subject.x + subject.width - object.width;
					break;
			}
			
			switch (vertical)
			{
				case CENTER:
					y = (subject.height - object.height) / 2 + subject.y;
					break;
				case TOP:
					y = subject.y;
					break;
				case BOTTOM:
					y = subject.y + subject.height - object.height;
					break;
			}	
			
			object.x = x;
			object.y = y;
		}
	}
}