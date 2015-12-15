package com.breadweb.watergametable
{
	import com.breadweb.state.IState;
	import com.breadweb.utils.Console;
	
	public class AbstractState implements IState
	{
		public function AbstractState()
		{
		}
		
		public function enter():void
		{
			Console.log("Entering state " + this);
		}
		
		public function exit():void
		{
			Console.log("Exiting state " + this);
		}
		
		public function update(time:int):void
		{			
		}
	}
}