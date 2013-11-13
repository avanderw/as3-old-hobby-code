package avdw.generate.terrain.dimension.two {
	import com.gskinner.utils.Rndm;
	
	/**
	 * NOTE: Seeding random number generator
	 * 
	 * Reference: http://code.google.com/p/fractalterraingeneration/wiki/Value_Noise
	 * 
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class ValueNoise {
		public static const LINEAR:int = 0;
		public static const COSINE:int = 1;
		public static const CUBIC:int = 2;
		
		private static var _seed:Number;
		private static var _size:int;
		
		public static function generate(size:int, detail:int = 12, roughness:Number = 0.65, type:int = COSINE, seed:Number = Number.NaN):Vector.<Vector.<Number>> {
			if (isNaN(seed)) {
				seed = Math.random() * 0xFFFFFF;
			}
			
			_seed = seed;
			_size = size;
			
			var heightmap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			
			// init
			for (i = 0; i < size; i++) {
				var rowData:Vector.<Number> = new Vector.<Number>();
				for (j = 0; j < size; j++) {
					rowData.push(0);
				}
				heightmap.push(rowData);
			}
			
			var i:int, j:int, count:int;
			var octaves:int;
			var presistance:Number, total:Number, frequency:Number, amplitude:Number;
			var min:Number = Number.POSITIVE_INFINITY;
			var max:Number = Number.NEGATIVE_INFINITY;
			
			// process
			for (i = 0; i < size; i++) {
				for (j = 0; j < size; j++) {
					total = 0;
					frequency = 1 / size;
					amplitude = roughness;
					
					for (count = 0; count < detail; count++) {
						total += smoothedNoise(i * frequency, j * frequency, type)* amplitude;
						
						frequency *= 2;
						amplitude *= roughness;
					}
					
					heightmap[i][j] = total;
					
					min = Math.min(min, total);
					max = Math.max(max, total);
				}
			}
			
			// normalize
			var range:Number = max - min;
			for (i = 0; i < size; i++) {
				for (j = 0; j < size; j++) {
					heightmap[i][j] = (heightmap[i][j] - min) / range;
				}
			}
			
			return heightmap;
		}
		
		private static function smoothedNoise(x:Number, y:Number, type:int):Number {
			var int_x:int = int(x);
			var int_y:int = int(y);
			
			var rem_x:Number = x - int_x;
			var rem_y:Number = y - int_y;
			var v1:Number, v2:Number, v3:Number, v4:Number, t1:Number, t2:Number;
			
			var value:Number;
			
			switch (type) {
				case LINEAR: 
					v1 = random(int_x, int_y);
					v2 = random(int_x + 1, int_y);
					v3 = random(int_x, int_y + 1);
					v4 = random(int_x + 1, int_y + 1);
					
					t1 = linear(v1, v2, rem_x);
					t2 = linear(v3, v4, rem_x);
					value = linear(t1, t2, rem_y);
					break;
				case COSINE: 
					v1 = random(int_x, int_y);
					v2 = random(int_x + 1, int_y);
					v3 = random(int_x, int_y + 1);
					v4 = random(int_x + 1, int_y + 1);
					
					t1 = cosine(v1, v2, rem_x);
					t2 = cosine(v3, v4, rem_x);
					value = cosine(t1, t2, rem_y);
					break;
				case CUBIC: 
					//as above, we must interpolate twice on the x-axis, then once between the two results on the y-axis
					//this is much more difficult than before because cubic interpolation requires 4 vertices each time,
					//so we really have to interpolate 4 times on the x-axis, then once between the 4 results on the y-axis
					var t3:Number, t4:Number;
					
					//	y-1
					v1 = random(int_x - 1, int_y - 1);
					v2 = random(int_x, int_y - 1);
					v3 = random(int_x + 1, int_y - 1);
					v4 = random(int_x + 2, int_y - 1);
					
					t1 = cubic(v1, v2, v3, v4, rem_x);
					
					//	y
					v1 = random(int_x - 1, int_y);
					v2 = random(int_x, int_y);
					v3 = random(int_x + 1, int_y);
					v4 = random(int_x + 2, int_y);
					
					t2 = cubic(v1, v2, v3, v4, rem_x);
					
					//	y+1
					v1 = random(int_x - 1, int_y + 1);
					v2 = random(int_x, int_y + 1);
					v3 = random(int_x + 1, int_y + 1);
					v4 = random(int_x + 2, int_y + 1);
					
					t3 = cubic(v1, v2, v3, v4, rem_x);
					
					//	y+2
					v1 = random(int_x - 1, int_y + 2);
					v2 = random(int_x, int_y + 2);
					v3 = random(int_x + 1, int_y + 2);
					v4 = random(int_x + 2, int_y + 2);
					
					t4 = cubic(v1, v2, v3, v4, rem_x);
					
					//now, interpolate between all these
					value = cubic(t1, t2, t3, t4, rem_y);
					break;
			}
			
			return value;
		}
		
		private static function random(x:int, y:int):Number {
			Rndm.seed = Math.pow(x + _seed, Math.E)  + Math.pow(y + _size, Math.E) ;
			
			return Rndm.random();
		}
		
		private static function linear(x1:Number, x2:Number, a:Number):Number {
			return (x1 * (1 - a) + x2 * a);
		}
		
		private static function cosine(x1:Number, x2:Number, a:Number):Number {
			//not 100% sure how this one works
			var temp:Number;
			temp = (1.0 - Math.cos(a * 3.1415927)) / 2.0;
			
			return (x1 * (1.0 - temp) + x2 * temp);
		}
		
		private static function cubic(x1:Number, x2:Number, x3:Number, x4:Number, a:Number):Number {
			//I honestly have no idea how this works
			var c1:Number, c2:Number, c3:Number, c4:Number;
			c1 = x4 - x3 - x1 + x2;
			c2 = x1 - x2 - c1;
			c3 = x3 - x1;
			c4 = x2;
			
			return (c1 * a * a * a + c2 * a * a + c3 * a + c4);
		}
	}

}