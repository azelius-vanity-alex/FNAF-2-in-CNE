import funkin.backend.MusicBeatGroup;

class BaseMinigame extends MusicBeatGroup
{
    public var finished:Bool = false;
    public var scanline:FunkinSprite;

    public function new()
    {
        super();

        scanline = new FunkinSprite();
        scanline.loadGraphic(Paths.image('minigames/scanline'));
        add(scanline);
    }

    public function finish()
    {
        finished = true;
    }

    public function bringScanlineToFront()
    {
        remove(scanline, false);
        add(scanline);
    }
}