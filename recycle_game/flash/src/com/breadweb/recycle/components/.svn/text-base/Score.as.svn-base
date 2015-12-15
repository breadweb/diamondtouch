package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameConst;
	import com.breadweb.recycle.Position;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	
	import gs.TweenMax;
	import gs.easing.Back;
	import gs.easing.Bounce;
	
	public class Score
	{
		[Embed(source="/../assets/layout.swf", symbol="score")]
		private const SCORE:Class;			
		
		private var _player:int;
		private var _container:MovieClip;
		private var _button:MovieClip;
		private var _finalText:MovieClip;
		private var _panel:MovieClip;
		private var _pos:Position;
		private var _extendX:int;
		private var _extendY:int;
		
		public function Score(player:int, pos:Position, extendX:int, extendY:int, rotation:int, layer:Sprite)
		{
			_player = player;
			_pos = pos;
			_extendX = extendX;
			_extendY = extendY;
			
			_container = new SCORE();
			_container.x = pos.xOut;
			_container.y = pos.yOut;
			_container.rotation = rotation;
			
			_button = _container.getChildByName("button") as MovieClip;
			_finalText = _container.getChildByName("final") as MovieClip;
			_panel = _container.getChildByName("panel") as MovieClip;
			
			TweenMax.to(_container["back"], .1, {tint:GameConst.COLORS[_player]});
			TweenMax.to(_button["label"], .1, {tint:GameConst.COLORS[_player]});
			(_button["label"]["txt"] as TextField).text = "PLAY AGAIN";
			
//			toggleFinal(false);
			
			layer.addChild(_container);
		}
		
		public function moveIn():void
		{
			TweenMax.to(_container, 1, {x:_pos.xIn, y:_pos.yIn, ease:Back.easeOut, delay:.25});
		}
		
		public function moveOut():void
		{
			TweenMax.to(_container, 1, {x:_pos.xOut, y:_pos.yOut, ease:Back.easeIn});
		}		
		
		public function setScore(type:String, score:String):void
		{
			(_panel[type] as TextField).text = score;
		}
		
		public function reset():void
		{
			moveOut();
			for (var i:int = 0; i < GameConst.TYPES.length; i++)
			{
				(_panel[GameConst.TYPES[i]] as TextField).text = "0\n0";
			}
		}
		
		public function toggleFinal(show:Boolean, finalText:String = ""):void
		{
			(_finalText["txt"] as TextField).text = finalText;
			if (show)
			{
				TweenMax.to(_container, 1, {x:_extendX, y:_extendY});
			}
//			
//			if (show)
//			{
//				TweenMax.to(_button, 1, {startAt:{alpha:0}, autoAlpha:1});
//				TweenMax.to(_finalText, 1, {startAt:{alpha:0}, autoAlpha:1});
//				_panel.visible = false;
//			} 
//			else
//			{
//				_button.visible = false;
//				_finalText.visible = false;
//				_panel.visible = true;
//			}
		}
		
		public function get player():int
		{
			return _player;
		}
		
		public function get container():MovieClip
		{
			return _container;	
		}
		
		public function get button():MovieClip
		{
			return _button;
		}		
	}
}