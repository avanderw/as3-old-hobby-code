package avdw.game.sum2fifteen {
	import com.greensock.TweenLite;
	import com.gskinner.motion.GTween;
	import com.gskinner.utils.Rndm;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.sampler.NewObjectSample;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.plugin.photonstorm.FlxBitmapFont;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class PlayState extends FlxState {
		[Embed(source="../../../assets/700x465-Cards-Table-Texture.png")]
		private const Background:Class;
		[Embed(source="../../../assets/fonts/070.png")]
		private const Font:Class;
		private var cards:Array;
		private var playerCards:Array;
		private var computerCards:Array;
		private var card:Card;
		private var debug:FlxText;
		private var debugBoard:Array;
		private var winner:Boolean = false;
		private var playerWin:FlxBitmapFont;
		private var computerWin:FlxBitmapFont;
		private var drawText:FlxBitmapFont;
		private var debugHelp:FlxText;
		private var debugOn:Boolean = false;
		private var gameEnd:FlxSprite;
		
		override public function create():void {
			super.create();
			FlxG.mouse.show();
			
			var bg:FlxSprite = new FlxSprite(0, 0, Background);
			add(bg);
			
			var playerArea:FlxSprite = new FlxSprite(70, 295);
			playerArea.makeGraphic(395, 115, 0x77000000);
			add(playerArea);
			
			var computerArea:FlxSprite = new FlxSprite(345, 165);
			computerArea.makeGraphic(318, 115, 0x77000000);
			add(computerArea);
			
			var bannerArea:FlxSprite = new FlxSprite(0, 5);
			bannerArea.makeGraphic(700, 35, 0xAA000000);
			add(bannerArea);
			
			gameEnd = new FlxSprite(0, 0);
			gameEnd.makeGraphic(700, 465, 0xAA000000);
			
			var font:FlxBitmapFont = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			font.setText("Try get three cards adding up to fifteen", false, 0, 0, FlxBitmapFont.ALIGN_LEFT);
			font.x = 20;
			font.y = 15;
			add(font);
			
			playerWin = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			playerWin.setText("YOU WIN");
			
			computerWin = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			computerWin.setText("YOU LOST");
			
			drawText = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			drawText.setText("GAME DRAW");
			drawText.x = computerWin.x = playerWin.x = 100;
			drawText.y = computerWin.y = playerWin.y = 200;
			
			var computerText:FlxBitmapFont = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			computerText.setText("computer");
			computerText.x = 490;
			computerText.y = 210;
			add(computerText);
			
			var playerText:FlxBitmapFont = new FlxBitmapFont(Font, 16, 16, FlxBitmapFont.TEXT_SET6, 20, 0, 1);
			playerText.setText("player");
			playerText.x = 330;
			playerText.y = 340;
			add(playerText);
			
			playerCards = [];
			computerCards = [];
			
			cards = [new Card(1), new Card(2), new Card(3), new Card(4), new Card(5), new Card(6), new Card(7), new Card(8), new Card(9)];
			cards.sort(randomSort);
			
			for (var i:int = 0; i < cards.length; i++) {
				cards[i].y = 50;
				cards[i].x = 5 + (i * (77));
				
				add(cards[i]);
			}
			
			debugBoard = [["%", "%", "%"], ["%", "%", "%"], ["%", "%", "%"]];
			debug = new FlxText(0, 0, 100, "%|%|%\n%|%|%\n%|%|%");
			debug.x = 650;
			debug.y = 400;
			
			debugHelp = new FlxText(0, 0, 100, "8|3|4\n1|5|9\n|6|7|2");
			debugHelp.x = 600;
			debugHelp.y = 400;
		}
		
		override public function update():void {
			super.update();
			
			if (FlxG.keys.justPressed("SPACE")) {
				debugOn = !debugOn;
				if (debugOn) {
					add(debug);
					add(debugHelp);
				} else {
					remove(debug);
					remove(debugHelp);
				}
			}
			
			if (winner && FlxG.mouse.justPressed()) {
				FlxG.resetState();
			}
			
			var played:Boolean = false;
			var selectedCard:Card;
			if (FlxG.mouse.justPressed() && !winner) {
				for each (card in cards) {
					if (card.pixelsOverlapPoint(FlxG.mouse.getScreenPosition())) {
						selectedCard = card;
						played = true;
					}
				}
			}
			
			if (played) {
				// player
				TweenLite.to(selectedCard, 1, {x: 75 + (playerCards.length * (77)), y: 300});
				playerCards.push(selectedCard);
				cards.splice(cards.indexOf(selectedCard), 1);
				debugBoard[selectedCard.row][selectedCard.col] = "X";
				winner = checkWin(playerCards);
				if (winner) {
					add(gameEnd);
					add(playerWin);
				}
				
				// computer
				var row:int;
				var col:int;
				var isFound:Boolean = false;
				if (cards.length != 0 && !winner) {
					var friendMap:Array = calc(computerCards, playerCards);
					print("friend", friendMap);
					for (row = 0; row < 3; row++) {
						for (col = 0; col < 3; col++) {
							if (friendMap[row][col] == 2) {
								selectedCard = getCard(row, col);
								isFound = true;
								break;
							}
						}
						if (isFound) {
							break;
						}
					}
					
					if (!isFound) {
						var blockMap:Array = calc(playerCards, computerCards);
						print("block", blockMap);
						for (row = 0; row < 3; row++) {
							for (col = 0; col < 3; col++) {
								if (blockMap[row][col] == 2) {
									selectedCard = getCard(row, col);
									isFound = true;
									break;
								}
							}
							if (isFound) {
								break;
							}
						}
					}
					
					if (!isFound) {
						var combined:Array = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
						var maxCount:int = 0;
						for (row = 0; row < 3; row++) {
							for (col = 0; col < 3; col++) {
								combined[row][col] = friendMap[row][col] + blockMap[row][col];
								maxCount = Math.max(maxCount, combined[row][col]);
							}
						}
						print("combined", blockMap);
						
						var selectVector:Vector.<Point> = new Vector.<Point>();
						for (row = 0; row < 3; row++) {
							for (col = 0; col < 3; col++) {
								if (combined[row][col] == maxCount) {
									selectVector.push(new Point(row, col));
								}
							}
						}
						
						var p:Point = selectVector[Math.floor(Math.random() * selectVector.length)];
						selectedCard = getCard(p.x, p.y);
					}
					
					TweenLite.to(selectedCard, 1, {x: 350 + (computerCards.length * (77)), y: 170});
					computerCards.push(selectedCard);
					cards.splice(cards.indexOf(selectedCard), 1);
					debugBoard[selectedCard.row][selectedCard.col] = "O";
					
					winner = checkWin(computerCards);
					if (winner) {
						add(gameEnd);
						add(computerWin);
					}
				} else if (cards.length == 0) {
					winner = true;
					add(gameEnd);
					add(drawText);
				}
				
				var str:String = "";
				for (row = 0; row < 3; row++) {
					for (col = 0; col < 3; col++) {
						str += debugBoard[row][col] + "|";
					}
					str = str.substr(0, str.length - 1);
					str += "\n";
				}
				debug.text = str;
			}
		}
		
		private function checkWin(cards:Array):Boolean {
			var calcMap:Array = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
			for each (card in cards) {
				calcMap[card.row + 1][card.col + 1] = 1;
				calcMap[card.row + 1][0] = calcMap[card.row + 1][4] += 1;
				calcMap[0][card.col + 1] = calcMap[4][card.col + 1] += 1;
				calcMap[0][0] = calcMap[4][4] += (card.row == 0 && card.col == 0) || (card.row == 1 && card.col == 1) || (card.row == 2 && card.col == 2) ? 1 : 0;
				calcMap[4][0] = calcMap[0][4] += (card.row == 0 && card.col == 2) || (card.row == 1 && card.col == 1) || (card.row == 2 && card.col == 0) ? 1 : 0;
				calcMap[card.row + 1][card.col + 1] = -1;
			}
			
			for (var row:int = 1; row < 4; row++) {
				for (var col:int = 1; col < 4; col++) {
					if (calcMap[row][col] == 0) {
						calcMap[row][col] = Math.max(calcMap[4][col], calcMap[row][4]);
						if ((row == 1 && col == 1) || (row == 3 && col == 3)) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[0][0]);
						} else if (row == 2 && col == 2) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[4][4], calcMap[0][4]);
						} else if ((row == 1 && col == 3) || (row == 3 && col == 1)) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[0][4]);
						}
					}
				}
			}
			
			for (var count:int = 0; count < 5; count++) {
				if (calcMap[count][0] == 3 || calcMap[0][count] == 3) {
					return true;
				}
			}
			return false;
		}
		
		private function getCard(row:int, col:int):Card {
			for each (var card:Card in cards) {
				if (card.row == row && card.col == col) {
					return card;
				}
			}
			throw new Error("should always select a card");
		}
		
		private function print(string:String, matrix:Array):void {
			var str:String = "";
			trace(string);
			for (var row:int = 0; row < 3; row++) {
				for (var col:int = 0; col < 3; col++) {
					str += "" + matrix[row][col] + " ";
				}
				str += "\n";
			}
			trace(str);
		}
		
		private function calc(cards:Array, remove:Array):Array {
			var calcMap:Array = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
			for each (card in cards) {
				calcMap[card.row + 1][card.col + 1] = 1;
				calcMap[card.row + 1][0] = calcMap[card.row + 1][4] += 1;
				calcMap[0][card.col + 1] = calcMap[4][card.col + 1] += 1;
				calcMap[0][0] = calcMap[4][4] += (card.row == 0 && card.col == 0) || (card.row == 1 && card.col == 1) || (card.row == 2 && card.col == 2) ? 1 : 0;
				calcMap[4][0] = calcMap[0][4] += (card.row == 0 && card.col == 2) || (card.row == 1 && card.col == 1) || (card.row == 2 && card.col == 0) ? 1 : 0;
				calcMap[card.row + 1][card.col + 1] = -1;
			}
			
			for (var row:int = 1; row < 4; row++) {
				for (var col:int = 1; col < 4; col++) {
					if (calcMap[row][col] == 0) {
						calcMap[row][col] = Math.max(calcMap[4][col], calcMap[row][4]);
						if ((row == 1 && col == 1) || (row == 3 && col == 3)) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[0][0]);
						} else if (row == 2 && col == 2) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[4][4], calcMap[0][4]);
						} else if ((row == 1 && col == 3) || (row == 3 && col == 1)) {
							calcMap[row][col] = Math.max(calcMap[row][col], calcMap[0][4]);
						}
					}
				}
			}
			calcMap.shift();
			calcMap.pop();
			for (var count:int = 0; count < 3; count++) {
				calcMap[count].shift();
				calcMap[count].pop();
			}
			for each (card in remove) {
				calcMap[card.row][card.col] = -1;
			}
			return calcMap;
		}
		
		private function randomSort(a:*, b:*):Number {
			if (Math.random() < 0.5)
				return -1;
			else
				return 1;
		}
	}

}
import org.flixel.FlxSprite;

