﻿package com.laz.display.test{	import com.laz.display.LText;	import com.laz.display.LTextVO;		import flash.display.MovieClip;		public class TextTest extends MovieClip	{		public function TextTest()		{			//single line textfield			var t1:LTextVO = new LTextVO;			t1.fX		= 38;			t1.fY		= 51;			t1.fFont	= Arial;			t1.fText 	= "Beep beep.  I'm the robot.";			var field1:LText = new LText(t1);			addChild(field1);						//single line with shadow and font color			var t2:LTextVO = new LTextVO;			t2.fX		= 38;			t2.fY		= 150;			t2.fSize	= 18;			t2.fColor	= 0xFF0000;			t2.fFont	= Arial;			t2.fText 	= "Fish heads, fish heads, roly-poly fish heads";			t2.fShadow 	= true;			var field2:LText = new LText(t2);			addChild(field2);						//multiline, special font, border, no shadow			var t3:LTextVO = new LTextVO;			t3.fX		= 38;			t3.fY		= 240;			t3.fW		= 125;			t3.fMulti	= true;			t3.fWrap	= true;			t3.fSize	= 16;			t3.fFont	= ComicSans;			t3.fText 	= "These are not the droids you're looking for.";			t3.fBorder 	= true;			var field3:LText = new LText(t3);			addChild(field3);									//single line with updated text			var t4:LTextVO 	 = t1;			t4.fY 			 = 385;			t4.fFont		 = Arial;			t4.fText 		 = "Here I am baby";			var field4:LText = new LText(t4);			addChild(field4);		}	}}