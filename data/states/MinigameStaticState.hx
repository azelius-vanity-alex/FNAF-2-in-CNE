var scanline:FunkinSprite;
var blip:FunkinSprite;
var play:Int = 3;
var randomize:Bool = false;

function create()
{
    FlxG.sound.playMusic(Paths.music('static end'), 1, true);

    blip = new FunkinSprite();
    blip.frames = Paths.getSparrowAtlas('camBlip');
    blip.color = FlxColor.RED;
    blip.animation.addByPrefix('blip', 'frame', 8, false);
    blip.animation.play('blip');
    add(blip);

    blip.animation.finishCallback = function(name:String)
    {
        play--;
        if (play <= 0)
        {
            blip.animation.pause();
        }
        else
        {
            blip.animation.play('blip');
        }
    };

    scanline = new FunkinSprite().loadGraphic(Paths.image('minigames/scanline'));
    add(scanline);

    new FlxTimer().start(10, function()
    {
        FlxG.switchState(new ModState("MinigameState", {minigame: 1}));
    });
}

var lastFrame:Int = -1;

function update(elapsed:Float)
{
    if (blip.animation.curAnim != null)
    {
        var currentFrame:Int = blip.animation.curAnim.curFrame;

        if (currentFrame != lastFrame)
        {
            lastFrame = currentFrame;
            blip.y = FlxG.random.float(-300, 200);
        }
    }
}