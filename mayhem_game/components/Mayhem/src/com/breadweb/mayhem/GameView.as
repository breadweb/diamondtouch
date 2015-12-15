package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.circle12.diamondtouch.DTTouchEventData;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import gs.TweenMax;
	import gs.easing.Back;
	import gs.easing.Elastic;
	import gs.easing.Expo;
	
	public class GameView extends Sprite
	{
		private var _control:GameControl;
		private var _data:GameData;
		
		public var gameLayer:Sprite;
		public var debugLayer:Sprite;
		
		public var mcMessage:MessageBox;
		public var mcEnd:EndBox;
		public var mcToken:TokenComponent;	
		public var mcCorners:Corners;
		public var mcScreen1:Screen1;
		public var mcScreen2:Screen2;
		public var mcScreen3:Screen3;
		
		public var aryGameCards:Vector.<CardComponent>;		
		public var arySlots:Vector.<SlotComponent>;
		public var arySlotCoords1:Array;
		public var arySlotCoords2:Array;
		public var aryChoices:Vector.<ChoiceComponent>;	
		public var aryCardCoords:Array;		
		public var aryColors:Array = [0xFF0000, 0x0000FF, 0x00FF00, 0xFFCC00];
		public var aryDefaultNames:Array = ["Red", "Blue", "Green", "Yellow"];		
		public var aryPlayerCoords:Array;
		public var aryPlayerRotations:Array;
		public var aryChoiceCoords1:Array;
		public var aryChoiceCoords2:Array;
		
		public var intCardSide:int = 114; // Actual card side length
		public var intCardSidePlay:int = 102 // Size side for game board
		public var intSpacer:int = 2;
		public var strCurrentScreen:String = "start";
		public var intModePage:Number = 0;		
		
		public function GameView()
		{
			_control = GameControl.getInstance();
			_data = _control.data;
			
			gameLayer = new Sprite();
			gameLayer.name = "_gameLayer";		
			debugLayer = new Sprite();
			debugLayer.name = "_debugLayer";
			
			addChild(gameLayer);
			addChild(debugLayer);	
		}

		public function init():void
		{
			setupViewComponents();
			
			arySlots = new Vector.<SlotComponent>();
			arySlotCoords1 = [[1548, 525], [-148, 525], [1548, 1162], [-148, 1162]];
			arySlotCoords2 = [[548, 338], [852, 338], [548, 581], [852, 581]];
			aryChoices = new Vector.<ChoiceComponent>();
			aryGameCards = new Vector.<CardComponent>();
			
			// Reset playing card side to standard size if our board is 54 cards or less
			intCardSidePlay = (_data.intCols * _data.intRows <= 54) ? intCardSide : intCardSidePlay;
			
			// Coordinates ranges for random outside area placement
			aryCardCoords = new Array();
			aryCardCoords[0] = [[-20, stage.stageWidth + 20], [intCardSidePlay * -1 - 20, intCardSidePlay * -1 - 20]];
			aryCardCoords[1] = [[-20, stage.stageWidth + 20], [stage.stageHeight + 20, stage.stageHeight + 20]];
			aryCardCoords[2] = [[intCardSidePlay * -1 - 20, intCardSidePlay * -1 - 20], [-20, stage.stageHeight + 20]];
			aryCardCoords[3] = [[stage.stageWidth + 20, stage.stageWidth + 20], [-20, stage.stageHeight + 20]];	
			
			aryPlayerCoords = new Array();
			aryPlayerCoords["bottom-right"] = [727, 1064];
			aryPlayerCoords["bottom-left"] = [212, 1064];
			aryPlayerCoords["bottom"] = [470, 1064];
			aryPlayerCoords["right"] = [1414, 755];
			aryPlayerCoords["left"] = [-14, 295];
			aryPlayerCoords["top"] = [930, -14];
			
			aryPlayerRotations = new Array();
			aryPlayerRotations["bottom-right"] = 0;
			aryPlayerRotations["bottom-left"] = 0;
			aryPlayerRotations["bottom"] = 0;		
			aryPlayerRotations["right"] = -90;
			aryPlayerRotations["left"] = 90;
			aryPlayerRotations["top"] = 180;		
			
			aryChoiceCoords1 = [[285, 399], [700, 399], [1115, 399], [285, 659], [700, 659], [1115, 659]];
			aryChoiceCoords2 = [[700, 399], [700, 687]];							
		}
		
		public function setupViewComponents():void
		{
			mcCorners = new Corners();
			gameLayer.addChild(mcCorners);
			setupCornerButtons();
			
			mcScreen1 = new Screen1();
			gameLayer.addChild(mcScreen1);
			mcScreen1.x = 233;
			mcScreen1.y = 94;
			mcScreen1.mcBtnStart.txtLabel.htmlText = "<b>Start Game</b>";
			mcScreen1.mcBtnReset.txtLabel.htmlText = "<b>Reset Players</b>";
			setupScreen1Buttons();
			
			mcScreen2 = new Screen2();
			gameLayer.addChild(mcScreen2);
			mcScreen2.x = 23;
			mcScreen2.y = 134;	
			mcScreen2.mcBtnBack.txtLabel.htmlText = "<b>Back</b>";
			setupScreen2Buttons();
			
			mcScreen3 = new Screen3();
			gameLayer.addChild(mcScreen3);
			mcScreen3.x = 480;
			mcScreen3.y = 160;
					
			mcEnd = new EndBox();
			gameLayer.addChild(mcEnd);
			mcEnd.x = gameLayer.stage.stageWidth / 2;
			mcEnd.y = gameLayer.stage.stageHeight / 2
			mcEnd.visible = false;	
			mcEnd.mcBtnAgain.txtLabel.htmlText = "<b>Play Again</b>";
			mcEnd.mcBtnRestart.txtLabel.htmlText = "<b>Start Screen</b>";			
			setupEndButtons();
				
			mcMessage = new MessageBox();
			gameLayer.addChild(mcMessage);
			mcMessage.visible = false;
			mcMessage.mcPopup.mcBtnOK.txtLabel.htmlText = "<b>OK</b>";
			setupMessageButton();
		}
		
		private function setupMessageButton():void
		{
			var button:MovieClip = mcMessage.mcPopup.mcBtnOK;
			if (CONFIG::DTENABLED)
			{			
				button["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(button);
				}
				button["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(button);
					toggleButton(button, false);
					hideMessage();
				}		
				_control.diamondTouch.addObserver(button);
			}
			else
			{
				button.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(button);		
				});						
				button.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(button);
					toggleButton(button, false);
					hideMessage();		
				});
			}
		}
		
		private function setupCornerButtons():void
		{
			if (_control.data.getSetting("enablecorners") != "true")
				return;
			
			var quit1:MovieClip = mcCorners.mcBtnQuit1;
			var quit2:MovieClip = mcCorners.mcBtnQuit2;
			var restart1:MovieClip = mcCorners.mcBtnRestart1;
			var restart2:MovieClip = mcCorners.mcBtnRestart2;
			
			if (CONFIG::DTENABLED)
			{			
				quit1["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					Console.log("Quit 1 pressed!");
					_control.sendExit();
				}
				quit2["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					Console.log("Quit 2 pressed!");
					_control.sendExit();
				}					
				restart1["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					Console.log("Restart 1 pressed!");
					_control.restart();
				}							
				restart2["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					Console.log("Restart 2 pressed!");
					_control.restart();
				}		
					
				_control.diamondTouch.addObserver(quit1);
				_control.diamondTouch.addObserver(quit2);
				_control.diamondTouch.addObserver(restart1);
				_control.diamondTouch.addObserver(restart2);
			}
			else
			{
				quit1.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					_control.sendExit();		
				});	
				quit2.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					_control.sendExit();		
				});				
				restart1.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					_control.restart();					
				});
				restart2.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					_control.restart();					
				});				
			}
		}	
		
		private function setupScreen1Buttons():void
		{
			var start:MovieClip = mcScreen1.mcBtnStart;
			var reset:MovieClip = mcScreen1.mcBtnReset;
			
			if (CONFIG::DTENABLED)
			{			
				start["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(start);
				}
				start["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(start);
					toggleButton(start, false);
					toggleButton(reset, false);
					_control.startGame();
				}	
				reset["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(reset);
				}
				reset["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(reset);
					resetPlayerSlots();
				}			
					
				_control.diamondTouch.addObserver(start);
				_control.diamondTouch.addObserver(reset);
			}
			else
			{
				start.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(start);		
				});						
				start.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(start);
					toggleButton(start, false);
					toggleButton(reset, false);					
					_control.startGame();		
				});
				reset.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(reset);		
				});						
				reset.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(reset);				
					resetPlayerSlots();		
				});				
			}
		}	
		
		private function setupScreen2Buttons():void
		{
			var modeBack:MovieClip = mcScreen2.mcBtnModeBack;
			var modeNext:MovieClip = mcScreen2.mcBtnModeNext;
			var back:MovieClip = mcScreen2.mcBtnBack;
			
			if (CONFIG::DTENABLED)
			{			
				modeBack["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(modeBack);
				}
				modeBack["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(modeBack);
					updateModeChoices(-1);
				}	
				modeNext["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(modeNext);
				}
				modeNext["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(modeNext);
					updateModeChoices(1);
				}			
				back["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(back);
				}
				back["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(back);
					toggleButton(back, false);
					toggleButton(modeBack, false);
					toggleButton(modeNext, false);					
					stepBack();
				}					
				
				_control.diamondTouch.addObserver(modeNext);
				_control.diamondTouch.addObserver(modeBack);
				_control.diamondTouch.addObserver(back);
			}
			else
			{
				modeBack.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(modeBack);		
				});						
				modeBack.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(modeBack);
					updateModeChoices(-1);		
				});
				modeNext.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(modeNext);		
				});						
				modeNext.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(modeNext);
					updateModeChoices(1);		
				});
				back.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(back);		
				});						
				back.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(back);
					toggleButton(back, false);
					toggleButton(modeBack, false);
					toggleButton(modeNext, false);			
					stepBack();		
				});					
			}
		}	
		
		private function setupEndButtons():void
		{
			var restart:MovieClip = mcEnd.mcBtnRestart;
			var replay:MovieClip = mcEnd.mcBtnAgain;
			
			if (CONFIG::DTENABLED)
			{			
				restart["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(restart);
				}
				restart["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(restart);
					toggleButton(restart, false);
					toggleButton(replay, false);					
					_control.finishUp();
				}	
				replay["onToucherPress"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					pressButton(replay);
				}
				replay["onToucherRelease"] = function(sender:Object, dtev:DTTouchEventData):void
				{
					releaseButton(replay);
					toggleButton(restart, false);
					toggleButton(replay, false);					
					_control.replay();
				}			
				
				_control.diamondTouch.addObserver(restart);
				_control.diamondTouch.addObserver(replay);
			}
			else
			{
				restart.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(restart);		
				});						
				restart.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(restart);
					toggleButton(restart, false);
					toggleButton(replay, false);					
					_control.finishUp();		
				});
				replay.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent):void
				{
					pressButton(replay);		
				});						
				replay.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent):void
				{
					releaseButton(replay);
					toggleButton(restart, false);
					toggleButton(replay, false);					
					_control.replay();		
				});				
			}
		}		
		
		// Initializing of game screens
		public function initScreen(strScreen:String):void 
		{	
			var i:int = 0;
			strCurrentScreen = strScreen;
			
			switch (strScreen)
			{
				case "start":
					// Create slots
					for (i = 0; i < _control.aryPlayers.length; i++)
					{
						var slot:SlotComponent = new SlotComponent();
						slot.init(i, arySlotCoords1[i][0], arySlotCoords1[i][1]);
						// If player selection screen is disabled, automatically set all player slots
						if (!_data.boolPlayerSelect)
						{
							slot.setSlotName(aryDefaultNames[i]);
							slot.selectPlayerSlot(true, i);
							slot.setReady(true);
						}
						arySlots[i] = slot;
					}										
					break;
				
					toggleButton(mcScreen1.mcBtnStart, true);
					toggleButton(mcScreen1.mcBtnReset, true);
				
				case "mode":

					// Only create a player object at the index in the array
					// that corresponds to the toucher value of a slot.
					// Not all connections will be used. For example, a two
					// player game could be connections 1 and 4 are active
					for (i = 0; i < arySlots.length; i++)
					{
						var intToucher:int = arySlots[i].toucher;
						if (arySlots[i].isReady)
						{
							var strLocation:String =  _data.aryPositions[intToucher];
							// Choose smaller game player objects if we have more than 54 cards
							var useAlt:Boolean = (_data.intCols * _data.intRows > 54);
							_control.aryPlayers[intToucher] = new PlayerComponent(useAlt);
							_control.aryPlayers[intToucher].init(intToucher, arySlots[i].slotName, aryPlayerCoords[strLocation], aryPlayerRotations[strLocation]);
						}
						else
						{
							if (intToucher != -1)
								_control.aryPlayers[intToucher] = null;
						}
					}										

					// Create six mode choices. There may be more or less, but this will be our
					// base for pagination of mode if necessary. We use the function for pagination to
					// initially populate the empty choices
					for (i = 0; i < 6; i++)
					{
						aryChoices[i] = new ChoiceComponent();
						aryChoices[i].init(i, "", "", null, 2, aryChoiceCoords1[i][0], aryChoiceCoords1[i][1], selectMode, i);
					}
					
					toggleButton(mcScreen2.mcBtnModeNext, true);
					toggleButton(mcScreen2.mcBtnModeBack, true);
					toggleButton(mcScreen2.mcBtnBack, true);					
					
					break;
				
				case "difficulty":
					
					// If the selected mode only supports 3-match, update the selected choice
					// images xml which will be activated when it redraws.  Otherwise we 
					// add a brand new choice object to add to the screen
					if (_data.aryModes[_control.intSelectedMode][3] > 1)
					{	
						if (aryChoices.length == 6)
						{
							aryChoices.push(new ChoiceComponent());
							aryChoices[6].init(6, _data.aryDiffs[1][1], _data.aryDiffs[1][2], aryChoices[_control.intSelectedChoice].aryImages, 3, aryChoiceCoords2[0][0], aryChoiceCoords2[1][1], selectDiff, _data.aryDiffs[1][0]);
						}
						else
						{
							aryChoices[6].updateInfo(_data.aryDiffs[1][1], _data.aryDiffs[1][2], aryChoices[_control.intSelectedChoice].aryImages, 3, selectDiff, _data.aryDiffs[1][0]);
						}
					}
					
					break;
							
				case "gameboard":
					
					var intRandom:Number = 0;
					
					// How many random matches will we have?
					var intMatches:Number = (_data.intCols * _data.intRows) / (_control.intSelectedDiff + 1);
					
					// Set our swirl point to when half the matches are made
					_control.intSwirlNumber1 = Math.floor(intMatches / 4);
					_control.intSwirlNumber2 = Math.floor(intMatches / 2) 
					
					// Create a temp duplicate array of the selected mode card set
					var aryTmp:Array = new Array();
					for (i = 0; i < _data.aryCards[_control.intSelectedMode].length(); i++)
					{
						aryTmp[i] = _data.aryCards[_control.intSelectedMode][i];
					}
					
					// Create a temp array that will hold the number of matches
					// dictated by the selected difficulty
					var aryTmp2:Array = new Array();
					for (i = 0; i < intMatches; i++)
					{
						intRandom = Math.floor(Math.random() * aryTmp.length / 3);
						// Push the difficulty amount of items random index into our new array
						for (var k:int = 0; k < _control.intSelectedDiff + 1; k++)
						{
							aryTmp2.push(aryTmp[(intRandom * 3 + k)]);
						}
						// Pull those items out of the array so they can't be chosen again
						for (k = 2; k >= 0; k--)
						{
							aryTmp.splice((intRandom * 3 + k), 1);
						}						
					}
					
					// Now create the card objects with our new array by randomly
					// picking out cards from the array
					var intCounter:Number = -1;
					var intCounterRnd:Number = 0;
					var intGridWidth:Number = _data.intCols * (intCardSidePlay + intSpacer);
					var intGridHeight:Number = _data.intRows * (intCardSidePlay + intSpacer);
					var intOffsetX:Number = (stage.stageWidth - intGridWidth) / 2;
					var intOffsetY:Number = (stage.stageHeight - intGridHeight) / 2; // - 20;				
					var aryRndX:Array;
					var aryRndY:Array;
					
					aryGameCards = new Vector.<CardComponent>();
					for (i = 0; i < _data.intRows; i++) // 6
					{
						for (var j:int = 0; j < _data.intCols; j++) // 8
						{
							var intX:Number = j * (intCardSidePlay + intSpacer) + intOffsetX;
							var intY:Number = i * (intCardSidePlay + intSpacer) + intOffsetY;
							
							intCounter++;
							
							// Cycle through the 4 sides of ranges
							intCounterRnd = (intCounterRnd == 3) ? 0 : intCounterRnd + 1;
							
							aryRndX = aryCardCoords[intCounterRnd][0];
							aryRndY = aryCardCoords[intCounterRnd][1];
							
							// Select random x and y coordinates from ranges selected
							var intRandX:Number = (aryRndX[0] == aryRndX[1]) ? aryRndX[0] : Math.round(Math.random() * (aryRndX[1] - aryRndX[0])) + aryRndX[0];
							var intRandY:Number = (aryRndY[0] == aryRndY[1]) ? aryRndY[0] : Math.round(Math.random() * (aryRndY[1] - aryRndY[0])) + aryRndY[0];						
							
							// Select random card
							intRandom = Math.floor(Math.random() * aryTmp2.length);
							// Set random rotation
							var intRndPosition:Number = Math.floor(Math.random() * _data.aryPositions.length);
							var intRndRotation:int = aryPlayerRotations[_data.aryPositions[intRndPosition]];
							
							aryGameCards[intCounter] = new CardComponent();
							aryGameCards[intCounter].addToView();
							aryGameCards[intCounter].init(
								intCounter,
								aryTmp2[intRandom].@id,
								aryTmp2[intRandom].@filename,
								intRandX,
								intRandY,
								intRndRotation * 3,
								intX,
								intY,
								intRndRotation,
								true,
								intCardSidePlay);
							
							aryTmp2.splice(intRandom, 1);						
						}
					}
					
					// Place the special token on the gameboard if Jail feature is enabled
					if (_data.boolJail)
					{
						var intHidingCard:Number = Math.floor(Math.random() * aryGameCards.length);
						mcToken = new TokenComponent();
						mcToken.init(aryGameCards[intHidingCard]);
					}
					
					break;	
			}
		}	
		
		// Screen animation
		public function animateScreen(strScreen:String, strDirection:String):void
		{
			Console.log("Animating " + strScreen + " " + strDirection);
			
			var i:int = 0;			
			
			switch (strScreen)
			{
				case "start":
					switch (strDirection)
					{
						case "in":
							
							if (_data.boolPlayerSelect) // If player selection screen is enabled
							{	
								TweenMax.to(mcScreen1.mcText1, .75, {autoAlpha:1});
								TweenMax.to(mcScreen1.mcText2, .75, {autoAlpha:1, delay:.2});
								TweenMax.to(mcScreen1.mcText3, .75, {autoAlpha:1, delay:.4});					
								for (i = 0; i < _control.aryPlayers.length; i++)
								{
									TweenMax.to(arySlots[i].slot, 1, {
										x:arySlotCoords2[i][0],
										y:arySlotCoords2[i][1],
										delay:.2 * i + .25,
										ease:Back.easeOut});
									TweenMax.delayedCall(.2 * i + .25, _control.soundManager.play, ["swoosh1"]);
								}
								TweenMax.to(mcScreen1.mcBtnStart, 1, {scaleX:1, scaleY:1, delay:1, ease:Expo.easeOut});
								TweenMax.to(mcScreen1.mcBtnReset, 1, {scaleX:1, scaleY:1, delay:1.2, ease:Expo.easeOut});						
							}
							else  // Only animate a few repositioned items in
							{	
								mcScreen1.mcText1.y = 220;
								mcScreen1.mcText3.y = 391;
								mcScreen1.mcBtnStart.x = (mcScreen1.width - mcScreen1.mcBtnStart.width) / 2;
								mcScreen1.mcBtnStart.y = 591;
								
								TweenMax.to(mcScreen1.mcText1, .75, {autoAlpha:1});
								TweenMax.to(mcScreen1.mcText3, .75, {autoAlpha:1, delay:.2});					
								TweenMax.to(mcScreen1.mcBtnStart, 1, {scaleX:1, scaleY:1, delay:.4, ease:Expo.easeOut});
								
							}
							break;
						
						case "out":
							
							TweenMax.to(mcScreen1.mcBtnStart, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.3});
							
							if (_data.boolPlayerSelect)
							{
								TweenMax.to(mcScreen1.mcBtnReset, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.5});
								_control.intTotalPlayers = 0;
								for (i = 0; i < _control.aryPlayers.length; i++)
								{
									// Fade out slots that are not ready. Animate others 
									if (!arySlots[i].isReady)
									{
										TweenMax.to(arySlots[i].slot, .5, {
											scaleX:0,
											scaleY:0,
											autoAlpha:0,
											delay:.1 * i,
											ease:Back.easeIn});
										
										TweenMax.delayedCall(.1 * i, _control.soundManager.play, ["swoosh2"]);
									}
									else
									{
										_control.intTotalPlayers++;
										if (arySlots[i].slotName.indexOf("Player") > -1)
										{
											arySlots[i].setSlotName("Player " + _control.intTotalPlayers);
											arySlots[i].setHeader("Player " + arySlots[i].NUMBER_LABELS[(_control.intTotalPlayers - 1)]);
											if (_control.aryPlayers[arySlots[i].toucher] != null)
											{
												_control.aryPlayers[arySlots[i].toucher].updatePlayer("Player " + _control.intTotalPlayers);
											}
											arySlots[i].toggleTouch(false);
										}									
									}
									arySlots[i].toggleTouch(false);							
								}
								
							}
							
							if (_data.boolPlayerSelect)
							{	
								// Animate activated slots towards their respective newly
								// instantiated player objects						
								var intDelay:Number = .5;
								for (i = 0; i < arySlots.length; i++)
								{	
									if (arySlots[i].isReady)
									{
										var intToucher:Number = arySlots[i].toucher;
										var strLocation:String = _data.aryPositions[intToucher];
										var intRotation:Number = aryPlayerRotations[strLocation];
										var intDirection:Number = intRotation / Math.abs(intRotation);
										intDelay += .25;
										var intDestX:Number = aryPlayerCoords[strLocation][0];
										var intDestY:Number = aryPlayerCoords[strLocation][1];
										
										switch (strLocation.toString())
										{
											case "top":
												intDestY -= 200;
												break;
											case "bottom-left":
											case "bottom-right":
											case "bottom":
												intDestY += 200;
												break;
											case "right":
												intDestX += 200;
												break;
											case "left":									
												intDestX -= 200;
												break;
										}
										
										TweenMax.to(arySlots[i].slot, 1.5, {
											x:intDestX,
											y:intDestY,
											rotation:aryPlayerRotations[strLocation] + 180,
											delay:intDelay,
											ease:Expo.easeOut});
										
										TweenMax.delayedCall(intDelay, _control.soundManager.play, ["swoosh1"]);
									}
								}																					
							}
							
							TweenMax.to(mcScreen1.mcText1, .4, {autoAlpha:0, delay:.3});
							TweenMax.to(mcScreen1.mcText2, .4, {autoAlpha:0, delay:.4});
							TweenMax.to(mcScreen1.mcText3, .4, {autoAlpha:0, delay:.5});
							
							break;
					}					
					break;
				
				case "mode":
					
					switch (strDirection)
					{
						case "in":

							updateModeChoices(1);				
							
							TweenMax.to(mcScreen2.mcText4, .4, {autoAlpha:1, delay:1});
							
							// Animate in the mode choices
							intDelay = ((_control.intTotalPlayers - 2) * .3) + 1.25;
							for (i = 0; i < 6; i++)
							{
								aryChoices[i].choice.x = aryChoiceCoords1[i][0];
								aryChoices[i].choice.y = aryChoiceCoords1[i][1];
								aryChoices[i].choice.alpha = 1;
								aryChoices[i].choice.scaleX = 0;
								aryChoices[i].choice.scaleY = 0;
								aryChoices[i].choice.visible = true;
								aryChoices[i].toggleTouch(true);
								
								TweenMax.to(aryChoices[i].choice, .9, {
									scaleX:1,
									scaleY:1,
									delay:(i*.15) + intDelay,
									ease:Expo.easeOut});
								
								TweenMax.delayedCall((i*.15) + intDelay, _control.soundManager.play, ["swoosh3"]);
							}									
							
							break;
						
						case "out":					
							
							TweenMax.to(mcScreen2.mcText4, .4, {autoAlpha:0});
							TweenMax.to(mcScreen2.mcBtnBack, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.4});
							TweenMax.to(mcScreen2.mcBtnModeBack, .5, {autoAlpha:0});
							TweenMax.to(mcScreen2.mcBtnModeNext, .5, {autoAlpha:0});
							
							for (i = 0; i < 6; i++)
							{
								if (aryChoices[i].choice.visible)
								{
									TweenMax.to(aryChoices[i].choice, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.1 * i, ease:Back.easeIn});
									TweenMax.delayedCall(.1 * i, _control.soundManager.play, ["swoosh4"]);
								}
							}															
							
							break;
						
						case "out-alt":
							
							TweenMax.to(mcScreen2.mcText4, .4, {autoAlpha:0});
							TweenMax.to(mcScreen2.mcBtnModeBack, .5, {autoAlpha:0});
							TweenMax.to(mcScreen2.mcBtnModeNext, .5, {autoAlpha:0});						
							
							for (i = 0; i < 6; i++)
							{
								// Fade out choices that were not selected 
								if (aryChoices[i].intArg != _control.intSelectedMode)
								{
									if (aryChoices[i].choice.visible)
									{
										TweenMax.to(aryChoices[i].choice, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.1 * i, ease:Back.easeIn});
										TweenMax.delayedCall(.1 * i, _control.soundManager.play, ["swoosh4"]);
									}
								}
								else
								{
									TweenMax.to(aryChoices[i].choice, 1, {
										x:aryChoiceCoords2[0][0],
										y:aryChoiceCoords2[0][1],
										delay:.5,
										ease:Back.easeOut});
									
									TweenMax.delayedCall(.5, _control.soundManager.play, ["swoosh2"]);

									TweenMax.to(aryChoices[i].choice, .1, {tint:0xFFFFFF, delay:1.6});
									TweenMax.to(aryChoices[i].choice, .25, {removeTint:true, delay:1.7});																
									
									// Reinitialize as a difficulty choice object as soon as it blips white
									// If we only have one difficulty, we need to show the 3 match instead of 2 match
									
									if (_data.aryModes[_control.intSelectedMode][3] > 1)
									{								
										TweenMax.delayedCall(1.7, aryChoices[i].updateInfo, [
											_data.aryDiffs[0][1],
											_data.aryDiffs[0][2],
											null,
											2,
											selectDiff,
											_data.aryDiffs[0][0]],
											aryChoices[i]);
									}
									else
									{
										TweenMax.delayedCall(1.7, aryChoices[i].updateInfo, [
											_data.aryDiffs[1][1],
											_data.aryDiffs[1][2],
											null,
											2,
											selectDiff,
											_data.aryDiffs[1][0]],
											aryChoices[i]);									
									}
									
									TweenMax.delayedCall(1.7, _control.soundManager.play, ["blip"]);
									TweenMax.delayedCall(1.8, aryChoices[i].toggleTouch, [true]);
								}
							}									
							
							break;
					}
					break;				
				
				case "difficulty":
					
					switch (strDirection)
					{
						case "in":
							
							TweenMax.to(mcScreen3.mcText5, .4, {autoAlpha:1, delay:1});
							
							// Only show 2nd choice if selected mode supports it
							if (_data.aryModes[_control.intSelectedMode][3] > 1)
							{						
								TweenMax.to(aryChoices[6].choice, .9, {autoAlpha:1, scaleX:1, scaleY:1, delay:2, ease:Expo.easeOut});
								TweenMax.delayedCall(2, _control.soundManager.play, ["swoosh3"]);
							}
							mcScreen2.mcBtnBack.scaleX = mcScreen2.mcBtnBack.scaleY = 0;
							mcScreen2.mcBtnBack.alpha = 1;
							mcScreen2.mcBtnBack.visible = true;
							toggleButton(mcScreen2.mcBtnBack, true);
							TweenMax.to(mcScreen2.mcBtnBack, 1, {scaleX:1, scaleY:1, delay:2.25, ease:Expo.easeOut});											
							break;
						
						case "out":
							
							TweenMax.to(mcScreen3.mcText5, .4, {autoAlpha:0});
							TweenMax.to(aryChoices[_control.intSelectedChoice].choice, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.1, ease:Back.easeIn});
							TweenMax.delayedCall(.1, _control.soundManager.play, ["swoosh4"]);

							// Only animate out 2nd choice if selected mode supports 2 difficulties
							if (_data.aryModes[_control.intSelectedMode][3] > 1)
							{						
								TweenMax.to(aryChoices[6].choice, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.2, ease:Back.easeIn});
								TweenMax.delayedCall(.2, _control.soundManager.play, ["swoosh4"]);
							}
							TweenMax.to(mcScreen2.mcBtnBack, .5, {scaleX:0, scaleY:0, autoAlpha:0, delay:.4});	
							break;
					}
					
					break;	
				
				case "gameboard":
					
					switch (strDirection)
					{
						case "in":
							
							// Animate in player objects
							for (i = 0; i < _control.aryPlayers.length; i++)
							{	
								if (_control.aryPlayers[i] != null) {				
									
									var intToucher:Number = _control.aryPlayers[i].toucher;
									var strLocation:String = _data.aryPositions[intToucher];							
									var intRotation:Number = aryPlayerRotations[strLocation];
									var intDirection:Number = (intRotation != 0) ? intRotation / Math.abs(intRotation) : 1;							
									intDelay += .25;
									var intDestX:Number = aryPlayerCoords[strLocation][0];
									var intDestY:Number = aryPlayerCoords[strLocation][1];
									
									switch (strLocation.toString()) {
										case "top":
											intDestY += 150;
											break;
										case "bottom-left":
										case "bottom-right":
										case "bottom":
											intDestY -= 150;
											break;
										case "right":
											intDestX -= 150;
											break;
										case "left":									
											intDestX += 150;
											break;
									}
									
									TweenMax.to(_control.aryPlayers[i].gamePlayer, 1, {
										x:intDestX,
										y:intDestY,
										delay:1 + intDelay,
										ease:Elastic.easeOut});
									
									_control.aryPlayers[i].lockDown.x = intDestX;
									_control.aryPlayers[i].lockDown.y = intDestY;
									
								}
							}
							// Animate in cards
							var aryTmp:Vector.<CardComponent> = new Vector.<CardComponent>();
							for (i = 0; i < aryGameCards.length; i++)
							{
								aryTmp[i] = aryGameCards[i];
							}
							for (i = 0; i < aryGameCards.length; i++) {
								
								var intRandom:Number = Math.floor(Math.random() * aryTmp.length);
								var intRandomTime:Number = Math.floor(Math.random() * aryGameCards.length);
								var intRandomTime2:Number = Math.floor(Math.random() * aryGameCards.length);
								
								var objCard:CardComponent = aryGameCards[aryTmp[intRandom].intIndex];
								objCard.dealCard(.05 * intRandomTime + 2);
								objCard.activateCard(.05 * intRandomTime2 + 6);			
								
								aryTmp.splice(intRandom, 1);
							}	
							
							// Activate token
							if (_control.data.boolJail)
							{
								TweenMax.delayedCall(aryGameCards.length * .05 + 6, mcToken.activateToken);
							}
							
							break;
						
						case "out":
							
							// Animate out player objects
							var intDelay:Number = 0;
							for (i = 0; i < _control.aryPlayers.length; i++)
							{
								if (_control.aryPlayers[i] != null)
								{				
									var intToucher:Number = _control.aryPlayers[i].toucher;
									var strLocation:String = _data.aryPositions[intToucher];
									
									TweenMax.to(_control.aryPlayers[i].gamePlayer, .5, {
										x:aryPlayerCoords[strLocation][0],
										y:aryPlayerCoords[strLocation][1],
										delay:intDelay,
										ease:Back.easeIn});
									
									intDelay += .2;									
								}
							}	
							
							break;
					}
					break;								
			}
		}
		
		public function stepBack():void
		{
			switch (strCurrentScreen)
			{
				case "mode":
					intModePage = 0;
					TweenMax.delayedCall(.10, animateScreen, ["mode", "out"]);
					TweenMax.delayedCall(.15, _control.restart, null);
					break;
				
				case "difficulty":
					intModePage = 0;
					TweenMax.delayedCall(.10, animateScreen, ["difficulty", "out"]);
					TweenMax.delayedCall(.75, animateScreen, ["mode", "in"]);
					break;
			}
		}		
		
		public function selectMode(intMode:int, intToucher:int, intChoiceIndex:int):void
		{
			// FIXME: Fix later. For now, need method to exist for choice components
			Console.log("selectMode: " + intMode + ", " + intToucher + ", " + intChoiceIndex);
				
			_control.intSelectedMode = intMode;
			_control.intSelectedChoice = intChoiceIndex;
			
			for (var i:int = 0; i < 6; i++)
			{
				aryChoices[i].toggleTouch(false);
			}	
			
			// Animate out screen differently based on the amount of difficulties
			if (_data.aryDiffs.length > 1)
			{
				animateScreen("mode", "out-alt");
				TweenMax.delayedCall(.10, initScreen, ["difficulty"]);
				TweenMax.delayedCall(.15, animateScreen, ["difficulty", "in"]);			
			}
			else
			{
				animateScreen("mode", "out");
				TweenMax.delayedCall(.10, initScreen, ["gameboard"]);
				TweenMax.delayedCall(.15, animateScreen, ["gameboard", "in"]);
			}	
		}	
		
		// Updates the mode choices on screen when pagination is required
		public function updateModeChoices(intDirection:int):void
		{
			// FIXME: Fix later. For now, need method to exist for choice components
			Console.log("updateModeChoices: " + intDirection);
	
			var intTotalModes:Number =  _data.aryModes.length;
			var intTotalPages:Number = Math.ceil(intTotalModes / 6);
			var intNewPage:Number = intModePage + intDirection;
			
			Console.log("Total modes = " + intTotalModes);
			Console.log("Total pages = " + intTotalPages);
			
			// If our destination page is valid...
			if (intNewPage > 0 && intNewPage <= intTotalPages) {
				
				// Set desitation page as current page.
				intModePage += intDirection;		
				
				// Figure out how many items for this page
				var intModesThisPage:Number = (intTotalModes - (intModePage - 1) * 6 >= 6) ? 6 : intTotalModes - (intModePage - 1) * 6;
				
				// Update choices
				for (var i:Number = 0; i < intModesThisPage; i++)
				{	
					var intModeIndex:Number = (intModePage-1) * 6 + i;
					
					var strHeader:String = _data.aryModes[intModeIndex][1];
					var strDesc:String = _data.aryModes[intModeIndex][2];									
					
					// Need two items from the array, so get random number from total
					// groups which are comprised of grous of three					
					var intRandom:Number = Math.round(Math.random() * (_data.aryCards[intModeIndex].length() / 3 - 1));
					var aryImages:Array = [_data.aryCards[intModeIndex][intRandom * 3], _data.aryCards[intModeIndex][(intRandom * 3 + 1)], _data.aryCards[intModeIndex][(intRandom * 3 + 2)]];
					
					// Update choice with new properties
					aryChoices[i].updateInfo(strHeader, strDesc, aryImages, 2, selectMode, intModeIndex);
					aryChoices[i].choice.visible = true;
				}									
				
				// Hide choices that weren't updated (less than 6 this page)
				for (i = intModesThisPage; i < 6; i++)
				{
					aryChoices[i].choice.visible = false;
				}
			}
			
			// Animate/activate arrows based on current page
			if (intModePage > 1) // We can go back at least one page
			{ 
				TweenMax.to(mcScreen2.mcBtnModeBack, .3, {autoAlpha:1});
				toggleButton(mcScreen2.mcBtnModeBack, true);
			}
			else
			{
				TweenMax.to(mcScreen2.mcBtnModeBack, .3, {autoAlpha:.5});
				toggleButton(mcScreen2.mcBtnModeBack, false);
			}
			
			if (intModePage < intTotalPages)  // We can go forward at least one page
			{
				TweenMax.to(mcScreen2.mcBtnModeNext, .3, {autoAlpha:1});
				toggleButton(mcScreen2.mcBtnModeNext, true);
			}
			else
			{
				TweenMax.to(mcScreen2.mcBtnModeNext, .3, {autoAlpha:.5});
				toggleButton(mcScreen2.mcBtnModeNext, false);
			}		
		}
		
		public function selectDiff(intDiff:Number, intToucher:Number, intChoiceIndex:Number):void
		{
			for (var i:int = 0; i < 6; i++)
			{
				aryChoices[i].toggleTouch(false);
			}								
			_control.intSelectedDiff = intDiff;
			TweenMax.delayedCall(.10, animateScreen, ["difficulty", "out"]);
			TweenMax.delayedCall(.15, initScreen, ["gameboard"]);
			TweenMax.delayedCall(.20, animateScreen, ["gameboard", "in"]);		
		}		
		
	    // Show a message
		public function showMessage(strMessage:String):void
		{
			toggleItems(false);
			toggleButton(mcMessage.mcPopup.mcBtnOK, true);
					
			mcMessage.mcPopup.txtMessage.htmlText = "<b>" + strMessage + "</b>";
			mcMessage.mcPopup.scaleX = mcMessage.mcPopup.scaleY = .1;
			mcMessage.mcPopup.alpha = mcMessage.mcModal.alpha = 0;
			mcMessage.visible = true;
			setToTop(mcMessage);
			
			TweenMax.to(mcMessage.mcPopup, .5, {autoAlpha:1, scaleX:1, scaleY:1, ease:Expo.easeOut});	
			TweenMax.to(mcMessage.mcModal, .5, {autoAlpha:.5});							
		}
		
		// Hide a message
		public function hideMessage():void
		{
			toggleItems(true);
			TweenMax.to(mcMessage.mcPopup, .5, {scaleX:0, scaleY:0, visible:false, ease:Back.easeIn});			
			TweenMax.to(mcMessage.mcModal, .5, {autoAlpha:0});						
		}	
		
		public function setToTop(mcClip:MovieClip):void
		{
			gameLayer.setChildIndex(mcClip, (gameLayer.numChildren - 1));			
		}
		
		private function toggleItems(boolEnable:Boolean):void
		{
			var i:int = 0;
			for (i = 0; i < arySlots.length; i++)
			{
				arySlots[i].toggleTouch(boolEnable);
			}
			for (i = 0; i < aryChoices.length; i++)
			{
				aryChoices[i].toggleTouch(boolEnable);
			}
			
			toggleButton(mcScreen2.mcBtnBack, boolEnable);
			toggleButton(mcScreen1.mcBtnStart, boolEnable);
			toggleButton(mcScreen1.mcBtnReset, boolEnable);
			toggleButton(mcCorners.mcBtnQuit1, boolEnable);
			toggleButton(mcCorners.mcBtnQuit2, boolEnable);
			toggleButton(mcCorners.mcBtnRestart1 , boolEnable);
			toggleButton(mcCorners.mcBtnRestart2, boolEnable);
		}
		
		public function toggleButton(mcButton:MovieClip, boolEnabled:Boolean):void
		{
			if (CONFIG::DTENABLED)
			{
				if (boolEnabled)
					_control.diamondTouch.addObserver(mcButton);
				else
					_control.diamondTouch.removeObserver(mcButton);
			}
			else
			{			
				mcButton.mouseEnabled = boolEnabled;	
			}			
		}
		
		public function pressButton(mcButton:MovieClip):void
		{
			TweenMax.to(mcButton, .1, {
				scaleX:.95,
				scaleY:.95,
				glowFilter:{color:0x11C5FE, alpha:1, blurX:.5, blurY:.5}});
			_control.soundManager.play("beepalt");
		}
		public function releaseButton(mcButton:MovieClip):void
		{
			TweenMax.to(mcButton, .25, {
				scaleX:1,
				scaleY:1,
				glowFilter:{alpha:0, blurX:0, blurY:0, remove:true},
				ease:Back.easeOut});
		}
		
		public function resetPlayerSlots():void
		{
			for (var i:int = 0; i < arySlots.length; i++)
			{
				arySlots[i].resetSlot();
			}
		}
		
		public function setSlotName(strName:String, strSerialNumber:String):void
		{
			for (var i:int = 0; i < arySlots.length; i++)
			{
				if (arySlots[i].slotName.indexOf("Player") > -1)
				{
					arySlots[i].setSlotName(strName);
					break;
				}				
			}
		}
		
		public function killSlots():void
		{
			for (var i:int = arySlots.length-1; i >= 0; i--)
			{
				if (arySlots[i] != null)
				{
					arySlots[i].destroy();
					arySlots[i] == null;
				}
			}
			arySlots.length = 0;
		}
		
		public function killChoices():void
		{
			for (var i:int = aryChoices.length - 1; i >= 0; i--)
			{
				aryChoices[i].destroy();
				aryChoices[i] == null;
			}				
			aryChoices.length = 0;
		}		
		
		public function killCards():void
		{
			for (var i:int = aryGameCards.length - 1; i >= 0; i--)
			{
				if (aryGameCards[i] != null)
				{
					aryGameCards[i].destroy();
					aryGameCards[i] == null;
				}
			}
			aryGameCards.length = 0;
		}
		
		public function killToken():void
		{
			if (mcToken != null)
				mcToken.destroy();
		}		
	}
}