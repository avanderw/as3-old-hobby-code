package avdw.demo.terrain {
	import avdw.generate.terrain.dimension.two.DiamondSquare;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="400",height="400",backgroundColor="#000000",frameRate="1")]
	
	public class DiamondSqaure extends Sprite {
		private var heightmap:Vector.<Vector.<Number>>;
		private const size:int = 129;
		private var mapRGB:Array = new Array(3);
		private var bmp:Bitmap = new Bitmap(new BitmapData(size, size));
		private var smoothness:Number = 0.8;
		
		// orig: private var shadingMultiplier:Number = 4;
		private var shadingMultiplier:Number = 2; // contrast
		private var shadingOffset:int = 160;
		private var shadingConvolutionFilter:ConvolutionFilter = new ConvolutionFilter(3, 3, [-3, -2, 0, -2, 0, 2, 0, 2, 3], 3, 1, true, true);
		private var colorTransform:ColorTransform = new ColorTransform(shadingMultiplier, shadingMultiplier, shadingMultiplier, 1, shadingOffset, shadingOffset, shadingOffset, 0);
		private var txt:TextField;
		
		
		public function DiamondSqaure() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			txt = new TextField();
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.textColor = 0xFFFFFF;
			mapRGB = getMapColors();
			generate();
			
			bmp.scaleX = 400 / size;
			bmp.scaleY = 400 / size;
			addChild(bmp);
			addChild(txt);
			
			stage.addEventListener(MouseEvent.CLICK, generate);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeypress);
		}
		
		private function onKeypress(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 38: // up
					smoothness += 0.05;
					break;
				case 40: // down
					smoothness -= 0.05;
					break;
			}
			
			generate();
		}
		
		private function generate(e:MouseEvent = null):void {
			heightmap = DiamondSquare.generate(size, smoothness);
			
			bmp.bitmapData.lock();
			for (var i:int = 0; i < size; i++) {
				for (var j:int = 0; j < size; j++) {
					var scaled:int = heightmap[i][j] * 0xFF;
					bmp.bitmapData.setPixel(i, j, scaled << 16 | scaled << 8 | scaled);
				}
			}
			bmp.bitmapData.unlock();
			bmp.bitmapData.paletteMap(bmp.bitmapData, bmp.bitmapData.rect, bmp.bitmapData.rect.topLeft, mapRGB[0], mapRGB[1], mapRGB[2]);
			
			// shading map
			var shading:Bitmap = new Bitmap(new BitmapData(size, size, false, 0));
			shading.bitmapData.applyFilter(bmp.bitmapData, bmp.bitmapData.rect, bmp.bitmapData.rect.topLeft, shadingConvolutionFilter);
			
			/**
			 * bake, with colour enhancement
			 */
			bmp.bitmapData.draw(shading.bitmapData, null, colorTransform, BlendMode.MULTIPLY);
			
			// update text
			txt.text = "Diamond Square" +
					   "\n---------------------------------------" +
			    "\nclick to generate" +
				"\nsmoothness (up/down): " + (Math.round(smoothness * 100) / 100);
		}
		
		/**
		 * Draws a bar of 256x1 with terrain colors and transitions
		 * (blue, light brown green, dark brown, white)
		 */
		private function getMapColors():Array {
			var mat:Matrix = new Matrix();
			mat.createGradientBox(256, 1, 0, 0, 0);
			
			var gradation:Object = {color: [0x000080, 0x0066ff, 0xcc9933, 0x00cc00, 0x996600, 0xffffff], alpha: [100, 100, 100, 100, 100, 100], ratio: [0, 96, 96, 128, 168, 224]};
			var gradientBar:Shape = new Shape();
			var g:Graphics = gradientBar.graphics;
			g.clear();
			g.beginGradientFill("linear", gradation.color, gradation.alpha, gradation.ratio, mat);
			g.drawRect(0, 0, 256, 1);
			g.endFill();
			
			mat.identity();
			
			var mapR:Array = new Array(256);
			var mapG:Array = new Array(256);
			var mapB:Array = new Array(256);
			// initialize the RGB arrays
			var gmap:BitmapData = new BitmapData(256, 1, false, 0);
			gmap.draw(gradientBar);
			for (var i:int = 0; i < 256; i++) {
				var col:uint = gmap.getPixel(i, 0);
				// get the red,green,blue channel values for each pixel in the gradient bar 
				// i then stand for the level of grey intensity in the perlin noise image
				mapR[i] = col & 0xff0000; // R  
				mapG[i] = col & 0x00ff00; // G
				mapB[i] = col & 0x0000ff; // B
			}
			gmap.dispose();
			
			return [mapR, mapG, mapB];
		}
	
	}

}