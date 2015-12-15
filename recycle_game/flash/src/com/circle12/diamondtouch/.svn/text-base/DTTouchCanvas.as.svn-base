package com.circle12.diamondtouch
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DTTouchCanvas extends Sprite
	{
		// Variables relating to the visible touch canvas
		private var _visibleTouchEnabled:Boolean = true;
		private var _touchBoxPid:Number = -1;
		
		public function get isTouchVisible():Boolean {
			return _visibleTouchEnabled;
		}
		public function set isTouchVisible( visible:Boolean ):void {
			_visibleTouchEnabled = visible;
		}
		public function get dt():DiamondTouch {
			return DiamondTouch.getDiamondTouch(stage);
		}


		public function DTTouchCanvas( isTouchVisible:Boolean=true ) {
			this.x = 0;
			this.y = 0;
			this.isTouchVisible = isTouchVisible;
			
			addEventListener( Event.ADDED_TO_STAGE, addedToStage );
		}
		
		private function addedToStage( evt:Event ):void {
			stage.addEventListener( TouchEvent.TOUCHER_DOWN, cursorToucherDown );
			stage.addEventListener( TouchEvent.TOUCHER_MOVE, cursorToucherMove );
			stage.addEventListener( TouchEvent.TOUCHER_UP, cursorToucherUp );
		}
		
		private function cursorToucherDown( evt:Event ):void {
			cursorToucherMove( evt );
		}
	
		private function cursorToucherMove( evt:Event ):void {
			if( !isTouchVisible ) {
				cursorToucherUp( evt );
			}
			else {
				var dtev:TouchEvent = null;
				if( evt is MouseEvent ) {
					dtev = TouchEvent.fromMouseEvent( MouseEvent(evt) );
				}
				else if( evt is TouchEvent ) {
					dtev = TouchEvent( evt );
				}
				else {
					return;
				}
				
				this.parent.addChild(this);
				
				// Create the cursor and box objects if we haven't already
				var cursor:Shape =
					Shape( getChildByName( "cursor"+dtev.receiver ) );
				if( cursor == null ) {
					cursor = new Shape();
					cursor.name = "cursor"+dtev.receiver;
					addChild( cursor );
				}
				var box:Shape =
					Shape( getChildByName( "box"+dtev.receiver ) );
				if( box == null ) {
					box = new Shape();
					box.name = "box"+dtev.receiver;
					addChild( box );
				}
				
				// Draw the cursor and box
				var pt:Point = dtev.getReferencePoint();
				cursor.graphics.clear();
				cursor.graphics.lineStyle( 0, dt.getToucherColor( dtev.receiver ) );
				cursor.graphics.moveTo( pt.x-4, pt.y );
				cursor.graphics.lineTo( pt.x+5, pt.y );
				cursor.graphics.moveTo( pt.x, pt.y-4 );
				cursor.graphics.lineTo( pt.x, pt.y+5 );
		
				box.graphics.clear();
				box.graphics.lineStyle( 0, dt.getToucherColor( dtev.receiver ) );
				box.graphics.moveTo( dtev.ulx, dtev.uly );
				box.graphics.lineTo( dtev.ulx, dtev.lry );
				box.graphics.lineTo( dtev.lrx, dtev.lry );
				box.graphics.lineTo( dtev.lrx, dtev.uly );
				box.graphics.lineTo( dtev.ulx, dtev.uly );
			}
		}
	
		private function cursorToucherUp(evt:Event):void {
			var dtev:TouchEvent = null;
			dtev = TouchEvent( evt );
			
			var cursor:Shape = Shape( getChildByName( "cursor"+dtev.receiver ) );
			if( cursor != null ) {
				cursor.graphics.clear();
			}
			var bbox:Shape = Shape( getChildByName( "box"+dtev.receiver ) );
			if( bbox != null ) {
				bbox.graphics.clear();
			}
		}
	}
}