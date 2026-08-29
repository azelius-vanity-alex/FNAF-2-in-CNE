class FreddyMask
{
    public var sprite:FunkinSprite;
    public var isOn:Bool = false;

    var floatTime:Float = 0;
    var floating:Bool = false;

    var centerX:Float;
    var centerY:Float;

    var radiusX:Float = 20;
    var radiusY:Float = 10;

    public var onTakeOffComplete:Void->Void = null;

    public function new()
    {
        sprite = new FunkinSprite();

        sprite.frames = Paths.getSparrowAtlas('mask');

        sprite.scale.set(1.05, 1.05);
        sprite.updateHitbox();

        // idfk the fps of the mask i just eyeball it #imcrine
        sprite.animation.addByPrefix('down', 'mask', 40, false);
        sprite.animation.addByIndices('up', 'mask', [6, 5, 4, 3, 2, 1, 0], '', 40, false);
        sprite.antialiasing = true;

        sprite.visible = false;
    }

    public function putOn()
    {
        if (isOn) return;

        isOn = true;

        sprite.visible = true;
        sprite.screenCenter();

        centerX = sprite.x;
        centerY = sprite.y;

        sprite.animation.play('down');

        sprite.animation.finishCallback = function(name:String)
        {
            if (name == 'down')
                floating = true;
        };
    }

    public function takeOff()
    {
        if (!isOn) return;

        isOn = false;

        sprite.animation.play('up');
        sprite.screenCenter();

        sprite.animation.finishCallback = function(name:String)
        {
            if (name == 'up')
                sprite.visible = false;

            if (onTakeOffComplete != null)
            {
                onTakeOffComplete();
                onTakeOffComplete = null;
            }
        };
    }

    public function update(elapsed:Float)
    {
        if (!floating)
            return;

        floatTime += elapsed * 1.3;

        sprite.x = centerX + Math.sin(floatTime) * radiusX;
        sprite.y = centerY + Math.sin(floatTime * 2) * radiusY;
    }
}