var camStatic:FunkinSprite;
var staticSound:FlxSound;

var freddyMask:FunkinSprite;
var gameOver:FunkinSprite;

function create()
{
    staticSound = FlxG.sound.load(Paths.sound('stare'), 1, true);
    staticSound.play();

    freddyMask = new FunkinSprite(0, 0, Paths.image('gameover'));
    freddyMask.antialiasing = true;
    freddyMask.visible = false;
    add(freddyMask);

    camStatic = new FunkinSprite();
    camStatic.frames = Paths.getSparrowAtlas('ui/static');
    camStatic.antialiasing = true;
    camStatic.animation.addByPrefix('static', 'frame', 60, true);
    camStatic.animation.play('static');
    add(camStatic);

    gameOver = new FunkinSprite(424, 710, Paths.image('gameovertxt'));
    gameOver.visible = false;
    add(gameOver);

    new FlxTimer().start(5, function()
    {
        staticSound.stop();

        /*
        // sorry, minigames ain't done!
        if (FlxG.random.int(1, 10) == 1)
        {
            FlxG.switchState(new ModState("MinigameStaticState"));
            return;
        }
        */

        freddyMask.visible = true;
        gameOver.visible = true;

        camStatic.alpha = 0.4;
        camStatic.blend = 0;

        new FlxTimer().start(8, function()
        {
            if (FlxG.random.int(1, 10000) == 1)
                FlxG.switchState(new ModState("SecretState", {img: 3, goToMenu: true}));
            else
                FlxG.switchState(new ModState("TitleStateFNAF"));
        });
    });
}