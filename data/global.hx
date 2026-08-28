import funkin.backend.utils.ShaderResizeFix;
import openfl.system.Capabilities;
import funkin.backend.MusicBeatState;
import funkin.backend.system.framerate.Framerate;
import flixel.system.scaleModes.FillScaleMode;

var fillMode:Bool = true;

// SCRIPT BY CHRONIC
function new() {
    if (fillMode)
        FlxG.scaleMode = new FillScaleMode();

    FlxG.fullscreen = fillMode;
    Framerate.debugMode = 0;

    windowShit(1024, 768, 0.715);
    FlxG.mouse.visible = true;
}

function postStateSwitch()
{
    MusicBeatState.skipTransOut = true;
    MusicBeatState.skipTransIn = true;
    FlxG.mouse.useSystemCursor = true;
}

var winWidth = Math.floor(Capabilities.screenResolutionX * (3 / 4)) > Capabilities.screenResolutionY ? Math.floor(Capabilities.screenResolutionY * (4 / 3)) : Capabilities.screenResolutionX;
var winHeight = Math.floor(Capabilities.screenResolutionX * (3 / 4)) > Capabilities.screenResolutionY ? Capabilities.screenResolutionY : Math.floor(Capabilities.screenResolutionX * (3 / 4));

public static function windowShit(newWidth:Int, newHeight:Int, scale:Float = 0.9){
    if(newWidth == 1024 && newHeight == 768)
        FlxG.resizeWindow(winWidth * scale, winHeight * scale);
    else
        FlxG.resizeWindow(newWidth, newHeight);
    FlxG.resizeGame(newWidth, newHeight);
    FlxG.scaleMode.gameSize.x = FlxG.width = FlxG.initialWidth = newWidth;
    FlxG.scaleMode.gameSize.y = FlxG.height = FlxG.initialHeight = newHeight;
    ShaderResizeFix.doResizeFix = true;
    ShaderResizeFix.fixSpritesShadersSizes();
    window.x = Capabilities.screenResolutionX/2 - window.width/2;
    window.y = Capabilities.screenResolutionY/2 - window.height/2;
}

function update()
{
    // originally it was f2 to match clickteam's restart shit
    // but f2 was already keybinded to opening console
    // so now its f4 lmaoo
    if (FlxG.keys.justPressed.F4)
    {
        FlxG.sound?.music?.stop();
        FlxG.switchState(new ModState("WarningStateFNAF"));
    }
}