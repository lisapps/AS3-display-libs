package com.laz.display
{

/*
 * Class LLine
 * by Lisa Ziegler (lisa.ziegler@gmail.com)
 * Copyright 2008
 */

	import flash.display.Shape;
	import flash.display.Sprite;

	public class LLine extends Sprite
	{
		
		private var oLine:Shape = new Shape;
	
		public function LLine (tnLineWidth:Number,
								tnLineColor:Number,
								tnLineAlpha:Number,
								tnStartX:Number,
								tnStartY:Number,
								tnEndX:Number,
								tnEndY:Number) 
		{
					
			oLine = draw(tnLineWidth,
							tnLineColor,
							tnLineAlpha,
							tnStartX,
							tnStartY,
							tnEndX,
							tnEndY);
		}
	
		private function draw(tnLineWidth:Number,
								tnLineColor:Number,
								tnLineAlpha:Number,
								tnStartX:Number,
								tnStartY:Number,
								tnEndX:Number,
								tnEndY:Number)
		{
	
			oLine.graphics.lineStyle(tnLineWidth,tnLineColor,tnLineAlpha);
			oLine.graphics.moveTo(tnStartX,tnStartY);
			oLine.graphics.lineTo(tnEndX,tnEndY);
			oLine.graphics.endFill();
            addChild(oLine);
			return oLine;
		}
	}	
}