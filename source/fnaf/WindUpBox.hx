class WindUpBox
{
    public var sprite:FunkinSprite;
    public var text:FunkinSprite;
    public var clickAndHold:FunkinSprite;
    public var circle:FunkinSprite;

    var windSound:FlxSound;

    public var pressed:Bool = false;

    var camera:FlxCamera;

    public var level:Int = 2000;
    public var drainTimer:Float = 0;
    public var windTimer:Float = 0;
    var windSoundTimer:Float = 0;

    public var canDrainBox:Bool = true; // only used for night 1

    public var drainAmount:Int = 2;

    public function new()
    {
        sprite = new FunkinSprite(357, 566, Paths.image('cameras/buttons/windUpBtn'));

        sprite.animation.addByPrefix('gray', 'gray');
        sprite.animation.addByPrefix('green', 'green');
        sprite.animation.play('gray');

        text = new FunkinSprite(365, 577, Paths.image('cameras/buttons/windUpTxt'));

        clickAndHold = new FunkinSprite(357, 635, Paths.image('cameras/buttons/clickAndHold'));

        circle = new FunkinSprite(292, 590, Paths.image('cameras/buttons/circle'));
        circle.antialiasing = true;
        circle.animation.addByPrefix('circle', 'circle', 1, false);
        circle.animation.play('circle');
        circle.animation.pause();
        
        sprite.visible = false;
        text.visible = false;
        clickAndHold.visible = false;
        circle.visible = false;

        windSound = FlxG.sound.load(Paths.sound('windup2'), 1, false);
    }

    public function setCamera(cam:FlxCamera)
    {
        camera = cam;

        sprite.camera = cam;
        text.camera = cam;
        clickAndHold.camera = cam;
        circle.camera = cam;
    }

    public function setVisible(value:Bool)
    {
        sprite.visible = value;
        text.visible = value;
        clickAndHold.visible = value;
        circle.visible = value;

        if (!value)
        {
            pressed = false;
            sprite.animation.play('gray', true);
        }
    }

    public function isEmpty():Bool
    {
        return level <= 0;
    }

    public function isMouseOver():Bool
    {
        return FlxG.mouse.overlaps(sprite, camera);
    }

    public function update(elapsed:Float)
    {
        if (sprite.visible)
        {
            if (isMouseOver() && FlxG.mouse.justPressed)
            {
                pressed = true;
                sprite.animation.play('green', true);
            }   

            if (FlxG.mouse.justReleased)
            {
                pressed = false;
                sprite.animation.play('gray', true);
            }
        }

        if (pressed)
        {
            if (canDrainBox)
            {
                level += 5;

                if (level > 2000)
                    level = 2000;
            }

            windSoundTimer += elapsed;

            if (windSoundTimer >= 0.5)
            {
                windSoundTimer -= 0.5;
                windSound.play();
            }
        }
        else
        {
            windSoundTimer = 0;
            
            if (windSound.playing)
                windSound.stop();
        }

        if (!pressed)
        {
            if (canDrainBox)
            {
                drainTimer += elapsed;

                if (drainTimer >= 0.05)
                {
                    var ticks:Int = Math.floor(drainTimer / 0.05);
                    drainTimer -= ticks * 0.05;

                    level -= drainAmount * ticks;

                    if (level < 0)
                        level = 0;
                }
            }
        }

        var circleFrame:Int = Math.floor((level / 2000) * 21);
        circleFrame = FlxMath.bound(circleFrame, 0, 21);

        if (circle.animation.curAnim.curFrame != circleFrame)
            circle.animation.curAnim.curFrame = circleFrame;
    }
}