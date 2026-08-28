import openfl.Assets;
import haxe.Json;
import fnaf.Animatronic;

class NightLoader
{
    public var nightNumber:Int;
    public var data:Dynamic;

    public function new(night:Int)
    {
        nightNumber = night;

        var path = 'nights/night' + night;

        data = Json.parse(Assets.getText(Paths.json(path)));

        trace('Loaded night ' + nightNumber);
    }

    public function applyStartingAI(animatronics:Array<Animatronic>)
    {
        for (anim in animatronics)
        {
            if (Reflect.hasField(data.startingAI, anim.name))
            {
                anim.aiLevel = Reflect.field(data.startingAI, anim.name);
            }
        }
    }

    public function applyHourAI(animatronics:Array<Animatronic>, hour:Int)
    {
        var hourData = Reflect.field(data.hours, Std.string(hour));

        if (hourData == null)
            return;

        for (anim in animatronics)
        {
            if (Reflect.hasField(hourData, anim.name))
            {
                anim.aiLevel = Reflect.field(hourData, anim.name);
            }
        }
    }

    public function getHourAI(hour:Int, name:String):Int
    {
        var hourData = Reflect.field(data.hours, Std.string(hour));

        if (hourData != null && Reflect.hasField(hourData, name))
            return Reflect.field(hourData, name);

        return getStartingAI(name);
    }
}