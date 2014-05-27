package {

import flash.events.Event;
import flash.geom.Point;

public class KeypadEvent extends Event
{
  public static const PRESSED:String = "KeypadEvent.PRESSED";

  public var point:Point;

  public function KeypadEvent(type:String, point:Point)
  {
    super(type);
    this.point = point;
  }
}

} // package