class Card extends FlxSprite {
	public var number:int;
	public var row:int;
	public var col:int;
	
	public function Card(number:int) {
		this.number = number;
		
		var clazz:Class;
		switch (number) {
			case 1: 
				clazz = CardAsset.ACE;
				row = 1;
				col = 0;
				break;
			case 2: 
				clazz = CardAsset.TWO;
				row = 2;
				col = 2;
				break;
			case 3: 
				clazz = CardAsset.THREE;
				row = 0;
				col = 1;
				break;
			case 4: 
				clazz = CardAsset.FOUR;
				row = 0;
				col = 2;
				break;
			case 5: 
				clazz = CardAsset.FIVE;
				row = 1;
				col = 1;
				break;
			case 6: 
				clazz = CardAsset.SIX;
				row = 2;
				col = 0;
				break;
			case 7: 
				clazz = CardAsset.SEVEN;
				row = 2;
				col = 1;
				break;
			case 8: 
				clazz = CardAsset.EIGHT;
				row = 0;
				col = 0;
				break;
			case 9: 
				clazz = CardAsset.NINE;
				row = 1;
				col = 2;
				break;
		}
		
		super(0, 0, clazz);
	}
	
	override public function toString():String {
		return "" + number;
	}
}

class CardAsset {
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 ace_of_spades.png")]
	public static const ACE:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 two_of_spades.png")]
	public static const TWO:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 three_of_spades.png")]
	public static const THREE:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 four_of_spades.png")]
	public static const FOUR:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 five_of_spades.png")]
	public static const FIVE:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 six_of_spades.png")]
	public static const SIX:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 seven_of_spades.png")]
	public static const SEVEN:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 eight_of_spades.png")]
	public static const EIGHT:Class;
	[Embed(source="../../../assets/cards/cards.virmir.com/75x105 nine_of_spades.png")]
	public static const NINE:Class;
}