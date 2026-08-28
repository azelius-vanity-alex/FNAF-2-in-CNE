import SaveData;

var cameraBlip:FunkinSprite;
var nightDisplay:FunkinSprite;
var nightNumber:Int;
var sixthNight:Bool = false;

var preset:Int = -1;
var presetName:String = '';
var customNightAI:Array<Int>;

function create()
{
    SaveData.load();

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
    else
    {
        nightNumber = SaveData.getInt('night', 1);
    }

    FlxG.sound.play(Paths.sound('blip3'), 1, false);

    cameraBlip = new FunkinSprite();
    cameraBlip.frames = Paths.getSparrowAtlas('camBlip');
    cameraBlip.animation.addByPrefix('blip', 'frame', 24, false);
    cameraBlip.animation.play('blip', true);
    add(cameraBlip);

    cameraBlip.animation.finishCallback = function(name:String)
    {
        if (name == 'blip')
        {
            cameraBlip.visible = false;
        }
    };

    nightDisplay = new FunkinSprite(395, 316, Paths.image('title/night/' + nightNumber));
    nightDisplay.antialiasing = true;
    add(nightDisplay);

    new FlxTimer().start(2, function()
    {
        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            if (FlxG.random.int(1, 10000) == 1)
                FlxG.switchState(new ModState("SecretState", {img: 2, night: nightNumber, sixthNight: sixthNight, ai: customNightAI, preset: preset, presetName: presetName}));
            else
                FlxG.switchState(new ModState("LoadingStateFNAF", {night: nightNumber, sixthNight: sixthNight, ai: customNightAI, preset: preset, presetName: presetName}));
        });
    });
}