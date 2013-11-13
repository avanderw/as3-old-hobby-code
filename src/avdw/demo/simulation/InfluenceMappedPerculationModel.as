package avdw.demo.simulation {
	import adobe.utils.CustomActions;
	import com.bit101.charts.LineChart;
	import com.bit101.components.HSlider;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.globalization.NumberFormatter;
	import mx.core.ButtonAsset;
	
	/**
	 * ...
	 * @author Andrew van der Westhuizen
	 */
	[SWF(width="400",height="600",backgroundColor="#000000")]
	
	public class InfluenceMappedPerculationModel extends Sprite {
		private var counter:int, moveAgentCount:int, updateGrowCount:int, updateFireCount:int, updateInfluenceCount:int = 1;
		private var tree:Point, fire:Point, agent:Point, entity:Point, goal:Point;
		private var displayTreeMap:Boolean = true, displayAgentMap:Boolean = true, displayFireMap:Boolean = true;
		private const gridWidth:int = 100, gridHeight:int = 100, gridSize:int = gridWidth * gridHeight;
		private const moveInterval:int = 1, growInterval:int = 5, propFireInterval:int = 3;
		private const treeMap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const fireMap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const agentMap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const goalMap:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const influence:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const goalInfluence:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const treeInfluence:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const fireInfluence:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		private const trees:Vector.<Point> = new Vector.<Point>();
		private const fires:Vector.<Point> = new Vector.<Point>();
		private const agents:Vector.<Point> = new Vector.<Point>();
		private const goals:Vector.<Point> = new Vector.<Point>();
		private const rendering:Bitmap = new Bitmap(new BitmapData(gridWidth, gridHeight, true, 0));
		private const map:Bitmap = new Bitmap(new BitmapData(gridWidth, gridHeight, true, 0xFFFFFFFF));
		private const negative:Boolean = false, positive:Boolean = true;
		private const influenceSprite:Sprite = new Sprite();
		private var treeFill:HSlider, goalInfluenceDecay:HSlider, fireInfluenceDecay:HSlider, agentPop:HSlider, firePop:HSlider,treeGrow:HSlider;
		private var numGoals:NumericStepper;
		private var lineChart:LineChart;
		
		public function InfluenceMappedPerculationModel():void {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initMap(treeMap);
			initMap(fireMap);
			initMap(agentMap);
			initMap(goalMap);
			initMap(influence);
			initMap(goalInfluence);
			initMap(fireInfluence);
			initMap(treeInfluence);
			
			rendering.scaleX = 4;
			rendering.scaleY = 3;
			map.scaleX = 4;
			map.scaleY = 3;
			
			var sprite:Sprite = new Sprite(); // wrapper for mouse event
			sprite.y = 600 - (rendering.scaleY * 100);
			sprite.addChild(rendering);
			sprite.addEventListener(MouseEvent.CLICK, showMap);
			addChild(sprite);
			
			influenceSprite.y = 600 - (rendering.scaleY * 100)
			influenceSprite.addEventListener(MouseEvent.CLICK, showMap); // wrapper for mouse event
			addChild(influenceSprite);
			//showMap();
			
			// gui stuff
			addChild(new Bitmap(new BitmapData(stage.stageWidth, 600 - (rendering.scaleY * 100), false, 0xFFFFFF)));
			var startFireBtn:PushButton = new PushButton(stage, stage.stageWidth - 198, 600 - (rendering.scaleY * 100) - 25, "Start Fires", startFire);
			var setupBtn:PushButton = new PushButton(stage, startFireBtn.x - 105, startFireBtn.y, "Setup", setup);
			
			var treeFillLbl:Label = new Label(stage, 90, 5, "Initial Tree Ratio:");
			var treeFillVal:Label = new Label(stage, treeFillLbl.x + treeFillLbl.width, 5, "0.47     ");
			treeFill = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, treeFillVal.y + 5, function(e:Event = null):void {
				treeFillVal.text = "" + Math.round(treeFill.value * 10) / 10;
			});
			treeFill.minimum = 0.2;
			treeFill.maximum = 0.7;
			treeFill.value = 0.47;
			
			var goalLbl:Label = new Label(stage, treeFillLbl.x, treeFillLbl.y + treeFillLbl.height + 5, "Number of Goals:");
			numGoals = new NumericStepper(stage, treeFillVal.x + treeFillVal.width +5, goalLbl.y);
			numGoals.minimum = 0;
			numGoals.maximum = 10;
			numGoals.value = 3;
			
			var goalInfluenceLbl:Label = new Label(stage, treeFillLbl.x, goalLbl.y + goalLbl.height + 5, "Goal Decay Rate:");
			var goalInfluenceVal:Label = new Label(stage, goalInfluenceLbl.x + goalInfluenceLbl.width, goalInfluenceLbl.y, "0.8");
			goalInfluenceDecay = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, goalInfluenceVal.y + 5, function(e:Event = null):void {
				goalInfluenceVal.text = "" + Math.round(goalInfluenceDecay.value * 10) / 10;
			});
			goalInfluenceDecay.minimum = 0.01;
			goalInfluenceDecay.maximum = 0.99;
			goalInfluenceDecay.value = 0.8;
			
			var fireInfluenceLbl:Label = new Label(stage, treeFillLbl.x, goalInfluenceLbl.y + goalInfluenceLbl.height + 5, "Fire Decay Rate:");
			var fireInfluenceVal:Label = new Label(stage, fireInfluenceLbl.x + fireInfluenceLbl.width, fireInfluenceLbl.y, "0.7");
			fireInfluenceDecay = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, fireInfluenceVal.y + 5, function(e:Event = null):void {
				fireInfluenceVal.text = "" + Math.round(fireInfluenceDecay.value * 10) / 10;
			});
			fireInfluenceDecay.minimum = 0.01;
			fireInfluenceDecay.maximum = 0.99;
			fireInfluenceDecay.value = 0.7;
			
			var agentPopLbl:Label = new Label(stage, treeFillLbl.x, fireInfluenceLbl.y + fireInfluenceLbl.height + 5, "Number of Agents:");
			var agentPopVal:Label = new Label(stage, agentPopLbl.x + agentPopLbl.width, agentPopLbl.y, "" + Math.round(0.005 * gridSize));
			agentPop = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, agentPopVal.y + 5, function(e:Event = null):void {
				agentPopVal.text = "" + Math.round(agentPop.value * gridSize);
			});
			agentPop.minimum = 0;
			agentPop.maximum = 0.05;
			agentPop.value = 0.005;
			
			var firePopLbl:Label = new Label(stage, treeFillLbl.x, agentPopLbl.y + agentPopLbl.height + 5, "Number of Fires:");
			var firePopVal:Label = new Label(stage, firePopLbl.x + firePopLbl.width, firePopLbl.y, "" + Math.round(0.005 * gridSize));
			firePop = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, firePopVal.y + 5, function(e:Event = null):void {
				firePopVal.text = "" + Math.round(firePop.value * gridSize);
			});
			firePop.minimum = 0;
			firePop.maximum = 0.1;
			firePop.value = 0.005;
			
			var treeGrowLbl:Label = new Label(stage, treeFillLbl.x, firePopLbl.y + firePopLbl.height + 5, "Regrowth Chance:");
			var treeGrowVal:Label = new Label(stage, treeGrowLbl.x + treeGrowLbl.width, treeGrowLbl.y, "0.1");
			treeGrow = new HSlider(stage, treeFillVal.x + treeFillVal.width +5, treeGrowVal.y + 5, function(e:Event = null):void {
				treeGrowVal.text = "" + Math.round(treeGrow.value * 10) / 10;
			});
			treeGrow.minimum = 0;
			treeGrow.maximum = 0.5;
			treeGrow.value = 0.1;
			
			lineChart = new LineChart(stage, 100, treeGrowLbl.y + treeGrowLbl.height + 5);
			lineChart.showGrid = true;
			
			// start simulation			
			setup();
			startFire();
			
			// animation event listeners
			addEventListener(Event.ENTER_FRAME, regrowTrees);
			addEventListener(Event.ENTER_FRAME, propFire);
			addEventListener(Event.ENTER_FRAME, moveAgents);
			addEventListener(Event.ENTER_FRAME, updateInfluenceMap);
		}
		
		private function setup(e:Event = null):void {
			lineChart.data = new Array();
			rendering.bitmapData.fillRect(new Rectangle(0, 0, gridWidth, gridHeight), 0x00000000);
			
			clearMap(treeMap);
			clearMap(fireMap);
			clearMap(agentMap);
			
			trees.splice(0, trees.length);
			agents.splice(0, agents.length);
			fires.splice(0, fires.length);
			goals.splice(0, goals.length);
			
			moveAgentCount = 0;
			updateGrowCount = 0;
			updateFireCount = 0;
			
			for (counter = 0; counter < gridSize * treeFill.value; counter++) {
				tree = new Point();
				
				// choose empty space for tree
				while (true) {
					tree.x = Math.floor(Math.random() * (gridWidth - 2) + 1);
					tree.y = Math.floor(Math.random() * (gridHeight - 2) + 1);
					
					if (tree.x == 0 || tree.y == 0) {
						throw new Error("WTF");
					}
					
					if (treeMap[tree.x][tree.y] == 0) {
						treeMap[tree.x][tree.y] = 1;
						break;
					}
				}
				
				trees.push(tree);
			}
			
			for (counter = 0; counter < gridSize * agentPop.value; counter++) {
				agent = new Point();
				
				// find empty space for agent
				while (true) {
					agent.x = Math.floor(Math.random() * (gridWidth - 2) + 1);
					agent.y = Math.floor(Math.random() * (gridHeight - 2) + 1);
					
					if (agent.x == 0 || agent.y == 0) {
						throw new Error("WTF");
					}
					
					if (treeMap[agent.x][agent.y] == 0 && agentMap[agent.x][agent.y] == 0) {
						agentMap[agent.x][agent.y] = 1;
						break;
					}
				}
				
				agents.push(agent);
			}
			
			for (counter = 0; counter < numGoals.value; counter++) {
				goal = new Point();
				
				// find empty space for goal
				while (true) {
					goal.x = Math.floor(Math.random() * (gridWidth - 2) + 1);
					goal.y = Math.floor(Math.random() * (gridHeight - 2) + 1);
					
					if (goal.x == 0 || goal.y == 0) {
						throw new Error("WTF");
					}
					
					if (treeMap[goal.x][goal.y] == 0 && agentMap[goal.x][goal.y] == 0 && goalMap[goal.x][goal.y] == 0) {
						goalMap[goal.x][goal.y] = 1;
						break;
					}
				}
				
				goals.push(goal);
			}
			
			rendering.bitmapData.fillRect(new Rectangle(0, 0, gridWidth, gridHeight), 0x00000000);
			render(trees, 0xFF00FF00);
			render(agents, 0xFF0000FF);
		}
		
		private function startFire(e:Event = null):void {
			for (counter = 0; counter < gridSize * firePop.value; counter++) {
				fire = new Point();
				
				// select non burning tree to burn
				while (true) {
					tree = trees[Math.floor(Math.random() * trees.length)];
					fire.x = tree.x;
					fire.y = tree.y;
					
					if (fire.x == 0 || fire.y == 0) {
						throw new Error("WTF");
					}
					
					if (fireMap[fire.x][fire.y] == 0) {
						fireMap[fire.x][fire.y] = 1;
						break;
					}
				}
				
				fires.push(fire);
			}
		}
		
		private function showMap(e:MouseEvent = null):void {
			if (influenceSprite.contains(map)) {
				influenceSprite.removeChild(map);
			} else {
				influenceSprite.addChild(map);
			}
		}
		
		private function updateInfluenceMap(e:Event):void {
			// split calculation over frames
			switch (updateInfluenceCount) {
				case 1: 
					clearMap(goalInfluence);
					generateInfluence(goals, goalInfluenceDecay.value, positive, goalInfluence);
					break;
				case 2: 
					clearMap(treeInfluence);
					generateInfluence(trees, 0.0001, negative, treeInfluence);
					break;
				case 3: 
					clearMap(fireInfluence);
					generateInfluence(fires, fireInfluenceDecay.value, negative, fireInfluence);
					break;
				case 4: 
					clearMap(influence);
					break;
				case 5: 
					combine(fireInfluence, treeInfluence, influence);
					//combine(fireInfluence, influence, influence);
					break;
				case 6: 
					combine(goalInfluence, influence, influence);
					break;
				case 7: 
					updateInfluenceCount = 0;
					var x:int, y:int;
					map.bitmapData.lock();
					for (x = 0; x < gridWidth; x++) {
						for (y = 0; y < gridHeight; y++) {
							var color:uint = (influence[x][y] < 0) ? 0x00FF0000 : 0x000000FF;
							color = color | (Math.abs(Math.round(influence[x][y] * 0xFF)) << 24);
							map.bitmapData.setPixel32(x, y, color);
						}
					}
					map.bitmapData.unlock();
					break;
				default: 
					throw new Error("number unkown");
			}
			
			updateInfluenceCount++;
		}
		
		private function combine(influence1:Vector.<Vector.<Number>>, influence2:Vector.<Vector.<Number>>, combinedInfluence:Vector.<Vector.<Number>>):void {
			var tmpInfluence:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
			initMap(tmpInfluence);
			
			var x:int, y:int;
			for (x = 0; x < gridWidth; x++) {
				for (y = 0; y < gridHeight; y++) {
					tmpInfluence[x][y] = Math.max(-1, Math.min(1, influence1[x][y] + influence2[x][y]));
				}
			}
			
			for (x = 0; x < gridWidth; x++) {
				for (y = 0; y < gridHeight; y++) {
					combinedInfluence[x][y] = tmpInfluence[x][y];
				}
			}
		}
		
		private function clearMap(map:Vector.<Vector.<Number>>):void {
			for (var x:int = 0; x < gridWidth; x++) {
				for (var y:int = 0; y < gridHeight; y++) {
					map[x][y] = 0;
				}
			}
		}
		
		private function generateInfluence(entities:Vector.<Point>, decayRate:Number, sign:Boolean, influence:Vector.<Vector.<Number>>):void {
			clearMap(influence);
			
			var processList:Vector.<Point> = new Vector.<Point>();
			for each (entity in entities) {
				processList.push(entity);
				influence[entity.x][entity.y] = (sign == positive) ? 1 : -1;
			}
			
			while (processList.length > 0) {
				if (processList.length > gridSize) {
					throw new Error("too many nodes to process");
				}
				entity = processList.shift();
				
				if (entity.x == 0 || entity.y == 0 || entity.x == 99 || entity.y == 99) {
					influence[entity.x][entity.y] = -1;
					continue;
				}
				
				if (influence[entity.x - 1][entity.y - 1] == 0) {
					processList.push(new Point(entity.x - 1, entity.y - 1));
					influence[entity.x - 1][entity.y - 1] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x - 0][entity.y - 1] == 0) {
					processList.push(new Point(entity.x - 0, entity.y - 1));
					influence[entity.x - 0][entity.y - 1] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x + 1][entity.y - 1] == 0) {
					processList.push(new Point(entity.x + 1, entity.y - 1));
					influence[entity.x + 1][entity.y - 1] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x - 1][entity.y - 0] == 0) {
					processList.push(new Point(entity.x - 1, entity.y - 0));
					influence[entity.x - 1][entity.y - 0] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x + 1][entity.y - 0] == 0) {
					processList.push(new Point(entity.x + 1, entity.y - 0));
					influence[entity.x + 1][entity.y - 0] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x - 1][entity.y + 1] == 0) {
					processList.push(new Point(entity.x - 1, entity.y + 1));
					influence[entity.x - 1][entity.y + 1] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x - 0][entity.y + 1] == 0) {
					processList.push(new Point(entity.x - 0, entity.y + 1));
					influence[entity.x - 0][entity.y + 1] = influence[entity.x][entity.y] * decayRate;
				}
				if (influence[entity.x + 1][entity.y + 1] == 0) {
					processList.push(new Point(entity.x + 1, entity.y + 1));
					influence[entity.x + 1][entity.y + 1] = influence[entity.x][entity.y] * decayRate;
				}
			}
		}
		
		private function moveAgents(e:Event):void {
			if (moveAgentCount == moveInterval) {
				moveAgentCount = 0;
				
				render(agents, 0x00000000);
				
				for each (agent in agents) {
					var move:Point = new Point();
					var maxEnergy:Number = influence[agent.x][agent.y];
					if (influence[agent.x - 1][agent.y - 1] > maxEnergy) {
						maxEnergy = influence[agent.x - 1][agent.y - 1];
						move.x = -1;
						move.y = -1;
					}
					if (influence[agent.x - 0][agent.y - 1] > maxEnergy) {
						maxEnergy = influence[agent.x - 0][agent.y - 1];
						move.x = -0;
						move.y = -1;
					}
					if (influence[agent.x + 1][agent.y - 1] > maxEnergy) {
						maxEnergy = influence[agent.x + 1][agent.y - 1];
						move.x = +1;
						move.y = -1;
					}
					if (influence[agent.x - 1][agent.y - 0] > maxEnergy) {
						maxEnergy = influence[agent.x - 1][agent.y - 0];
						move.x = -1;
						move.y = -0;
					}
					if (influence[agent.x + 1][agent.y - 0] > maxEnergy) {
						maxEnergy = influence[agent.x + 1][agent.y - 0];
						move.x = +1;
						move.y = -0;
					}
					if (influence[agent.x - 1][agent.y + 1] > maxEnergy) {
						maxEnergy = influence[agent.x - 1][agent.y + 1];
						move.x = -1;
						move.y = +1;
					}
					if (influence[agent.x - 0][agent.y + 1] > maxEnergy) {
						maxEnergy = influence[agent.x - 0][agent.y + 1];
						move.x = -0;
						move.y = +1;
					}
					if (influence[agent.x + 1][agent.y + 1] > maxEnergy) {
						maxEnergy = influence[agent.x + 1][agent.y + 1];
						move.x = +1;
						move.y = +1;
					}
					
					if (agentMap[agent.x + move.x][agent.y + move.y] != 1 && treeMap[agent.x + move.x][agent.y + move.y] != 1) {
						agentMap[agent.x][agent.y] = 0;
						agentMap[agent.x + move.x][agent.y + move.y] = 1;
						agent.x += move.x;
						agent.y += move.y;
					}
				}
				
				render(agents, 0xFF0000FF);
			}
			
			moveAgentCount++;
		}
		
		private function regrowTrees(e:Event):void {
			if (updateGrowCount == growInterval) {
				updateGrowCount = 0;
				
				var growTrees:Vector.<Point> = new Vector.<Point>();
				for each (tree in trees) {
					if (treeMap[tree.x][tree.y] == 0.5 && Math.random() < treeGrow.value) {
						treeMap[tree.x][tree.y] = 1;
						growTrees.push(tree);
					}
				}
				
				render(growTrees, 0xFF00FF00);
			}
			
			updateGrowCount++;
		}
		
		private function propFire(e:Event):void {
			if (fires.length > gridSize) {
				throw new Error("too many fires");
			}
			
			if (updateFireCount == propFireInterval) {
				updateFireCount = 0;
				
				var removedFires:Vector.<Point> = new Vector.<Point>();
				for (counter = 0; counter < fires.length; counter++) {
					var fire:Point = fires.shift();
					
					if (treeMap[fire.x - 1][fire.y - 1] == 1 && fireMap[fire.x - 1][fire.y - 1] != 1) {
						fires.push(new Point(fire.x - 1, fire.y - 1));
						fireMap[fire.x - 1][fire.y - 1] = 1;
					}
					if (treeMap[fire.x - 0][fire.y - 1] == 1 && fireMap[fire.x - 0][fire.y - 1] != 1) {
						fires.push(new Point(fire.x - 0, fire.y - 1));
						fireMap[fire.x - 0][fire.y - 1] = 1;
					}
					if (treeMap[fire.x + 1][fire.y - 1] == 1 && fireMap[fire.x + 1][fire.y - 1] != 1) {
						fires.push(new Point(fire.x + 1, fire.y - 1));
						fireMap[fire.x + 1][fire.y - 1] = 1;
					}
					if (treeMap[fire.x - 1][fire.y - 0] == 1 && fireMap[fire.x - 1][fire.y - 0] != 1) {
						fires.push(new Point(fire.x - 1, fire.y - 0));
						fireMap[fire.x - 1][fire.y - 0] = 1;
					}
					if (treeMap[fire.x + 1][fire.y - 0] == 1 && fireMap[fire.x + 1][fire.y - 0] != 1) {
						fires.push(new Point(fire.x + 1, fire.y - 0));
						fireMap[fire.x + 1][fire.y - 0] = 1;
					}
					if (treeMap[fire.x - 1][fire.y + 1] == 1 && fireMap[fire.x - 1][fire.y + 1] != 1) {
						fires.push(new Point(fire.x - 1, fire.y + 1));
						fireMap[fire.x - 1][fire.y + 1] = 1;
					}
					if (treeMap[fire.x - 0][fire.y + 1] == 1 && fireMap[fire.x - 0][fire.y + 1] != 1) {
						fires.push(new Point(fire.x - 0, fire.y + 1));
						fireMap[fire.x - 0][fire.y + 1] = 1;
					}
					if (treeMap[fire.x + 1][fire.y + 1] == 1 && fireMap[fire.x + 1][fire.y + 1] != 1) {
						fires.push(new Point(fire.x + 1, fire.y + 1));
						fireMap[fire.x + 1][fire.y + 1] = 1;
					}
					
					treeMap[fire.x][fire.y] = 0.5;
					fireMap[fire.x][fire.y] = 0;
					removedFires.push(fire);
				}
				
				render(removedFires, 0xFF996600);
				render(fires, 0xFFFF0000);
				
				lineChart.data.push(fires.length);
				lineChart.draw();
			}
			updateFireCount++;
		
		}
		
		private function render(entities:Vector.<Point>, color:uint):void {
			rendering.bitmapData.lock();
			for each (var entity:Point in entities) {
				rendering.bitmapData.setPixel32(entity.x, entity.y, color);
			}
			rendering.bitmapData.unlock();
		}
		
		private function initMap(map:Vector.<Vector.<Number>>):void {
			for (var x:int = 0; x < gridWidth; x++) {
				var col:Vector.<Number> = new Vector.<Number>();
				for (var y:int = 0; y < gridHeight; y++) {
					col.push(0);
				}
				map.push(col);
			}
		}
	
	}

}