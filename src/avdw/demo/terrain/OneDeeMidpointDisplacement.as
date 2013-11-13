package avdw.demo.terrain {
	import avdw.generate.terrain.dimension.one.MidpointDisplacement;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="600",height="400",backgroundColor="#000000",frameRate="1")]
	
	public class OneDeeMidpointDisplacement extends Sprite {
		private const render:Sprite = new Sprite();
		private const iterationText:TextField = new TextField();
		private const smoothnessText:TextField = new TextField();
		private const bitmap:Bitmap = new Bitmap(new BitmapData(600, 400, false, 0));
		private const bmpMatrix:Matrix = new Matrix(1, 0, 0, 1, 0, 100);
		private const filter:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
		private var heightmap:Vector.<Number>;
		private var matrix:Matrix;
		private var resolution:int;
		private var smoothness:Number = 0.8
		private var iteration:int;
		
		public function OneDeeMidpointDisplacement():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(bitmap);
			
			matrix = new Matrix();
			matrix.createGradientBox(600, 200, -Math.PI / 2);
			
			render.y = 100;
			addChild(render);
			
			iterationText.textColor = 0xFFFFFF;
			smoothnessText.textColor = 0xFFFFFF;
			smoothnessText.x = 100;
			addChild(iterationText);
			addChild(smoothnessText);
			var text:TextField = new TextField();
			text.textColor = 0xFFFFFF;
			text.text = "\tup / down arrow to change smoothness\t\tclick to generate new heightmap";
			text.autoSize = TextFieldAutoSize.LEFT;
			text.x = 200;
			addChild(text);
			
			generateTerrain();
			resetResolution();
			updateResolution();
			updateText();
			renderTerrain();
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
			stage.addEventListener(MouseEvent.CLICK, generateTerrain);
			stage.addEventListener(MouseEvent.CLICK, resetResolution);
			stage.addEventListener(Event.ENTER_FRAME, updateResolution);
			stage.addEventListener(Event.ENTER_FRAME, updateText);
			stage.addEventListener(Event.ENTER_FRAME, renderTerrain);
		}
		
		private function keyHandler(e:KeyboardEvent):void {
			if (e.keyCode == 38) { // up
				smoothness += 0.1;
			} else if (e.keyCode == 40) { // down 
				smoothness -= 0.1;
			}
			
			smoothness = Math.max(0.1, Math.min(smoothness, 1));
			smoothness = Math.round(smoothness * 10) / 10;
			generateTerrain();
			resetResolution();
		}
		
		private function updateText(e:Event = null):void {
			iterationText.text = "iteration " + iteration;
			smoothnessText.text = "smoothness " + smoothness;
		}
		
		private function resetResolution(e:MouseEvent = null):void {
			resolution = 300;
			iteration = 1;
		}
		
		private function updateResolution(e:Event = null):void {
			iteration++;
			resolution /= 2;
			if (resolution < 1) {
				resetResolution();
			}
		
		}
		
		private function generateTerrain(e:MouseEvent = null):void {
			heightmap = MidpointDisplacement.generate(600, smoothness);
		}
		
		private function renderTerrain(e:Event = null):void {
			var commands:Vector.<int> = new Vector.<int>();
			var data:Vector.<Number> = new Vector.<Number>();
			
			for (var i:int = 0; i < heightmap.length; i += resolution) {
				if (i == 0) {
					commands.push(GraphicsPathCommand.MOVE_TO);
				} else {
					commands.push(GraphicsPathCommand.LINE_TO);
				}
				data.push(i, heightmap[i] * 200);
			}
			commands.push(GraphicsPathCommand.LINE_TO);
			data.push(600, heightmap[599] * 200);
			
			bitmap.bitmapData.draw(render, bmpMatrix);
			bitmap.bitmapData.colorTransform(bitmap.getRect(stage), filter);
			
			render.graphics.clear();
			render.graphics.lineStyle(2);
			render.graphics.lineGradientStyle(GradientType.LINEAR, [0x000080, 0x0066ff, 0xcc9933, 0x00cc00, 0x996600, 0xffffff], [1, 1, 1, 1, 1, 1], [0, 96, 96, 128, 168, 224], matrix);
			render.graphics.drawPath(commands, data);
		}
	}
}