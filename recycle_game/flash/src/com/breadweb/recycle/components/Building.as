package com.breadweb.recycle.components
{
	import com.breadweb.recycle.GameConst;
	import com.breadweb.recycle.GameControl;
	import com.breadweb.recycle.SoundControl;
	import com.breadweb.utils.Console;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class Building
	{
		[Embed(source="/../assets/layout.swf", symbol="building_glass")]
		private const GLASS_BUILDING:Class;		
		
		[Embed(source="/../assets/layout.swf", symbol="building_plastic")]
		private const PLASTIC_BUILDING:Class;	
		
		[Embed(source="/../assets/layout.swf", symbol="building_metal")]
		private const METAL_BUILDING:Class;	
		
		[Embed(source="/../assets/layout.swf", symbol="building_paper")]
		private const PAPER_BUILDING:Class;			
		
		private var _type:String;
		private var _container:MovieClip;
		private var _currentStack:int;
		
		public function Building(type:String, xpos:int, ypos:int, rotation:int, layer:Sprite)
		{
			_type = type;
			switch (_type)
			{
				case GameConst.GLASS:
					_container = new GLASS_BUILDING();
					break;
				case GameConst.PLASTIC:
					_container = new PLASTIC_BUILDING();
					break;
				case GameConst.METAL:
					_container = new METAL_BUILDING();
					break;
				case GameConst.PAPER:
					_container = new PAPER_BUILDING();
					break;				
			}
			_container.x = xpos;
			_container.y = ypos;
			_container.rotation = rotation;
			_container.visible = false;
			layer.addChild(_container);
			
			reset();
		}
		
		public function stackFinished(amount:int):void
		{
			var increment:int = int(GameControl.getInstance().settings["totalstack"]) / 10;
			var totalIncrements:int = amount / increment;
			Console.getInstance().log("totalIncrements " + totalIncrements);
			
			if (totalIncrements > _currentStack && totalIncrements <= 10)
			{
				Console.getInstance().log("stacking! " + totalIncrements);
				TweenMax.to((_container.getChildByName("finished" + totalIncrements) as MovieClip), .5,
					{startAt:{alpha:0, tint:0xFFFFFF},
//					{startAt:{alpha:0, scaleX:.1, scaleY:.1, tint:0xFFFFFF},
					autoAlpha:1,
//					scaleX:1,
//					scaleY:1,
					delay:.25,
					removeTint:true,
					ease:Back.easeOut});
				_currentStack = totalIncrements;
				TweenMax.delayedCall(.5, SoundControl.getInstance().play, ["finished"]);
			}
		}
		
		public function reset():void
		{
			// Hide stacked finished products
			for (var i:int = 1; i <= 10; i++)
			{
				(_container.getChildByName("finished" + i) as MovieClip).visible = false;
			}
			_currentStack = 0;
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