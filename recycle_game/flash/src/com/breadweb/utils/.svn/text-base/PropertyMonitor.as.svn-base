package com.breadweb.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public class PropertyMonitor extends Sprite
	{
		static private var _instance:PropertyMonitor;
		private var _back:Sprite;
		private var _tf:TextField;
		private var _subjects:Dictionary;
		private var _enabled:Boolean = false;
		
		public function PropertyMonitor(enforcer:SingletonEnforcer) {}
		
		public static function getInstance():PropertyMonitor
		{
			if (_instance == null)
			{
				_instance = new PropertyMonitor(new SingletonEnforcer());
			}
			return _instance;
		}	
		
		public function init(layer:Sprite, lines:int = 10, backAlpha:Number = .75):void
		{
			layer.addChild(this);
			
			var w:int = 500;
			
			var format:TextFormat = new TextFormat("Verdana", 12, 0xFFFFFF);
			
			_tf = new TextField();
			_tf.width = w - 10;
			_tf.wordWrap = true;
			_tf.y = 10;
			_tf.x = 10;
			_tf.selectable = true;
			_tf.autoSize = "left";
			_tf.defaultTextFormat = format;
			addChild(_tf);
			
			for (var i:int = 0; i < lines; i++)
			{
				_tf.appendText(i + "\n");
			}
			
			_back = new Sprite();
			_back.graphics.beginFill(0x000000);
			_back.graphics.drawRect(0, 0, w, _tf.height + 20);
			_back.graphics.endFill();
			_back.alpha = backAlpha;
			addChild(_back);
				
			_tf.autoSize = "none";			
			
			setChildIndex(_tf, numChildren - 1);
			visible = false;
			x = stage.stageWidth - width - 10;
			y = stage.stageHeight - height - 10;
			
			_subjects = new Dictionary();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
			_enabled = true;
		}
		
		/**
		 * Add an object property to monitor
		 * 
		 * @param id A string describing the property being monitored
		 * @param object The object containing the property to monitor
		 * @param prop The name of the public property to monitor
		 */
		public function addSubject(id:String, object:*, prop:String):void
		{
			if (_enabled)
			{
				_subjects[id] = new Array(object, prop);
			}	
		}
		
		public function removeSubject(id:String):void
		{
			if (_enabled)
			{
				for (var i:String in _subjects)
				{
					if (i == id)
					{
						delete _subjects[i];
						return;
					}
				}
			}
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			if (evt.keyCode == 192)
			{
				visible = !visible;
			}
		}
		
		private function onEnterFrame(evt:Event):void
		{
			var output:String = "";
			for (var i:String in _subjects)
			{
				var parts:Array = (_subjects[i] as Array);
				output += i + ": " + parts[0][parts[1]] + "\n";
			}
			_tf.text = output;
		}
	}
}

class SingletonEnforcer {}