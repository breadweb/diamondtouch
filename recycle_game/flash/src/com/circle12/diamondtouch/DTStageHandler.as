package com.circle12.diamondtouch
{
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class DTStageHandler
	{
		// Variables relating to the stage size
		public var player_width:Number;
		public var player_height:Number;
		public var player_ul:Object = new Point();
		public var player_lr:Object = new Point();
		public var player_left:Number;	
		public var player_top:Number;
		public var player_right:Number;
		public var player_bottom:Number;	
		public var authored_stage_width:Number = -1;
		public var authored_stage_height:Number = -1;
		public var stageDimsPid:Number;
		private var stage:Stage;
		private var _eventSegmentEnable:Boolean = false;

		public function get eventSegmentEnable():Boolean {
			return _eventSegmentEnable;
		}
		public function set eventSegmentEnable( value:Boolean ):void {
			_eventSegmentEnable = value;
		}

		public function DTStageHandler( stage:Stage )
		{
			this.stage = stage;
			stageDimsPid = setInterval( recordStageAndPlayerDimensions, 100 );	
		}
		
		public function waitToRecord():void {
			clearInterval(stageDimsPid);
			stageDimsPid = setInterval( recordStageAndPlayerDimensions, 100, false );
		}
		
		private function recordStageAndPlayerDimensions(
				forceAuthoredDimensionsReload:Boolean = false ):void {
			clearInterval( stageDimsPid );
			var originalScaleMode:String = stage.scaleMode;
			stage.scaleMode = "noScale";
			player_width = stage.stageWidth;
			player_height = stage.stageHeight;	
			if( authored_stage_width == -1 || forceAuthoredDimensionsReload ) {			
				stage.scaleMode = "showAll";
				authored_stage_width = stage.stageWidth;
				authored_stage_height = stage.stageHeight;	
			}
			stage.scaleMode = originalScaleMode;		
			switch( stage.align ) {			
				case "" :
					player_ul.x = 0-(player_width-authored_stage_width)/2;
					player_ul.y = 0-(player_height-authored_stage_height)/2;
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width)/2;
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height)/2;			
					break;
				case "B" :
					player_ul.x = 0-(player_width-authored_stage_width)/2;
					player_ul.y = 0-(player_height-authored_stage_height);
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width)/2;
					player_lr.y = authored_stage_height;
					break;
				case "T" :
					player_ul.x = 0-(player_width-authored_stage_width)/2;
					player_ul.y = 0;
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width)/2;
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height);
					break;
				case "L" :
					player_ul.x = 0;
					player_ul.y = 0-(player_height-authored_stage_height)/2;
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width);
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height)/2;
					break;
				case "LB" :
					player_ul.x = 0;
					player_ul.y = 0-(player_height-authored_stage_height);
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width);
					player_lr.y = authored_stage_height;	
					break;
				case "LT" :
					player_ul = new Point( 0, 0 );
					player_lr.x = authored_stage_width +
						(player_width-authored_stage_width);
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height);
					break;
				case "R" :
					player_ul.x = 0-(player_width-authored_stage_width);
					player_ul.y = 0-(player_height-authored_stage_height)/2;
					player_lr.x = authored_stage_width;
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height)/2;
					break;
				case "RB" :
					player_ul.x = 0-(player_width-authored_stage_width);
					player_ul.y = 0-(player_height-authored_stage_height);
					player_lr.x = authored_stage_width;
					player_lr.y = authored_stage_height;
					break;
				case "RT" :
					case "TR" :
					player_ul.x = 0-(player_width-authored_stage_width);
					player_ul.y = 0;
					player_lr.x = authored_stage_width;
					player_lr.y = authored_stage_height +
						(player_height-authored_stage_height);	
					break;
			}	
			player_left = player_ul.x;		
			player_top = player_ul.y;
			player_right = player_lr.x;
			player_bottom = player_lr.y
		}
		
		public function adjustForStageAlignAndScaleMode( dtev:TouchEventData ):void {
			var i:Number;
			var pw:Number;
			var aw:Number;
			var ph:Number;
			var ah:Number;
			var resized_stage_width:Number;
			var resized_stage_height:Number;
			var offset_x:Number;
			var offset_y:Number;
			
			switch (stage.scaleMode) {
				case "noScale":
					switch (stage.align) {
						case "" :
						case "B" :
						case "T" :
							dtev.x = dtev.x -
								(player_width-authored_stage_width)/2;
							dtev.ulx = dtev.ulx -
								(player_width-authored_stage_width)/2;
							dtev.lrx = dtev.lrx -
								(player_width-authored_stage_width)/2;					
							if (eventSegmentEnable) {
								for (i=0; i<dtev.xSegments.length; i++) {
									pw = player_width;
									aw = authored_stage_width;
									dtev.xSegmentsIdx( i,
											dtev.xSegments[i] - (pw-aw)/2 );
								}
							}
							break;
						case "L" :
						case "LB" :
						case "LT" :
							break;
						case "R" :
						case "RB" :
						case "RT" :
						case "TR" :
							dtev.x = dtev.x -
								(player_width-authored_stage_width);
							dtev.ulx = dtev.ulx -
								(player_width-authored_stage_width);
							dtev.lrx = dtev.lrx -
								(player_width-authored_stage_width);	
							if (eventSegmentEnable) {
								for (i=0; i<dtev.xSegments.length; i++) {
									pw = player_width;
									aw = authored_stage_width;
									dtev.xSegmentsIdx( i,
											dtev.xSegments[i]-(pw-aw) );
								}
							}						
							break;
					}
					switch (stage.align) {
						case "" :
						case "L" :
						case "R" :
							dtev.y = dtev.y -
								(player_height-authored_stage_height)/2;
							dtev.uly = dtev.uly -
								(player_height-authored_stage_height)/2;
							dtev.lry = dtev.lry -
								(player_height-authored_stage_height)/2;
							if (eventSegmentEnable) {
								for (i=0; i<dtev.ySegments.length; i++) {
									ph = player_height;
									ah = authored_stage_height;
									dtev.ySegmentsIdx( i,
											dtev.ySegments[i]-(ph-ah)/2 );
								}
							}
							break;
						case "B" :
						case "LB" :
						case "RB" :
							dtev.y = dtev.y -
								(player_height-authored_stage_height);
							dtev.uly = dtev.uly -
								(player_height-authored_stage_height);
							dtev.lry = dtev.lry -
								(player_height-authored_stage_height);	
							if (eventSegmentEnable) {
								for (i=0; i<dtev.ySegments.length; i++) {
									ph = player_height;
									ah = authored_stage_height;
									dtev.ySegmentsIdx( i,
											dtev.ySegments[i]-(ph-ah));
								}
							}						
							break;
						case "T" :
						case "LT" :
						case "RT" :
						case "TR" :			
							break;
					}
					break;
				case "exactFit" :	
					dtev.x = Math.round(dtev.x *
							(authored_stage_width / player_width));
					dtev.y = Math.round(dtev.y *
							(authored_stage_height / player_height));
					dtev.ulx = Math.round(dtev.ulx *
							(authored_stage_width / player_width));
					dtev.uly = Math.round(dtev.uly *
							(authored_stage_height / player_height));
					dtev.lrx = Math.round(dtev.lrx *
							(authored_stage_width / player_width));
					dtev.lry = Math.round(dtev.lry *
							(authored_stage_height / player_height));
					if (eventSegmentEnable) {
						for (i=0; i<dtev.xSegments.length; i++) {
							aw = authored_stage_width;
							pw = player_width;
							dtev.xSegmentsIdx( i,
									Math.round( dtev.xSegments[i] * (aw/pw) ) );
						}
						for (i=0; i<dtev.ySegments.length; i++) {
							ah = authored_stage_height;
							ph = player_height;
							dtev.ySegmentsIdx( i,
									Math.round( dtev.ySegments[i] * (ah/ph) ) );
						}
					}
					break;
				case "showAll" :
					if ((player_width/player_height) >
							(authored_stage_width/authored_stage_height)) {
						dtev.y = Math.round(dtev.y *
								(authored_stage_height/player_height));
						dtev.uly = Math.round(dtev.uly *
								(authored_stage_height/player_height));
						dtev.lry = Math.round(dtev.lry *
								(authored_stage_height/player_height));
						if (eventSegmentEnable) {
							for (i=0; i<dtev.ySegments.length; i++) {
								ah = authored_stage_height;
								ph = player_height;
								dtev.ySegmentsIdx( i,
										Math.round( dtev.ySegments[i] * (ah/ph) ) );
							}
						}
						resized_stage_width =
							((authored_stage_width / authored_stage_height) *
							 player_height);
						offset_x = 0;
						switch(stage.align) {
							case "L" :
							case "LB" :
							case "LT" :
								break;
							case "" :
							case "B" :
							case "T" :
								offset_x = (player_width-resized_stage_width)/2;
								break;
							case "R" :
							case "RB" :
							case "RT" :
							case "TR" :	
								offset_x = (player_width - resized_stage_width);
								break;						
						}
						dtev.x = Math.round((dtev.x - offset_x) *
								(authored_stage_width / resized_stage_width));
						dtev.ulx = Math.round((dtev.ulx - offset_x) *
								(authored_stage_width / resized_stage_width));
						dtev.lrx = Math.round((dtev.lrx - offset_x) *
								(authored_stage_width / resized_stage_width));
						if (eventSegmentEnable) {
							for (i=0; i<dtev.xSegments.length; i++) {
								aw = authored_stage_width;
								dtev.xSegmentsIdx( i,
										Math.round((dtev.xSegments[i] - offset_x) *
											(aw / resized_stage_width)));
							}
						}
					} else {
						dtev.x = Math.round(dtev.x *
								(authored_stage_width/player_width));
						dtev.ulx = Math.round(dtev.ulx *
								(authored_stage_width/player_width));
						dtev.lrx = Math.round(dtev.lrx *
								(authored_stage_width/player_width));
						resized_stage_height =
							((authored_stage_height / authored_stage_width) *
							 player_width);
						if (eventSegmentEnable) {
							for (i=0; i<dtev.xSegments.length; i++) {
								aw = authored_stage_width;
								pw = player_width;
								dtev.xSegmentsIdx( i,
										Math.round( dtev.xSegments[i] * (aw/pw) ) );
							}
						}
						offset_y = 0;
						switch(stage.align) {
							case "LT" :
							case "T" :
							case "RT" :
							case "TR" :						
								break;
							case "L" :
							case "" :
							case "R" :
								offset_y =
									(player_height - resized_stage_height) / 2;
								break;
							case "LB" :
							case "B" :
							case "RB" :
								offset_y =
									(player_height - resized_stage_height);
								break;						
						}
						dtev.y = Math.round((dtev.y - offset_y) *
								(authored_stage_height / resized_stage_height));
						dtev.uly = Math.round((dtev.uly - offset_y) *
								(authored_stage_height / resized_stage_height));
						dtev.lry = Math.round((dtev.lry - offset_y) *
								(authored_stage_height / resized_stage_height));
						if (eventSegmentEnable) {
							for (i=0; i<dtev.ySegments.length; i++) {
								ah = authored_stage_height;
								dtev.ySegmentsIdx( i,
										Math.round((dtev.ySegments[i] - offset_y) *
											(ah / resized_stage_height)));
							}
						}
					}
					break;
				case "noBorder" :
					if ((player_width/player_height) >
							(authored_stage_width/authored_stage_height)) {
						dtev.x = Math.round(dtev.x *
								(authored_stage_width/player_width));
						dtev.ulx = Math.round(dtev.ulx *
								(authored_stage_width/player_width));
						dtev.lrx = Math.round(dtev.lrx *
								(authored_stage_width/player_width));	
						resized_stage_height =
							(authored_stage_height / authored_stage_width) *
							player_width;	
						if (eventSegmentEnable) {
							for (i=0; i<dtev.xSegments.length; i++) {
								aw = authored_stage_width;
								pw = player_width;
								dtev.xSegmentsIdx( i,
										Math.round(dtev.xSegments[i] * (aw/pw) ) );
							}
						}
						offset_y = 0;
						switch(stage.align) {
							case "LT" :
							case "T" :
							case "RT" :
							case "TR" :						
								break;
							case "L" :
							case "" :
							case "R" :
								offset_y =
									(resized_stage_height - player_height) / 2;
								break;
							case "LB" :
							case "B" :
							case "RB" :
								offset_y =
									(resized_stage_height - player_height);
								break;							
						}
						dtev.y = Math.round((dtev.y + offset_y) *
								(authored_stage_height / resized_stage_height));
						dtev.uly = Math.round((dtev.uly + offset_y) *
								(authored_stage_height / resized_stage_height));
						dtev.lry = Math.round((dtev.lry + offset_y) *
								(authored_stage_height / resized_stage_height));
						if (eventSegmentEnable) {
							for (i=0; i<dtev.ySegments.length; i++) {
								ah = authored_stage_height;
								dtev.ySegmentsIdx( i,
										Math.round((dtev.ySegments[i] + offset_y) *
											(ah / resized_stage_height)));
							}
						}
					} else {
						dtev.y = Math.round(dtev.y *
								(authored_stage_height/player_height));
						dtev.uly = Math.round(dtev.uly *
								(authored_stage_height/player_height));
						dtev.lry = Math.round(dtev.lry *
								(authored_stage_height/player_height));
						resized_stage_width =
							(authored_stage_width / authored_stage_height) *
							player_height;						
						if( eventSegmentEnable ) {
							for (i=0; i<dtev.ySegments.length; i++) {
								ah = authored_stage_height;
								ph = player_height;
								dtev.ySegmentsIdx( i,
										Math.round( dtev.ySegments[i] * (ah/ph) ) );
							}
						}					
						offset_x = 0;
						switch(stage.align) {
							case "L" :
							case "LB" :
							case "LT" :
								break;
							case "" :
							case "B" :
							case "T" :
								offset_x =
									(resized_stage_width - player_width) / 2;
								break;
							case "R" :
							case "RB" :
							case "RT" :
								case "TR" :	
								offset_x =
									(resized_stage_width - player_width);
								break;						
						}
						dtev.x = Math.round((dtev.x + offset_x) *
								(authored_stage_width / resized_stage_width));
						dtev.ulx = Math.round((dtev.ulx + offset_x) *
								(authored_stage_width / resized_stage_width));
						dtev.lrx = Math.round((dtev.lrx + offset_x) *
								(authored_stage_width / resized_stage_width));
						if( eventSegmentEnable ) {
							for (i=0; i<dtev.xSegments.length; i++) {
								aw = authored_stage_width;
								dtev.xSegmentsIdx( i,
										Math.round((dtev.xSegments[i] + offset_x) *
											(aw / resized_stage_width)));
							}
						}
					}
					break;
			}
		}
	}
}