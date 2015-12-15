package com.breadweb.mayhem
{
	import com.breadweb.utils.Console;
	import com.breadweb.utils.FPSCounter;
	import com.breadweb.utils.SoundManager;
	import com.circle12.diamondtouch.DTTouchEvent;
	import com.circle12.diamondtouch.DiamondTouch;
	
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.fscommand;
	
	import gs.TweenMax;
	import gs.easing.Back;
	import gs.easing.Circ;
	import gs.easing.Cubic;
	import gs.easing.Expo;
	import gs.easing.Linear;
	
	public class GameControl
	{					
		private static var _instance:GameControl;	
		private var _totalIdleTime:int = 0;
		private var _loadTasks:int = 1;
		private var _loadedTasks:int = 0;
		
		public var currentPlayer:int = 0;		
		public var config:XML;		
		public var loader:Sprite;
		public var soundManager:SoundManager;
		public var view:GameView;	
		public var data:GameData;
		public var diamondTouch:DiamondTouch;			
		public var aryPlayers:Vector.<PlayerComponent>;
		public var intTotalPlayers:Number = 0;			
		public var intSelectedToucher:Number = 0;
		public var intSelectedMode:Number = -1;
		public var intSelectedChoice:Number = -1;
		public var intSelectedDiff:Number = 2;
		public var intMatchesMade:int = 0;
		public var intSwirlNumber1:Number = 0;
		public var intSwirlNumber2:Number = 0;	
		
		public function GameControl(enforcer:SingletonEnforcer)	{}
		
		public static function getInstance():GameControl
		{
			if (_instance == null)
			{
				_instance = new GameControl(new SingletonEnforcer());
			}
			return _instance;
		}	
		
		public function init(loader:Sprite):void 
		{
			this.loader = loader;
			
			// Initialize managers
			soundManager = new SoundManager();
			soundManager.init("assets/sounds/");			
			
			// Load up external configuration xml file
			var configLoader:URLLoader = new URLLoader();
			configLoader.load(new URLRequest("assets/xml/config.xml"));
			configLoader.addEventListener(Event.COMPLETE, onConfigLoaded, false, 0, true);				
		}
		
		public function initGame():void
		{
			Console.log("Initializing game!", this);
			
			view = new GameView();
			loader.addChild(view);
			
			if (data.getSetting("console") == "true")
			{			
				Console.attach(view.debugLayer, Console.BLACK, 30);
			}
			
			if (data.getSetting("fpscounter") == "true")
			{
				var fps:FPSCounter = new FPSCounter();
				fps.init(view.debugLayer);		
			}			
			
			// Register external functions
			if (!CONFIG::DEBUG)
			{
				Security.allowDomain("*");			
				ExternalInterface.addCallback("onPlayerSelect", onPlayerSelect);				
			}
			else
			{
				if (Capabilities.playerType == "StandAlone")				
					loader.stage.displayState = StageDisplayState.FULL_SCREEN;
			}		
			
			// Initialize DiamondTouch surface and event listeners. The current
			// DTFlash library only supports primitive events. Web and debug 
			// deploys will substitute with mouse events 
			if (CONFIG::DTENABLED)
			{
				diamondTouch = DiamondTouch.getDiamondTouch(loader.stage);
				diamondTouch.addEventListener(DTTouchEvent.TOUCHDOWN, onTouch);

				if (data.getSetting("dtmouse") == "true")
				{
					Console.log("Enabling DT mouse emulation...", this);
					diamondTouch.enableTouchEmulation(true);
				}				
				
				
				if (data.getSetting("dtboxes") == "true")
				{
					Console.log("Enabling DT debug touch boxes...", this);
					diamondTouch.showCursorAndTouchBox(true);					
				}				
			}
			else
			{
				loader.stage.addEventListener(MouseEvent.MOUSE_DOWN, onTouch);
			}
			
			loader.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEvent);				
			
			// Initialize game arrays
			aryPlayers = new Vector.<PlayerComponent>(4);
			
			view.init();
			view.initScreen("start");
			view.animateScreen("start", "in");
		}
		
		private function onTouch(evt:Event):void
		{
			_totalIdleTime = 0;			
		}
		
		/**
		 * Only used to manually set the player index in
		 * environments where the DT table is not enabled
		 * such as the web preview or local debugging
		 */
		private function onKeyEvent(evt:KeyboardEvent):void
		{
			var index:int = evt.keyCode - 48;
			if (index > -1 && index < 4 && !Console.isReceivingInput())
			{
				Console.log("Switching player to " + index);
				currentPlayer = index;
				onTouch(evt);				
			}
		}	
		
		private function onPlayerSelect(player:String):void
		{	
			Console.log("Switching player to " + player);
			currentPlayer = int(player);
		}	
		
		private function onConfigLoaded(evt:Event):void
		{		
			config = new XML(evt.target.data);
			
			// Initialize the data manager class
			data = new GameData(config);
			
			if (data.getSetting("console") == "true")
			{
				Console.init(true);			
				new GameCommands();	
			}
			
			// Load all card data files
			_loadTasks += data.aryModes.length;
			data.loadAllCardData();
			
			// Load all external audio files
			for each (var sounds:XML in (config.sounds as XMLList).children()) 
			{
				_loadTasks++;
				var key:String = sounds.attribute("key").toString();
				var file:String = sounds.attribute("file").toString();
				soundManager.loadSound(file, key, setTaskLoaded); 
			}
			
			setTaskLoaded();		
		}	
		
		public function setTaskLoaded():void
		{
			_loadedTasks++;
			if (_loadedTasks >= _loadTasks)
				initGame();
		}	
		
		public function sendExit():void
		{
			Console.log("Sending exit!");
			
			if (Capabilities.playerType == "StandAlone")
				fscommand("quit");
			else
				ExternalInterface.call("exit", "");
		}		
		
		public function startGame():void
		{	
			var intReady:Number = 0;
			for (var i:int = 0; i < view.arySlots.length; i++)
			{
				if (view.arySlots[i].isReady)
				{
					intReady++;
				}
			}
			
			if (intReady > 1)
			{
				view.initScreen("mode");
				TweenMax.delayedCall(.10, view.animateScreen, ["start", "out"]);
				TweenMax.delayedCall(.15, view.animateScreen, ["mode", "in"]);
			}
			else
			{
				view.showMessage("At least two players need to be ready before the game can begin!");
			}
		}	
			
		// Restarting the game needs to destroy all dynamic objects,
		// reset movie clip states and properties
		public function restart():void
		{		
			// Kill possible TweenMax delayed calls and tweens
			TweenMax.killAllTweens();
			TweenMax.killAllDelayedCalls(); 
			
			// Kill all objects
			killPlayers();
			view.killSlots();
			view.killToken();
			view.killChoices();
			view.killCards();

			var aryButtons:Array = [view.mcScreen1.mcBtnStart, view.mcScreen1.mcBtnReset, view.mcScreen2.mcBtnBack];
			for (var i:int = 0; i < aryButtons.length; i++)
			{
				aryButtons[i].scaleX = aryButtons[i].scaleY = 0;
				aryButtons[i].visible = true;
				aryButtons[i].alpha = 1;
				view.toggleButton(aryButtons[i], true);
			}
			
			// Reset all other properties			
			view.mcScreen1.mcText1.alpha = 0;
			view.mcScreen1.mcText2.alpha = 0;
			view.mcScreen1.mcText3.alpha = 0;
			view.mcScreen2.mcText4.alpha = 0;
			view.mcScreen3.mcText5.alpha = 0;
			view.mcEnd.visible = false;
			view.mcMessage.visible = false;
			intMatchesMade = 0;
			view.intModePage = 0;
			
			TweenMax.delayedCall(.20, view.initScreen, ["start"]);
			TweenMax.delayedCall(.35, view.animateScreen, ["start", "in"]);		
		}
		
		public function replay():void
		{
			for (var i:int = 0; i < aryPlayers.length; i++)
			{
				if (aryPlayers[i] != null) {
					aryPlayers[i].updateScore(false);
				}
			}		
			intMatchesMade = 0;
			hideEnd();
			TweenMax.delayedCall(.10, view.initScreen, ["gameboard"]);
			TweenMax.delayedCall(.3, view.animateScreen, ["gameboard", "in"]);		
		}
				
		public function endGame():void
		{
			var i:int = 0;
			
			view.setToTop(view.mcEnd);

			// Dupliate players array for sorting
			var aryPlayersSort:Array = new Array();
			for (i = 0; i < aryPlayers.length; i++)
			{
				if (aryPlayers[i] != null)
				{
					aryPlayersSort.push(aryPlayers[i]);
				}
			}
			aryPlayersSort.sort(sortOnMatches, Array.DESCENDING);
			// Figure out if anyone tied by comparing top scores down
			var aryWinners:Array = new Array();
			aryWinners.push("<b>" + aryPlayersSort[0].strName + "</b>");
			for (i = 1; i < aryPlayersSort.length; i++)
			{
				if (aryPlayersSort[i].intMatches == aryPlayersSort[(i - 1)].intMatches)
				{
					aryWinners.push("<b>" + aryPlayersSort[i].strName + "</b>");
				}
				else
				{
					break;
				}
			}		
			// Putting together message
			var strText:String = "";
			if (aryWinners.length > 1)
			{
				strText = aryWinners.join(", ");
				strText = strText.substr(0, strText.indexOf(", " + aryWinners[aryWinners.length - 1]));
				strText += " and " + aryWinners[aryWinners.length -1]; 
				strText += " are the winners with <b>" + aryPlayersSort[0].intMatches + " matches</b>!";
			}
			else
			{
				strText = aryWinners[0] + " is the winner with <b>" + aryPlayersSort[0].intMatches + " matches</b>!";
			}
			
			view.mcEnd.txtEnd.htmlText = strText;
			view.mcEnd.scaleX = view.mcEnd.scaleY = .1;
			view.mcEnd.alpha = 0;
			view.mcEnd.visible = true;
			
			view.toggleButton(view.mcEnd.mcBtnRestart, true);
			view.toggleButton(view.mcEnd.mcBtnAgain, true);
			
			// If token hasn't been selected, animate it out and kill it.
			if (data.boolJail && view.mcToken.token != null)
			{
				TweenMax.to(view.mcToken.token, .65, {scaleX:0, scaleY:0, visible:false, ease:Back.easeIn, delay:.5, onComplete:view.killToken});
			}
			
			TweenMax.to(view.mcEnd, .5, {autoAlpha:1, scaleX:1, scaleY:1, delay:1, ease:Back.easeOut});	
			TweenMax.to(view.mcEnd.mcBtnRestart, 1, {scaleX:1, scaleY:1, delay:1.1, ease:Expo.easeOut});
			TweenMax.to(view.mcEnd.mcBtnAgain, 1, {scaleX:1, scaleY:1, delay:1.2, ease:Expo.easeOut});				
			
			TweenMax.delayedCall(1, soundManager.play, ["applause"]);
						
			TweenMax.delayedCall(1, view.killCards, null);			
		}
		
		private function hideEnd():void
		{
			TweenMax.to(view.mcEnd.mcBtnRestart, .5, {scaleX:0, scaleY:0, ease:Expo.easeIn});
			TweenMax.to(view.mcEnd.mcBtnAgain, .5, {scaleX:0, scaleY:0, delay:.1, ease:Expo.easeIn});		
			TweenMax.to(view.mcEnd, .5, {autoAlpha:0, scaleX:.1, scaleY:.1, delay:.3, ease:Back.easeIn});									
		}
		
		// Restarting the game after the end
		public function finishUp():void
		{
			hideEnd();
			TweenMax.delayedCall(.15, view.animateScreen, ["gameboard", "out"]);
			TweenMax.delayedCall(1.5, restart, null);
		}
		
		private function sortOnMatches(a:PlayerComponent, b:PlayerComponent):Number
		{
			if (a.intMatches > b.intMatches) {
				return 1;
			} else if (a.intMatches < b.intMatches) {
				return -1;
			} else {
				return 0;
			}
		}
		
		public function killPlayers():void
		{
			for (var i:int = aryPlayers.length - 1; i >= 0; i--) 
			{
				if (aryPlayers[i] != null)
				{
					aryPlayers[i].destroy();
					aryPlayers[i] == null;
				}
			}				
		}		
		
		// The token calls this when touched
		public function onTokenTouch(intToucher:int):void
		{
			// Check to see if there is an active card above the token. For the DT,
			// the touch event will go through the card unlike a mouse event which
			// is blocked by a covering display object
			for (var i:int = 0; i < view.aryGameCards.length; i++)
			{
				if (!view.aryGameCards[i].boolActive)
					break;
				
				if (view.aryGameCards[i].card.x == view.mcToken.token.x && view.aryGameCards[i].card.y == view.mcToken.token.y)
				{
					Console.log("Active card is blocking token!");
					return;
				}
			}
			
			soundManager.play("coin");
			TweenMax.delayedCall(.4, soundManager.play, ["celldoor"]);
			
			view.mcToken.toggleTouch(false);
			TweenMax.to(view.mcToken.token, .5, {removeTint:true, startAt:{tint:0xFFFFFF}});
			TweenMax.to(view.mcToken.token, .65, {scaleX:0, scaleY:0, visible:false, ease:Back.easeIn, delay:.5, onComplete:view.killToken});

			// Lock down players except the person who touched the token and
			// set them to unlock 5 seconds later.
			for (var i:int = 0; i < aryPlayers.length; i++)
			{
				if (aryPlayers[i] != null && intToucher != i)
				{
					aryPlayers[i].setLockDown(true, aryPlayers[intToucher].strName, view.aryColors[intToucher].toString(16), 10);
					TweenMax.delayedCall(.4, aryPlayers[i].showLockDown, [true]);
					TweenMax.delayedCall(10, aryPlayers[i].setLockDown, [false, "", "", 0]);
					TweenMax.delayedCall(10, aryPlayers[i].showLockDown, [false]);
				}
			}
		}
		
		// A card calls this when touched. Lots of things to check!
		public function onCardTouch(intCard:int, intToucher:int):void
		{
			// Only registered players can do anything with the cards
			// Nothing can be done while the user is in Jail lockdown
			if (aryPlayers[intToucher] != null && !aryPlayers[intToucher].getLockDown()) {
				
				// Try to add the card to the player's selected card.
				var boolAdded:Boolean = aryPlayers[intToucher].addSelection(intCard);
				
				// If not a duplicate, test the player's current set of selections
				if (boolAdded)
				{	
					var strReturn:String = testMatch(aryPlayers[intToucher].arySelections);
					
					switch (strReturn)
					{
						case "match": // The max number of cards selected with a match
							
							var i:int = 0;
							
							for (i = 0; i < aryPlayers[intToucher].arySelections.length; i++)
							{
								var objCard:CardComponent = view.aryGameCards[aryPlayers[intToucher].arySelections[i]];							
								// Disable cards
								objCard.toggleTouch(false);
								// Remove other player highlights from card
								objCard.resetAllHigh();
								// Remove card from gameplay
								objCard.boolActive = false;
								// Animate out cards, destroy cards
								view.setToTop(objCard.card);
								var aryStackCoords:Point = aryPlayers[intToucher].getStackCoords();
								TweenMax.to(objCard.card, 1, {
									scaleX:aryPlayers[intToucher].gamePlayer.mcScorer.mcStack.scaleX, 
									scaleY:aryPlayers[intToucher].gamePlayer.mcScorer.mcStack.scaleY,
									x:aryStackCoords.x, y:aryStackCoords.y,
									rotation:view.aryPlayerRotations[intToucher],
									delay:i * .1,
									ease:Cubic.easeInOut});						
							}
							// Remove selected index from all player selections
							var arySelections:Array = aryPlayers[intToucher].arySelections.join(",").split(",");
							for (i = 0; i < arySelections.length; i++)
							{
								for (var j:int = 0; j < aryPlayers.length; j++)
								{
									if (aryPlayers[j] != null)
									{
										aryPlayers[j].removeSelection(arySelections[i]);
									}
								}
							}
							// Increase player score
							aryPlayers[intToucher].updateScore(true);
							// Sound
							soundManager.play("match");
							// Increment number of matches
							intMatchesMade++;

							// If we met the swirl threshold, swirl!
							if (data.boolSwirl && (intMatchesMade == intSwirlNumber1 || intMatchesMade == intSwirlNumber2))
							{
								swirlCards();
							}
							// Check for end of game
							if (intMatchesMade == data.intRows * data.intCols / (intSelectedDiff + 1))
							{
								endGame();
							}						
							break;
						
						case "nomatch": // The max number of cards selected without a match
							
							// Remove player's highlight from all selected cards and show shake animation
							for (i = 0; i < aryPlayers[intToucher].arySelections.length; i++)
							{
								view.aryGameCards[aryPlayers[intToucher].arySelections[i]].shakeOff(intToucher, false);
							}
							// Remove all selected cards from player
							aryPlayers[intToucher].resetSelections();
							// Sound
							soundManager.play("beep3-" + (intToucher + 1));
							break;
						
						case "nomax": // The max number of card selections not met
							
							// Tilt card toward person
							view.aryGameCards[intCard].spinTo(view.aryPlayerRotations[data.aryPositions[intToucher]]);
							// Add player highlight to selected card
							view.aryGameCards[intCard].toggleHigh(intToucher, true);
							// Sound
							soundManager.play("beep1-" + (intToucher + 1));
							break;
					}
				}
				else
				{
					view.aryGameCards[intCard].toggleHigh(intToucher, false);
					soundManager.play("beep1-" + (intToucher + 1));
				}
			}
			else
			{
				// Let the lockdown players know that they can't do anything! WRONG! :P
				soundManager.play("wrong");
			}
		}
		
		// Test passed array of selected cards and return outcome
		private function testMatch(aryCardIDs:Array):String
		{
			if (aryCardIDs.length == intSelectedDiff + 1)
			{	
				// Compare a card with the next one in front of it
				// and if continue to match through the end of the array
				// we havae a match!
				for (var i:int = 0; i < aryCardIDs.length - 1; i++)
				{
					if (view.aryGameCards[aryCardIDs[i]].strID != view.aryGameCards[aryCardIDs[(i + 1)]].strID)
					{
						return "nomatch";
					}
				}			
				return "match";
			}
			else
			{
				return "nomax";
			}
		}
			
		// Swirling mayhem!
		public function swirlCards():void
		{		
			Console.log("Swirling cards!");
			
			var i:int = 0;
			
			soundManager.play("swirl");

			// Create set of random coordinates for current grid
			var aryNewSpots:Array = new Array();
			var intGridWidth:Number = data.intCols * (view.intCardSidePlay + view.intSpacer);
			var intGridHeight:Number = data.intRows * (view.intCardSidePlay + view.intSpacer);		
			var intOffsetX:Number = (loader.stage.stageWidth - intGridWidth) / 2;
			var intOffsetY:Number = (loader.stage.stageHeight - intGridHeight) / 2;
			
			for (i = 0; i < data.intRows; i++)  // 6
			{
				for (var j:int = 0; j < data.intCols; j++)  // 8
				{
					aryNewSpots.push([j * (view.intCardSidePlay + view.intSpacer) + intOffsetX, i * (view.intCardSidePlay + view.intSpacer) + intOffsetY]);
				}
			}
			
			// Loop through all cards
			for (i = 0; i < view.aryGameCards.length; i++)
			{
				if (view.aryGameCards[i].boolActive) // If card is active...
				{
					view.aryGameCards[i].toggleTouch(false);
					// Pull a random coordinate set from array
					var intIndex:Number = Math.round(Math.random() * (aryNewSpots.length - 1));
					var intDelay:Number = Math.random();
					var intSpeed:Number = Math.round(Math.random() * 2) + 2;
					// Create 2 random bezier points for all cards
					var aryBezier1:Array = [Math.round(Math.random() * loader.stage.stageWidth), Math.round(Math.random() * loader.stage.stageHeight)];
					var aryBezier2:Array = [Math.round(Math.random() * loader.stage.stageWidth), Math.round(Math.random() * loader.stage.stageHeight)];
					// Tween cards to new spots at random speeds
					TweenMax.to(view.aryGameCards[i].card, intSpeed, {
						x:aryNewSpots[intIndex][0] + view.aryGameCards[i].card.width / 2,
						y:aryNewSpots[intIndex][1] + view.aryGameCards[i].card.height / 2,
						bezierThrough:[{x:aryBezier1[0], y:aryBezier1[1]}, {x:aryBezier2[0], y:aryBezier2[1]}],
						delay:intDelay,
						ease:Cubic.easeInOut});
					// Remove random position so can't be used again
					aryNewSpots.splice(intIndex, 1);
					// Set cards to be active again
					TweenMax.delayedCall(4, view.aryGameCards[i].toggleTouch, [true]);
				}
			}
			
			// Animate swirl text
			var swirl:SwirlText = new SwirlText();
			view.gameLayer.addChild(swirl);
			swirl.x = loader.stage.stageWidth / 2;
			swirl.y = loader.stage.stageHeight / 2;
			swirl.scaleY = swirl.scaleX = swirl.alpha = 0;
			TweenMax.to(swirl, 1, {rotation:"+360", alpha:1, scaleX:1.5, scaleY:1.5, ease:Linear.easeNone, dropShadowFilter:{ alpha:1, angle:0, blurX:5, blurY:5, color:0x000000, distance:0, strength:1000}});
			TweenMax.to(swirl, 3, {rotation:"+360", alpha:1, ease:Circ.easeOut, delay:1});
			TweenMax.to(swirl, 1, {rotation:"+360", alpha:1, scaleX:0, scaleY:0, ease:Back.easeIn, delay:4, onComplete:removeSwirl, onCompleteParams:[swirl]});
		}
		
		private function removeSwirl(swirl:SwirlText):void
		{
			swirl.parent.removeChild(swirl);
		}
	}
}

class SingletonEnforcer {}