package com.zgg.display
{
	import fl.motion.easing.*;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.utils.*;
 	
	public class AsTween
	{
		public static var defaultEase:Function 	= AsTween.easeOut;
		protected static var noGC:Dictionary 	= new Dictionary(false);
		
		private static var s:Sprite 			= new Sprite(); //controlling container. tell "s" to add to delays if needed
		private static var gcTimer:Timer 		= new Timer(2000);
		protected static var currTime:uint; 
		protected static var animTimer:Timer; 
		private static var classInit:Boolean; //flag for tweenVars loaded and ready to be passed to appro tween functions
		private static var listeners:Boolean; //If true, the ENTER_FRAME is being listened for (there are tweens that are in the queue)
	
		public var duration:Number; 	//Duration (in seconds)
		public var tweenVars:Object; 	//tween vars, like alpha etc.
		//tweenVars.delay
		//tweenVars.overwrite
		//tweenVars.ease
		//tweenVars.easeParams
		//tweenVars.customizedEase
		//tweenVars.alpha
		public var delay:Number;	 	//Delay (in seconds)
		public var startTime:int; 		//Start time is the same as the start of the timer.
		public var initTime:int;
		
		public var tweens:Array; 	//Contains parsed data for each property that's being tweened (each has to have a target, property, start, and a change).
		public var target:Object; 	//Target object (often a MovieClip)
		
		protected var initDone:Boolean;
		protected var active:Boolean; 
		protected var subTweens:Array; 		//used for any non-default tweens
		protected var hasSubTweens:Boolean; //Has sub-tweens.
		
		public function AsTween(oTarget:Object, nDuration:Number, otweenVars:Object)	//target can be array
		{
			
			//set up target arrays and variables
			target 	 		= oTarget;
			duration 		= nDuration || 0.001;	//can't be zero
			tweenVars	 	= otweenVars;
			
			if (target == null) 
				{
					return;
				}
			
			
			//checks to see if there is a valid animation target
			if ((tweenVars.overwrite != false && target != null) || noGC[target] == undefined) 
			{ 
				delete noGC[target];
				noGC[target] = new Dictionary(false);	//Prevents garbage collection; Flash problem being collected before tween is complete
			}
			noGC[target][this] = this;	//"this" sticks current instance of AsTween into the 
										//dictionary obj, with target as the key, for later garbage collection
			
			if(tweenVars.delay != undefined)
				{
					delay = tweenVars.delay;
				} else {
					delay = 0;
				}
			

			//default ease
			if (!(tweenVars.ease is Function)) 
			{
				tweenVars.ease = defaultEase;
			}
			
			//custom eases
			if (tweenVars.easeParams != null) 
			{	
				tweenVars.customizedEase = tweenVars.ease;
				tweenVars.ease = easeCustom;
			}
			
			//tween the alpha
			if (!isNaN(Number(tweenVars.newAlpha))) 
			{	
				tweenVars.alpha = Number(tweenVars.newAlpha);
			}
				
			//reset everything to initial states
			tweens = [];
			subTweens = [];
			initDone = false;
			hasSubTweens = initDone;
			
			if (active != false)
			nDuration == 0 && delay == 0;
			
			if (!classInit) 
			{
				currTime = getTimer();

				//trace("duration: " + duration)
				animTimer = new Timer((duration), 0);
				animTimer.addEventListener(TimerEvent.TIMER, prepDraw);
				animTimer.start();
				
				init();
				classInit = true;
				initTime = currTime;
			}
			
			if (!listeners && !active) 
			{
				gcTimer.addEventListener("gcTimer", collectGarbage);
            	gcTimer.start();
				listeners = true;
			}
		}


		public function init():void 
		{
			//Here's a big hairy check to see what type of tween is 
			//being requested, and then calls to the right functions
			var isDO:Boolean = (target is DisplayObject);
			var item:String;
			var i:int;
			
			/*			//fix: multiple not working yet.
			if (target is Array) {
				var endArray:Array = tweenVars.endArray;
				trace ("target.length: " + target.length);
				for (i = 0; i < target.length; i++) 
				{
					if (target[i] != endArray[i] && target[i] != undefined) //overwrite old array if it exists
					{
					    //o: object, p:property, s:starting value, c:change in value
						tweens.push({o:target, item:String(i), s:target[i], c:endArray[i] - target[i]}); 
					}
				}
			} else {
				*/
				
				for (item in tweenVars) //there is probably a much better way to do this
				{
					/*(item == "ease" || item == "delay" || item == "newAlpha" || item == "customizedEase" 
					|| item == "easeParams" || item == "overwrite" || item == "onComplete" || item == "onCompleteParams" 
					|| item == "onUpdate" || item == "onUpdateParams") 
					*/
					
					//see which items are in tweenVars
					if (item == "tint" && isDO) 
					{ 
						var clr:ColorTransform = target.transform.colorTransform;
						var endClr:ColorTransform = new ColorTransform();
						//see if there's an alpha with the tint
						if (tweenVars.alpha != undefined) 
						{
							endClr.alphaMultiplier = tweenVars.alpha;
							//clear this value for next tween
							delete tweenVars.alpha;
							
							for (i = tweens.length - 1; i > -1; i--) 
							{
								if (tweens[i].item == "alpha") 
								{
									tweens.splice(i, 1);
									break;
								}
							}
						} else {
							endClr.alphaMultiplier = target.alpha;
						}
						
						
						if ((tweenVars[item] != null && tweenVars[item] != "") || tweenVars[item] == 0) 
						{ //to remove the colorization, pass in null or "" for the tint
							endClr.color = tweenVars[item];
						}
						
						addSubTweens(tintCustom, {itemrogress:0}, {progress:1}, {target:target, color:clr, endColor:endClr});
						
						} else {
						if (target.hasOwnProperty(item)) 
						{
							if (typeof(tweenVars[item]) == "number") {
								tweens.push({o:target, item:item, s:target[item], c:tweenVars[item] - target[item]}); //o:object, item:property, s:starting value, c:change in value
							} else {
								tweens.push({o:target, item:item, s:target[item], c:Number(tweenVars[item])}); //o:object, item:property, s:starting value, c:change in value
							}
						}
					}
					
				}
			}
			
			if (typeof(tweenVars.alpha) == "number") 
			{
				target.visible = !(target.alpha == 0);
			}
			
			initDone = true;
		}
		
		
		//Here's the function that you call from another class
		public static function zTween(target:Object, duration:Number, tweenVars:Object):AsTween 
		{
			return new AsTween(target, duration, tweenVars);
		}
		
		
		public function addSubTweens(_cFunc:Function, _target:Object, _props:Object, _info:Object = null):void
		{
			var cust:Object = {cFunc:_cFunc, target:_target, info:_info};
			
			subTweens.push(cust);
			for (var p:String in _cFunc) 
			{
				if (target.hasOwnProperty(p)) {
					if (typeof(_props[p]) == "number") {
						tweens.push({o:target, p:p, s:target[p], c:_props[p] - target[p], cust:cust}); //o:Object, p:Property, s:Starting value, c:Change in value, sub:Subtween object;
					} else {
						tweens.push({o:target, p:p, s:target[p], c:Number(_props[p]), cust:cust});
					}
				}
			}
			hasSubTweens = true;
		}
		

		//calls draw for each tween target in the dictionary
		public static function prepDraw(e:Event = null):void 
		{
			trace("prepDraw being called");
			var t:uint = currTime = getTimer();
			if (listeners) 
			{
				var a:Dictionary = noGC;
				var p:Object;
				var tw:Object;
				
				for each (p in a) 
				{
					for (tw in p) 
					{
						if (p[tw] != undefined && p[tw].isActive) 
						{
							p[tw].draw(t);
						}
					}
				}
			}
			
		}
		
		
		//changes values for desired tween every timer tick
		public function draw(t:uint):void 
		{
			var time:Number = (t - startTime) / 1000;
			if (time > duration) 
			{
				time = duration;
			}
			
			var factor:Number = tweenVars.ease(time, 0, 1, duration);
			var td:Object;
			var i:int;
			
			for (i = tweens.length - 1; i > -1; i--) 
			{
				td = tweens[i];
				td.o[td.p] = td.s + (factor * td.c);  //which translates to:  obj[property] = target (tweenVars.ease(time, 0, 1, duration) * numChange)
			}
			
			if (hasSubTweens) 
			{
				 //has sub-tweens
				for (i = subTweens.length - 1; i > -1; i--) 
				{
					subTweens[i].cFunc(subTweens[i]);
				}
			}
			
			if (tweenVars.onUpdate != null) 
			{
				tweenVars.onUpdate.apply(tweenVars.onUpdateParams);
			}
			
			if (time == duration) 
			{
				isComplete(true); //run complete function
			}
		}
		
		
		public function isComplete(skipDraw:Boolean = false):void 
		{
			if (!skipDraw) 
			{
				if (!initDone) {
					init();
				}
				startTime = currTime - (duration * 1000);
				draw(currTime); //Just to force the final render
				return;
			}
			
			if (typeof(tweenVars.newAlpha) == "number" && target.alpha == 0) 
			{ 
				target.visible = false;
			}
			
			if (tweenVars.onComplete != null) {
				tweenVars.onComplete.apply(tweenVars.onCompleteParams);
			}
			removeTween(this);
		}
		
		
		//animation active boolean used to flag for garbage collection
		public function get isActive():Boolean 
		{
			if (active) {
				return true;
			} else if ((currTime - initTime) / 1000 > delay) 
			  {
				active = true;
				startTime = initTime + (delay * 1000);
				
				if (typeof(tweenVars.autoAlpha) == "number") {
					target.visible = true;
				}
				if (tweenVars.onStart != null) {
					tweenVars.onStart.apply(tweenVars.onStartParams);
				}
				return true;
			} else {
				return false;
			  }
		}
		
		
		public static function removeTween(t:AsTween = null):void 
		{
			if (t != null && noGC[t.target] != undefined) {
				delete noGC[t.target][t];
			}
		}
		
		
		//call this function from anywhere to immediately kill all tweens of an display object
		public static function killTweens(ko:Object = null, complete:Boolean = false):void 
		{
			trace("k0 Object: " + ko);
			trace("k0 in noGC: " + noGC[ko]);
			if (ko != null && noGC[ko] != undefined) 
			{
				
				if (complete) {
					var o:Object = noGC[ko];
					
					for (var tw:* in o) {
						o[tw].complete(false);
					}
				}
				delete noGC[ko];
			}
		}
		

		public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number 
		{
			return -c * (t /= d) * (t - 2) + b;
		}
		

		//used when easeParams are passed in via the tweenVars object.
		protected function easeCustom(t:Number, b:Number, c:Number, d:Number):Number 
		{ 
			return tweenVars.customizedEase.apply(null, arguments.concat(tweenVars.easeParams));
		}
		
		
		public static function tintCustom(o:Object):void 
		{
			var n:Number = o.target.progress;
			var r:Number = 1 - n;
			var sc:Object = o.info.color;
			var ec:Object = o.info.endColor;
			o.info.target.transform.colorTransform = new ColorTransform(sc.redMultiplier * r + ec.redMultiplier * n,
																		  sc.greenMultiplier * r + ec.greenMultiplier * n,
																		  sc.blueMultiplier * r + ec.blueMultiplier * n,
																		  sc.alphaMultiplier * r + ec.alphaMultiplier * n,
																		  sc.redOffset * r + ec.redOffset * n,
																		  sc.greenOffset * r + ec.greenOffset * n,
																		  sc.blueOffset * r + ec.blueOffset * n,
																		  sc.alphaOffset * r + ec.alphaOffset * n);
		}
		

		public static function collectGarbage(e:TimerEvent):void 
		{
			var kt_cnt:uint = 0;
			var found:Boolean;
			var p:Object, twp:Object, tw:Object;
			for (p in noGC) {
				found = false;
				for (twp in noGC[p]) {
					found = true;
					break;
				}
				if (!found) {
					delete noGC[p];
				} else {
					kt_cnt++;
				}
			}
			if (kt_cnt == 0) {
				gcTimer.removeEventListener("gcTimer", collectGarbage);
				gcTimer.stop();
				listeners = false;
			}
		}

	}
}