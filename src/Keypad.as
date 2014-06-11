package {

import flash.display.Sprite;
import flash.events.MouseEvent;
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

  private var _cols:int;
  private var _width:int;
  private var _height:int;

  private var _keycode2key:Array;
  private var _pos2key:Array;
  private var _keys:Array;
  private var _particles:Array;
  private var _focus:Keytop;

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

    addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
    addEventListener(MouseEvent.MOUSE_OVER, onMouseMove);
    addEventListener(MouseEvent.MOUSE_OUT, onMouseMove);
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

  public function mousedown(p:Point):void
  {
    var key:Keytop = getKeyByCoords(p.x, p.y);
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

  public function flashAll(duration:int=30):void
  {
    for each (var key:Keytop in _keys) {
      if (key.parent == this) {
	key.flash(0, duration);
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

    for each (var part:Particle in _particles) {
      removeChild(part);
    }
    _particles = new Array();
  }

  public function layoutFull(kw:int=32, kh:int=32, margin:int=4):void
  {
    _cols = 0;
    _width = 0;
    _height = 0;
    for each (var key:Keytop in _keys) {
      var pos:Point = key.pos;
      var dx:int = kw*pos.y / KEYCODES.length;
      key.rect = new Rectangle((kw + margin) * pos.x + dx,
			       (kh + margin) * pos.y,
			       kw, kh);
      addChild(key);
      _cols = Math.max(_cols, pos.x+1);
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
    _cols = n;
    _width = w;
    _height = size;
  }

  public function getPan(x:int):Number
  {
    var n:int = Math.floor(_cols/2);
    return (x-n)/(n-1);
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

  public function getKeyByCoords(x:int, y:int):Keytop
  {
    for each (var key:Keytop in _keys) {
      if (key.parent == this) {
	if (key.rect.contains(x, y)) return key;
      }
    }
    return null;
  }

  public function makeParticle(rect:Rectangle, color:uint, 
			       duration:int=10, speed:int=2):Particle
  {
    var part:Particle = new Particle(rect, color, duration, speed);
    _particles.push(part);
    addChildAt(part, 0);
    return part;
  }

  private function onMouseMove(e:MouseEvent):void
  {
    var key:Keytop = getKeyByCoords(e.localX, e.localY);
    if (_focus != key) {
      if (_focus != null) {
	_focus.highlight = false;
      }
      _focus = key;
      if (_focus != null) {
	_focus.highlight = true;
      }
    }
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
			   duration:int=10, count:int=0, speed:int=2)
  {
    _rect = rect;
    _color = color;
    _duration = duration;
    _count = count;
    _speed = speed;
  }

  public function update():void
  {
    var w:int = _count*_speed;
    var color:uint = (_color != 0)? _color : Utils.rnd(0xffffff);
    x = _rect.x-w;
    y = _rect.y-w;
    graphics.clear();
    graphics.beginFill(color, 1.0-_count/_duration);
    graphics.drawRect(0, 0, _rect.width+w*2, _rect.height+w*2);
    _count++;
    if (_duration <= _count) {
      visible = false;
    }
  }
}
