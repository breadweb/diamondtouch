package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import gs.TweenMax;
	import gs.easing.Back;

	public class PlayerComponent
	{
		private var _gamePlayer:MovieClip;
		private var _lockDown:MovieClip;
		private var _control:GameControl;
		private var _toucher:int = -1;
		private var _locked:Boolean = false;
		
		public var intMatches:Number = 0;
		public var strName:String = "";
		public var arySelections:Array;
		
		public function PlayerComponent(useAlt:Boolean)
		{
			_control = GameControl.getInstance();
			
			_gamePlayer = (useAlt) ? new GamePlayerAlt() : new GamePlayer();
			_lockDown = (useAlt) ? new LockDownAlt() : new LockDown();
			
			_control.view.gameLayer.addChild(_gamePlayer);
			_control.view.gameLayer.addChild(_lockDown);
			_control.view.setToTop(_lockDown);
			_lockDown.visible = false;
		}
		
		public function init(intToucher:int, _strName:String, _aryCoords:Array, _intRotation:Number):void {
			
			_toucher = intToucher;				
			
			Console.log(intToucher + ", " + strName);		
			
			_gamePlayer.x = _aryCoords[0];
			_gamePlayer.y = _aryCoords[1];
			_gamePlayer.rotation = _intRotation;
			_lockDown.x = _aryCoords[0];
			_lockDown.y = _aryCoords[1];
			_lockDown.rotation = _intRotation;			
			
			// Setup scorer
			TweenMax.to(_gamePlayer.mcScorer.mcName, .1, {tint:_control.view.aryColors[intToucher]});				
			
			updatePlayer(_strName);
			resetSelections();		
		}
		
		public function updatePlayer(_strName:String):void
		{
			strName = _strName;
			_gamePlayer.mcScorer.mcName.txtName.text = strName;
		}
		
		public function updateScore(boolIncrease:Boolean):void
		{
			intMatches = (boolIncrease) ? intMatches + 1 : 0;
			_gamePlayer.mcScorer.mcScore.txtScore.text = intMatches;
			TweenMax.to(_gamePlayer.mcScorer.mcScore, .5, {xscale:1.5, yscale:1.5, ease:Back.easeOut});
			TweenMax.to(_gamePlayer.mcScorer.mcScore, .25, {xscale:1, yscale:1, delay:.5});
		}
		
		public function resetSelections():void
		{
			arySelections = new Array();
		}
		
		public function addSelection(intCard:int):Boolean
		{
			var intDups:int = 0;
			for (var i:int = 0; i < arySelections.length; i++)
			{
				if (arySelections[i] == intCard)
				{
					intDups++;
					removeSelection(intCard);
				}
			}
			if (intDups == 0)
			{
				arySelections.push(intCard);
				return true;
			} else {
				return false;
			}
		}
		
		public function removeSelection(intCard:Number):void
		{
			for (var i:int = arySelections.length - 1; i >= 0; i--)
			{
				if (arySelections[i] == intCard)
				{
					arySelections.splice(i, 1);
				}
			}		
		}
		
		public function hasCard(intCard:Number):Boolean
		{
			for (var i:int = 0; i < arySelections.length; i++)
			{
				if (arySelections[i] == intCard)
					return true;
			}
			return false;
		}
		
		public function getStackCoords():Point
		{
			return (_gamePlayer.mcScorer.mcStack as MovieClip).localToGlobal(new Point(0,0));
		}
		
		public function getTotalSelected():Number
		{
			return arySelections.length;
		}	
		
		public function setLockDown(locked:Boolean, strPlayer:String, strColor:String, intTime:Number):void
		{
			_locked = locked;
			for (var i:int = 0; i < intTime; i++)
			{
				TweenMax.delayedCall(i, updateLockDown, [strPlayer, strColor, intTime - i]); 
			}
		}
		
		private function updateLockDown(strPlayer:String, strColor:String, intSeconds:Number):void
		{
			var strMessage:String = "<font color='#" + strColor + "'>" + strPlayer + "</font> has the board for the next " + intSeconds + " seconds.";
			_lockDown.mcLockDown.txtMessage.htmlText = strMessage;
		}
		
		public function showLockDown(locked:Boolean):void
		{
			_control.view.setToTop(_lockDown);
			var intAlpha:Number = (locked) ? 1 : 0;
			TweenMax.to(_lockDown, .5, {autoAlpha:intAlpha});
		}
		
		public function destroy():void
		{
			// TODO: Remove listeners
			
			_gamePlayer.parent.removeChild(_gamePlayer);
			_gamePlayer = null;
			_lockDown.parent.removeChild(_lockDown);
			_lockDown = null;			
		}		
		
		public function getLockDown():Boolean
		{
			return _locked;
		}	
		
		public function get toucher():int
		{
			return _toucher;
		}
		
		public function get gamePlayer():MovieClip
		{
			return _gamePlayer;
		}
		
		public function get lockDown():MovieClip
		{
			return _lockDown;
		}		
	}
}