package {

import flash.events.Event;
import flash.geom.Point;

public class KeypadEvent extends Event
{
  public static const PRESSED:String = "KeypadEvent.PRESSED";

  public var key:Keytop;

  public function KeypadEvent(type:String, key:Keytop)
  {
    super(type);
    this.key = key;
  }
}

} // package

