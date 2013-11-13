package avdw.demo.procedural {
	import as3isolib.core.EventListenerDescriptor;
	import avdw.generate.noise.CInterpolate;
	import avdw.generate.noise.CSignal2D;
	import avdw.generate.noise.generator.CBillow2D;
	import avdw.generate.noise.generator.CPerlin2D;
	import avdw.generate.noise.generator.CRidgedMulti2D;
	import avdw.generate.noise.generator.IGenerator2D;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.demonsters.debugger.MonsterDebugger;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="512",height="300",backgroundColor="0x0",frameRate="30")]
	
	public class Noise2DGeneration extends Sprite {
		private var bitmapData:BitmapData;
		private var lastRow:int, lastCol:int;
		private var noise:IGenerator2D;
		private var generatorUI:ComboBox;
		private var frequencyUI:NumericStepper;
		private var lacunarityUI:NumericStepper;
		private var octavesUI:NumericStepper;
		private var persistenceUI:NumericStepper;
		private var seedUI:InputText;
		private var offsetUI:NumericStepper;
		private var gainUI:NumericStepper;
		private var exponentUI:NumericStepper;
		private var signalUI:ComboBox;
		private var interpolationUI:ComboBox;
		
		public function Noise2DGeneration() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			MonsterDebugger.initialize(this);
			
			var ui:Sprite = new Sprite();
			generatorUI = new ComboBox(ui, 0, 0, "", [{label: "2D Perlin", noise: new CPerlin2D(), enable: [1, 1, 1, 1, 1, 0, 0, 0]}, {label: "2D Billow", noise: new CBillow2D(), enable: [1, 1, 1, 1, 1, 0, 0, 0]}, {label: "2D MultiRidge", noise: new CRidgedMulti2D(), enable: [1, 1, 1, 0, 1, 1, 1, 1]}]);
			generatorUI.selectedIndex = 0;
			generatorUI.addEventListener(Event.SELECT, enableUI);
			
			frequencyUI = new NumericStepper(ui, 80, 23);
			frequencyUI.value = 1;
			frequencyUI.step = 0.5;
			lacunarityUI = new NumericStepper(ui, 80, 43);
			lacunarityUI.value = 2;
			lacunarityUI.step = 0.2;
			octavesUI = new NumericStepper(ui, 80, 63);
			octavesUI.value = 6;
			persistenceUI = new NumericStepper(ui, 80, 83);
			persistenceUI.value = 0.5;
			persistenceUI.step = 0.1;
			seedUI = new InputText(ui, 80, 103);
			seedUI.text = "" + uint(Math.random() * 0xFFFF);
			seedUI.width = 80;
			offsetUI = new NumericStepper(ui, 80, 123);
			offsetUI.value = 1;
			offsetUI.step = 0.1;
			gainUI = new NumericStepper(ui, 80, 143);
			gainUI.value = 2;
			gainUI.step = 0.1;
			exponentUI = new NumericStepper(ui, 80, 163);
			exponentUI.value = 1;
			exponentUI.step = 0.1;
			
			interpolationUI = new ComboBox(ui, 80, 181, "", [{label: "none", func: CInterpolate.NONE}, {label: "linear", func: CInterpolate.LINEAR}, {label: "hermite", func: CInterpolate.HERMITE}, {label: "quintic", func: CInterpolate.QUINTIC}]);
			interpolationUI.selectedIndex = 2;
			signalUI = new ComboBox(ui, 80, 202, "", [{label: "gradient", func: CSignal2D.GRADIENT}]);
			signalUI.selectedIndex = 0;
			
			new PushButton(ui, 80, 223, "render", render).width = 80;
			new PushButton(ui, 163, 101, "randomize", randomSeed).width = 80;
			
			new Label(ui, 0, 20, "frequency");
			new Label(ui, 0, 40, "lacunarity");
			new Label(ui, 0, 60, "octaves");
			new Label(ui, 0, 80, "persistence");
			new Label(ui, 0, 100, "seed");
			new Label(ui, 0, 120, "offset");
			new Label(ui, 0, 140, "gain");
			new Label(ui, 0, 160, "exponent");
			new Label(ui, 0, 180, "interpFunc");
			new Label(ui, 0, 200, "signalFunc");
			
			enableUI();
			
			ui.x = 5;
			ui.y = 5;
			addChild(ui);
			
			bitmapData = new BitmapData(256, 256, false, 0xFF000000);
			var bmp:Bitmap = new Bitmap(bitmapData);
			bmp.x = 251;
			bmp.y = 5;
			addChild(bmp);
		}
		
		private function randomSeed(e:Event):void {
			seedUI.text = "" + uint(Math.random() * 0xFFFF);
		}
		
		private function enableUI(e:Event = null):void {
			(!generatorUI.selectedItem.enable[0]) ? frequencyUI.alpha = 0 : frequencyUI.alpha = 1;
			(!generatorUI.selectedItem.enable[1]) ? lacunarityUI.alpha = 0 : lacunarityUI.alpha = 1;
			(!generatorUI.selectedItem.enable[2]) ? octavesUI.alpha = 0 : octavesUI.alpha = 1;
			(!generatorUI.selectedItem.enable[3]) ? persistenceUI.alpha = 0 : persistenceUI.alpha = 1;
			(!generatorUI.selectedItem.enable[4]) ? seedUI.alpha = 0 : seedUI.alpha = 1;
			(!generatorUI.selectedItem.enable[5]) ? offsetUI.alpha = 0 : offsetUI.alpha = 1;
			(!generatorUI.selectedItem.enable[6]) ? gainUI.alpha = 0 : gainUI.alpha = 1;
			(!generatorUI.selectedItem.enable[7]) ? exponentUI.alpha = 0 : exponentUI.alpha = 1;
		}
		
		private function render(e:Event):void {
			bitmapData.fillRect(bitmapData.rect, 0xFF000000);
			
			noise = generatorUI.selectedItem.noise;
			noise.frequency = frequencyUI.value;
			noise.lacunarity = lacunarityUI.value;
			noise.ocaves = octavesUI.value;
			noise.persistence = persistenceUI.value;
			noise.seed = uint(seedUI.text);
			noise.offset = offsetUI.value;
			noise.gain = gainUI.value;
			noise.exponent = exponentUI.value;
			
			noise.noiseFunction = signalUI.selectedItem.func;
			noise.interpolationFunction = interpolationUI.selectedItem.func;
			
			lastRow = lastCol = 0;
			
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, animate);
			}
		}
		
		private function animate(e:Event):void {
			var isBroken:Boolean = false;
			if (lastRow < 255 || (lastRow == 254 && lastCol < 0xFF)) {
				bitmapData.lock();
				var startTime:Number = new Date().getTime();
				for (var row:int = lastRow; row < 256; row++) {
					for (var col:int = lastCol; col < 256; col++) {
						var num:Number = (noise.value(row / 255, col / 255) + 1) / 2 * 0xff;
						var color:uint = num & 0xFF;
						color = color << 16 | color << 8 | color;
						bitmapData.setPixel(col, row, color);
						lastCol = (col + 1) & (255);
						if (new Date().getTime() - startTime > 33.3333) {
							isBroken = true;
							break;
						}
					}
					lastRow = row;
					if (isBroken) {
						break;
					}
				}
				bitmapData.unlock();
			} else {
				removeEventListener(Event.ENTER_FRAME, animate);
			}
		
		}
	
	}

}