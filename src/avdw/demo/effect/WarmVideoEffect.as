package avdw.demo.effect {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="320",height="240",backgroundColor="0",frameRate="30")]
	public class WarmVideoEffect extends Sprite {
		[Embed(source="../../../assets/256x240 Fire Colors.png")]
		private const FIRE_CLASS:Class;
		private const ZERO_POINT:Point = new Point();
		private const SPREAD:ConvolutionFilter = new ConvolutionFilter(3, 3, [0, 1, 0,  1, 1, 1,  0, 1, 0], 5);
		private const grey:BitmapData = new BitmapData(320, 240, false, 0x0);;
		private const cooling:BitmapData = new BitmapData(320, 240, false, 0x0);
		private const fire:BitmapData = new BitmapData(320, 240, false, 0x0);
		private const color:ColorMatrixFilter = new ColorMatrixFilter([
				0.16, 0, 0, 0, 0,
				0, 0.16, 0, 0, 0,
				0, 0, 0.16, 0, 0,
				0, 0, 0, 1, 0
			]);
		
		private var cam:Camera;
		private var vid:Video;
		private var offset:Array = [new Point(), new Point()];
		private var palette:Array;
		private var zeroArray:Array;
		
		public function WarmVideoEffect() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (Camera.names.length > 0) {
				cam = Camera.getCamera();
				cam.setQuality(0, 50);
				cam.setMode(320, 240, 30, true);
			} else {
				error();
			}
			
			if (cam != null) {
				cam.addEventListener(StatusEvent.STATUS, statusHandler);
				vid = new Video(cam.width, cam.height);
				vid.attachCamera(cam);
			}
			
			var fireColor:Bitmap = new FIRE_CLASS();
			palette = [];
			zeroArray = [];
			for (var i:int = 0; i < 256; i++) {
				palette.push(fireColor.bitmapData.getPixel(i, 0));
				zeroArray.push(0);
			}
			
			addEventListener(Event.ENTER_FRAME, animate);
		}
		
		private function statusHandler(event:StatusEvent):void {
			switch (event.code) {
				case "Camera.Muted": 
					error();
					break;
				case "Camera.Unmuted": 
					addChild(vid);
					addChild(new Bitmap(fire));
					break;
				default: 
					trace(event.code);
			}
			
			cam.removeEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		private function error():void {
		
		}
		
		
		private function animate(e:Event):void {
			grey.draw(vid);
			grey.applyFilter(grey, grey.rect, ZERO_POINT, SPREAD);
			cooling.perlinNoise(50, 50, 2, 982374, false, false, 0, true, offset);
			offset[0].x += 2.0;
			offset[1].y += 2.0;
			cooling.applyFilter(cooling, cooling.rect, ZERO_POINT, color);
			grey.draw(cooling, null, null, BlendMode.SUBTRACT);
			grey.scroll(0, -3);
			fire.paletteMap(grey, grey.rect, ZERO_POINT, palette, zeroArray, zeroArray, zeroArray);
		}
	}

}