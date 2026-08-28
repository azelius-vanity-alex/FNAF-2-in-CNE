class OfficeButton
{
    public var sprite:FunkinSprite;
    public var hovered:Bool = false;

    public var cooldown:Float = 0;
    public var cooldownTime:Float = 0.3;

    public var onHover:Void->Void;
    public var onLeave:Void->Void;

    public function new(image:String)
    {
        sprite = new FunkinSprite();
        sprite.antialiasing = true;
        sprite.loadGraphic(Paths.image(image));
    }

    public function isMouseOver(cam:FlxCamera):Bool
        return sprite.overlapsPoint(FlxG.mouse.getWorldPosition(cam));
    
    public function update(elapsed:Float, cam:FlxCamera)
    {
        if (cooldown > 0)
            cooldown -= elapsed;

        var over = isMouseOver(cam);

        if (over && !hovered && cooldown <= 0)
        {
            hovered = true;
            cooldown = cooldownTime;

            if (onHover != null)
                onHover();
        }

        if (!over && hovered)
        {
            hovered = false;

            if (onLeave != null)
                onLeave();
        }
    }
}