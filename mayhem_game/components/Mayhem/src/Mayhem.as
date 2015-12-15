package
{
	import com.breadweb.mayhem.GameControl;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width='1400', height='1050', backgroundColor='#1E3648', frameRate='40')]
	public class Mayhem extends Sprite
	{
		public function Mayhem()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);			
		}
		
		private function onAdded(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			GameControl.getInstance().init(this);
		}		
	}	
}