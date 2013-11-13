package avdw.game.sum2fifteen {
	import org.flixel.FlxGame;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="699",height="465",backgroundColor="0xFFFFFF",frameRate="30")]
	public class PlayGame extends FlxGame {
		
		public function PlayGame() {
			super(700, 465, PlayState);
		}
	
	}

}