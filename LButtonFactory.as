package com.laz.display
{

/*
 * Class LButtonFactory
 * by Lisa Ziegler (lisa.ziegler@gmail.com)
 * Copyright 2008
 */
	
	import flash.display.Sprite;
	
	public class LButtonFactory extends Sprite
	{
	
		public function LButtonFactory(taButtons:Object):void
		{
			if(!(taButtons is Array)) //will run even if used for only a simgle button
				{
					createButton(taButtons);
				}
				else
				{
					//looping through all btns
					for(var btns:Number = 0;btns < taButtons.length;btns++)
					{
						createButton(taButtons[btns]);
					}
				}
		}
		

		public function createButton(newBtn:Object):void
		{
			var oNewButton = new LButton(newBtn as LButtonVO);
				addChild(oNewButton);
	
		}
		

		
	}
}