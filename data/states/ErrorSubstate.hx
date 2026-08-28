var cams:FlxCamera;

var blackScreen:FunkinSprite;
var error:FunkinSprite;
var night:Int = 1;
var msgNum:Int = 1;
var goToMenu:Bool;

function create()
{
    if (data != null)
    {
        night =  data.night;
        goToMenu = data.goToMenu;
        msgNum = data.msgNum;
    }

    cams = new FlxCamera();
    FlxG.cameras.add(cams, true);

    blackScreen = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackScreen.camera = cams;
    add(blackScreen);

    error = new FunkinSprite(33, 19, Paths.image('dreamstate/errors/msg$msgNum'));
    error.camera = cams;
    add(error);


    new FlxTimer().start(3, function()
    {
        if (goToMenu)
            FlxG.switchState(new ModState("TitleStateFNAF"));
        else
            FlxG.switchState(new ModState("NightState"));
    });
}