package com.breadweb.watergametable
{
	import com.breadweb.utils.Console;
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import gs.TweenMax;
	import gs.easing.Back;
	
	public class GameView extends Sprite
	{
		public const SKIP_INTRODUCTION:String = "SKIP INTRODUCTION";
		public const SKIP_INSTRUCTIONS:String = "SKIP INSTRUCTIONS";
		private var _container:MovieClip;	
		private var _introText:MovieClip;
		private var _instructionsText:MovieClip;
		public var finishButton:MovieClip;
		public var skipButton:MovieClip;
		public var skipButtonText:TextField;
		public var introClip:MovieClip;
		public var dropArea:MovieClip;
		public var gameLayer:Sprite;
		public var debugLayer:Sprite;	
		
		public function GameView()
		{
			gameLayer = new Sprite();
			gameLayer.name = "_gameLayer";		
			debugLayer = new Sprite();
			debugLayer.name = "_debugLayer";
			
			addChild(gameLayer);
			addChild(debugLayer);	
			
			_container = new MainView();
			_container.stop();
			gameLayer.addChild(_container);
			
			_introText = _container.getChildByName("introText") as MovieClip;	
			_instructionsText = _container.getChildByName("instructionsText") as MovieClip;
			dropArea = _container.getChildByName("dropArea") as MovieClip;
			introClip = _container.getChildByName("introClip") as MovieClip;
			finishButton = _container.getChildByName("finishButton") as MovieClip;
			skipButton = _container.getChildByName("skipButton") as MovieClip;
			skipButtonText = skipButton.getChildByName("textLabel") as TextField;
		}
		
		// Start playing at a specific label marker in a movieclip
		// By default the clip is the main container but can be any clip
		public function goTo(marker:String, clip:MovieClip = null):void
		{
			if (!clip)
				clip = _container;				
			
			var found:Boolean = false;
			for (var i:int = 0; i < clip.currentLabels.length; i++)
			{
				if ((clip.currentLabels[i] as FrameLabel).name == marker)
				{
					found = true;
					break;
				}
			}
			
			if (found)
				clip.gotoAndPlay(marker);
			else
				Console.log("Frame label not found: " + marker, this);
			
			return;
		}
		
		public function playIntroPart(marker:String):void
		{
			goTo(marker, introClip);
		}
		
		public function toggleIntroClip(show:Boolean):void
		{
			if (show)
			{
				introClip.visible = true;
				TweenMax.to(introClip, 1, {y:0});
			}
			else
			{
				TweenMax.to(introClip, 1, {y:1450, visible:false});
			}
		}
		
		public function getPlayer(player:String):MovieClip
		{
			return _container.getChildByName(player) as MovieClip;
		}
		
		public function changeIntroText(textValue:String, animate:Boolean = true, fadeOut:int = 0):void
		{
			var tf:TextField = _introText.getChildByName("introText") as TextField;
			if (tf != null)
			{
				tf.text = textValue;
				if (animate)
					TweenMax.to(_introText, 2, {alpha:1, startAt:{alpha:0}});
				else
					_introText.alpha = 1;
				
				// Fade out after changing if specified
				if (fadeOut > 0)
				{
					var delayAmount:int = (animate) ? fadeOut + 2 : fadeOut;
					TweenMax.to(_introText, 1, {alpha:0, delay:delayAmount});
				}
			}
		}
		
		public function changeSubText(textValue:String, animate:Boolean = true):void
		{
			var tf:TextField = _introText.getChildByName("subText") as TextField;
			if (tf != null)
			{
				tf.text = textValue;
				if (animate)
					TweenMax.to(_introText, 2, {alpha:1, startAt:{alpha:0}});
				else
					_introText.alpha = 1;				
			}
		}
		
		public function showInstructionsText(show:Boolean = true, animate:Boolean = true):void
		{
			if (show)
			{
				if (animate)
					TweenMax.to(_instructionsText, 1, {startAt:{scaleX:0, scaleY:0, autoAlpha:0}, scaleX:1, scaleY:1, autoAlpha:1, ease:Back.easeOut});
				else
				{
					_instructionsText.scaleX = 1;
					_instructionsText.scaleY = 1;
					_instructionsText.alpha = 1;
				}				
			}
			else
			{
				if (animate)
					TweenMax.to(_instructionsText, 1, {scaleX:0, scaleY:0, autoAlpha:1, ease:Back.easeIn});
				else
				{				
					_instructionsText.alpha = 0;
					_instructionsText.visibe = false;
				}
			}
		}		
		
		public function setFinishButton(show:Boolean):void
		{
			if (show)
			{
				TweenMax.to(finishButton, 1, {autoAlpha:1});
			}
			else
			{
				finishButton.alpha = 0;
				finishButton.visible = false;
			}
		}
		
		public function setSkipButton(show:Boolean):void
		{
			if (show)
			{
				skipButton.enabled = true;
				TweenMax.to(skipButton, 1, {autoAlpha:1});
			}
			else
			{
				skipButton.enabled = false;
				if (skipButton.visible)
					TweenMax.to(skipButton, 1, {autoAlpha:0});
			}
		}
		
		public function advanceSkipButton():void
		{
			setSkipButtonText(SKIP_INSTRUCTIONS);
			TweenMax.to(skipButton, 1, {startAt:{tint:0xFFFFFF}, tint:null});
		}
		
		public function setSkipButtonText(text:String):void
		{
			skipButtonText.text = text;
		}
	}
}