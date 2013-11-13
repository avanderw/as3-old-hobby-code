package avdw.demo.effect {
	import avdw.generate.effect.MokuMoku;
	import com.bit101.components.Text;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	/**
	 * Reference: http://wonderfl.net/c/5hBU
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width=320,height=480,backgroundColor=0xFFFFFF,frameRate=30)]
	
	public class SmokeEffect extends Sprite {
		[Embed(source="../../../assets/320x480 Water Candle.jpg")]
		private const Background:Class;
		private var mokuMoku:MokuMoku;
		private var timer:Timer = new Timer(1000 / 20);
		
		public function SmokeEffect() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(new Background());
			
			mokuMoku = new MokuMoku(stage.stageWidth, stage.stageHeight, 75, 1);
			addChild(mokuMoku);
			
			mokuMoku.startEmitter(stage.stageWidth / 2, 200);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, down);
			stage.addEventListener(MouseEvent.MOUSE_UP, up);
			timer.start();
			
			var txt:TextField = new TextField();
			txt.text = "hold left-click to generate smoke";
			txt.textColor = 0xFFFFFF;
			txt.autoSize = TextFieldAutoSize.LEFT;
			addChild(txt);
		}
		
		private function up(e:MouseEvent):void {
			timer.removeEventListener(TimerEvent.TIMER, emitAtMouse);
		}
		
		private function down(e:MouseEvent):void {
			timer.addEventListener(TimerEvent.TIMER, emitAtMouse);
		}
		
		private function emitAtMouse(e:TimerEvent):void {
			mokuMoku.addSmoke(mouseX, mouseY);
		}
	
	}

}