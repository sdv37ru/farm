package
{
	import flash.display.*;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.Event;
	import flash.net.*;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	import flash.text.*;
	import flash.utils.getDefinitionByName;
	
	import org.osmf.elements.ImageElement;
	
	[SWF(width="880", height="454")]
	
	public class Farm extends Sprite
	{
		//internal var newplantsonfield:Array = new Array();
		internal var plantsonfield:Array = new Array();
		internal var plantsimagescache:Array = new Array();
		internal var serverurl:String = "http://localhost:1234/";
		public var state:String="waiting for action";
		public var display_status_val:TextField = new TextField();
		public var display_x_val:TextField = new TextField();
		public var display_y_val:TextField = new TextField();
		public var movingplant:plantonfield;
		public var movingplantimg_startplace:Bitmap = new Bitmap();
		public var movingplantimg:Bitmap = new Bitmap();
		
		public function Farm()
		{
			init_farm();
			getSituation("",0,0,0);
		}
		
		internal function init_farm():void{
			renderBG("BG.jpg");
			
			var display_txt:TextField = new TextField();
			display_txt.text = "Actions:";
			display_txt.selectable=false;
			display_txt.x=800;
			display_txt.y=5;
			addChild(display_txt);
			
			// Добавляем кнопки
			var clover_button:PushButton=new PushButton(790, 30, 60, 20, "Clover+");
			clover_button.addEventListener(MouseEvent.CLICK, clover_button_click);
			addChild(clover_button);
			
			var sunflower_button:PushButton=new PushButton(790, 60, 60, 20, "Sunflower+");
			sunflower_button.addEventListener(MouseEvent.CLICK, sunflower_button_click);
			addChild(sunflower_button);
			
			var potato_button:PushButton=new PushButton(790, 90, 60, 20, "Potato+");
			potato_button.addEventListener(MouseEvent.CLICK, potato_button_click);
			addChild(potato_button);
			
			var harvest_button:PushButton=new PushButton(790, 120, 60, 20, "Harvest");
			harvest_button.addEventListener(MouseEvent.CLICK, harvest_button_click);
			addChild(harvest_button);
			
			var turn_button:PushButton=new PushButton(790, 150, 60, 20, "Turn");
			turn_button.addEventListener(MouseEvent.CLICK, turn_button_click);
			addChild(turn_button);
			
			var display_status_lab:TextField = new TextField();
			display_status_lab.text = "Status:";
			display_status_lab.selectable=false;
			display_status_lab.x=800;
			display_status_lab.y=180;
			addChild(display_status_lab);
			
			display_status_val.text = state;
			display_status_val.selectable=false;
			display_status_val.x=785;
			display_status_val.y=200;
			addChild(display_status_val);
			
			var display_xy_lab:TextField = new TextField();
			display_xy_lab.text = "Coordinats";
			display_xy_lab.selectable=false;
			display_xy_lab.x=800;
			display_xy_lab.y=230;
			addChild(display_xy_lab);
			
			var display_x_lab:TextField = new TextField();
			display_x_lab.text = "x:";
			display_x_lab.selectable=false;
			display_x_lab.x=785;
			display_x_lab.y=250;
			addChild(display_x_lab);
			
			display_x_val.text = "0";
			display_x_val.selectable=false;
			display_x_val.x=800;
			display_x_val.y=250;
			addChild(display_x_val);
			
			var display_y_lab:TextField = new TextField();
			display_y_lab.text = "y:";
			display_y_lab.selectable=false;
			display_y_lab.x=785;
			display_y_lab.y=270;
			addChild(display_y_lab);
			
			display_y_val.text = "0";
			display_y_val.selectable=false;
			display_y_val.x=800;
			display_y_val.y=270;
			addChild(display_y_val);
		}
		
		internal function clover_button_click(event:Event):void{
			state = "clover";
			refresh_state();
		}
		
		internal function sunflower_button_click(event:Event):void{
			state = "sunflower";
			refresh_state();
		}
		
		internal function potato_button_click(event:Event):void{
			state = "potato";
			refresh_state();
		}
		
		internal function harvest_button_click(event:Event):void{
			state = "harvest";
			refresh_state();
		}
		
		internal function turn_button_click(event:Event):void{
			state = "turn";
			refresh_state();
			//for(var i:Number=0; i<plantsonfield.length; i++){
				//var plnt:plantonfield = plantsonfield[i];
				//if (plnt.pState < 5 && plnt.pImage != null){
					//plnt.pImage.visible = false;
				//}
			//}
			getSituation(state,0,0,0);
		}
		
		internal function refresh_state():void{
			display_status_val.text = state;
		}
		
		internal function renderBG(imageurl:String):void{
			var img:Bitmap = new Bitmap;
			var url:URLRequest = new URLRequest(imageurl);
			var loader:Loader = new Loader();
			loader.load(url);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onMyPictureLoadError);
			function loadProgress(event:ProgressEvent):void
			{
				//var percentLoaded:Number = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
				//trace("Loading: "+percentLoaded+"%");
			}
			function loadComplete(event:Event):void
			{
				//trace("Complete");
				img = (Bitmap)(loader.content);
				img.height = (img.height - img.height % 2) / 2;
				img.width = (img.width - img.width % 2) / 2;
				var s0:Sprite = new Sprite();
				s0.addChild(img);
				s0.addEventListener(MouseEvent.CLICK, plant_some_plant);
				s0.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void{move_plant_click(event)});
				s0.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void{donemove_plant_click(event)});
				addChild(s0);
			}
			function onMyPictureLoadError(event:Event):void
			{
			}
		}
		
		internal function plant_some_plant(event:MouseEvent):void{
			if ((state == "clover")||(state == "sunflower")||(state == "potato")){
				var clickX:Number = event.localX;
				var clickY:Number = event.localY;
				var fieldcoord:Object = decartToIzo(clickX - 58, clickY - 215);
				var fieldX:Number = fieldcoord.x;
				var fieldY:Number = fieldcoord.y;
//				var fieldX:Number = getFieldX(clickX, clickY, 50);
//				var fieldY:Number = getFieldY(clickX, clickY, 50);
				if (fieldX < 0 || fieldY < 0 || fieldX > 60 || fieldY > 60){
					state = "waiting for action"
					refresh_state();
				}
				else{
					getSituation(state,fieldX,fieldY,0);
				}
			}
		}
		
		internal function renderNewImage(imageurl:String,image_x:Number,image_y:Number):void{
			var img:Bitmap = new Bitmap;
			var url:URLRequest = new URLRequest(imageurl);
			var loader:Loader = new Loader();
			loader.load(url);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onMyPictureLoadError);
			function loadProgress(event:ProgressEvent):void
			{
				//var percentLoaded:Number = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
				//trace("Loading: "+percentLoaded+"%");
			}
			function loadComplete(event:Event):void
			{
				//trace("Complete");
				img = (Bitmap)(loader.content);
				img.height = (img.height - img.height % 2) / 2;
				img.width = (img.width - img.width % 2) / 2;
				addChild(img);
			}
			function onMyPictureLoadError(event:Event):void
			{
			}
		}
		
		internal function getSituation(action:String, coordX:Number, coordY:Number, plantid:Number):void
		{
			renderBG("BG.jpg");
			//plantsonfield = new Array();
			var dataXML:XML =  
				<field>
					<act>{action}</act> 
					<x>{coordX}</x> 
					<y>{coordY}</y>
					<id>{plantid}</id>
				</field>;
			var request:URLRequest = new URLRequest(serverurl + "field"); 
			request.contentType = "text/xml"; 
			request.data = dataXML.toXMLString(); 
			request.method = URLRequestMethod.POST; 
			var loader:URLLoader = new URLLoader(); 
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			try 
			{ 
				loader.load(request); 
			} 
			catch (error:ArgumentError) 
			{ 
				trace("An ArgumentError has occurred."); 
			} 
			catch (error:SecurityError) 
			{ 
				trace("A SecurityError has occurred."); 
			}
		}
		
		internal function handleComplete( event:Event):void
		{
			var loader:URLLoader = URLLoader(event.target);
			if(loader != null) {
				var e:XML = new XML(loader.data);
				parseXML(e);
				updateField();
			}
			state = "waiting for action"
			refresh_state();
		}
		
		internal function parseXML(xml:XML):void 
		{  
			plantsonfield = new Array();
			//var country:XML=xml["country"][0];  
			var plants:XMLList=xml["field"][0].child("clover");  
			for(var i:Number=0; i<plants.length(); i++){  
				var xmlplant:XML = plants[i];
				var plant:plantonfield = new plantonfield("clover", xmlplant.attribute("id"), xmlplant.attribute("x"), xmlplant.attribute("y"), xmlplant.attribute("process_end"));
				plantsonfield.push(plant);
			}
			plants=xml["field"][0].child("sunflower");  
			for(i=0; i<plants.length(); i++){  
				xmlplant = plants[i];
				plant = new plantonfield("sunflower", xmlplant.attribute("id"), xmlplant.attribute("x"), xmlplant.attribute("y"), xmlplant.attribute("process_end"));
				plantsonfield.push(plant);
			}
			plants=xml["field"][0].child("potato");  
			for(i=0; i<plants.length(); i++){  
				xmlplant = plants[i];
				plant = new plantonfield("potato", xmlplant.attribute("id"), xmlplant.attribute("x"), xmlplant.attribute("y"), xmlplant.attribute("process_end"));
				plantsonfield.push(plant);
			}
		}
		
		internal function plantarraycontains(array:Array, srch:plantonfield):Boolean{
			for(var i:Number=0; i<array.length; i++){ 
				var elem:plantonfield = array[i];
				if (elem.pId == srch.pId && elem.pName == srch.pName && elem.pState == srch.pState && elem.pX == srch.pX && elem.pY == srch.pY)
				{
					return true;
				}
			}
			return false;
		}
		
		internal function updateField():void{
			for(var i:Number=0; i<plantsonfield.length; i++){ 
				var plant:plantonfield = plantsonfield[i];
				//if (!plantarraycontains(plantsonfield, plant)){
					var founded:Boolean = false;
					for(var j:Number=0; j<plantsimagescache.length; j++){
						var plantimg:cachedimage = plantsimagescache[j];
						if (plant.pName == plantimg.pName && plant.pState == plantimg.pState)
						{
							var thisplantimage:Bitmap = new Bitmap(plantimg.pImage.bitmapData, "auto", false);
							thisplantimage.height = plantimg.pImage.height;
							thisplantimage.width = plantimg.pImage.width;
							renderImage(plant, thisplantimage);
							founded = true;
							break;
						}
					}
					if (!founded)
					{
						getAndRenderImage(plant);
						//founded = false;
					}
				//}
				//if (i == 1) { break;}
			}
			//plantsonfield = newplantsonfield;
		}
		
		internal function renderImage(plantinfo:plantonfield, img:Bitmap):plantonfield{
			//var img:Bitmap = bitmap_cont.pImage;
			img.x = getRealX(plantinfo.pX,plantinfo.pY, img.width);
			img.y = getRealY(plantinfo.pX,plantinfo.pY, img.height);
			//plantinfo.pImage = img;
			//img.name = plantinfo.pId.toString();
			var s1:Sprite = new Sprite();
			s1.addChild(img);
			s1.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{harvest_plant_click(event, plantinfo, img)});
			s1.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void{startmove_plant_click(event, plantinfo, img)});
			s1.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void{move_plant_click(event)});
			s1.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void{donemove_plant_click(event)});
			addChild(s1);
			return plantinfo;
		}
		
		internal function getAndRenderImage(plantinfo:plantonfield):plantonfield{
			var imageurl:String = serverurl + "images/" + plantinfo.pName + "/" + plantinfo.pState + ".png";
			var url:URLRequest = new URLRequest(imageurl);
			var loader:Loader = new Loader();
			loader.load(url);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onMyPictureLoadError);
			function loadProgress(event:ProgressEvent):void
			{
				//var percentLoaded:Number = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
				//trace("Loading: "+percentLoaded+"%");
			}
			function loadComplete(event:Event):void
			{
				//trace("Complete");
				var img:Bitmap = (Bitmap)(loader.content);
				img.height = (img.height - img.height % 2) / 2;
				img.width = (img.width - img.width % 2) / 2;
				plantsimagescache.push(new cachedimage(plantinfo.pName, plantinfo.pState, img));
				img.x = getRealX(plantinfo.pX,plantinfo.pY, img.width);
				img.y = getRealY(plantinfo.pX,plantinfo.pY, img.height);
				//plantinfo.pImage = img;
				//img.name = plantinfo.pId.toString();
				var s2:Sprite = new Sprite();
				s2.addChild(img);
				s2.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{harvest_plant_click(event, plantinfo, img)});
				s2.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void{startmove_plant_click(event, plantinfo, img)});
				s2.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void{move_plant_click(event)});
				s2.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void{donemove_plant_click(event)});
				addChild(s2);
			}
			function onMyPictureLoadError(event:Event):void
			{
			}
			return plantinfo;
		}
		
		internal function harvest_plant_click(event:MouseEvent, plant:plantonfield, img:Bitmap):void{
			if (state == "harvest"){
				if (plant.pState == 5){
					plantsonfield.splice(plantsonfield.indexOf(plant),1);
					img.visible=false;
					getSituation(state, plant.pX, plant.pY, plant.pId);
				}
				state = "waiting for action";
				refresh_state();
			}
			else{
				if ((state == "clover")||(state == "sunflower")||(state == "potato")){
					var fieldcoord:Object = decartToIzo(event.localX - 58, event.localY - 215);
					if (plant.pX == fieldcoord.x && plant.pY == fieldcoord.y){
						state = "waiting for action";
						refresh_state();
						return;
					}
					else{
						plant_some_plant(event);
					}
				}
				state = "waiting for action";
				refresh_state();
			}
		}
		
		internal function startmove_plant_click(event:MouseEvent, plant:plantonfield , img:Bitmap):void{
			if (state == "waiting for action"){
				state = "move"
				refresh_state();
				movingplant = plant;
				movingplantimg_startplace = new Bitmap(img.bitmapData, "auto", false);
				movingplantimg_startplace.width = img.width;
				movingplantimg_startplace.height = img.height;
				movingplantimg_startplace.x = img.x;
				movingplantimg_startplace.y = img.y;
				movingplantimg_startplace.visible = false;
				movingplantimg = img;
			}
		}
		
		internal function move_plant_click(event:MouseEvent):void{
			var fieldcoord:Object = decartToIzo(event.stageX - 58 ,event.stageY - 215);
			if (state == "move"){
				var newx:Number = event.stageX - movingplantimg.width + 35;
				var newy:Number = event.stageY - movingplantimg.height + 15;
				movingplantimg.x = newx;
				movingplantimg.y = newy;
			}
		}
		
		internal function donemove_plant_click(event:MouseEvent):void{
			if (state == "move"){
				var fieldcoord:Object = decartToIzo(event.stageX - 58 ,event.stageY - 215);
				var newx:Number = fieldcoord.x;
				var newy:Number = fieldcoord.y;
//				var newx:Number = getFieldX(event.stageX ,event.stageY, movingplantimg.height);
//				var newy:Number = getFieldY(event.stageX, event.stageY, movingplantimg.height);
				var posibblemove:Boolean = true;
				var plnt:plantonfield;
				if (newx < 0 || newy < 0 || newx > 60 || newy > 60){
					plnt = movingplant;
					posibblemove = false;
				}
				else{
					for(var i:Number=0; i<plantsonfield.length; i++){ 
						plnt = plantsonfield[i];
						if (plnt.pX == newx && plnt.pY == newy){
							posibblemove = false;
							break;
						}
					}
				}
				if (!posibblemove){
					movingplantimg_startplace.visible = true;
					var s2:Sprite = new Sprite();
					s2.addChild(movingplantimg_startplace);
					s2.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void{harvest_plant_click(event, plnt, movingplantimg_startplace)});
					s2.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void{startmove_plant_click(event, plnt, movingplantimg_startplace)});
					s2.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void{move_plant_click(event)});
					s2.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void{donemove_plant_click(event)});
					addChild(s2);
					movingplantimg.visible = false;
					state = "waiting for action";
					refresh_state();
				}
				else{
					plantsonfield.splice(plantsonfield.indexOf(plnt),1);
					movingplantimg.visible = false;
					getSituation(state, newx, newy, movingplant.pId);
				}
			}
		}
		
		internal function getRealX(x:Number, y:Number, w:Number):Number{
			var newX:Number =  (58 + 5 * (x + y));
			return newX;
		}
		
		internal function getRealY(x:Number, y:Number, h:Number):Number{
			var newY:Number =(215 + 12.5 - (h) + 2.5 * (x - y));
			return newY - (newY % 1);
		}
		
		internal function getField_X(rx:Number, ry:Number, rh:Number):Number{
			//var newX:Number = (rx + ry - 248)/10;
			var newX:Number = (rx + 2*ry + 2*rh - 450)/10;
			return newX - newX % 5;
		}
		
		internal function getField_Y(rx:Number, ry:Number, rh:Number):Number{
			//var newY:Number = (rx - ry + 132)/10;
			var newY:Number = (rx - 2*ry - 2*rh + 397)/10;
			return newY - newY % 5;
		}
		
		internal function decartToIzo (x:Number, y:Number):Object {
			var i:Number = (x / 4 + y / 2)/12;
			var j:Number = (x / 4 - y / 2)/12;
			i = (i - i % 1) * 5;
			j = (j - j % 1) * 5;
			display_x_val.text = i.toString();
			display_y_val.text = j.toString();
			return {x:i, y:j};
		}
	}
}
import flash.display.Bitmap;

