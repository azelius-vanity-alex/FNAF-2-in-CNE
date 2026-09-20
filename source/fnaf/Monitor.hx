class Monitor
{
    public var sprite:FunkinSprite;

    public var isOpen:Bool = false;
    public var isAnimating:Bool = false;

    public var onOpenFinished:Void->Void;
    public var onCloseFinished:Void->Void;

    public function new()
    {
        sprite = new FunkinSprite();

        sprite.frames = Paths.getSparrowAtlas('monitor');

        sprite.animation.addByPrefix('open', 'monitor', 60, false);
        sprite.animation.addByIndices('close', 'monitor', [9,8,7,6,5,4,3,2,1,0], '', 30, false);
        sprite.antialiasing = true;

        sprite.visible = false;

        sprite.animation.finishCallback = function(anim:String)
        {
            isAnimating = false;
            sprite.visible = false;

            switch(anim)
            {
                case 'open':
                    if (onOpenFinished != null)
                        onOpenFinished();

                case 'close':
                    if (onCloseFinished != null)
                        onCloseFinished();
            }
        }
    }

    public function open()
    {
        if (isOpen || isAnimating)
            return;

        isOpen = true;
        isAnimating = true;

        sprite.visible = true;
        sprite.animation.play('open', true);
    }

    public function close()
    {
        if (!isOpen || isAnimating)
            return;

        isOpen = false;
        isAnimating = true;

        sprite.visible = true;
        sprite.animation.play('close', true);
    }
}