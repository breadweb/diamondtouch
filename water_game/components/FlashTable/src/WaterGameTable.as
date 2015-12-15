package
{
	import com.breadweb.watergametable.GameControl;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width='1400', height='1050', backgroundColor='#1E3648', frameRate='40')]
	public class WaterGameTable extends Sprite
	{
		public function WaterGameTable()
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