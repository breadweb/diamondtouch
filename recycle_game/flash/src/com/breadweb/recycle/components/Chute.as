package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameControl;
	import com.breadweb.utils.Console;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import gs.TweenLite;
	
	public class Chute
	{
		[Embed(source="/../assets/layout.swf", symbol="chute")]
		private const CHUTE:Class;			
		
		private var _type:String;
		private var _container:MovieClip;

		public function Chute(type:String, xpos:int, ypos:int, layer:Sprite)
		{
			_type = type;
			_container = new CHUTE();
			_container.x = xpos;
			_container.y = ypos;
			_container.gotoAndStop(_type);
			_container.visible = false;
			layer.addChild(_container);
		}
		
		public function start():void
		{
			var spins:int = GameControl.getInstance().settings["spins"] * .5;
			var gameTime:int = GameControl.getInstance().settings["gametime"] * 3;
			TweenLite.to(_container.getChildByName("icon") as MovieClip, gameTime, {rotation:spins * -360});			
		}
		
		public function stop():void
		{
			TweenLite.killTweensOf(_container.getChildByName("icon") as MovieClip);
		}
		
		public function showMatch(color:uint):void
		{
			var ring:MovieClip = _container.getChildByName("ring") as MovieClip;
			Console.getInstance().log(ring.name + " " + color, this);
			
			TweenLite.to(ring, .15, {tint:color, alpha:1});
			TweenLite.to(ring, 1, {removeTint:true, alpha:0, delay:.25, overwrite:0});
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