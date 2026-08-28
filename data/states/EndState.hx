var image:Int = 1;
var graphics:Array<String> = [
    'salary1',
    'salary2',
    'termination'
];

var theImage:FunkinSprite;

var canPressEnter:Bool = false;

function create()
{
    if (data != null)
        image = data.image;

    graphic = graphics[image - 1];

    theImage = new FunkinSprite(0, 0, Paths.image('ending/${graphic}'));
    theImage.antialiasing = true;
    add(theImage);

    FlxG.sound.playMusic(Paths.music('musicbox2'), 1, false);

    FlxG.camera.fade(FlxColor.BLACK, 2, true, function()
    {
        canPressEnter = true;
    });

    new FlxTimer().start(21, function()
    {
        fade();
    });
}

function update(elapsed:Float)
{
    if (FlxG.keys.justPressed.ENTER && canPressEnter)
    {    
        fade();
    }
}

function fade()
{
    canPressEnter = false;
    FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
    {
        FlxG.switchState(new ModState("TitleStateFNAF"));
    });
}