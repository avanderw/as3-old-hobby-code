package avdw.generate.terrain.dimension 
{
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class MathUtil 
	{
		
		/**
		 * Returns a number that will contain the value
		 * fitting the pattern 2n +1
		 * 
		 * @param	val
		 * @return
		 */
		public static function adjustUp(val:int):int {
			var size:int = 2;
			
			while (size + 1 < val) {
				size *= 2;
			}
			
			return size + 1;
		}
		
	}

}