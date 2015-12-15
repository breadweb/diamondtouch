package com.breadweb.recycle
{
	import com.breadweb.utils.Console;
	import com.breadweb.utils.ExternalAsset;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;

	public class GarbageType
	{
		public var name:String;
		public var type:String;
		public var file:String;
		public var content:Bitmap;
		private var _onReady:Function;
		private var _onReadyParms:Array;
		
		public function GarbageType(xml:XML, onReady:Function = null, onReadyParms:Array = null)
		{
			name = xml.@name;
			type = xml.@type;
			file = xml.@file;
			_onReady = onReady;
			_onReadyParms = onReadyParms;
			
			var extAsset:ExternalAsset = new ExternalAsset("assets/" + file);
			extAsset.addEventListener(Event.COMPLETE, onComplete);
			extAsset.load();
		}
		
		private function onComplete(evt:Event):void
		{
			var extAsset:ExternalAsset = evt.target as ExternalAsset;
			content = Bitmap(extAsset.content);
			
			extAsset.removeEventListener(Event.COMPLETE, onComplete);
			extAsset = null;
			
			if (_onReady != null)
			{
				_onReady.apply(null, _onReadyParms);
			}
		}

	}
}