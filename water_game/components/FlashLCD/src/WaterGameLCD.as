package
{
	import com.breadweb.watergamelcd.GameControl;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(width='1920', height='1080', backgroundColor='#FFFFFF', frameRate='40')]
	public class WaterGameLCD extends Sprite
	{
		public function WaterGameLCD()
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