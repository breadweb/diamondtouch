package com.breadweb.utils
{
	import com.breadweb.utils.Console;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	public class ExternalAsset extends EventDispatcher
	{
		private var _loader:Loader;
		private var _url:String;
		
		public function ExternalAsset(url:String)
		{
			_url = url;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaded);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);				
		}
		
		private function onLoaded(evt:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onError(evt:IOErrorEvent):void
		{
			Console.getInstance().log("ExternalAsset Error: " + evt.text, true);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaded);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}	
		
		/**
		 * Beging loading the external asset
		 */
		public function load():void
		{
			_loader.load(new URLRequest(_url));
		}
		
		public function get content():DisplayObject
		{
			return _loader.content;
		}		
	}
}