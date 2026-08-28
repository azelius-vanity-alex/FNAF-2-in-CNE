import SaveData;

var camWorld:FlxCamera;
var maskCamera:FlxCamera;

var maskSprite:FunkinSprite;
var stage:FunkinSprite;
var camStatic:FunkinSprite;
var cameraBlip:FunkinSprite;

var bonnie:FunkinSprite;
var chica:FunkinSprite;
var goldenFreddy:FunkinSprite;
var puppet:FunkinSprite;

var goldenLeftSeen:Bool = false;
var goldenRightSeen:Bool = false;
var goldenTriggered:Bool = false;

var staticTimer:Float = 0;
var staticFlashTimer:Float = 0;
var staticFlickers:Int = 0;
var staticFlashing:Bool = false;

var camBaseX:Float;

var camRangeLeft:Float = 700;
var camRangeRight:Float = 700;

var deadZone:Float = 150; // center area where camera doesn't move
var camSpeed:Float = 200;

var camVelocityX:Float = 0;

var stateChica:Int = 1;
var stateBonnie:Int = 1;
var dream:Int = 1;

var floatTime:Float = 0;
var radiusX:Float = 10;
var radiusY:Float = 10;
var centerX:Float;
var centerY:Float;

var canMove:Bool = true;

var cameraMoveSound:FlxSound;
var robotSound:FlxSound;

var night:Int = 1;

function create()
{
    SaveData.load();

    if (data != null)
    {
        dream = data.dream;
        night = data.night;
    }

    camWorld = new FlxCamera();
    FlxG.cameras.add(camWorld);

    camBaseX = camWorld.scroll.x;

    maskCamera = new FlxCamera();
    maskCamera.bgColor = 0x000000;
    FlxG.cameras.add(maskCamera);

    FlxCamera.defaultCameras = [camWorld];

    maskCamera.fade(FlxColor.BLACK, 5, true);

    maskSprite = new FunkinSprite(0, 0, Paths.image('dreamstate/mask'));
    maskSprite.camera = maskCamera;
    maskSprite.screenCenter();
    maskSprite.scale.set(1, 1);
    maskSprite.antialiasing = true;
    add(maskSprite);

    centerX = maskSprite.x;
    centerY = maskSprite.y;

    camStatic = new FunkinSprite();
    camStatic.frames = Paths.getSparrowAtlas('ui/static');
    camStatic.alpha = 0.4;
    camStatic.blend = 0;
    camStatic.animation.addByPrefix('static', 'frame', 49, true);
    camStatic.animation.play('static');
    camStatic.camera = maskCamera;
    camStatic.antialiasing = true;
    camStatic.visible = false;
    add(camStatic);

    cameraBlip = new FunkinSprite();
    cameraBlip.frames = Paths.getSparrowAtlas('camBlip');
    cameraBlip.animation.addByPrefix('blip', 'frame', 24, true);
    cameraBlip.animation.play('blip');
    cameraBlip.visible = false;
    cameraBlip.camera = maskCamera;
    add(cameraBlip);

    stage = new FunkinSprite(0, 0, Paths.image('dreamstate/stage'));
    stage.screenCenter();
    stage.antialiasing = true;
    add(stage);

    bonnie = new FunkinSprite(875, 0, Paths.image('dreamstate/${dream}/bonnie_state${stateBonnie}'));
    bonnie.antialiasing = true;
    add(bonnie);

    chica = new FunkinSprite(-875, 0, Paths.image('dreamstate/${dream}/chica_state${stateBonnie}'));
    chica.antialiasing = true;
    add(chica);

    if (dream == 3)
    {
        goldenFreddy = new FunkinSprite(390, 0, Paths.image('dreamstate/3/goldenfreddy'));
        goldenFreddy.antialiasing = true;
        goldenFreddy.visible = false;
        add(goldenFreddy);
    }

    if (dream == 4)
    {
        puppet = new FunkinSprite(300 + camWorld.scroll.x, 0, Paths.image('dreamstate/4/puppet'));
        puppet.antialiasing = true;
        add(puppet);
    }

    camWorld.addShader(new CustomShader("perspective"));

    FlxG.sound.play(Paths.sound('ambience2'), 1, false);
    FlxG.sound.play(Paths.sound('scary space'), 1, false);

    cameraMoveSound = FlxG.sound.load(Paths.sound('machine turn'), 1, true);
    robotSound = FlxG.sound.load(Paths.sound('robot'), 1, true);

    new FlxTimer().start(30, function()
    {
        robotSound.play();

        new FlxTimer().start(2, function()
        {
            robotSound.stop();
            FlxG.sound.play(Paths.sound('static end'), 1, true);
            cameraBlip.visible = true;

            new FlxTimer().start(1, function()
            {
                if (dream == 1)
                {
                    SaveData.setBool('firstDreamState', false);
                    SaveData.save();
                }
    

                canMove = false;
                FlxG.sound.list.forEach(function(sound:FlxSound)
                {
                    sound.stop();
                });

                persistentUpdate = false;
                persistentDraw = true;
                openSubState(new ModSubState("ErrorSubstate", {goToMenu: dream == 1, msgNum: dream}));
            });
        });
    });
}

