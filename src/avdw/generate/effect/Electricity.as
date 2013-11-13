package avdw.generate.effect {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * TODO: Scaling the range with the length better
	 * 
	 * Reference: http://wonderfl.net/c/miZT
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class Electricity extends Sprite {
		private const unstableFilters:Array = [new GlowFilter(0xffffff, 0.5, 16, 16, 1, 1), new GlowFilter(0xffff00, 1, 8, 8, 1, 1), new DropShadowFilter(0, 90, 0xcc3300, 1, 64, 64, 5, 3)];
		private const stableFilters:Array = [new GlowFilter(0xffffff, 0.5, 16, 16, 1, 1), new GlowFilter(0x00ffff, 1, 8, 8, 1, 1), new DropShadowFilter(0, 90, 0x0033CC, 1, 64, 64, 5, 3)];
		
		private var speedSet:Boolean = false;
		private var betweenSet:Boolean = false;
		private var noiseSet:Boolean = false;
		private var filtersSet:Boolean = false;
		
		private var timer:Timer;
		private var point1:Point;
		
		private var perlinNoise:BitmapData;
		private var noiseRange:int;
		private var noiseMask:int;
		private var pattern:int;
		private var length:Number;
		private var ry:int = 0;
		private var rx:int = 0;
		private var vx:Number = 0;
		private var vy:Number = 1;
		
		public function between(point1:Point, point2:Point):Electricity {
			this.point1 = point1;
			
			var _dx:Number = point2.x - point1.x;
			var _dy:Number = point2.y - point1.y;
			var _len:Number = Math.sqrt(_dx * _dx + _dy * _dy);
			if (_len != 0) {
				length = _len;
				vx = _dx / length;
				vy = _dy / length;
			}
			
			betweenSet = true;
			return this;
		}
		
		private function noise(power:int = 7):Electricity {
			noiseRange = 1 << power;
			noiseMask = noiseRange - 1;
			
			perlinNoise = new BitmapData(noiseRange, noiseRange);
			// check octaves vs noise
			perlinNoise.perlinNoise(noiseRange, noiseRange, 8, Math.floor(Math.random() * 0xFFFFFF), true, true, BitmapDataChannel.BLUE);
			normalize(perlinNoise); // only using blue channel (8bit max val 0xFF [255])
			
			noiseSet = true;
			return this;
		}
		
		public function stable():Electricity {
			pattern = 1;
			filters = stableFilters;
			
			filtersSet = true;
			return this;
		}
		
		public function unstable():Electricity {
			pattern = 0;
			filters = unstableFilters;
			
			filtersSet = true;
			return this;
		}
		
		public function speed(fps:int = 30):Electricity {
			fps = Math.max(Math.min(50, fps), 1);
			
			timer = new Timer(1000 / fps);
			timer.addEventListener(TimerEvent.TIMER, animate);
			
			speedSet = true;
			return this;
		}
		
		private function animate(e:TimerEvent):void {
			if (pattern == 0) {
				rx += Math.floor(Math.random() * 4);
				ry = Math.floor(Math.random() * noiseRange);
			} else {
				rx++;
				ry += 2;
			}
			rx &= noiseMask;
			ry &= noiseMask;
			var colBase:int = perlinNoise.getPixel(rx, ry) & 0xff;
			graphics.clear();
			graphics.lineStyle(Math.floor(Math.random() * 4) + 1, 0xffffff);
			var _x:Number = point1.x;
			var _y:Number = point1.y;
			graphics.moveTo(_x, _y);
			for (var i:int = 1; i < noiseRange; i++) {
				var c:int = (perlinNoise.getPixel((rx + i) & noiseMask, ry) & 0xff) - colBase;
				graphics.lineTo(_x + c * vy, _y + c * -vx);
				_x += vx * length / noiseRange;
				_y += vy * length / noiseRange;
			}
		}
		
		public function turnOn():Electricity {
			if (!betweenSet) {
				throw new Error("you need to set the points the electricity will flow between");
			}
			if (!speedSet) {
				speed();
			}
			if (!noiseSet) {
				noise();
			}
			if (!filtersSet) {
				unstable();
			}
			timer.start();
			
			return this;
		}
		
		public function turnOff():Electricity {
			timer.stop();
			
			return this;
		}
		
		public function destroy():Electricity {
			betweenSet = false;
			speedSet = false;
			noiseSet = false;
			
			timer = null;
			point1 = null;
			
			perlinNoise = null;
			
			ry = 0;
			rx = 0;
			vx = 0;
			vy = 1;
			
			return this;
		}
		
		private function normalize(data:BitmapData, range:int = 255):void {
			var min:int = range;
			var max:int = 0;
			for (var i:int = 0; i < data.height; i++) {
				for (var j:int = 0; j < data.width; j++) {
					var col:int = data.getPixel(j, i);
					if (col < min)
						min = col;
					if (col > max)
						max = col;
				}
			}
			if (max == 0)
				return;
			for (i = 0; i < data.height; i++) {
				for (j = 0; j < data.width; j++) {
					col = (data.getPixel(j, i) & 0xff) - min;
					col = col * range / max;
					data.setPixel(j, i, col);
				}
			}
		}
	}

}