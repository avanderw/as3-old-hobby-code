package avdw.demo.effect {
	import avdw.generate.effect.HexagonalMask;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 *
	 * Reference: http://wonderfl.net/c/jLM1
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="450",height="600",backgroundColor="0xFFFFFF",frameRate="30")]
	
	public class HexagonalViewEffect extends Sprite {
		// http://photos.travelblog.org/Photos/22189/85140/f/530317-Bamboo-Forest-0.jpg
		[Embed(source="../../../assets/450x600 Bamboo Forest.jpg")]
		private var Picture:Class; 
		private var hexMaskEffect:HexagonalMask;
		private var hexagons:int = 300;
		private var diameter:int = 20;
		private var txt:TextField;
		
		public function HexagonalViewEffect():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var container:Sprite = new Sprite();
			var picture:Bitmap = new Picture();
			container.addChild(picture);
			addChild(container);
			
			txt = new TextField();
			txt.textColor = 0x333333;
			txt.autoSize = TextFieldAutoSize.LEFT;
			updateText();
			stage.addChild(txt);
			
			hexMaskEffect = new HexagonalMask(stage, container, picture);
			hexMaskEffect.apply(new Point(picture.width / 2, picture.height / 2), hexagons, diameter);
			
			stage.addEventListener(MouseEvent.CLICK, reapply);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeypress);
		}
		
		private function onKeypress(e:KeyboardEvent):void 
		{
			switch (e.keyCode) {
				case 38: // up
					hexagons += 20;
					break;
				case 40: // down
					hexagons -= 20;
					break;
				case 37: // left
					diameter -= 1;
					break;
				case 39: // right
					diameter += 1;
					break;
			}
			
			hexMaskEffect.apply(new Point(mouseX, mouseY), hexagons, diameter);
			
			updateText();
		}
		
		private function reapply(e:MouseEvent):void {
			hexMaskEffect.apply(new Point(mouseX, mouseY), hexagons, diameter);
			//hexMaskEffect.remove();
			
			updateText();
		}
		
		private function updateText():void 
		{
			txt.text = "Hexagonal View Effect" +
					   "\n---------------------------------------" +
			    "\nclick to generate at mouse click" +
				"\nhexagons (up/down):\t" + hexagons +
				"\ndiameter (left/right):\t\t" + diameter +
				"\n\nfuture version will have speed control";
		}
	
	}

}