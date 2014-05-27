package {

import flash.display.Shape;
import flash.geom.Rectangle;
import flash.geom.Point;

public class Keytop extends Shape
{
  public const BORDER_COLOR:uint = 0x666666;

  private var _color:uint;
  private var _rect:Rectangle;
  private var _duration:int;
  private var _count:int;
  private var _highlit:Boolean;
  
  public function Keytop(rect:Rectangle)
  {
    x = rect.x;
    y = rect.y;
    _rect = rect;
    repaint();
  }
  
  public function get rect():Rectangle
  {
    return _rect.clone();
  }

  public function repaint():void
  {
    graphics.clear();
    graphics.lineStyle(0, BORDER_COLOR);
    graphics.drawRect(0, 0, _rect.width, _rect.height);
    if (_count < _duration) {
      graphics.beginFill(_color, 1.0-_count/_duration);
      graphics.drawRect(0, 0, _rect.width, _rect.height);
    }
  }

  public function activate(color:uint, duration:int=10):void
  {
    _color = color;
    _duration = duration;
    _count = 0;
    repaint();
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
