package avdw.demo.particle {
	import avdw.generate.particle.Hanabi;
	import com.gskinner.utils.Rndm;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * Reference: http://wonderfl.net/c/rp2U
	 * Background: http://idesigniphone.net/wallpapers/04445.jpg 
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="320",height="480",backgroundColor="0x0",frameRate="30")]
	
	public class FireworksEffect extends Sprite {
		[Embed(source="../../../assets/320x480 Night Sky.jpg")]
		private const Background:Class;
		
		public function FireworksEffect() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(new Background());
			
			var hanabi:Hanabi = new Hanabi(stage.stageWidth, stage.stageHeight);
			addChild(hanabi);
			
			stage.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					hanabi.explode(mouseX, mouseY);
				});
			
			var timer:Timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
					hanabi.explode(Rndm.integer(50, stage.stageWidth - 50), Rndm.integer(50, 240));
				});
			timer.start();
		}
	}
}

