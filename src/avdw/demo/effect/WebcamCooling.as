package avdw.demo.effect {
	import as3isolib.graphics.BitmapFill;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="640",height="480",backgroundColor="0x0",frameRate="30")]
	
	public class WebcamCooling extends Sprite {
		private const zeroPoint:Point = new Point();
		private const rain:Rain = new Rain();
		private const snow:Snow = new Snow();
		private const outline:BitmapData = new BitmapData(640, 480);
		private const edgeFilter:ConvolutionFilter = new ConvolutionFilter(3, 3, [-1, -2, -1, -2, 12, -2, -1, -2, -1]);
		private var camera:Camera;
		private var video:Video;
		
		public function WebcamCooling() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (Camera.names.length > 0) {
				camera = Camera.getCamera();
				camera.setQuality(0, 50);
				camera.setMode(640, 480, 30, true);
			} else {
				throw new Error("no camera");
			}
			
			if (camera != null) {
				camera.addEventListener(StatusEvent.STATUS, statusHandler);
				video = new Video(camera.width, cam.height);
				video.attachCamera(camera);
			}
			
			rain.setCollisionBitmap(outline);
			snow.setCollisionBitmap(outline);
		}
		
		private function statusHandler(event:StatusEvent):void {
			switch (event.code) {
				case "Camera.Muted": 
					throw new Error("camera disabled");
					break;
				case "Camera.Unmuted": 
					addChild(video);
					addChild(rain);
					addChild(snow);
					addEventListener(Event.ENTER_FRAME, animate);
					break;
				default: 
					throw new Error("some problem " + event.code);
			}
			
			cam.removeEventListener(StatusEvent.STATUS, statusHandler);
		}
		
		private function animate(e:Event):void {
			outline.draw(video);
			outline.applyFilter(outline, outline.rect, zeroPoint, edgeFilter);
			
			rain.animate();
			snow.animate();
		}
	
	}

}
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Rectangle;

class Rain extends Sprite {
	private const raindrops:Vector.<RainDrop> = new Vector.<RainDrop>();
	private const pool:Vector.<RainDrop> = new Vector.<RainDrop>();
	private const bounds:Rectangle = new Rectangle(0, 0, 640, 480);
	private var collisionBitmap:BitmapData;
	
	public function setCollisionBitmap(bitmapData:BitmapData):void {
		collisionBitmap = bitmapData;
	}
	
	public function animate():void {
		if (pool.length > 0 && Math.random() < 0.05) {
			raindrops.push(pool.pop().reset());
		}
		
		var i:int = raindrops.length;
		while (--i >= 0) {
			if (raindrops[i].outsideBounds(bounds)) {
				pool.push(raindrops.splice(i, 1));
			} else if (raindrops[i].isDead) {
				pool.push(raindrops.splice(i, 1));
			} else {
				raindrops[i].collide(collisionBitmap);
				raindrops.update();
			}
		}
	}
}

class Snow extends Sprite {
	private const snowdrops:Vector.<SnowDrop> = new Vector.<SnowDrop>();
	private const pool:Vector.<SnowDrop> = new Vector.<SnowDrop>();
	private const bounds:Rectangle = new Rectangle(0, 0, 640, 480);
	private var collisionBitmap:BitmapData;
	
	public function setCollisionBitmap(bitmapData:BitmapData):void {
		collisionBitmap = bitmapData;
	}
	
	public function animate():void {
		if (pool.length > 0 && Math.random() < 0.05) {
			snowdrops.push(pool.pop().reset());
		}
		
		var i:int = snowdrops.length;
		while (--i >= 0) {
			if (snowdrops[i].outsideBounds(bounds)) {
				pool.push(snowdrops.splice(i, 1));
			} else if (snowdrops[i].isDead) {
				pool.push(snowdrops.splice(i, 1));
			} else {
				snowdrops[i].update(collisionBitmap);
			}
		}
	}
}