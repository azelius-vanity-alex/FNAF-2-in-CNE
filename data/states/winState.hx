import SaveData;

var cameraWin:FlxCamera;

var sixAM:FunkinSprite;
var am:FunkinSprite;
var blackScreen:FunkinSprite;

var sixAMSound:FlxSound;

var confetti:Array<FunkinSprite> = [];

var night:Int;
var sixthNight:Bool = false;

function create()
{
    SaveData.load();

    if (data != null)
    {
        if (data.night != null)
            night = data.night;

        if (data.sixthNight != null)
            sixthNight = data.sixthNight;
    }

    cameraWin = new FlxCamera();
    cameraWin.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(cameraWin, true);

    sixAMSound = FlxG.sound.load(Paths.sound('six am'), 1, false);
    sixAMSound.play();

    blackScreen = new FunkinSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
    blackScreen.alpha = 0;
    FlxTween.tween(blackScreen, {alpha: 1}, 1);
    add(blackScreen);

    sixAM = new FunkinSprite(387, 320, Paths.image('sixAM/sixAM'));
    sixAM.animation.addByPrefix('five', '5AM', 6, false);
    sixAM.animation.addByPrefix('six', '6AM', 6, false);
    sixAM.animation.play('five');
    sixAM.animation.pause();
    sixAM.alpha = 0;
    FlxTween.tween(sixAM, {alpha: 1}, 1);
    add(sixAM);

    am = new FunkinSprite(506, 321, Paths.image('sixAM/AM'));
    am.alpha = 0;
    FlxTween.tween(am, {alpha: 1}, 1);
    add(am);

    for (i in 0...100)
    {
        var piece = new FunkinSprite(FlxG.random.float(0, FlxG.width), FlxG.random.float(-FlxG.height, FlxG.height));
        piece.frames = Paths.getSparrowAtlas('sixAM/confetti');

        piece.animation.addByPrefix('confetti', 'confetti', 12, true);
        piece.animation.play('confetti');

        piece.velocity.y = 0;
        piece.velocity.x = 0;
        piece.angularVelocity = 0;

        piece.visible = false;

        piece.camera = cameraWin;

        add(piece);
        confetti.push(piece);
    }

    new FlxTimer().start(11, function(timer:FlxTimer)
    {
        if (sixthNight)
        {
            SaveData.setBool('night6done', true);
            SaveData.setBool('customNightUnlocked', true);
            SaveData.save();

            cameraWin.fade(FlxColor.BLACK, 1, false, function()
            {
                FlxG.switchState(new ModState("EndState", {image: 2}));
            });

            return;
        }

        if (night == 2 || night == 3 || night == 4)
        {
            SaveData.setInt('night', night + 1);
            SaveData.save();

            cameraWin.fade(FlxColor.BLACK, 1, false, function()
            {
                FlxG.switchState(new ModState("DreamState", {dream: night}));
            });

            return;
        }

        if (night < 5)
        {
            SaveData.setInt('night', night + 1);
            SaveData.save();

            cameraWin.fade(FlxColor.BLACK, 1, false, function()
            {
                FlxG.switchState(new ModState("NightState"));
            });

            return;
        }

        SaveData.setInt('night', 5);
        SaveData.setBool('sixthNightUnlocked', true);
        SaveData.save();

        if (night == 5)
        {
            SaveData.setBool('night5done', true);
            SaveData.save();
        }

        cameraWin.fade(FlxColor.BLACK, 1, false, function()
        {
            FlxG.switchState(new ModState("EndState", {image: night == 5 ? 1 : 3}));
        });
    }); 

    new FlxTimer().start(1.8, function()
    {
        sixAM.animation.play('five', true);
        sixAM.animation.finishCallback = function(name:String)
        {
            if (name == 'five')
            {
                startConfetti();
                new FlxTimer().start(1, function() sixAM.animation.play('six', true));
            }

            if (name == 'six')
                FlxG.sound.play(Paths.sound('cheer'), 1, false);
        };
    });

    for (sprite in [blackScreen, sixAM, am])
        sprite.camera = cameraWin;
}

function startConfetti()
{
    for (piece in confetti)
    {
        var delay:Float = FlxG.random.float(0, 1.5);

        new FlxTimer().start(delay, function(timer)
        {
            piece.visible = true;

            piece.x = FlxG.random.float(-50, FlxG.width + 50);
            piece.y = FlxG.random.float(-1000, -20);

            piece.velocity.y = FlxG.random.float(50, 100);
            piece.velocity.x = FlxG.random.float(-50, 100);
            piece.angularVelocity = FlxG.random.float(-400, 400);

            piece.animation.play('confetti', true);
        });
    }
}

function update(elapsed:Float)
{
    for (piece in confetti)
    {
        if (!piece.visible)
            continue;

        piece.x += piece.velocity.x * elapsed;
        piece.y += piece.velocity.y * elapsed;
        piece.angle += piece.angularVelocity * elapsed;
    }
}