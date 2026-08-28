class VentLight
{
    public var side:String;
    public var isOn:Bool = false;

    public var light:FunkinSprite;

    public static function precache()
    {
        for (side in ["left", "right"])
        {
            PlayState.instance.graphicCache.cache(Paths.image('office/ventlight/${side}_off'));
            PlayState.instance.graphicCache.cache(Paths.image('office/ventlight/${side}_on'));
        }
    }

    public function new(side:String)
    {
        this.side = side;

        light = new FunkinSprite(0, 0, Paths.image('office/ventlight/${side}'));
        light.antialiasing = true;
        light.animation.addByPrefix('off', 'off');
        light.animation.addByPrefix('on', 'on');

        updateGraphic();
    }        

    function updateGraphic()
    {
        var state = isOn ? "on" : "off";
        light.animation.play(state, true);
    }

    public function turnOn()
    {
        if (isOn) return;

        isOn = true;
        updateGraphic();
    }

    public function turnOff()
    {
        if (!isOn) return;

        isOn = false;
        updateGraphic();
    }

    public function toggle()
    {
        if (isOn)
            turnOff();
        else
            turnOn();
    }

    public function isMouseOver(cam:FlxCamera):Bool
        return light.overlapsPoint(FlxG.mouse.getWorldPosition(cam));
        
    public function update(elapsed:Float) {}
}