package avdw.generate.noise.generator {
	import avdw.generate.noise.CInterpolate;
	import avdw.generate.noise.CSignal2D;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class CPerlin2D implements IGenerator2D {
		private var _frequency:Number = 1;
		private var _lacunarity:Number = 2;
		private var _ocaves:Number = 6;
		private var _persistence:Number = 0.5;
		private var _seed:uint = 0;
		private var _interpolationFunction:Function = CInterpolate.HERMITE;
		private var _noiseFunction:Function = CSignal2D.GRADIENT;
		
		public function CPerlin2D() {
		
		}
		
		public function set frequency(value:Number):void {
			_frequency = value;
		}
		
		public function set lacunarity(value:Number):void {
			_lacunarity = value;
		}
		
		public function set ocaves(value:Number):void {
			_ocaves = value;
		}
		
		public function set persistence(value:Number):void {
			_persistence = value;
		}
		
		public function set seed(value:uint):void {
			_seed = value;
		}
		
		public function set offset(value:Number):void {
			// not used
		}
		
		public function set gain(value:Number):void {
			// not used
		}
		
		public function set exponent(value:Number):void {
			// not used
		}
		
		public function set interpolationFunction(value:Function):void {
			_interpolationFunction = value;
		}
		
		public function set noiseFunction(value:Function):void {
			_noiseFunction = value;
		}
		
		public function value(x:Number, y:Number):Number {
			var value:Number = 0;
			var signal:Number = 0;
			var curPersistence:Number = 1.0;
			var seed:uint;
			
			x *= _frequency;
			y *= _frequency;
			
			for (var curOctave:int = 0; curOctave < _ocaves; curOctave++) {
				seed = (_seed + curOctave) & 0xffffffff;
				signal = _noiseFunction(x, y, seed, _interpolationFunction);
				value += signal * curPersistence;
				
				x *= _lacunarity;
				y *= _lacunarity;
				curPersistence *= _persistence;
			}
			
			return Math.min(1, Math.max(-1, value));
		}
	
	}

}