var goldenStep:Int = 0;

var goldenRight:Float = 300;

function updateGoldenFreddy()
{
    if (dream != 3 || goldenStep >= 3)
        return;

    var offset = camWorld.scroll.x - camBaseX;

    switch (goldenStep)
    {
        case 0:
            if (offset >= goldenRight)
                goldenStep = 1;

        case 1:
            if (offset <= -600)
            {
                goldenStep = 2;
                goldenFreddy.visible = true;
            }

        case 2:
            goldenStep = 3;
    }
}

function updatePuppet(elapsed:Float)
{
    var targetX = 300 + camWorld.scroll.x;
    puppet.x = FlxMath.lerp(puppet.x, targetX, elapsed);
}

function updateStatic(elapsed:Float)
{
    if (!staticFlashing)
    {
        staticTimer += elapsed;

        if (staticTimer >= 2)
        {
            staticTimer = 0;

            staticFlickers = FlxG.random.int(1, 3);
            staticFlashTimer = 0;
            staticFlashing = true;

            camStatic.visible = true;
        }

        return;
    }

    staticFlashTimer += elapsed;

    if (staticFlashTimer >= 0.08)
    {
        staticFlashTimer = 0;

        camStatic.visible = !camStatic.visible;

        if (!camStatic.visible)
        {
            staticFlickers--;

            if (staticFlickers <= 0)
            {
                staticFlashing = false;
                camStatic.visible = false;
            }
        }
    }
}

function updateCamera(elapsed:Float)
{   
    if (!canMove) return;

    var mouseX = FlxG.mouse.screenX;
    var centerX = FlxG.width / 2;
    var mouseOffset = mouseX - centerX;
    var moveSpeed:Float = 0;

    if (Math.abs(mouseOffset) > deadZone)
    {
        var distance = Math.abs(mouseOffset) - deadZone;
        var strength = distance / (centerX - deadZone);
        strength *= 2;
        strength = FlxMath.bound(strength, 0, 1);

        moveSpeed = FlxMath.signOf(mouseOffset) * strength * camSpeed;
    }

    var oldX = camWorld.scroll.x;
    camWorld.scroll.x += moveSpeed * elapsed;
    camWorld.scroll.x = FlxMath.bound(camWorld.scroll.x, camBaseX - camRangeLeft, camBaseX + camRangeRight);

    if (camWorld.scroll.x != oldX)
    {
        if (!cameraMoveSound.playing)
            cameraMoveSound.play(true);
    }
    else
    {
        if (cameraMoveSound.playing)
            cameraMoveSound.stop();
    }
}

function updateMaskMovement(elapsed:Float)
{
    floatTime += elapsed / 1.5;
    maskSprite.x = centerX + Math.sin(floatTime) * radiusX;
    maskSprite.y = centerY + Math.sin(floatTime * 2) * radiusY;
}

function update(elapsed:Float)
{
    updateCamera(elapsed);
    updateMaskMovement(elapsed);
    updateStatic(elapsed);
    if (dream == 4)
        updatePuppet(elapsed);
    updateGoldenFreddy();
}