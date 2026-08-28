class Jumpscare extends FunkinSprite
{
    var animName:String;
    var finished:Bool = false;

    var jumpscareFPS:Map<String, Int> = [
        "freddy" => 24,
        "chica" => 24,
        "WFreddy" => 50,
        "WChica" => 24,
        "WFoxy" => 36
    ];

    public function new(animatronic:String)
    {
        animName = animatronic;

        super(0, 0);

        var fps:Int = jumpscareFPS.exists(animatronic) ? jumpscareFPS.get(animatronic) : 30;

        frames = Paths.getSparrowAtlas("jumpscare/" + animatronic + "_jumpscare");

        animation.addByPrefix("jumpscare", "jumpscare0", fps, false);
        animation.addByPrefix("jumpscareLoop", "jumpscare_loop", fps, true);

        visible = false;
        antialiasing = true;

        scrollFactor.set();

        screenCenter();
    }

    public function start()
    {
        visible = true;

        animation.play("jumpscare", true);

        FlxG.sound.play(Paths.sound("jumpscare"));

        animation.finishCallback = function(name:String)
        {
            if (name == "jumpscare")
            {
                animation.play("jumpscareLoop", true);
                new FlxTimer().start(0.6, function(_)
                {
                    finish();
                });
            }
        };
    }

    function finish()
    {
        if (finished)
            return;

        finished = true;

        FlxG.switchState(new ModState("StaticState"));
    }
}