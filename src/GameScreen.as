package {

import flash.ui.Keyboard;
import flash.media.Sound;
import flash.display.Bitmap;
import flash.utils.getTimer;
import flash.geom.Point;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;

//  GameScreen
//
public class GameScreen extends Screen
{
  private var _clock:int;
  private var _status:Bitmap;
  private var _arpeggio:Arpeggio;
  private var _keypad:Keypad;

  private var _repeat:int;
  private var _toplay:int;

  [Embed(source="../assets/correct.mp3", mimeType="audio/mpeg")]
  private static const CorrectSoundCls:Class;
  private const correctSound:Sound = new CorrectSoundCls();
  [Embed(source="../assets/wrong.mp3", mimeType="audio/mpeg")]
  private static const WrongSoundCls:Class;
  private const wrongSound:Sound = new WrongSoundCls();

  public function GameScreen(width:int, height:int)
  {
    _status = Font.createText("TEXT");
    addChild(_status);

    _keypad = new Keypad();
    _keypad.x = 100;
    _keypad.y = 100;
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    addChild(_keypad);

    _arpeggio = new Arpeggio();
  }

  // open()
  public override function open():void
  {
    _repeat = 0;
    _toplay = 0;
    _arpeggio.setTune(Arpeggio.PAT0, Arpeggio.WRONG0);
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
    var text:String = "TEXT";
    Font.renderText(_status.bitmapData, text);

    _keypad.update(_clock);
    if (0 < _repeat) {
      if ((_clock % 12) == 0) {
	if (_toplay == 0) {
	  _arpeggio.setCorruption(1);
	}
	playKey(_toplay);
	incKey();
      }
    }

    _clock++;
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

  private function playKey(i:int):void
  {
    var key:Keytop = _keypad.getKey(i, 0);
    if (i < _arpeggio.numNotes) {
      var color:uint = _arpeggio.getColor(i);
      key.activate(color);
      _keypad.makeParticle(key.rect, color | 0x888888);
      _arpeggio.playNote(i);
    }
  }

  private function incKey():void
  {
    _toplay = (_toplay+1) % _arpeggio.numNotes;
    if (_toplay == 0) {
      _repeat++;
    }
  }
  
  private function onKeypadPressed(e:KeypadEvent):void
  {
    var keypad:Keypad = Keypad(e.target);
    var p:Point = e.point;
    var key:Keytop = keypad.getKey(p.x, p.y);
    if (key != null) {
      var i:int = p.x;
      if (_repeat == 0) {
	if (i == _toplay) {
	  playKey(_toplay);
	  incKey();
	}
      } else if (i < _arpeggio.numNotes) {
	playKey(i);
	if (_arpeggio.isCorrupted(i)) {
	  correctSound.play();
	} else {
	  wrongSound.play();
	}
      }
    }
  }
}

} // package

import flash.display.Shape;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.events.Event;
import baseui.Font;
import baseui.Screen;
import baseui.ScreenEvent;
import baseui.SoundLoop;


//  Arpeggio
// 
class Arpeggio extends Object
{
  // Safe
  public static const PAT0:String = "C5 G4 F4 G4 C5 G4 E4 G4";
  // Medium
  public static const PAT1:String = "D5s A4 F4s A4 D5s A4 F4 A4";
  // Danger
  public static const PAT2:String = "A4 A5 E5 F5 A5 E5 F5 A5";
  // Wrong
  public static const WRONG0:String = "C4s C5s D4s A3s F4s G4s A4s";

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
    setCorruption(0);
  }

  public function setCorruption(n:int):void
  {
    var i:int;
    _corrupted = new Array(_notes.length);
    for (i = 0; i < _corrupted.length; i++) {
      _corrupted[i] = null;
    }
    var left:int = _notes.length;
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

  public function isCorrupted(i:int):Boolean
  {
    return (_corrupted[i] != null);
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

  public function playNote(i:int):void
  {
    var note:String = getNote(i);
    if (note) {
      var sound:SoundGenerator = new SoundGenerator(SoundGenerator.RECT);
      sound.pitch = SoundGenerator.getPitch(note);
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
