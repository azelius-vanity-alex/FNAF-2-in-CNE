// this state is REALLY eyeballed.

import SaveData;
import funkin.menus.ModSwitchMenu;

var staticSprite:FunkinSprite;
var camLine1:FunkinSprite;
var animatronics:FunkinSprite;
var cameraBlip:FunkinSprite;
var title:FunkinSprite;
var version:FunkinSprite;
var copyright:FunkinSprite;

// btns
var newGame:FunkinSprite;
var continueSprite:FunkinSprite;
var sixthNight:FunkinSprite;
var customNight:FunkinSprite;
var night:FunkinSprite;
var nightNumberSprite:FunkinSprite;

var firstStar:FunkinSprite;
var secondStar:FunkinSprite;
var thirdStar:FunkinSprite;

var news:FunkinSprite;

var arrow:FunkinSprite;

var titleTimer:FlxTimer;
var randomTmr:FlxTimer;
var transitionTmr:FlxTimer;

var nightNumber:Int;
var sixthNightUnlocked:Bool;
var customNightUnlocked:Bool;

var buttons:Array<MenuButton> = [];
var lastHovered:MenuButton = null;

var canSelect:Bool = true;
var canSkip:Bool = false;
var selectedNewGame:Bool = false;
var transitioning:Bool = false;

var deleteFrames:Int;

function create()
{
    SaveData.load();

    nightNumber = SaveData.getInt('night', 1);
    sixthNightUnlocked = SaveData.getBool('sixthNightUnlocked');
    customNightUnlocked = SaveData.getBool('customNightUnlocked');

    
    FlxG.sound.playMusic(Paths.music('title'), 1, true);
    FlxG.sound.play(Paths.sound('static2'), 1, false);

    animatronics = new FunkinSprite(0, 0, Paths.image('title/title'));
    animatronics.antialiasing = true;
    animatronics.animation.addByPrefix('normal', 'normal', 8, false);
    animatronics.animation.addByPrefix('bonnie', 'bonnie', 8, false);
    animatronics.animation.addByPrefix('chica', 'chica', 8, false);
    animatronics.animation.addByPrefix('freddy', 'freddy', 8, false);

    if (canSelect)
    {
        animatronics.animation.finishCallback = function(name:String)
        {
            if (name != 'normal')
                animatronics.animation.play('normal');
        };

        titleTimer = new FlxTimer().start(0.5, function(timer:FlxTimer)
        {
            animatronics.alpha = FlxG.random.float(0.1, 1);
            playRandomTitleAnimation();
            timer.reset(0.5);
        });

        randomTmr = new FlxTimer().start(FlxG.random.float(0.5, 1), function(timer:FlxTimer)
        {
            playBlip();
            cameraBlip.visible = FlxG.random.bool(80);
            timer.reset(FlxG.random.float(0.5, 1));
        });
    }
    
    add(animatronics);

    staticSprite = new FunkinSprite();
    staticSprite.frames = Paths.getSparrowAtlas('ui/static');
    staticSprite.alpha = 0.4;
    staticSprite.blend = 0;
    staticSprite.antialiasing = true;
    staticSprite.animation.addByPrefix('static', 'frame', 60, true);
    staticSprite.animation.play('static');
    add(staticSprite);

    camLine1 = new FunkinSprite(0, -35, Paths.image('ui/camLine1'));
    camLine1.scale.y -= 0.5;
    camLine1.blend = 0;
    camLine1.alpha = 0.2;
    add(camLine1);

    cameraBlip = new FunkinSprite();
    cameraBlip.frames = Paths.getSparrowAtlas('camBlip');
    cameraBlip.animation.addByPrefix('blip', 'frame', 5, false);
    cameraBlip.blend = 0;
    cameraBlip.alpha = 0.2;
    add(cameraBlip);
    playBlip();

    title = new FunkinSprite(96, 39, Paths.image('title/fnaf2'));
    add(title);

    firstStar = new FunkinSprite(94, 341, Paths.image('title/star'));
    firstStar.visible = SaveData.getBool('night5done');
    add(firstStar);

    secondStar = new FunkinSprite(171, 341, Paths.image('title/star'));
    secondStar.visible = SaveData.getBool('night6done');
    add(secondStar);

    thirdStar = new FunkinSprite(246, 341, Paths.image('title/star'));
    thirdStar.visible = SaveData.getBool('goldenFreddyDone');
    add(thirdStar);

    var newGameButton = new MenuButton('newGame', 86, 437, 'title/newgame', true);
    var continueButton = new MenuButton('continue', 86, 507, 'title/continue', true);
    var sixthNightButton = new MenuButton('sixthNight', 90, 582, 'title/sixnight', sixthNightUnlocked);
    var customNightButton = new MenuButton('customNight', 89, 650, 'title/customnight', customNightUnlocked);

    buttons = [
        newGameButton,
        continueButton,
        sixthNightButton,
        customNightButton
    ];

    for (button in buttons)
        add(button.sprite);

    version = new FunkinSprite(26, 738, Paths.image('title/version'));
    add(version);

    resetData = new FunkinSprite(335, 736, Paths.image('title/resetData'));
    add(resetData);

    copyright = new FunkinSprite(790, 735, Paths.image('title/copyright'));
    add(copyright);

    arrow = new FunkinSprite(33, 439, Paths.image('title/arrow'));
    add(arrow);

    night = new FunkinSprite(97, 549, Paths.image('title/nights'));
    night.visible = false;
    add(night);

    nightNumberSprite = new FunkinSprite(171, 550, Paths.image('title/number/' + nightNumber));
    nightNumberSprite.visible = false;
    add(nightNumberSprite);

    news = new FunkinSprite(0, 0, Paths.image('news'));
    news.antialiasing = true;
    news.alpha = 0;
    add(news);
}

