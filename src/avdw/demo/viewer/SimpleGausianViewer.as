package avdw.demo.viewer {
	import avdw.viewer.GausianViewer;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="400",height="300",backgroundColor="0xFFFFFF",frameRate="30")]
	public class SimpleGausianViewer extends Sprite {
		
		public function SimpleGausianViewer() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var viewer:GausianViewer = new GausianViewer(stage.stageWidth*0.8, stage.stageHeight*0.8);
			addChild(viewer);
			
			viewer.x = (stage.stageWidth - viewer.width) / 2;
			viewer.y = (stage.stageHeight - viewer.height) / 2;
			
			viewer.add(30, 3.25, "Andrew");
			viewer.add(25, 8.33, "Shantelle");
			viewer.add(33, 5.97, "Bianca");
			viewer.add(7, 3.16, "2x Dice");
			/*viewer.add(Math.random(), Math.random(), "4");
			viewer.add(Math.random(), Math.random(), "5");
			viewer.add(Math.random(), Math.random(), "6");
			viewer.add(Math.random(), Math.random(), "7");
			viewer.add(Math.random(), Math.random(), "8");*/
			
			viewer.plot();
			
		}
	
	}

}