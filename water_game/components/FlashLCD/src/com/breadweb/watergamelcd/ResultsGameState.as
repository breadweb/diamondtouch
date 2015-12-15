package com.breadweb.watergamelcd
{
	import com.breadweb.state.IState;
	import com.breadweb.utils.Console;
	
	import flash.events.Event;
	
	import gs.TweenMax;
	
	public class ResultsGameState implements IState
	{
		private var _view:GameView;
		private var _control:GameControl;
		private var _timeToWait:int = 2000;
		private var _timeWaited:int = 0;
		private var _results:Array;
		private var _resultsToShow:int = 0;
		private var _resultsShown:int = 0;
		private var _finalScript:String;
		private var _showResults:Boolean = false;
		
		public function ResultsGameState(results:Array)
		{
			_control = GameControl.getInstance();
			_view = _control.view;
			_results = results;
			
			_finalScript = _results.pop();
			
			_resultsToShow = _results.length / 3;
			
			Console.log("Results = " + _results, this);
		}
		
		public function enter():void
		{
			_control.loader.addEventListener(Event.ENTER_FRAME, onEnterFrame);				
		}
		
		public function exit():void
		{
			if (_control.loader.hasEventListener(Event.ENTER_FRAME))
				_control.loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_view.stopAllieScript();	
			
			TweenMax.killDelayedCallsTo(finishUp);
		}
		
		public function update(time:int):void
		{
			// Don't proceed if the results process hasn't started
			if (!_showResults)
				return;
			
			// Don't update time waited until the current allie script is done playing
			if (_view.isAlliePlaying())
				return;
			
			// If all results are shown, show the final end game button and prevent
			// from processing this update any further
			if (_resultsShown >= _results.length / 3)
			{
				_showResults = false;				
				TweenMax.delayedCall(2, finishUp);
				return;
			}
			
			_timeWaited += time;
			if (_timeWaited >= _timeToWait)
			{
				_view.setResultsView(_results[_resultsShown * 3], _results[_resultsShown * 3 + 1]);
				_view.playAllieScript(_results[_resultsShown * 3 + 2]);				
				_resultsShown++;
				_timeWaited = 0;
			}
		}
		
		private function onEnterFrame(evt:Event):void
		{
			// Wait for current alligator animation to complete
			if (_view.isAlliePlaying())
				return;
			
			// Kick things off after a slight delay
			_control.loader.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			TweenMax.delayedCall(3.5, init);
		}
		
		private function finishUp():void
		{
			_view.setResultsView("", "");
			_view.playAllieScript(_finalScript);
			_control.sendGameCue("end_game");
		}
		
		private function init():void
		{
			_view.setScene(GameView.SCENE_FINAL);
			_view.fadeIn();
			_view.playAllieScript("Post1");	
			_showResults = true;
		}
	}
}