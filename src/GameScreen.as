package {

import flash.media.Sound;
import flash.media.SoundTransform;
import flash.geom.Rectangle;
import baseui.Screen;
import baseui.ScreenEvent;

//  GameScreen
//
public class GameScreen extends Screen
{
  [Embed(source="../assets/correct.mp3", mimeType="audio/mpeg")]
  private static const CorrectSoundCls:Class;
  private const correctSound:Sound = new CorrectSoundCls();
  [Embed(source="../assets/wrong.mp3", mimeType="audio/mpeg")]
  private static const WrongSoundCls:Class;
  private const wrongSound:Sound = new WrongSoundCls();
  [Embed(source="../assets/next.mp3", mimeType="audio/mpeg")]
  private static const NextSoundCls:Class;
  private const nextSound:Sound = new NextSoundCls();

  private const MAX_MISS:int = 3;

  private var _status:Status;
  private var _arpeggio:Arpeggio;
  private var _keypad:Keypad;

  private var _repeat:int;
  private var _noteleft:int;

  private var _start:int;
  private var _ticks:int;
  private var _interval:int;
  private var _nextnote:int;

  public function GameScreen(width:int, height:int)
  {
    super(width, height);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-16);
    addChild(_status);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    addChild(_keypad);

    _arpeggio = new Arpeggio();
  }

  // open()
  public override function open():void
  {
    _status.level = 0;
    _status.score = 0;
    _status.miss = 0;
    _status.update();

    _ticks = 0;
    _start = 0;
    setupLevel();
  }

  // close()
  public override function close():void
  {
  }

  // pause()
  public override function pause():void
  {
  }

  // resume()
  public override function resume():void
  {
  }

  // update()
  public override function update():void
  {
    if (_start < _ticks) {
      if ((_ticks % _interval) == 0) {
	if (_repeat != 0) {
	  // auto play
	  playKey(_nextnote);
	  incKey();
	}
      }
    }

    graphics.clear();
    drawBand(_ticks);
    drawBand(_ticks+3);
    graphics.lineStyle(0, Keytop.BORDER_COLOR);
    graphics.moveTo(0, screenHeight/2);
    graphics.lineTo(screenWidth, screenHeight/2);

    _keypad.update();
    _ticks++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _keypad.keydown(keycode);
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
  }

  private function onKeypadPressed(e:KeypadEvent):void
  {
    var keypad:Keypad = Keypad(e.target);
    var i:int = e.key.pos.x;
    if (_repeat == 0) {
      if (i == _nextnote) {
	playKey(_nextnote);
	incKey();
      }
    } else if (i < _arpeggio.numNotes) {
      var key:Keytop = _keypad.getKeyByPos(i, 0);
      var pan:Number = _keypad.getPan(i);
      _keypad.flash(key, 0);
      if (_arpeggio.hitNoise(i)) {
	correctSound.play(0, 0, new SoundTransform(1.0, pan));
	key.highlight(0xffffff);
	_status.score++;
	_status.update();
	_noteleft--;
      } else {
	wrongSound.play(0, 0, new SoundTransform(1.0, pan));
	key.highlight(0);
	_status.miss++;
	_status.update();
	if (MAX_MISS < _status.miss) {
	  gameOver();
	}
      }
    }
  }

  private function playKey(i:int):void
  {
    var color:uint = _arpeggio.getColor(i);
    var key:Keytop = _keypad.getKeyByPos(i, 0);
    key.highlight(color);
    _keypad.flash(key, color);
    _arpeggio.playNote(i, _keypad.getPan(i));
  }

  private function incKey():void
  {
    _nextnote++;
    if (_arpeggio.numNotes <= _nextnote) {
      if (_repeat == 0) {
	_start = _ticks+15;
      }
      _repeat++;
      setupNoise();
    }
  }

  private function setupNoise():void
  {
    _nextnote = 0;

    if (_noteleft == 0) {
      // Next level.
      _status.level++;
      _status.update();
      setupLevel();

    } else if (_repeat < 3) {
      // Play first twice for free.

    } else {
      // Add noise.
      var i:int = (_repeat-3);
      var n:int = 0;
      switch (_status.level) {
      case 0:
      case 1:
	n = ((i % 2) == 0)? 1 : 0;
	break;
      }
      n = Math.min(n, _noteleft);
      if (!_arpeggio.addNoise(n)) {
	gameOver();
      }
    }
  }

  private function setupLevel():void
  {
    // Setup a new tune.
    switch (_status.level) {
    case 0:
      _arpeggio.setTune(Arpeggio.TUNE0, Arpeggio.NOISE0);
      _interval = 10;
      _noteleft = 4;
      break;

    case 1:
      _arpeggio.setTune(Arpeggio.TUNE1, Arpeggio.NOISE1);
      _interval = 8;
      _noteleft = 6;
      break;

    }

    _keypad.clear();
    _keypad.layoutLine(_arpeggio.numNotes, screenWidth/2);
    _keypad.x = (screenWidth-_keypad.rect.width)/2;
    _keypad.y = (screenHeight-_keypad.rect.height)/2;
    _repeat = 0;
    _nextnote = 0;

    nextSound.play();
    _arpeggio.playNote(0, 0, 0.5, 2.0);
  }

  private function gameOver():void
  {
  }

  private function drawBand(t:int):void
  {
    t = 30-(t % 30);
    var r:Rectangle = _keypad.rect;
    var cx:int = screenWidth/2;
    var cy:int = screenHeight/2;
    var dx0:Number = screenWidth*2/t;
    var dy0:Number = screenHeight/2/t;
    var dx1:Number = screenWidth*2/(t+0.5);
    var dy1:Number = screenHeight/2/(t+0.5);
    graphics.lineStyle(0);
    graphics.beginFill(0x333333);
    if ((screenWidth*3/r.width) < t) {
      graphics.moveTo(cx-dx1, cy);
      graphics.lineTo(cx-dx0, cy);
      graphics.lineTo(cx-dx0, cy-dy0*2);
      graphics.lineTo(cx+dx0, cy-dy0*2);
      graphics.lineTo(cx+dx0, cy);
      graphics.lineTo(cx+dx1, cy);
      graphics.lineTo(cx+dx1, cy-dy1*2);
      graphics.lineTo(cx-dx1, cy-dy1*2);
    } else {
      graphics.moveTo(cx-dx1, cy+dy1);
      graphics.lineTo(cx-dx0, cy+dy0);
      graphics.lineTo(cx+dx0, cy+dy0);
      graphics.lineTo(cx+dx1, cy+dy1);
    }
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.media.Sound;
import flash.media.SoundChannel;
import baseui.Font;


//  Arpeggio
// 
class Arpeggio extends Object
{
  public static const TUNE0:String = "C4 G4 E4 G4";
  public static const NOISE0:String = "B3 A4s C4s C5s";

  public static const TUNE1:String = "F4 C4 A4 C5";
  public static const NOISE1:String = "G4 B3 C5s D5s";
  
  public static const TUNE2:String = "C4 G3 D4 G4 E4 G4";
  public static const NOISE2:String = "B3 D4s C4s F4s D4s C4s";

  public static const TUNE3:String = "C4 A3 D4s A3 F4 G3s";
  public static const NOISE3:String = "B3 D4s C4s F4s D4s C4s";

  public static const TUNE4:String = "C5 G4 F4 G4 C5 G4 E4 G4";
  public static const NOISE4:String = "C4s C5s D4s A3s F4s G4s A4s";

  public static const TUNE5:String = "G3 C4 E4 G3 E4 G3 E4 G3";

  public static const TUNE6:String = "D5s A4 F4s A4 D5s A4 F4 A4";

  public static const TUNE7:String = "A4 A5 E5 F5 A5 E5 F5 A5";

  public var volume:Number = 0.1;

  private var _tune:Array;
  private var _noisesrc:Array;
  private var _noise:Array;

  public function Arpeggio()
  {
  }

  public function setTune(tune:String, noisesrc:String):void
  {
    _tune = tune.split(/ /);
    _noisesrc = noisesrc.split(/ /);
    clearNoise();
  }
  
  public function clearNoise():void
  {
    _noise = new Array(_tune.length);
    for (var i:int = 0; i < _noise.length; i++) {
      _noise[i] = null;
    }
  }

  public function addNoise(n:int):Boolean
  {
    var left:int = 0;
    var i:int;
    for (i = 0; i < _noise.length; i++) {
      if (_noise[i] == null) {
	left++;
      }
    }
    while (0 < n) {
      if (left == 0) return false;
      while (true) {
	i = Utils.rnd(_tune.length);
	if (_noise[i] == null) break;
      }
      _noise[i] = _noisesrc[i];
      left--;
      n--;
    }
    return true;
  }

  public function hitNoise(i:int):Boolean
  {
    var b:Boolean = (_noise[i] != null);
    _noise[i] = null;
    return b;
  }

  public function get numNotes():int
  {
    return _tune.length;
  }

  public function getNote(i:int):String
  {
    var note:String = _noise[i];
    if (note == null) {
      note = _tune[i];
    }
    return note;
  }

  public function getColor(i:int):uint
  {
    if (_noise[i] != null) {
      return 0x444444;
    }
    switch (_tune[i].charAt(0)) {
    case "C": return 0xff0000;
    case "D": return 0x00cc00;
    case "E": return 0x0022ff;
    case "F": return 0xcccc00;
    case "G": return 0xff00ff;
    case "A": return 0xff4400;
    case "B": return 0x440000;
    default: return 0x444444;
    }
  }

  public function playNote(i:int, pan:Number, attack:Number=0.01, decay:Number=0.3):void
  {
    var note:String = getNote(i);
    if (note) {
      var sound:SoundGenerator = new SoundGenerator(SoundGenerator.RECT);
      sound.pitch = SoundGenerator.getPitch(note);
      sound.pan = pan;
      sound.volume = volume;
      sound.attack = attack;
      sound.decay = decay;
      sound.play();
    }
  }
}


//  Status
// 
class Status extends Sprite
{
  public var level:int;
  public var score:int;
  public var miss:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("LEVEL: 00   SCORE: 00   MISS: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "LEVEL: "+Utils.format(level,2);
    text += "   SCORE: "+Utils.format(score,2);
    text += "   MISS: "+Utils.format(miss,2);
    Font.renderText(_text.bitmapData, text);
  }
}


//  Overlay
// 
class Overlay extends Sprite
{
}
