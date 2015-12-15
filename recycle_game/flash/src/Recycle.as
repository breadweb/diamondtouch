package
{
	import com.breadweb.recycle.GameControl;
	
	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(width='1400', height='1050', backgroundColor='#FFFFFF', frameRate='40')]
	public class Recycle extends Sprite
	{
		public function Recycle()
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