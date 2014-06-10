package {

import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.geom.Point;

public class Keytop extends Shape
{
  public static const HIGHLIT_COLOR:uint = 0xffffff;
  public static const BORDER_COLOR:uint = 0x666666;

  private var _pos:Point;
  private var _rect:Rectangle;
  private var _color:uint;
  private var _duration:int;
  private var _count:int;
  private var _highlight:Boolean;
  private var _invalidated:Boolean;
  
  public function Keytop(pos:Point)
  {
    _pos = pos;
  }

  public override function toString():String
  {
    return ("<Keytop: "+_pos.x+","+_pos.y+">");
  }

  public function get pos():Point
  {
    return _pos;
  }

  public function set rect(v:Rectangle):void
  {
    _rect = v;
    _invalidated = true;
  }
  
  public function get rect():Rectangle
  {
    return _rect;
  }

  public function set highlight(v:Boolean):void
  {
    _highlight = v;
    _invalidated = true;
  }
  
  public function get highlight():Boolean
  {
    return _highlight;
  }

  public function flash(color:uint, duration:int):void
  {
    _count = 0;
    _color = color;
    _duration = duration;
    _invalidated = true;
  }

  public function repaint():void
  {
    if (_rect != null) {
      x = _rect.x;
      y = _rect.y;
      graphics.clear();
      if (_highlight) {
	graphics.lineStyle(2, HIGHLIT_COLOR);
      } else {
	graphics.lineStyle(0, BORDER_COLOR);
      }
      graphics.beginFill(0);
      graphics.drawRect(0, 0, _rect.width, _rect.height);
      if (_count < _duration) {
	var color:uint = (_color != 0)? _color : Utils.rnd(0xffffff);
	graphics.beginFill(color, 1.0-_count/_duration);
	graphics.drawRect(0, 0, _rect.width, _rect.height);
      }
    }
  }

  public function update():void
  {
    if (_duration) {
      _count++;
      _invalidated = true;
    }
    if (_invalidated) {
      _invalidated = false;
      repaint();
    }
  }
}

} // package
