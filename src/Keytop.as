package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

public class Keytop extends Shape
{
  public const BORDER_COLOR:uint = 0x666666;

  private var _pos:Point;
  private var _rect:Rectangle;
  private var _color:uint;
  private var _duration:int;
  private var _count:int;
  
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
    repaint();
  }
  
  public function get rect():Rectangle
  {
    return _rect;
  }

  public function blink(color:uint, duration:int=10):void
  {
    _color = color;
    _duration = duration;
    _count = 0;
    repaint();
  }

  public function repaint():void
  {
    if (_rect != null) {
      x = _rect.x;
      y = _rect.y;
      graphics.clear();
      graphics.lineStyle(0, BORDER_COLOR);
      graphics.drawRect(0, 0, _rect.width, _rect.height);
      if (_count < _duration) {
	graphics.beginFill(_color, 1.0-_count/_duration);
	graphics.drawRect(0, 0, _rect.width, _rect.height);
      }
    }
  }

  public function update(t:int):void
  {
    if (_duration) {
      _count++;
      repaint();
    }
  }
}

} // package
