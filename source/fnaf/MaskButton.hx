import fnaf.OfficeButton;

class MaskButton extends OfficeButton
{
    public var onPressed:Void->Void;

    public function new()
    {
        super("ui/maskBtn");
    }

    override function press()
    {
        super.press();

        if (onPressed != null)
            onPressed();
    }

    public function hideUntilLeave()
    {
        sprite.visible = false;

        onLeave = function()
        {
            sprite.visible = true;
        };
    }
}