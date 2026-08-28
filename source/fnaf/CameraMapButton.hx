class CameraMapButton
{
    public var id:String;

    public var button:FunkinSprite;
    public var label:FunkinSprite;

    public var color:String;

    public function new(id:String, x:Float, y:Float, color:String = 'Gray')
    {
        this.id = id;
        this.color = color;

        button = new FunkinSprite(x, y, Paths.image('cameras/buttons/camBtn'));
        button.animation.addByPrefix('gray', 'gray');
        button.animation.addByPrefix('green', 'green');

        label = new FunkinSprite(x, y, Paths.image('cameras/buttons/' + id));
        label.antialiasing = false;

        label.x += 7;
        label.y += 7;
    }

    public function isMouseOver(cam:FlxCamera):Bool
        return FlxG.mouse.overlaps(button, cam);

    public function setSelected(value:Bool)
    {
        var color = value ? 'green' : 'gray';
        button.animation.play(color, true);
    }

    public function setVisible(value:Bool)
    {
        button.visible = value;
        label.visible = value;
    }
}