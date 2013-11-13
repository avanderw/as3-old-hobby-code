package avdw.generate.effect {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * TODO: add in a speed parameter to control the animation speed
	 *
	 * This class will apply an animated mask to an image.
	 * The animation is a collection of hexagons being built around a point.
	 * Where the hexagons are built the mask is applied to reveal the image.
	 *
	 * Reference: http://wonderfl.net/c/jLM1
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	public class HexagonalMask {
		private const angles:Vector.<Number> = new Vector.<Number>();
		
		private var stage:Stage;
		private var container:Sprite;
		private var displayObject:DisplayObject;
		private var hexagons:int;
		private var diameter:int;
		private var firstHex:Hexagon;
		
		private const V:Number = 30;
		
		private var sprite:Sprite = new Sprite(); // hexigons
		private var shape:Shape = new Shape(); // hexigon borders
		
		public function HexagonalMask(stage:Stage, container:Sprite, displayObject:DisplayObject):void {
			this.stage = stage;
			this.container = container;
			this.displayObject = displayObject;
		}
		
		public function remove():void {
			if (container.contains(sprite))
				container.removeChild(sprite);
			if (container.contains(shape))
				container.removeChild(shape);
			displayObject.mask = null;
		}
		
		/**
		 *
		 * @param	start
		 * @param	hexagons
		 * @param	diameter
		 */
		public function apply(start:Point, hexagons:int = 300, diameter:int = 20):void {
			var count:int;
			this.diameter = diameter;
			this.hexagons = hexagons;
			
			displayObject.mask = sprite;
			container.addChild(sprite);
			container.addChild(shape);
			
			for (count = 0; count < 6; count++) {
				angles.push(Math.PI / 180 * (60 * count));
			}
			
			firstHex = new Hexagon();
			firstHex.origin = start;
			firstHex.v = 0;
			var currHex:Hexagon = firstHex;
			
			for (count = 0; count < hexagons; count++) {
				currHex.next = new Hexagon();
				var tmpHex:Hexagon = firstHex;
				// traverse from origin to outside hex randomly
				// create new hex on border and link it as next for animation
				while (true) {
					var idx:uint = Math.floor(Math.random() * 6); // choose random neighbour
					if (!tmpHex.link[idx]) { // if it does not exist 
						// create it and link it
						currHex.next.origin.x = tmpHex.origin.x + diameter * Math.cos(angles[idx]);
						currHex.next.origin.y = tmpHex.origin.y + diameter * Math.sin(angles[idx]);
						checkLink(currHex.next);
						
						break; // and break, thus will have correct # hexagons
					} else { // if it exists 
						tmpHex = tmpHex.link[idx]; // traverse it
					}
				}
				currHex.next.v = Math.random() * -20 + (-10 * count);
				currHex = currHex.next;
			}
			
			stage.addEventListener(Event.ENTER_FRAME, animate);
		}
		
		/**
		 * This method assigns a new link on the correct hexigon.
		 *
		 * @param	cp
		 */
		private function checkLink(cp:Hexagon):void {
			for (var i:uint = 0; i < 6; i++) {
				var cx:Number = cp.origin.x + diameter * Math.cos(angles[i]);
				var cy:Number = cp.origin.y + diameter * Math.sin(angles[i]);
				var p:Hexagon = firstHex;
				while (p.next) {
					if (cx < p.origin.x + 2 && cx > p.origin.x - 2 && cy < p.origin.y + 2 && cy > p.origin.y - 2) {
						cp.link[i] = p;
						p.link[(i + 3) % 6] = cp;
					}
					p = p.next;
				}
			}
		}
		
		private function animate(e:Event = null):void {
			var g:Graphics = shape.graphics; // border graphics
			var sg:Graphics = sprite.graphics; // hexigon graphics
			var p:Hexagon = firstHex;
			var cnt:uint = 0;
			
			sg.clear();
			g.clear();
			g.lineStyle(1, 0x000000);
			while (p) {
				if (p.v < 610)
					p.v += V;
				if (p.v >= 0) {
					if (p.v >= 600) {
						g.beginFill(0xFFFFFF, p.a / 100 - (Math.random()));
						if (p.a > 0)
							p.a -= 5;
						sg.beginFill(0xAAFFAA, 0.1);
					}
					var bx:Number = 0;
					var by:Number = 0;
					for (var i:Number = 0; i <= 6; i++) {
						var ang:Number = Math.PI / 180 * (60 * i - 90);
						var lx:Number = p.origin.x + diameter / 2 * Math.cos(ang);
						var ly:Number = p.origin.y + diameter / 2 * Math.sin(ang);
						if (i == 0) {
							g.moveTo(lx, ly);
							sg.moveTo(lx, ly);
							bx = lx;
							by = ly;
						} else {
							if (i * 100 <= p.v) {
								g.lineTo(lx, ly);
								if (p.v >= 600)
									sg.lineTo(lx, ly);
								bx = lx;
								by = ly;
							}
							if (i * 100 > p.v && (i - 1) * 100 <= p.v) {
								g.lineTo(bx + (lx - bx) * (p.v % 100) / 100, by + (ly - by) * (p.v % 100) / 100);
							}
						}
					}
					g.endFill();
				}
				p = p.next;
				cnt++;
			}
		}
	
	}

}

import flash.geom.Point;

/**
 * ...
 * @author Andrew van der Westhuizen
 */
class Hexagon {
	public var origin:Point = new Point();
	
	public var v:Number = 0;
	public var a:Number = 100;
	public var link:Array = new Array();
	public var next:Hexagon;
	
	public function Hexagon() {
	
	}

}