package {

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.geom.Point;

public class Keypad extends Sprite
{
  public static const KEYCODES:Array = 
    [
     [ 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 189, 187 ], // "1234567890-="
     [ 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 219, 221 ], // "qwertyuiop[]"
     [ 65, 83, 68, 70, 71, 72, 74, 75, 76, 186, 222 ],	   // "asdfghjkl;'"
     [ 90, 88, 67, 86, 66, 78, 77, 188, 190, 191 ],	   // "zxcvbnm,./"
     ];

  private var _width:int;
  private var _height:int;

  private var _keycode2key:Array;
  private var _pos2key:Array;
  private var _keys:Array;
  private var _particles:Array;

  public function Keypad()
  {
    _keys = new Array();
    _keycode2key = new Array(256);
    _pos2key = new Array(KEYCODES.length);

    for (var y:int = 0; y < KEYCODES.length; y++) {
      var row:Array = KEYCODES[y];
      _pos2key[y] = new Array(row.length);
      for (var x:int = 0; x < row.length; x++) {
	var code:int = row[x];
	var pos:Point = new Point(x, y);
	var key:Keytop = new Keytop(pos);
	_keycode2key[code] = key;
	_pos2key[y][x] = key;
	_keys.push(key);
      }
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

  public function get rect():Rectangle
  {
    return new Rectangle(x, y, _width, _height);
  }

  public function keydown(keycode:int):void
  {
    var key:Keytop = getKeyByCode(keycode);
    if (key != null) {
      dispatchEvent(new KeypadEvent(KeypadEvent.PRESSED, key));
    }
  }

  public function update():void
  {
    for each (var key:Keytop in _keys) {
      if (key.parent == this) {
	key.update();
      }
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

  public function clear():void
  {
    for each (var key:Keytop in _keys) {
      if (key.parent == this) {
	removeChild(key);
      }
    }
  }

  public function layoutFull(kw:int=32, kh:int=32, margin:int=4):void
  {
    _width = 0;
    _height = 0;
    for each (var key:Keytop in _keys) {
      var pos:Point = key.pos;
      var dx:int = kw*pos.y / rows;
      key.rect = new Rectangle((kw + margin) * pos.x + dx,
			       (kh + margin) * pos.y,
			       kw, kh);
      addChild(key);
      _width = Math.max(key.rect.right);
      _height = Math.max(key.rect.bottom);
    }
  }

  public function layoutLine(n:int, w:int):void
  {
    var unit:int = w/(5*(n-1)+4);
    var size:int = unit*4;
    for (var i:int = 0; i < n; i++) {
      var key:Keytop = getKeyByPos(i, 0);
      key.rect = new Rectangle((size+unit) * i, 0, size, size);
      addChild(key);
    }
    _width = w;
    _height = size;
  }

  public function flash(key:Keytop, color:uint):void
  {
    if (key.rect != null) {
      makeParticle(key.rect, color);
    }
  }

  public function getKeyByCode(code:int):Keytop
  {
    if (0 <= code && code < _keycode2key.length) {
      return _keycode2key[code];
    }
    return null;
  }

  public function getKeyByPos(x:int, y:int):Keytop
  {
    if (0 <= y && y < _pos2key.length) {
      var a:Array = _pos2key[y];
      if (0 <= x && x < a.length) {
	return a[x];
      }
    }
    return null;
  }

  public function makeParticle(rect:Rectangle, color:uint, 
			       duration:int=10, speed:int=2):Particle
  {
    var part:Particle = new Particle(rect, color, duration, speed);
    _particles.push(part);
    addChild(part);
    return part;
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
    if (_color != 0) {
      graphics.beginFill(_color, 1.0-_count/_duration);
    } else {
      graphics.lineStyle(1, Keytop.BORDER_COLOR);
    }
    graphics.drawRect(0, 0, _rect.width+w*2, _rect.height+w*2);
    _count++;
    if (_duration <= _count) {
      visible = false;
    }
  }
}
