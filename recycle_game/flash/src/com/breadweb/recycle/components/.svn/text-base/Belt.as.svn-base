package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameConst;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Belt
	{
		[Embed(source="/../assets/layout.swf", symbol="smallbelt")]
		private const BELT:Class;			
		
		private var _type:String;
		private var _container:MovieClip;
		
		public function Belt(type:String, xpos:int, ypos:int, scalex:int, scaley:int, layer:Sprite)
		{
			_type = type;
			
			_container = new BELT();
			_container.x = xpos;
			_container.y = ypos;
			_container.scaleX = scalex;
			_container.scaleY = scaley;
			_container.visible = false;
			
			layer.addChild(_container);
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get container():MovieClip
		{
			return _container;	
		}
	}
}