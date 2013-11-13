package avdw.game.sum2fifteen {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="699",height="465",backgroundColor="0xFFFFFF",frameRate="30")]
	
	public class Sum2Fifteen extends Sprite {
		[Embed(source="../../assets/700x465-Cards-Table-Texture.png")]
		private const Background:Class;
		
		public function Sum2Fifteen() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function randomSort(a:*, b:*):Number {
			if (Math.random() < 0.5)
				return -1;
			else
				return 1;
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(new Background());
			var cards:Array = [new Card(1), new Card(2), new Card(3), new Card(4), new Card(5), new Card(6), new Card(7), new Card(8), new Card(9)];
			cards.sort(randomSort);
			
			for (var i:int = 0; i < cards.length; i++) {
				cards[i].scaleX = cards[i].scaleY = 0.15;
				cards[i].y = 50;
				cards[i].x = 5 + (i * (cards[i].width + 2));
				cards[i].addEventListener(MouseEvent.CLICK, cardClicked);
				addChild(cards[i]);
			}
		}
		
		private function cardClicked(e:MouseEvent):void {
			trace(e.target.number);
		}
	
	}

}

import flash.display.Sprite;

class Card extends Sprite {
	public var number:int;
	
	public function Card(number:int) {
		this.number = number;
		
		switch (number) {
			case 1: 
				addChild(new CardAsset.ACE());
				break;
			case 2: 
				addChild(new CardAsset.TWO());
				break;
			case 3: 
				addChild(new CardAsset.THREE());
				break;
			case 4: 
				addChild(new CardAsset.FOUR());
				break;
			case 5: 
				addChild(new CardAsset.FIVE());
				break;
			case 6: 
				addChild(new CardAsset.SIX());
				break;
			case 7: 
				addChild(new CardAsset.SEVEN());
				break;
			case 8: 
				addChild(new CardAsset.EIGHT());
				break;
			case 9: 
				addChild(new CardAsset.NINE());
				break;
		}
	}
}

class CardAsset {
	[Embed(source="../../assets/cards/cards.virmir.com/ace_of_spades.png")]
	public static const ACE:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/two_of_spades.png")]
	public static const TWO:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/three_of_spades.png")]
	public static const THREE:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/four_of_spades.png")]
	public static const FOUR:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/five_of_spades.png")]
	public static const FIVE:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/six_of_spades.png")]
	public static const SIX:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/seven_of_spades.png")]
	public static const SEVEN:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/eight_of_spades.png")]
	public static const EIGHT:Class;
	[Embed(source="../../assets/cards/cards.virmir.com/nine_of_spades.png")]
	public static const NINE:Class;
}