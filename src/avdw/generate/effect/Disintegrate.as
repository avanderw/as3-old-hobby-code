package avdw.generate.effect {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * Reference: http://wonderfl.net/c/yFSI
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class Disintegrate {
		private var _bgSprite:Sprite;
		private var _displayData:BitmapData;
		private var _display:Bitmap;
		private var _particle:Bitmap;
		private var _twincle:Bitmap;
		
		private var _effectW:int;
		private var _effectH:int;
		private var _point:Point = new Point();
		private var _rect:Rectangle;
		private var _effectCount:int;
		//private var _shadow:DropShadowFilter = new DropShadowFilter(2, 90, 0x000000, 0.5, 32, 32, 1, 3);
		private var _particleColorTrans:ColorTransform = new ColorTransform(0.8, 0.85, 0.9);
		private var _particlePoint:Point;
		private var _twincleMatrix:Matrix;
		
		private var speedSet:Boolean = false;
		private var heatToleranceSet:Boolean = false;
		private var smoothnessSet:Boolean = false;
		private var burnToleranceSet:Boolean = false;
		private var framesSet:Boolean = false;
		private var burnColorSet:Boolean = false;
		private var particleMarginSet:Boolean = false;
		private var twinkleAlphaSet:Boolean = false;
		private var twinkleSizeSet:Boolean = false;
		private var particleSpeedSet:Boolean = false;
		
		private var _heatTolerance:int;
		private var _smoothness:int;
		private var _burnTolerance:Number;
		private var _frames:int;
		private var _burnColor:uint;
		private var _particleMargin:int;
		
		private var _baseData:BitmapData;
		private var _clear:BitmapData;
		private var _black:BitmapData;
		private var _cloud:BitmapData;
		private var _card:BitmapData;
		private var _fire:BitmapData;
		private var _fireClear:BitmapData;
		private var _noise:BitmapData;
		private var _particleMask:BitmapData;
		private var _particleFire:BitmapData;
		private var _particleDisplay:BitmapData;
		private var _twincleDisplay:BitmapData;
		
		private var parent:DisplayObjectContainer;
		private var childIndex:int;
		private var displayObject:DisplayObject;
		private var timer:Timer;
		
		public function Disintegrate():void {
			_display = new Bitmap();
			//_display.filters = [_shadow];
			
			_particle = new Bitmap();
			_particle.blendMode = BlendMode.ADD;
			
			_twincle = new Bitmap();
			_twincle.blendMode = BlendMode.ADD;
		}
		
		/**
		 * The vertical direction and speed the particles will move.
		 *
		 * @param	speed
		 * @return
		 */
		public function particleSpeed(speed:Number = -1):Disintegrate {
			_particlePoint = new Point(0, speed);
			
			particleSpeedSet = true;
			return this;
		}
		
		/**
		 * Size of the twinkle on the particles.
		 *
		 * @param	size
		 * @return
		 */
		public function twinkleSize(size:int = 4):Disintegrate {
			_twincle.scaleX = _twincle.scaleY = size;
			_twincleMatrix = new Matrix(1 / size, 0, 0, 1 / size);
			
			twinkleSizeSet = true;
			return this;
		}
		
		/**
		 * If you look closely, you will see a twinkle effect on the particles.
		 * Setting this to 1 will make it much more apparent.
		 *
		 * @param	alpha range of [0 : 1]
		 * @return
		 */
		public function twinkleAlpha(alpha:Number = 0.5):Disintegrate {
			_twincle.alpha = Math.max(0, Math.min(1, alpha));
			
			twinkleAlphaSet = true;
			return this;
		}
		
		/**
		 * Used in conjuntion with the particle speed.
		 * This determines where the particles are clipped, relative to the image.
		 *
		 * @param	margin range of [0:~]
		 * @return
		 */
		public function particleMargin(margin:int = 15):Disintegrate {
			_particleMargin = Math.max(0, margin);
			
			particleMarginSet = true;
			return this;
		}
		
		/**
		 * This is the color of the burn and not the particles.
		 *
		 * @param	color
		 * @return
		 */
		public function burnColor(color:uint = 0xFFFFFFFF):Disintegrate {
			_burnColor = color;
			
			burnColorSet = true;
			return this;
		}
		
		/**
		 * The length of the animation in frames. Similar effects to speed, but more severe.
		 *
		 * @param	amount
		 * @return
		 */
		public function frames(amount:int = 150):Disintegrate {
			_frames = amount;
			
			framesSet = true;
			return this;
		}
		
		/**
		 * This affects strength of the vertical gradient that is applied,
		 * which allows the affect to burn from the top to the bottom of the
		 * display object.
		 *
		 * @param	amount Alpha of the gradient applied, range [0:1]
		 * @return
		 */
		public function burnTolerance(amount:Number = 0.5):Disintegrate {
			_burnTolerance = Math.max(0, Math.min(1, amount));
			
			burnToleranceSet = true;
			return this;
		}
		
		/**
		 * Octaves for the perlin noise, affects how smooth the burn is
		 *
		 * @param	amount
		 * @return
		 */
		public function smoothness(amount:int = 8):Disintegrate {
			_smoothness = amount;
			
			smoothnessSet = true;
			return this;
		}
		
		/**
		 * Resolution for the perlin noise, affects size of burn areas
		 *
		 * @param	amount
		 * @return
		 */
		public function heatTolerance(amount:int = 150):Disintegrate {
			_heatTolerance = amount;
			
			heatToleranceSet = true;
			return this;
		}
		
		/**
		 * Framerate that the timer will run at, capped at range [1:50]
		 *
		 * @param	fps
		 * @return
		 */
		public function speed(fps:int = 30):Disintegrate {
			fps = Math.max(Math.min(50, fps), 1);
			
			timer = new Timer(1000 / fps);
			timer.addEventListener(TimerEvent.TIMER, animate);
			
			speedSet = true;
			return this;
		}
		
		/**
		 * Will execute the effect on the displayObject provided
		 *
		 * @param	displayObject
		 */
		public function disintegrate(displayObject:DisplayObject):void {
			if (!speedSet)
				speed();
			if (!heatToleranceSet)
				heatTolerance();
			if (!smoothnessSet)
				smoothness();
			if (!burnToleranceSet)
				burnTolerance();
			if (!framesSet)
				frames();
			if (!burnColorSet)
				burnColor();
			if (!particleMarginSet)
				particleMargin();
			if (!twinkleAlphaSet)
				twinkleAlpha();
			if (!twinkleSizeSet)
				twinkleSize();
			if (!particleSpeedSet)
				particleSpeed();
			
			this.displayObject = displayObject;
			parent = displayObject.parent;
			childIndex = parent.getChildIndex(displayObject);
			parent.removeChild(displayObject);
			
			// below has been reversed, because of child index
			parent.addChildAt(_particle, childIndex); 
			parent.addChildAt(_twincle, childIndex);
			parent.addChildAt(_display, childIndex);
			
			_effectW = Math.ceil(displayObject.width);
			_effectH = Math.ceil(displayObject.height) + _particleMargin * 2;
			_rect = new Rectangle(0, 0, _effectW, _effectH);
			
			_clear = new BitmapData(_effectW, _effectH, true, 0x00000000);
			_black = new BitmapData(_effectW, _effectH, true, 0xff000000);
			_displayData = _clear.clone();
			_display.bitmapData = _displayData;
			_baseData = _clear.clone();
			_baseData.draw(displayObject, new Matrix(1, 0, 0, 1, 0, _particleMargin));
			_card = _black.clone();
			_card.copyPixels(_baseData, _rect, _point, null, null, true);
			_fireClear = new BitmapData(_effectW, _effectH, true, _burnColor);
			_fire = _fireClear.clone();
			_particleMask = _black.clone();
			_particleFire = _fireClear.clone();
			_particleDisplay = _clear.clone();
			_particle.bitmapData = _particleDisplay;
			_twincleDisplay = new BitmapData(_effectW / 4, _effectH / 4, true, 0x00000000);
			_twincle.bitmapData = _twincleDisplay;
			_twincle.smoothing = true;
			// 中央に配置
			_display.x = displayObject.x;
			_display.y = displayObject.y - _particleMargin;
			_particle.x = displayObject.x;
			_particle.y = displayObject.y - _particleMargin;
			_twincle.x = displayObject.x;
			_twincle.y = displayObject.y - _particleMargin;
			
			// 雲模様の作成
			_cloud = new BitmapData(_effectW, _effectH);
			_cloud.perlinNoise(_heatTolerance, _heatTolerance, _smoothness, int(Math.random() * 500), false, true, 0, true);
			var tmpGradient:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(_effectW, _effectH, Math.PI / 2, 0, 0);
			tmpGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0xffffff], [_burnTolerance, _burnTolerance], [0, 255], matrix);
			tmpGradient.graphics.drawRect(0, 0, _effectW, _effectH);
			_cloud.draw(tmpGradient);
			
			// ノイズの作成
			var originalNoise:BitmapData = _clear.clone();
			originalNoise.noise(int(Math.random() * int.MAX_VALUE), 0, 255, 7, true);
			_noise = _black.clone();
			
			_noise.threshold(originalNoise, _rect, _point, ">", 0x00f00000, 0x00000000, 0x00ff0000, false);
			
			// フレーム開始
			_effectCount = 0;
			
			animate();
			timer.start();
		}
		
		/**
		 * Will stop the timer and thus the animation
		 *
		 * @return
		 */
		public function pause():Disintegrate {
			timer.stop();
			
			return this;
		}
		
		/**
		 * Will resume the timer and thus the animation
		 * @return
		 */
		public function resume():Disintegrate {
			timer.start();
			
			return this;
		}
		
		/**
		 * Not yet implemented, but will eventually reverse the animation
		 *
		 * @return
		 */
		public function reverse():Disintegrate {
			return this;
		}
		
		/**
		 * Executed on each timer event
		 *
		 * @param	e
		 */
		private function animate(e:TimerEvent = null):void {
			_effectCount++;
			
			_displayData.lock();
			_particleDisplay.lock();
			
			_displayData.copyPixels(_black, _rect, _point);
			var threshold:int = _effectCount * 0xff0000 / _frames;
			//_card.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			_displayData.copyPixels(_card, _rect, _point);
			
			_fire.copyPixels(_fireClear, _rect, _point);
			_fire.threshold(_cloud, _rect, _point, ">", threshold, 0x00000000, 0x00ff0000, false);
			threshold = (_effectCount - 1) * 0xff0000 / _frames;
			_fire.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			
			_displayData.copyPixels(_fire, _rect, _point, null, null, true);
			_displayData.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_displayData.threshold(_cloud, _rect, _point, "<", threshold, 0x00000000, 0x00ff0000, false);
			
			_particleMask.copyPixels(_black, _rect, _point);
			_fire.copyChannel(_baseData, _rect, _point, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			_particleMask.copyPixels(_fire, _rect, _point, null, null, true);
			_particleMask.copyPixels(_noise, _rect, _point, null, null, true);
			
			_particleFire.copyPixels(_fireClear, _rect, _point);
			_particleFire.copyChannel(_particleMask, _rect, _point, BitmapDataChannel.RED, BitmapDataChannel.ALPHA);
			
			_particleDisplay.copyPixels(_particleFire, _rect, _point, null, null, true);
			_particleDisplay.colorTransform(_rect, _particleColorTrans);
			_particleDisplay.copyPixels(_particleDisplay, _rect, _particlePoint);
			
			_twincleDisplay.copyPixels(_clear, _rect, _point);
			_twincleDisplay.draw(_particleDisplay, _twincleMatrix);
			
			_displayData.unlock();
			_particleDisplay.unlock();
			
			if (_frames <= _effectCount)
				complete();
		}
		
		/**
		 * Reset state and fire event to notify end of animation
		 */
		private function complete():void {
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, animate);
			
			_displayData.copyPixels(_clear, _rect, _point);
			_particleDisplay.copyPixels(_clear, _rect, _point);
			
			parent.removeChild(_display);
			parent.removeChild(_particle);
			parent.removeChild(_twincle);
			
			parent.addChildAt(displayObject, Math.min(childIndex, parent.numChildren));
			displayObject.dispatchEvent(new Event(Event.COMPLETE));
		}
	}

}