package com.breadweb.recycle.behaviors
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class Dragging
	{
		private var _dob:Sprite;
		private var _bounds:Rectangle;
		private var _isDragging:Boolean = false;
		private var _enabled:Boolean = false;
		private var _upCallback:Function;
		private var _downCallback:Function;
		
		/**
		 * Create a new dragging behavior for a display object
		 * 
		 * @param dob The display object that should be able to drag
		 * @param upCallback Extra function to call when mouse up event is fired
		 * @param downCallback Extra function to call when mouse down event is fired
		 */		
		public function Dragging(dob:Sprite, bounds:Rectangle, upCallback:Function = null, downCallback:Function = null)
		{
			_dob = dob;
			_bounds = bounds;
			_upCallback = upCallback;
			_downCallback = downCallback;
			init();
		}
		
		private function init():void
		{
			_dob.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		private function onMouseUp(evt:Event):void
		{
			_dob.stopDrag();
			_isDragging = false;
			_dob.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (_upCallback != null)
			{
				_upCallback.apply(null, [evt]);
			}
		}
		
		private function onMouseDown(evt:Event):void
		{
			if (!_enabled)
			{
				return;
			}			
			_dob.startDrag();
			_isDragging = true;
			_dob.parent.setChildIndex(_dob, _dob.parent.numChildren - 1);
			_dob.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			if (_downCallback != null)
			{
				_downCallback.apply(null, [evt]);
			}
		}
			
		public function die():void
		{
			_dob.stopDrag();
			_dob.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_dob.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		public function set enabled(v:Boolean):void
		{
			_enabled = v;
		}
	}
}