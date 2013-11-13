package avdw.demo.effect {
	import com.gskinner.utils.Rndm;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Reference: http://www.complexification.net/gallery/machines/sandstroke/
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="500",height="500",backgroundColor="0xFFFFFF",frameRate="30")]
	public class SandStrokeEffect extends Sprite {
		[Embed(source="../../../assets/100x1 Complexification - longcolor.png")]
		private const LongColor:Class;
		private var k:int = 22;
		private var sweeps:Vector.<Sweep>;
		private const goodcolor:Vector.<uint> = new Vector.<uint>();
		private var bmp:Bitmap;
		
		public function SandStrokeEffect() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			bmp = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight));
			addChild(bmp);
			
			var count:int;
			var b:Bitmap = new LongColor();
			
			// extract color
			for (count = 0; count < b.width; count++) {
				goodcolor.push(b.bitmapData.getPixel(count, 0));
			}
			// pad with whites
			for (count = 0; count < 6; count++) {
				goodcolor.push(0xFFFFFF);
			}
			// pad with blacks
			for (count = 0; count < 6; count++) {
				goodcolor.push(0x000000);
			}
			
			sweeps = new Vector.<Sweep>();
			var g:int = int(stage.stageWidth / k);
			for (count = 0; count < k; count++) {
				sweeps.push(new Sweep(0, Rndm.float(stage.stageHeight), g * 10, bmp.bitmapData, goodcolor));
			}
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function loop(e:Event):void {
			for each (var sweep:Sweep in sweeps) {
				sweep.render(stage.stageWidth);
			}
		}
	
	}

}
import flash.display.BitmapData;
import com.gskinner.utils.Rndm;

class Sweep {
	// feet
	private var ox:Number, oy:Number;
	private var x:Number, y:Number;
	private var vx:Number;
	
	private var ogage:Number;
	private var gage:Number;
	
	private var myc:uint;
	
	private var time:Number;
	private var sc:Number, sg:Number;
	
	private var _bmpData:BitmapData;
	private var goodcolor:Vector.<uint>;
	
	public function Sweep(X:Number, Y:Number, Gage:Number, bmpData:BitmapData, goodcolors:Vector.<uint>) {
		// init
		_bmpData = bmpData;
		this.goodcolor = goodcolors;
		ox = x = X;
		oy = y = Y;
		ogage = gage = Gage;
		
		// randomize limb properties
		selfinit();
	}
	
	private function selfinit():void {
		// init color sweeps
		myc = goodcolor[Rndm.integer(goodcolor.length)];
		sg = Rndm.float(0.01, 0.1);
		x = ox;
		y = oy;
		gage = ogage;
		vx = 1.0;
	}
	
	public function render(width:int):void {
		// move through time
		x += vx;
		if (x > width)
			selfinit();
		
		tpoint(int(x), int(y), myc, 0.07);
		
		sg += Rndm.float(-0.042, 0.042);
		
		if (sg < -0.3) {
			sg = -0.3;
		} else if (sg > 0.3) {
			sg = 0.3;
		} else if ((sg > -0.01) && (sg < 0.01)) {
			if (Rndm.random() < 0.01)
				myc = goodcolor[Rndm.integer(goodcolor.length)];
		}
		
		var wd:Number = 200;
		var w:Number = sg / wd;
		_bmpData.lock();
		for (var i:int = 0; i < wd; i++) {
			tpoint(int(x), int(y + gage * Math.sin(i * w)), myc, 0.1 - i / (wd * 10 + 10)); // down
			tpoint(int(x), int(y - gage * Math.sin(i * w)), myc, 0.1 - i / (wd * 10 + 10)); // up
		}
		_bmpData.unlock();
	}
	
	// translucent point
	private function tpoint(x1:int, y1:int, myc:uint, a:Number):void {
		var r:int, g:int, b:int;
		var c:uint;
		
		c = _bmpData.getPixel(x1, y1);
		
		r = int((c >> 16 & 0xFF) + ((myc >> 16 & 0xFF) - (c >> 16 & 0xFF)) * a);
		g = int((c >> 8 & 0xFF) + ((myc >> 8 & 0xFF) - (c >> 8 & 0xFF)) * a);
		b = int((c >> 0 & 0xFF) + ((myc >> 0 & 0xFF) - (c >> 0 & 0xFF)) * a);
		
		_bmpData.setPixel(x1, y1, r << 16 | g << 8 | b);
	}

}