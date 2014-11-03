package haxe.ui.toolkit.core;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import haxe.ui.toolkit.controls.popups.Popup;
import haxe.ui.toolkit.core.Component;
import haxe.ui.toolkit.core.Screen;
import haxe.ui.toolkit.layout.AbsoluteLayout;

class Root extends Component {
	private var _modalOverlay:Component;
	private var _modalOverlayCounter:Int = 0;
	
	private var _mousePos:Point;
	
	public function new() {
		super();
		_layout = new AbsoluteLayout();
		#if !html5
		_clipContent = false;
		#else
		_clipContent = false;
		#end
		_mousePos = new Point(0, 0);
		Screen.instance.addEventListener(Event.RESIZE, _onScreenResize);
	}

	//******************************************************************************************
	// Overrides
	//******************************************************************************************
	private override function preInitialize():Void {
		super.preInitialize();
		addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent) {
			_mousePos = new Point(event.stageX, event.stageY);
		});
		resizeRoot();
	}
	
	//******************************************************************************************
	// Event handlers
	//******************************************************************************************
	private function _onScreenResize(event:Event):Void {
		resizeRoot();
	}

	//******************************************************************************************
	// Instance fields
	//******************************************************************************************
	public var mousePosition(get, null):Point;

	private function get_mousePosition():Point {
		return _mousePos;
	}
	
	//******************************************************************************************
	// Helpers
	//******************************************************************************************
	public function add(item:Dynamic) {
		var r = null;
		if (Std.is(item, String)) {
			r = addChild(Toolkit.processXmlResource(cast item));
		} else if (Std.is(item, Controller)) {
			r = addChild(cast(item, Controller).view);
		} else {
			trace(item + " item not supported in Root.add");
		}
		return r;
	}
	
	private function resizeRoot():Void {
		if (percentWidth > 0) {
			width = (Screen.instance.width * percentWidth) / 100; 
		}
		if (percentHeight > 0) {
			height = (Screen.instance.height * percentHeight) / 100; 
		}
		
		//sprite.scrollRect = new Rectangle(0, 0, width, height);
	}
	
	public function showModalOverlay():Void {
		_modalOverlayCounter++;
		
		if (_modalOverlay == null) {
			_modalOverlay = new Component();
			_modalOverlay.id = "modalOverlay";
			_modalOverlay.percentWidth = _modalOverlay.percentHeight = 100;
		}
		if (findChild("modalOverlay") == null) {
			addChild(_modalOverlay);
		}
		_modalOverlay.visible = true;
		
		#if !(android)
		for (child in children) {
			if (Std.is(child, Popup) == false && child.id != "modalOverlay") {
				var c:Component = cast(child, Component);
			}
		}
		#end
	}
	
	public function hideModalOverlay():Void {
		_modalOverlayCounter--;
		if (_modalOverlayCounter <= 0) {
			if (_modalOverlay != null) {
				_modalOverlay.visible = false;
			}
			
			#if !(android)
			for (child in children) {
				if (Std.is(child, Popup) == false && child.id != "modalOverlay") {
					var c:Component = cast(child, Component);
				}
			}
			#end
			_modalOverlayCounter = 0;
		}
	}
}