package avdw.demo.terrain {
	import as3isolib.bounds.IBounds;
	import as3isolib.display.IsoView;
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoGrid;
	import as3isolib.display.scene.IsoScene;
	import as3isolib.enum.RenderStyleType;
	import as3isolib.graphics.IFill;
	import as3isolib.graphics.SolidColorFill;
	import avdw.generate.effect.Disintegrate;
	import avdw.generate.terrain.dimension.two.MidpointDisplacement;
	import avdw.generate.terrain.dimension.two.DiamondSquare;
	import avdw.generate.terrain.dimension.two.ValueNoise;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	/**
	 * TODO: Implement an ISO view for the terrain generation algorithms
	 *
	 * Reference: http://code.google.com/p/as3isolib/
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="600",height="500",backgroundColor="0xFFFFFF",frameRate="30")]
	
	public class IsoTerrainView extends Sprite {
		[Embed(source="../../../assets/600x500 Space Background.jpg")]
		private const Background:Class;
		
		private var mapColors:Array;
		private var heightmap:Vector.<Vector.<Number>>;
		private var size:int;
		private var scene:IsoScene;
		private var cellSize:int;
		private var smoothness:Number;
		private var status:TextField;
		private var view:IsoView;
		private var bitmap:Bitmap;
		private var algo:int = 0;
		
		public function IsoTerrainView() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(new Background());
			
			scene = new IsoScene();
			scene.hostContainer = this;
			
			cellSize = 10;
			smoothness = 0.75;
			
			mapColors = getMapColors();
			
			size = 33;
			heightmap = MidpointDisplacement.generate(size, smoothness);
			for (var i:int = 0; i < size; i++) {
				for (var j:int = 0; j < size; j++) {
					var box:IsoBox = new IsoBox();
					box.setSize(cellSize, cellSize, Math.round(heightmap[i][j] * 10) * 10);
					box.moveTo(i * cellSize, j * cellSize, 0);
					box.styleType = RenderStyleType.SOLID;
					box.fill = new SolidColorFill(mapColors[Math.floor(255 * heightmap[i][j])], 1);
					scene.addChild(box);
				}
			}
			scene.render();
			
			view = new IsoView();
			view.setSize(stage.stageWidth, stage.stageHeight / 2);
			view.clipContent = false;
			view.showBorder = false;
			view.addScene(scene);
			
			addChild(view);
			
			status = new TextField();
			status.selectable = false;
			status.text = "Algorithm: Midpoint Displacement";
			status.textColor = 0xFFFFFF;
			status.autoSize = TextFieldAutoSize.LEFT;
			addChild(status);
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void {
			status.text = "Generating...";
			scene.removeAllChildren();
			
			var timer:Timer = new Timer(100, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, generate);
			timer.start();
		}
		
		private function generate(e:TimerEvent):void {
			algo++;
			if (algo > 2) {
				algo = 0;
			}
			switch (algo) {
				case 0: 
					status.text = "Algorithm: Midpoint Displacement";
					heightmap = MidpointDisplacement.generate(size, 0.75);
					break;
				case 1: 
					status.text = "Algorithm: Broken Diamond Square";
					heightmap = DiamondSquare.generate(size, 0.75);
					break;
				case 2: 
					status.text = "Algorithm: Value Noise";
					heightmap = avdw.generate.terrain.dimension.two.ValueNoise.generate(size);
					break;
			}
			
			for (var i:int = 0; i < size; i++) {
				for (var j:int = 0; j < size; j++) {
					var box:IsoBox = new IsoBox();
					heightmap[i][j] = Math.min(1, Math.max(0, heightmap[i][j]));
					box.setSize(cellSize, cellSize, Math.round(heightmap[i][j] * 10) * 10);
					box.moveTo(i * cellSize, j * cellSize, 0);
					box.styleType = RenderStyleType.SOLID;
					box.fill = new SolidColorFill(mapColors[Math.floor(255 * heightmap[i][j])], 1);
					scene.addChild(box);
				}
			}
			scene.render();
		}
		
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
			
			var map:Array = new Array(256);
			// initialize the RGB arrays
			var gmap:BitmapData = new BitmapData(256, 1, false, 0);
			gmap.draw(gradientBar);
			for (var i:int = 0; i < 256; i++) {
				var col:uint = gmap.getPixel(i, 0);
				// get the red,green,blue channel values for each pixel in the gradient bar 
				// i then stand for the level of grey intensity in the perlin noise image
				map[i] = col;
			}
			gmap.dispose();
			
			return map;
		}
	
	}

}