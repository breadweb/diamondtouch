package com.breadweb.utils
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getQualifiedClassName;
	
	public class Console extends Sprite
	{
		static private var _instance:Console;
		private var _back:Sprite;
		private var _tf:TextField;
		private var _counter:int;
		private var _enabled:Boolean = false;
		
		public function Console(enforcer:SingletonEnforcer)	{}
		
		public static function getInstance():Console
		{
			if (_instance == null)
			{
				_instance = new Console(new SingletonEnforcer());
			}
			return _instance;
		}
		
		public function init(layer:Sprite, lines:int = 20, backAlpha:Number = .75):void
		{
			layer.addChild(this);
			
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			
			var format:TextFormat = new TextFormat("Verdana", 12, 0xFFFFFF);
			
			_tf = new TextField();
			_tf.width = w - 20;
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
			
			_tf.text = "";	
			_tf.autoSize = "none";			
			
			setChildIndex(_tf, numChildren - 1);
			visible = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			_enabled = true;
		}
		
		private function onKeyDown(evt:KeyboardEvent):void
		{
			if (evt.keyCode == 192)
			{
				visible = !visible;
			}
		}
		
		public function log(logText:*, object:* = null):void
		{
			if (!_enabled)
			{
				return;
			}
			
			var output:String = (_counter++) + " ";
			if (object != null)
			{
				var className:String = getQualifiedClassName(object);
				className = className.substr(className.lastIndexOf(":") + 1, className.length - 1);
				output += className + ": ";
			}
			output += logText.toString();
			_tf.appendText(output + "\n");
			_tf.scrollV = _tf.numLines;
			trace(output);
		}
	}
}

class SingletonEnforcer {}