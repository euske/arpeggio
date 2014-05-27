package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

public class Keypad extends Sprite
{
  public static const MARGIN:int = 4;
  public static const KEY_WIDTH:int = 32;
  public static const KEY_HEIGHT:int = 32;

  public static const KEYCODES:Array = 
    [
     [ 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 189, 187 ], // "1234567890-="
     [ 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 219, 221 ], // "qwertyuiop[]"
     [ 65, 83, 68, 70, 71, 72, 74, 75, 76, 186, 222 ],	   // "asdfghjkl;'"
     [ 90, 88, 67, 86, 66, 78, 77, 188, 190, 191 ],	   // "zxcvbnm,./"
     ];

  private var _keycode2pt:Array;
  private var _pt2key:Array;
  private var _keys:Array;
  private var _particles:Array;

  public function Keypad()
  {
    var x:int, y:int, row:Array;
    _keycode2pt = new Array(256);
    for (y = 0; y < KEYCODES.length; y++) {
      row = KEYCODES[y];
      for (x = 0; x < row.length; x++) {
	var code:int = row[x];
	_keycode2pt[code] = new Point(x, y);
      }
    }

    _keys = new Array();
    _pt2key = new Array(KEYCODES.length);
    for (y = 0; y < _pt2key.length; y++) {
      row = new Array(KEYCODES[y].length);
      for (x = 0; x < row.length; x++) {
	var r:Rectangle = getKeyRect(x, y);
	var key:Keytop = new Keytop(r);
	addChild(key);
	row[x] = _keys.length;
	_keys.push(key);
      }
      _pt2key[y] = row;
    }

    _particles = new Array();
  }

  public function get rows():int
  {
    return KEYCODES.length;
  }

  public function get cols():int
  {
    return KEYCODES[0].length;
  }

  public function get keys():Array
  {
    return _keys;
  }

  public function keydown(keycode:int):void
  {
    var p:Point = getPoint(keycode);
    if (p != null) {
      dispatchEvent(new KeypadEvent(KeypadEvent.PRESSED, p));
    }
  }

  public function update(t:int):void
  {
    for each (var key:Keytop in _keys) {
      key.update(t);
    }
    for (var i:int = 0; i < _particles.length; i++) {
      var part:Particle = _particles[i];
      part.update();
      if (!part.visible) {
	_particles.splice(i, 1);
	i--;
	removeChild(part);
      }
    }
  }

  public function makeParticle(rect:Rectangle, color:uint, 
			       duration:int=10, speed:int=2):Particle
  {
    var part:Particle = new Particle(rect, color, duration, speed);
    _particles.push(part);
    addChild(part);
    return part;
  }

  public function getPoint(keycode:int):Point
  {
    if (keycode < 0 || _keycode2pt.length <= keycode) return null;
    return _keycode2pt[keycode];
  }

  public function getKeyRect(x:int, y:int):Rectangle
  {
    var dx:int = KEY_WIDTH*y / 4;
    return new Rectangle((KEY_WIDTH + MARGIN) * x + dx,
			 (KEY_HEIGHT + MARGIN) * y,
			 KEY_WIDTH,
			 KEY_HEIGHT);
  }

  public function getKey(x:int, y:int):Keytop
  {
    if (0 <= y && y < _pt2key.length) {
      var row:Array = _pt2key[y];
      if (0 <= x && x < row.length) {
	var i:int = row[x];
	return _keys[i];
      }
    }
    return null;
  }
}

} // package

import flash.display.Shape;
import flash.geom.Rectangle;

class Particle extends Shape
{
  private var _rect:Rectangle;
  private var _color:uint;
  private var _duration:int;
  private var _speed:int;
  private var _count:int;
  
  public function Particle(rect:Rectangle, color:uint,
			   duration:int=10, speed:int=2)
  {
    _rect = rect;
    _color = color;
    _duration = duration;
    _speed = speed;
    _count = 0;
  }

  public function update():void
  {
    var w:int = _count*_speed;
    x = _rect.x-w;
    y = _rect.y-w;
    graphics.clear();
    graphics.beginFill(_color, 1.0-_count/_duration);
    graphics.drawRect(0, 0, _rect.width+w*2, _rect.height+w*2);
    _count++;
    if (_duration <= _count) {
      visible = false;
    }
  }
}
