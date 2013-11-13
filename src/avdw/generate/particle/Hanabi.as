package avdw.generate.particle {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * Reference: http://wonderfl.net/c/rp2U
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class Hanabi extends Sprite {
		private const colorTransform:ColorTransform = new ColorTransform(.8, .8, .9, .8);
		private const particles:Vector.<Particle> = new Vector.<Particle>();
		private const blur:BlurFilter = new BlurFilter(1, 1);
		private const zero:Point = new Point();
		
		private var canvas:Bitmap;
		private var glow:Bitmap;
		private var explosionSize:int;
		
		private var animationTimer:Timer;
		private var changeColorTransformTimer:Timer;
		
		public function Hanabi(width:int, height:int, fps:int = 30, explosionSize:int = 10) {
			this.explosionSize = explosionSize;
			
			canvas = new Bitmap(new BitmapData(width, height, true, 0x0));
			
			glow = new Bitmap(new BitmapData(width / 4, height / 4, true, 0x0), PixelSnapping.NEVER, true);
			glow.scaleX = glow.scaleY = 4;
			glow.blendMode = BlendMode.ADD;
			
			addChild(canvas);
			addChild(glow);
			
			animationTimer = new Timer(1000 / Math.min(60, Math.max(1, fps)));
			animationTimer.addEventListener(TimerEvent.TIMER, animate);
			animationTimer.start();
			
			changeColorTransformTimer = new Timer(100);
			changeColorTransformTimer.addEventListener(TimerEvent.TIMER, changeColorTransform);
			changeColorTransformTimer.start();
		}
		
		private function changeColorTransform(e:TimerEvent):void {
			(colorTransform.redMultiplier > 0.9) ? colorTransform.redMultiplier = 0.8 : colorTransform.redMultiplier += 0.01;
		}
		
		public function explode(x:int, y:int):void {
			var i:int = 200;
			while (i--)
				createParticle(x, y);
		}
		
		private function createParticle(x:int, y:int):void {
			var p:Particle = new Particle();
			p.x = x;
			p.y = y;
			
			var radius:Number = Math.sqrt(Math.random()) * explosionSize;
			var angle:Number = Math.random() * (Math.PI) * 2;
			p.vx = Math.cos(angle) * radius;
			p.vy = Math.sin(angle) * radius;
			
			particles.push(p);
		}
		
		private function animate(e:TimerEvent):void {
			canvas.bitmapData.lock();
			canvas.bitmapData.applyFilter(canvas.bitmapData, canvas.bitmapData.rect, zero, blur);
			canvas.bitmapData.colorTransform(canvas.bitmapData.rect, colorTransform);
			
			var i:int = particles.length;
			while (i--) { // backwards to alleviate removing items whilst iterating through vector
				var p:Particle = particles[i];
				p.vy += 0.2; // gravity
				p.vx *= 0.9; // drag
				p.vy *= 0.9; // drag
				p.x += p.vx;
				p.y += p.vy;
				canvas.bitmapData.setPixel32(p.x, p.y, p.c);
				
				// remove pixels that are offstage / that are too slow in either direction
				if ((p.x > canvas.bitmapData.width || p.x < 0) || (p.y < 0 || p.y > canvas.bitmapData.height) || Math.abs(p.vx) < .01 || Math.abs(p.vy) < .01) {
					particles.splice(i, 1);
				}
			}
			
			canvas.bitmapData.unlock();
			
			// think the below also loses detail and causes the glow to only happen on some particles
			// the never pixel snapping setting will remove the pixels on resize
			glow.bitmapData.fillRect(glow.bitmapData.rect, 0x0);
			glow.bitmapData.draw(canvas.bitmapData, new Matrix(0.25, 0, 0, 0.25));
		}
		
		public function destroy():void {
			changeColorTransformTimer.stop();
			changeColorTransformTimer.removeEventListener(TimerEvent.TIMER, changeColorTransform);
			
			animationTimer.stop();
			animationTimer.removeEventListener(TimerEvent.TIMER, animate);
		}
	
	}

}

class Particle {
	public var x:Number;
	public var y:Number;
	public var vx:Number;
	public var vy:Number;
	public var c:uint;
	
	public function Particle() {
		this.x = 0;
		this.y = 0;
		this.vx = 0;
		this.vy = 0;
		this.c = 0xFFFFFFFF;
	}
}