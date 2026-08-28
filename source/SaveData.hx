import sys.io.File;
import sys.FileSystem;
import haxe.ds.StringMap;
import funkin.backend.assets.ModsFolder;

using StringTools;

class SaveData
{
    public static var path:String = 'mods/${ModsFolder.currentModFolder}/data/save.txt';
    private static var data:StringMap<String> = new StringMap();

    private static var defaults = {
        night: '1',
        sixthNightUnlocked: 'false',
        customNightUnlocked: 'false',
        night5done: 'false',
        night6done: 'false',
        four20Done: 'false',
        newAndShinyDone: 'false',
        doubleTroubleDone: 'false',
        nightOfMisfitsDone: 'false',
        foxyFoxyDone: 'false',
        ladiesNightDone: 'false',
        freddysCircusDone: 'false',
        cupcakeChallengeDone: 'false',
        fazbearFeverDone: 'false',
        goldenFreddyDone: 'false',
        firstDreamState: 'true'
    };

    public static function createDefault():Void
    {
        if (!FileSystem.exists(path))
        {
            data = new StringMap();

            for (key in Reflect.fields(defaults))
                data.set(key, Reflect.field(defaults, key));

            save();
        }
    }

    public static function load():Void
    {
        createDefault();

        data = new StringMap();

        var fileContent:String = File.getContent(path);

        for (line in fileContent.split('\n'))
        {
            line = line.trim();

            if (line == '')
                continue;

            var separator:Int = line.indexOf('=');

            if (separator <= 0)
                continue;

            var key:String = line.substring(0, separator).trim();
            var value:String = line.substring(separator + 1).trim();

            if (key != '')
                data.set(key, value);
        }
    }

    public static function get(key:String, defaultValue:String = ''):String
        return data.exists(key) ? data.get(key) : defaultValue;

    public static function getInt(key:String, defaultValue:Int = 0):Int
    {
        var value:Null<Int> = Std.parseInt(get(key, Std.string(defaultValue)));
        return value == null ? defaultValue : value;
    }

    public static function getBool(key:String, defaultValue:Bool = false):Bool
    {
        var value:String = get(key, Std.string(defaultValue)).toLowerCase();

        if (value == 'true')
            return true;

        if (value == 'false')
            return false;

        return defaultValue;
    }

    public static function set(key:String, value:String):Void
        data.set(key, value);

    public static function setInt(key:String, value:Int):Void
        set(key, Std.string(value));

    public static function setBool(key:String, value:Bool):Void
        set(key, Std.string(value));

    public static function save():Void
    {
        var output:Array<String> = [];

        for (key in Reflect.fields(defaults))
        {
            if (data.exists(key))
                output.push(key + '=' + data.get(key));
        }

        for (key => value in data)
        {
            if (!Reflect.hasField(defaults, key))
                output.push(key + '=' + value);
        }

        File.saveContent(path, output.join('\n'));
    }

    public static function reset():Void
    {
        data = new StringMap();

        for (key in Reflect.fields(defaults))
            data.set(key, Reflect.field(defaults, key));

        save();
    }
}