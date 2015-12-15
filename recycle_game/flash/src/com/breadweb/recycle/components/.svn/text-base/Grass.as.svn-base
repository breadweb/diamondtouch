package com.breadweb.recycle.components
{
	import com.breadweb.recycle.Position;
	
	import flash.display.Sprite;
	
	import gs.TweenMax;
	
	public class Grass
	{
		[Embed(source="/../assets/layout.swf", symbol="grasswide")]
		private const GRASSWIDE:Class;	
		
		[Embed(source="/../assets/layout.swf", symbol="grasstall")]
		private const GRASSTALL:Class;				
		
		private var _pos:Position;
		private var _container:Sprite;
		
		public function Grass(type:String, pos:Position, rotation:int, layer:Sprite)
		{
			_pos = pos;
			_container = (type == "wide") ? new GRASSWIDE() : new GRASSTALL();
			_container.x = _pos.xIn;
			_container.y = _pos.yIn;
			_container.rotation = rotation;
		
			layer.addChild(_container);
		}
		
		public function moveIn():void
		{
			TweenMax.to(_container, 1, {x:_pos.xIn, y:_pos.yIn});
		}
		
		public function moveOut():void
		{
			TweenMax.to(_container, 1, {x:_pos.xOut, y:_pos.yOut});
		}		
	}
}