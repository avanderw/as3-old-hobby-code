package avdw.generate.terrain.dimension.two {
	import flash.geom.Point;
	import com.gskinner.utils.Rndm;
	import avdw.generate.terrain.dimension.MathUtil;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class MidpointDisplacement {
		/**
		 *
		 * @param	size
		 * @param	smoothness
		 * @param	seed
		 * @return
		 */
		public static function generate(size:int, smoothness:Number = 1, seed:Number = Number.NaN):Vector.<Vector.<Number>> {
			if (isNaN(seed)) {
				seed = Math.random() * 0xFFFFFF;
			}
			smoothness = Math.max(Math.min(1, smoothness), 0);
			
			var i:int, j:int;
			var heightmap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			var length:int = MathUtil.isPowerOfTwo(size-1) ? size : MathUtil.adjustUp(size);
			
			// init
			for (i = 0; i < length; i++) {
				var rowData:Vector.<Number> = new Vector.<Number>();
				for (j = 0; j < length; j++) {
					rowData.push(0);
				}
				heightmap.push(rowData);
			}
			
			// setup
			Rndm.seed = seed;
			heightmap[0][0] = Rndm.random();
			heightmap[0][length - 1] = Rndm.random();
			heightmap[length - 1][length - 1] = Rndm.random();
			heightmap[length - 1][0] = Rndm.random();
			
			// new Point(row, col);
			var toProcess:Vector.<Object> = new Vector.<Object>();
			toProcess.push(new Point(0, 0), new Point(length - 1, length - 1), smoothness);
			
			// process
			var min:Number = Math.min(heightmap[0][0], heightmap[0][length - 1], heightmap[length - 1][length - 1], heightmap[length - 1][0]);
			var max:Number = Math.max(heightmap[0][0], heightmap[0][length - 1], heightmap[length - 1][length - 1], heightmap[length - 1][0]);
			while (toProcess.length != 0) {
				var topLeft:Point = toProcess.shift() as Point;
				var bottomRight:Point = toProcess.shift() as Point;
				var offset:Number = toProcess.shift() as Number;
				var midpoint:Point = new Point((topLeft.x + bottomRight.x) / 2, (topLeft.y + bottomRight.y) / 2);
				
				heightmap[topLeft.x][midpoint.y] = (heightmap[topLeft.x][topLeft.y] + heightmap[topLeft.x][bottomRight.y]) / 2;
				heightmap[midpoint.x][bottomRight.y] = (heightmap[topLeft.x][bottomRight.y] + heightmap[bottomRight.x][bottomRight.y]) / 2;
				heightmap[bottomRight.x][midpoint.y] = (heightmap[bottomRight.x][bottomRight.y] + heightmap[bottomRight.x][topLeft.y]) / 2;
				heightmap[midpoint.x][topLeft.y] = (heightmap[bottomRight.x][topLeft.y] + heightmap[topLeft.x][topLeft.y]) / 2;
				heightmap[midpoint.x][midpoint.y] = ((heightmap[topLeft.x][topLeft.y] + heightmap[topLeft.x][bottomRight.y] + heightmap[bottomRight.x][bottomRight.y] + heightmap[bottomRight.x][topLeft.y]) / 4) + Rndm.float(-offset, offset);
				
				min = Math.min(heightmap[midpoint.x][midpoint.y], min);
				max = Math.max(heightmap[midpoint.x][midpoint.y], max);
				
				// terminating condition
				if (bottomRight.x - midpoint.x != 1) { // square so no need to check column diff
					offset = offset / Math.pow(2, smoothness); // reduce randomness
					toProcess.push(topLeft, midpoint, offset);
					toProcess.push(new Point(topLeft.x, midpoint.y), new Point(midpoint.x, bottomRight.y), offset);
					toProcess.push(midpoint, bottomRight, offset);
					toProcess.push(new Point(midpoint.x, topLeft.y), new Point(bottomRight.x, midpoint.y), offset);
				}
			}
			
			// clip length
			heightmap = heightmap.slice(0, size);
			for (i = 0; i < size; i++) {
				heightmap[i] = heightmap[i].slice(0, size);
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
	
	}

}