import org.osmf.elements.ImageElement;

class cachedimage extends Object{
	public var pName:String;
	public var pState:Number;
	public var pImage:Bitmap;
	public function cachedimage(p_Name:String, p_State:Number, p_Image:Bitmap){
		pName = p_Name;
		pState = p_State;
		pImage = p_Image;
	}
}

class plantonfield extends Object{
	public var pName:String;
	public var pId:Number;
	public var pX:Number;
	public var pY:Number;
	public var pState:Number;
	//public var pImage:Bitmap;
	public function plantonfield(p_Name:String, p_Id:Number, p_X:Number, p_Y:Number, p_State:Number){
		pName = p_Name;
		pId = p_Id;
		pX = p_X;
		pY = p_Y;
		pState = p_State;
	}
} 

import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

class PushButton extends SimpleButton
{
	private var button_x:Number=0;
	private var button_y:Number=0;
	private var button_width:Number=0;
	private var button_height:Number=0;
	private var button_text:String="";
	
	public function PushButton(buttonX:Number, 
							   buttonY:Number, 
							   buttonWidth:Number, 
							   buttonHeight:Number, 
							   buttonText:String)
	{
		button_x=buttonX;
		button_y=buttonY;
		button_width=buttonWidth;
		button_height=buttonHeight;
		button_text=buttonText;
		
		upState=button_sprite(0x888888);
		overState=button_sprite(0x999999);
		downState=button_sprite(0xAAAAAA);
		hitTestState=button_sprite(0xBBBBBB);
		
		x=buttonX;
		y=buttonY;
	}
	
	
	private function button_sprite(color:uint = 0x888888):Sprite
	{
		
		var b_sprite:Sprite=new Sprite();
		
		b_sprite.graphics.lineStyle(1);
		b_sprite.graphics.beginFill(color);
		b_sprite.graphics.drawRect(0, 0, button_width,  button_height);
		b_sprite.graphics.endFill();
		
		var button_label:TextField;
		button_label=new TextField();
		button_label.text=button_text;
		button_label.selectable = false;
		button_label.autoSize=TextFieldAutoSize.CENTER;
		button_label.x=(button_width-button_label.textWidth)/2-1;
		button_label.y=(button_height-button_label.textHeight)/2-2;
		
		b_sprite.addChild(button_label);
		
		return b_sprite;
	}
	
}

//TODO: 
// 1. обрабытывать видимость (растение на переднем плане загораживает растение на заднем)
// 2. убрать перерисовку не изменившихся эллементов (бэкграунд, растения)