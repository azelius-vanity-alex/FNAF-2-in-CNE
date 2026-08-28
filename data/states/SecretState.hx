var img:Int = 1;

var secret:FunkinSprite;

var goToMenu:Bool;

var nightNumber:Int;
var sixthNight:Bool = false;

var preset:Int = -1;
var presetName:String = '';
var customNightAI:Array<Int>;

function create()
{
    if (data != null)
    {
        img = data.img;

        if (data.goToMenu != null)
            goToMenu = data.goToMenu;
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

    secret = new FunkinSprite().loadGraphic(Paths.image('secret/$img'));
    secret.antialiasing = true;
    add(secret);

    var sound = FlxG.sound.load(Paths.sound('pop static'), 1, false);

    sound.onComplete = function()
    {
        if (goToMenu)
            FlxG.switchState(new ModState("TitleStateFNAF"));
        else
            FlxG.switchState(new ModState("NightState", {night: nightNumber, sixthNight: sixthNight, ai: customNightAI, preset: preset, presetName: presetName}));
    };

    sound.play();
}