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

  [Embed(source="../assets/guides/welcome.mp3", mimeType="audio/mpeg")]
  private static const WelcomeSoundCls:Class;
  private const welcomeSound:Sound = new WelcomeSoundCls();
  [Embed(source="../assets/guides/guide1.mp3", mimeType="audio/mpeg")]
  private static const Guide1SoundCls:Class;
  private const guide1Sound:Sound = new Guide1SoundCls();
  [Embed(source="../assets/guides/guide2.mp3", mimeType="audio/mpeg")]
  private static const Guide2SoundCls:Class;
  private const guide2Sound:Sound = new Guide2SoundCls();
  [Embed(source="../assets/guides/gameover.mp3", mimeType="audio/mpeg")]
  private static const GameOverSoundCls:Class;
  private const gameOverSound:Sound = new GameOverSoundCls();
  [Embed(source="../assets/guides/finish.mp3", mimeType="audio/mpeg")]
  private static const FinishSoundCls:Class;
  private const finishSound:Sound = new FinishSoundCls();

  private const START_LEVEL:int = 0;
  private const MAX_MISS:int = 3;
  private const DELAY:int = 15;

  public const TUNES:Array = 
    [
     // 0
     new Tune("C4 G4 E4 G4", 
	      "B3 A4s C4s C5s"),
     // 1
     new Tune("F4 C4 A4 C5",
	      "G4 A3s C5s D5s"),
     // 2
     new Tune("C4 G3 D4 G4 E4 G4",
	      "B3 D4s C4s F4s D4s C4s"),
     // 3
     new Tune("C4 A3 D4s A3 F4 G3s",
	      "A3 F3s B3 E3 A4s F3s"),
     // 4
     new Tune("C5 G4 F4 G4 C5 G4 E4 G4",
	      "C4s C5s D4s A4 B3 D4 F3 C5s"),
     // 5
     new Tune("G3 C4 E4 G3 E4 G3 E4 G3",
	      "C4 G4s A3 F4s G4 C3s A4 C4"),
     // 6
     new Tune("D5s A4 F4s A4 D5s A4 F4 A4",
	      "E4 C4s E4 C4s G4s F4 G4s F4"),
     // 7
     new Tune("A4 A5 E5 F5 A5 E5 F5 A5",
	      "C4 D4 E4 F4 G4 A4 B4 C5"),
     ];

  private var _status:Status;
  private var _guide:Guide;
  private var _arpeggio:Arpeggio;
  private var _keypad:Keypad;

  private var _tutorial:Boolean;
  private var _repeat:int;
  private var _noteleft:int;

  private var _start:int;
  private var _ticks:int;
  private var _interval:int;
  private var _nextnote:int;

  public function GameScreen(width:int, height:int)
  {
    super(width, height);

    _arpeggio = new Arpeggio();

    _status = new Status();
    _status.x = (width-_status.width)/2;
    _status.y = (height-_status.height-16);
    addChild(_status);

    _keypad = new Keypad();
    _keypad.addEventListener(KeypadEvent.PRESSED, onKeypadPressed);
    addChild(_keypad);

    _guide = new Guide(width*3/4, height/2);
    _guide.x = (width-_guide.width)/2;
    _guide.y = (height-_guide.height)/2;
    addChild(_guide);

  }

  // open()
  public override function open():void
  {
    _ticks = 0;
    _start = 0;

    _tutorial = true;
    _guide.show("ARPEGGIO", 
		"PRESS KEYS IN A CERTAIN ROW\nFROM LEFT TO RIGHT.",
		welcomeSound);
    initGame();
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

    var n:int = _interval*2;
    graphics.clear();
    drawBand(n-(_ticks % n));
    drawBand(n-((_ticks+3) % n));
    graphics.lineStyle(0, Keytop.BORDER_COLOR);
    graphics.moveTo(0, screenHeight/2);
    graphics.lineTo(screenWidth, screenHeight/2);

    _guide.update();
    _keypad.update();
    _ticks++;
  }

  // keydown(keycode)
  public override function keydown(keycode:int):void
  {
    _guide.hide();
    _keypad.keydown(keycode);
  }

  // keyup(keycode)
  public override function keyup(keycode:int):void 
  {
  }

  private function drawBand(t:int):void
  {
    var r:Rectangle = _keypad.rect;
    var cx:int = screenWidth/2;
    var cy:int = screenHeight/2;
    var dx0:Number = screenWidth*2/t;
    var dy0:Number = screenHeight/2/t;
    var dx1:Number = screenWidth*2/(t+0.5);
    var dy1:Number = screenHeight/2/(t+0.5);
    graphics.lineStyle(0, 0);
    graphics.beginFill(0x333333);

    graphics.moveTo(cx-dx1, cy);
    graphics.lineTo(cx-dx0, cy);
    graphics.lineTo(cx-dx0, cy-dy0*2);
    graphics.lineTo(cx+dx0, cy-dy0*2);
    graphics.lineTo(cx+dx0, cy);
    graphics.lineTo(cx+dx1, cy);
    graphics.lineTo(cx+dx1, cy-dy1*2);
    graphics.lineTo(cx-dx1, cy-dy1*2);

    if (t < (screenWidth*3/r.width)) {
      graphics.moveTo(cx-dx1, cy+dy1);
      graphics.lineTo(cx-dx0, cy+dy0);
      graphics.lineTo(cx+dx0, cy+dy0);
      graphics.lineTo(cx+dx1, cy+dy1);
    }
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
	if (_tutorial && _status.level == 0) {
	  _guide.show(null, "TRY TO SPOT WRONG NOTE\nBY PRESSING KEY.",
		      guide1Sound);
	}
	_start = _ticks+DELAY;
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
      case 2:
	n = ((i % 2) == 0)? 1 : 0;
	break;

      case 5:
      case 7:
	n = 2;
	break;

      default:
	n = 1;
	break;
      }
      n = Math.min(n, _noteleft-_arpeggio.numNoises);
      trace("setupNose: i="+i+", n="+n);
      if (!_arpeggio.addNoise(n)) {
	gameOver();
      }
    }
  }

  private function setupLevel():void
  {
    // Setup a new tune.
    if (TUNES.length <= _status.level) {
      finishGame();
      return
    }

    _arpeggio.setTune(TUNES[_status.level]);

    switch (_status.level) {
    case 0:
      _interval = 10;
      _noteleft = 4;
      break;

    case 1:
      _interval = 8;
      _noteleft = 6;
      if (_tutorial) {
	_tutorial = false;
	_guide.show(null, "DIFFICULTY IS INCREASED.\nPRESS KEYS AGAIN.",
		    guide2Sound);
      }
      break;

    case 2:
    case 3:
      _interval = 8;
      _noteleft = 8;
      break;

    case 4:
    case 5:
      _interval = 6;
      _noteleft = 10;
      break;

    case 6:
    case 7:
    default:
      _interval = 4;
      _noteleft = 10;
      break;

    }
    trace("setupLevel: level="+_status.level+
	  ", interval="+_interval+
	  ", noteleft="+_noteleft);

    _keypad.clear();
    _keypad.layoutLine(_arpeggio.numNotes, screenWidth/2);
    _keypad.x = (screenWidth-_keypad.rect.width)/2;
    _keypad.y = (screenHeight-_keypad.rect.height)/2;
    _repeat = 0;
    _nextnote = 0;

    nextSound.play();
    _arpeggio.playNote(0, 0, 0.5, 2.0);

    _status.miss = 0;
    _status.update();
    
    _start = _ticks+DELAY;
  }

  private function initGame():void
  {
    _status.level = START_LEVEL;
    _status.score = 0;
    _status.update();

    setupLevel();
  }

  private function gameOver():void
  {
    _guide.show("GAME OVER", 
		"PRESS KEY TO PLAY AGAIN.",
		gameOverSound);
    _start = _ticks+DELAY;
    initGame();
  }

  private function finishGame():void
  {
    _guide.show("CONGRATULATIONS!", 
		"YOU BEAT THE GAME.",
		finishSound);
    _start = _ticks+DELAY;
    initGame();
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


//  Tune
// 
class Tune extends Object
{
  public var notes:Array;
  public var noises:Array;
  
  public function Tune(notes:String, noises:String)
  {
    this.notes = notes.split(/ /);
    this.noises = noises.split(/ /);
  }
}


//  Arpeggio
// 
class Arpeggio extends Object
{
  public var volume:Number = 0.1;

  private var _tune:Tune;
  private var _noise:Array;

  public function Arpeggio()
  {
  }

  public function setTune(tune:Tune):void
  {
    _tune = tune;
    clearNoise();
  }
  
  public function clearNoise():void
  {
    _noise = new Array(_tune.notes.length);
    for (var i:int = 0; i < _noise.length; i++) {
      _noise[i] = null;
    }
  }

  public function addNoise(n:int):Boolean
  {
    var left:int = _noise.length - numNoises;
    while (0 < n) {
      if (left == 0) return false;
      while (true) {
	var i:int = Utils.rnd(_noise.length);
	if (_noise[i] == null) break;
      }
      _noise[i] = _tune.noises[i];
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

  public function get numNoises():int
  {
    var n:int = 0;
    for (var i:int = 0; i < _noise.length; i++) {
      if (_noise[i] != null) {
	n++;
      }
    }
    return n;
  }

  public function get numNotes():int
  {
    return _tune.notes.length;
  }

  public function getNote(i:int):String
  {
    var note:String = _noise[i];
    if (note == null) {
      note = _tune.notes[i];
    }
    return note;
  }

  public function getColor(i:int):uint
  {
    if (_noise[i] != null) {
      return 0x444444;
    }
    switch (_tune.notes[i].charAt(0)) {
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


//  Guide
// 
class Guide extends Sprite
{
  public const MARGIN:int = 16;

  private var _title:Bitmap;
  private var _text:Bitmap;
  private var _sound:Sound;
  private var _channel:SoundChannel;
  private var _count:int;

  public function Guide(width:int, height:int)
  {
    graphics.beginFill(0, 0.2);
    graphics.drawRect(0, 0, width, height);
  }

  public function set title(v:String):void
  {
    if (_title != null) {
      removeChild(_title);
      _title = null;
    }
    if (v != null) {
      _title = Font.createText(v, 0xffffff, 0, 2);
      _title.x = (width-_title.width)/2;
      _title.y = MARGIN;
      addChild(_title);
    }
  }

  public function set text(v:String):void
  {
    if (_text != null) {
      removeChild(_text);
      _text = null;
    }
    if (v != null) {
      _text = Font.createText(v, 0xffffff, 2, 2);
      _text.x = (width-_text.width)/2;
      _text.y = (height-_text.height-MARGIN);
      addChild(_text);
    }
  }

  public function show(title:String=null, text:String=null, 
		       sound:Sound=null, delay:int=30):void
  {
    this.title = title;
    this.text = text;
    _sound = sound;
    _count = delay;
    visible = true;
  }

  public function hide():void
  {
    if (_channel != null) {
      _channel.stop();
      _channel = null;
    }
    visible = false;
  }

  public function update():void
  {
    if (_count != 0) {
      _count--;
    } else {
      if (_sound != null) {
	_channel = _sound.play();
	_sound = null;
      }
    }
  }
}
