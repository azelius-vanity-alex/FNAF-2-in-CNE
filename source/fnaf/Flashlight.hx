import flixel.effects.FlxFlicker;

class Flashlight
{
    public var isOn:Bool = false;

    public var battery:Float = 0;
    public var maxBattery:Float = 0;

    var sprite:FunkinSprite;
    var text:FunkinSprite;

    var canFlicker:Bool = true;

    var night:Int;

    public function new(night:Int)
    {
        this.night = night;

        maxBattery = getMaxBattery(night);
        battery = maxBattery;

        sprite = new FunkinSprite(39, 37);
        sprite.frames = Paths.getSparrowAtlas('ui/battery');
        for (i in 0...5)
        {
            var prefix = i == 0 ? '00000' : i + '0000';
            sprite.animation.addByPrefix(Std.string(i), prefix, 1, false);
        }

        text = new FunkinSprite(51, 23, Paths.image('ui/flashlight'));
    }
    
    function addToState(state)
    {
        state.add(sprite);
        state.add(text);
    }

    function getMaxBattery(night:Int):Int
    {
        return switch (night)
        {
            case 1:
                7000;
            case 2:
                6000;
            case 3:
                5000;
            case 4:
                4000;
            default:
                3000;
        }
    }
    
    function updateBattery()
    {
        if (!isOn)
            return;

        if (battery <= 0)
        {
            battery = 0;
            isOn = false;
            return;
        }

        battery--;
    }

    function updateBatterySprite()
    {
        var batteryAnim:Int = Math.round((battery / maxBattery) * 4);
        batteryAnim = FlxMath.bound(batteryAnim, 0, 4);

        sprite.animation.play(Std.string(batteryAnim), true);
    }

    var flickerTimer:Float = 0;

    function updateFlicker(elapsed:Float)
    {
        if (!canFlicker)
            return;

        var flickerThreshold:Float = maxBattery * 0.05;

        if (battery > flickerThreshold)
        {
            flickerTimer = 0;

            if (FlxFlicker.isFlickering(sprite))
                FlxFlicker.stopFlickering(sprite);

            sprite.visible = true;
            return;
        }   

        flickerTimer += elapsed;

        if (flickerTimer >= 0.2)
        {
            flickerTimer -= 0.2;

            if (!FlxFlicker.isFlickering(sprite))
                FlxFlicker.flicker(sprite, 0.1, 0.2, false);
        }
    }   

    public function update(input:Bool, elapsed)
    {
        if (battery <= 0)
        {
            battery = 0;
            isOn = false;
            sprite.visible = false;
            text.visible = false;

            if (FlxFlicker.isFlickering(sprite))
                FlxFlicker.stopFlickering(sprite);

            return;
        }

        isOn = input;

        if (isOn)
        {
            battery--;
        }

        updateBatterySprite();
        updateFlicker(elapsed);
    }

    public function getSprite():FunkinSprite
    {
        return sprite;
    }
}