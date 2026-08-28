class FoxyMinigame extends BaseMinigame
{
    var foxy:FunkinSprite;

    public function new()
    {
        super();
        foxy = new FunkinSprite();
        foxy.frames = Paths.getSparrowAtlas('minigames/foxyMinigame/foxy');
        add(foxy);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}