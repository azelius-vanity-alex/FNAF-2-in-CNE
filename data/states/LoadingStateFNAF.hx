var loadingIcon:FunkinSprite;

var nightNumber:Int;
var sixthNight:Bool = false;

var preset:Int = -1;
var presetName:String = '';
var customNightAI:Array<Int>;

function create()
{
    if (data != null && data.night != null)
    {
        if (data.night != null)
            nightNumber = data.night;
        if (data.sixthNight != null)
            sixthNight = data.sixthNight == true;
        if (data.ai != null)
            customNightAI = data.ai;
        if (data.preset != null)
            preset = data.preset;
        if (data.presetName != null)
            presetName = data.presetName;
    }

    loadingIcon = new FunkinSprite(958, 703, Paths.image('loadingIcon'));
    loadingIcon.antialiasing = true;
    add(loadingIcon);

    FlxG.switchState(new ModState("GameplayState", {night: nightNumber, sixthNight: sixthNight, ai: customNightAI, preset: preset, presetName: presetName}));

}