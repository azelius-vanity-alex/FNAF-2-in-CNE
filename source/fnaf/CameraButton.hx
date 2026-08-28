import fnaf.OfficeButton;

class CameraButton extends OfficeButton
{
    public var onPressed:Void->Void;

    public function new()
    {
        super('ui/cameraBtn');
    }

    override function press()
    {
        super.press();

        if (onPressed != null)
            onPressed();
    }
}