function playBlip()
{
    cameraBlip.visible = true;
    cameraBlip.animation.play('blip');

    cameraBlip.animation.finishCallback = function(name:String)
    {
        if (name == 'blip')
        {
            cameraBlip.visible = false;
        }
    };
}

function playRandomTitleAnimation()
{
    var animations:Array<String> = [
        'freddy',
        'bonnie',
        'chica',
        'normal'
    ];

    var randomAnimation:String = FlxG.random.getObject(animations);

    animatronics.animation.play(randomAnimation);
}

function update(elapsed:Float)
{
    if (FlxG.keys.justPressed.ENTER && selectedNewGame && canSkip)
    {
        transitionTmr.cancel();

        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.sound.music.stop();
            FlxG.switchState(new ModState("NightState"));
        });
    }

    if (!canSelect) return;

    if (controls.SWITCHMOD) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    if (FlxG.keys.pressed.DELETE)
    {
        deleteFrames++;
    }
    if (FlxG.keys.justReleased.DELETE)
    {
        deleteFrames = 0;
    }

    if (deleteFrames >= 100)
    {
        SaveData.reset();
        FlxG.resetState();
    }

    camLine1.y += 0.6;

    if (camLine1.y > FlxG.height + 35)
        camLine1.y = -35;

    var hovered:MenuButton = null;

    for (button in buttons)
    {
        if (button.isHovered())
        {
            hovered = button;
            break;
        }
    }

    if (hovered != lastHovered)
    {
        if (hovered != null)
        {
            night.visible = hovered.name == 'continue';
            nightNumberSprite.visible = hovered.name == 'continue';

            FlxG.sound.play(Paths.sound('blip3'));

            arrow.visible = true;
            arrow.y = hovered.sprite.y + (hovered.sprite.height - arrow.height) / 2;
        }

        lastHovered = hovered;
    }

    if (FlxG.mouse.justPressed && hovered != null)
    {
        switch (hovered.name)
        {
            case 'newGame':
                canSelect = false;
                selectedNewGame = true;
                transition();

            case 'continue':
                FlxG.sound.music.stop();
                FlxG.switchState(new ModState("NightState", {night: SaveData.getInt('night', 1)}));

            case 'sixthNight':
                FlxG.sound.music.stop();
                FlxG.switchState(new ModState("NightState", {night: 6, sixthNight: true}));

            case 'customNight':
                FlxG.switchState(new ModState("CustomNightState"));
        }
    }
}

function transition()
{
    SaveData.setInt('night', 1);
    SaveData.save();

    FlxTween.tween(news, {alpha: 1}, 2, {
        onComplete: function(_)
        {
            canSkip = true;
        }
    });

    transitionTmr = new FlxTimer().start(6, function()
    {
        trace('TRANSITION TIMER FINISHED');

        FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
        {
            canSkip = false;

            FlxG.sound.music.stop();
            FlxG.switchState(new ModState("NightState"));
        });
    });
}

class MenuButton
{
    public var sprite:FunkinSprite;
    public var name:String;
    public var unlocked:Bool;

    public function new(name:String, x:Float, y:Float, graphic:String, unlocked:Bool = true)
    {
        this.name = name;
        this.unlocked = unlocked;

        sprite = new FunkinSprite(x, y, Paths.image(graphic));
        sprite.visible = unlocked;
    }

    public function isHovered():Bool
    {
        if (!unlocked)
            return false;

        return sprite.overlapsPoint(FlxG.mouse.getWorldPosition(FlxG.camera));
    }
}