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

  private var _status:Status;
  private var _arpeggio:Arpeggio;
  private var _keypad:Keypad;

  private var _start:int;
  private var _ticks:int;
  private var _interval:int;
  private var _toplay:int;
  private var _repeat:int;
  private var _tune:int;

  public function GameScreen(width:int, height:int)
  {
    super(width, height);

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = 4;
    addChild(_status);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    addChild(_keypad);

    _arpeggio = new Arpeggio();
  }

  // open()
  public override function open():void
  {
    _status.score = 0;
    _status.miss = 0;
    _status.update();
    _ticks = 0;
    _start = 0;
    _interval = 12;
    _toplay = 0;
    prepareTune();
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
    if (_start < _ticks && (_ticks % _interval) == 0) {
      if (0 < _repeat) {
	if (_toplay == 0) {
	  prepareTune();
	}
	playKey(_toplay);
	incKey();
      }
    }

    graphics.clear();
    graphics.lineStyle(0, Keytop.BORDER_COLOR);
    graphics.moveTo(0, screenHeight/2);
    graphics.lineTo(screenWidth, screenHeight/2);
    drawBackground((_ticks % 30)-15);

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
      if (i == _toplay) {
	playKey(_toplay);
	incKey();
      }
    } else if (i < _arpeggio.numNotes) {
      var key:Keytop = _keypad.getKeyByPos(i, 0);
      var pan:Number = _keypad.getPan(i);
      _keypad.flash(key, 0);
      if (_arpeggio.hitCorruption(i)) {
	correctSound.play(0, 0, new SoundTransform(1.0, pan));
	key.highlight(0xffffff);
	_status.score++;
	_status.update();
      } else {
	wrongSound.play(0, 0, new SoundTransform(1.0, pan));
	key.highlight(0);
	_status.miss++;
	_status.update();
      }
    }
  }

  private function prepareTune():void
  {
    if (0 < _repeat) {
      if (2 < _repeat && (_repeat % 2) == 1) {
	_arpeggio.addCorruption(1);
      }
      return;
    }

    _arpeggio.setTune(Arpeggio.PAT0, Arpeggio.WRONG0);
    _keypad.clear();
    _keypad.layoutLine(_arpeggio.numNotes, screenWidth-200);
    _keypad.x = (screenWidth-_keypad.rect.width)/2;
    _keypad.y = (screenHeight-_keypad.rect.height)/2;
    _repeat = 0;

    nextSound.play();
    _start = _ticks+24;
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
    _toplay = (_toplay+1) % _arpeggio.numNotes;
    if (_toplay == 0) {
      _repeat++;
    }
  }

  private const vx:int = 12;
  private const vy:int = 4;
  private function drawBackground(t:int):void
  {
    var r:Rectangle = _keypad.rect;
    var y0:int = screenHeight/2;
    if (t < 0) { 
      var h:Number = screenHeight/4+vy*t;
      graphics.lineStyle(0, 0x666666);
      graphics.drawRect(r.left-vx*t, y0-h,
			r.width+2*vx*t, h);
    } else if (t < 10) {
      var t0:Number = 40/(10-t);
      var t1:Number = 40/(10.5-t);
      graphics.beginFill(0x666666);
      graphics.moveTo(r.left-vx*t0, y0+vy*t0);
      graphics.lineTo(r.left-vx*t1, y0+vy*t1);
      graphics.lineTo(r.right+vx*t1, y0+vy*t1);
      graphics.lineTo(r.right+vx*t0, y0+vy*t0);
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
  public static const PAT0:String = "C4 G4 E4 G4";
  public static const WRONG0:String = "C4s F4 F4 A4s";
  
  public static const PAT1:String = "C5 G4 F4 G4 C5 G4 E4 G4";
  public static const WRONG1:String = "C4s C5s D4s A3s F4s G4s A4s";

  public static const PAT2:String = "D5s A4 F4s A4 D5s A4 F4 A4";
  public static const PAT3:String = "A4 A5 E5 F5 A5 E5 F5 A5";

  public var volume:Number = 0.1;
  public var attack:Number = 0.01;
  public var decay:Number = 0.3;

  private var _notes:Array;
  private var _wrongs:Array;
  private var _corrupted:Array;

  public function Arpeggio()
  {
  }

  public function setTune(pat:String, wrongpat:String):void
  {
    _notes = pat.split(/ /);
    _wrongs = wrongpat.split(/ /);
    clearCorruption();
  }
  
  public function clearCorruption():void
  {
    _corrupted = new Array(_notes.length);
    for (var i:int = 0; i < _corrupted.length; i++) {
      _corrupted[i] = null;
    }
  }

  public function addCorruption(n:int):void
  {
    var left:int = 0;
    var i:int;
    for (i = 0; i < _corrupted.length; i++) {
      if (_corrupted[i] == null) {
	left++;
      }
    }
    while (0 < n && 0 < left) {
      while (true) {
	i = Utils.rnd(_notes.length);
	if (_corrupted[i] == null) break;
      }
      _corrupted[i] = getRandomNote();
      left--;
      n--;
    }
  }

  public function hitCorruption(i:int):Boolean
  {
    var b:Boolean = (_corrupted[i] != null);
    _corrupted[i] = null;
    return b;
  }

  public function get numNotes():int
  {
    return _notes.length;
  }

  public function getNote(i:int):String
  {
    var note:String = _corrupted[i];
    if (note == null) {
      note = _notes[i];
    }
    return note;
  }

  public function getColor(i:int):uint
  {
    if (_corrupted[i] != null) {
      return 0x444444;
    }
    switch (_notes[i].charAt(0)) {
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

  public function playNote(i:int, pan:Number):void
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

  private function getRandomNote():String
  {
    return Utils.choose(_wrongs);
  }
}


//  Status
// 
class Status extends Sprite
{
  public var score:int;
  public var miss:int;

  private var _text:Bitmap;

  public function Status()
  {
    _text = Font.createText("SCORE: 00  MISS: 00", 0xffffff, 0, 2);
    addChild(_text);
  }

  public function update():void
  {
    var text:String = "SCORE: "+Utils.format(score,2);
    text += "  MISS: "+Utils.format(miss,2);
    Font.renderText(_text.bitmapData, text);
  }
}
