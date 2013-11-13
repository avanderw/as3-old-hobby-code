package avdw.demo.effect {
	import avdw.generate.effect.Electricity;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="400",height="400",backgroundColor="0x000000",frameRate="30")]
	
	public class ElectricityEffect extends Sprite {
		// http://thumbs.dreamstime.com/thumblarge_443/1255191133v3470Z.jpg
		[Embed(source = "../../../assets/400x400 Hands.jpg")]
		private var Picture:Class;
		
		public function ElectricityEffect() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(new Picture());
			
			var effect1:Electricity = new Electricity();
			effect1.between(new Point(260, 70), new Point(140, 330)).turnOn().unstable();
			addChild(effect1);
			
			var effect2:Electricity = new Electricity();
			effect2.between(new Point(260, 70), new Point(140, 330)).turnOn().unstable();
			addChild(effect2);
			
			var effect3:Electricity = new Electricity();
			effect3.between(new Point(70, 140), new Point(330, 260)).turnOn().unstable();
			addChild(effect3);
			
			var effect4:Electricity = new Electricity();
			effect4.between(new Point(70, 140), new Point(330, 260)).turnOn().unstable();
			addChild(effect4);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				effect1.stable();
				effect2.stable();
				effect3.stable();
				effect4.stable();
			});
			
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
				effect1.unstable();
				effect2.unstable();
				effect3.unstable();
				effect4.unstable();
			});
			
			
			var text:TextField = new TextField();
			text.text = "Click the image to stabilize the beams";
			text.autoSize = TextFieldAutoSize.LEFT;
			text.background = true;
			text.backgroundColor = 0xEEEEEE;
			addChild(text);
		}
	
	}

}