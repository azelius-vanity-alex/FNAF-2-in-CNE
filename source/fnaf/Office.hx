import fnaf.Hallway;
import flixel.graphics.FlxGraphic;

class Office extends FunkinSprite
{
    public var hallway:Hallway;

    public var leftVentView:FunkinSprite;
    public var rightVentView:FunkinSprite;

    public var jj:FunkinSprite;
    public var desk:FunkinSprite;

    public var hideAnimatronicOverlays:Bool = false;

    public var toyFreddy:FunkinSprite;
    public var officeAnimatronic:FunkinSprite;

    var mangleOffice:FunkinSprite;
    var balloonBoy:FunkinSprite;
    var goldenFreddy:FunkinSprite;

    var paperpal:FunkinSprite;

    var goldenFreddyWasVisible:Bool = false;
    var goldenFreddyFading:Bool = false;

    public var leftVentAnimatronic:FunkinSprite;
    public var rightVentAnimatronic:FunkinSprite;

    var graphicPaths:Array<String> = [
        'office/office_static',
        'office/office_leftvent',
        'office/office_rightvent',

        'office/toyfreddy',
        'office/office_WFreddy',
        'office/office_WBonnie',
        'office/office_WChica',

        'office/office_chica_leftvent',
        'office/office_mangle_rightvent',
        'office/office_bonnie_rightvent',
        'office/office_balloonboy_leftvent',

        'office/mangle',
        'office/balloonboy'
    ];

    var cachedGraphics:Map<String, FlxGraphic> = [];

    var currentOfficeAnimatronic:String = '';
    var currentLeftVentAnimatronic:String = '';
    var currentRightVentAnimatronic:String = '';

    public var goldenFreddyTweenDone:Void->Void;

    // plushies
    var freddyPlush:FunkinSprite;
    var bonniePlush:FunkinSprite;
    var chicaPlush:FunkinSprite;
    var foxyPlush:FunkinSprite;
    var toyBonniePlush:FunkinSprite;
    var cupcakePlush:FunkinSprite;
    var microphone:FunkinSprite;
    var goldenFreddyPlush:FunkinSprite;
    var bbPlush:FunkinSprite;

    public function new()
    {
        for (path in graphicPaths)
        {
            var graphic:FlxGraphic = Paths.image(path);

            cachedGraphics.set(path, graphic);
            FlxG.state.graphicCache.cache(graphic);
        }

        super(0, 0, getCachedGraphic('office/office_static'));

        hallway = new Hallway();

        leftVentView = new FunkinSprite(0, 0, getCachedGraphic('office/office_leftvent'));
        rightVentView = new FunkinSprite(0, 0, getCachedGraphic('office/office_rightvent'));

        hallway.visible = false;
        leftVentView.visible = false;
        rightVentView.visible = false;

        screenCenter();
        hallway.screenCenter();
        leftVentView.screenCenter();
        rightVentView.screenCenter();

        officeAnimatronic = new FunkinSprite(0, 0);
        officeAnimatronic.visible = false;

        toyFreddy = new FunkinSprite(521, 2, Paths.image('office/toyfreddy'));
        toyFreddy.visible = false;

        mangleOffice = new FunkinSprite(402, 0, Paths.image('office/mangle'));

        mangleOffice.visible = false;

        balloonBoy = new FunkinSprite(-29, 256, Paths.image('office/balloonboy'));
        balloonBoy.visible = false;

        goldenFreddy = new FunkinSprite(0, 236, Paths.image('office/goldenfreddy'));

        goldenFreddy.visible = false;
        goldenFreddy.alpha = 0;

        leftVentAnimatronic = new FunkinSprite(0, 0);
        leftVentAnimatronic.visible = false;

        rightVentAnimatronic = new FunkinSprite(0, 0);
        rightVentAnimatronic.visible = false;

        jj = new FunkinSprite(722, 645).loadGraphic(Paths.image('office/JJ'));
        jj.visible = false;

        desk = new FunkinSprite(268, 332);
        desk.frames = Paths.getSparrowAtlas('office/desk');

        desk.animation.addByPrefix('idle', 'desk', 30, true);
        desk.animation.play('idle');

        paperpal = new FunkinSprite(724, 130, Paths.image('office/paperpal'));
        paperpal.visible = false;

        freddyPlush = new FunkinSprite(356, 480).loadGraphic(Paths.image('office/plushies/freddy'));
        bonniePlush = new FunkinSprite(454, 472).loadGraphic(Paths.image('office/plushies/bonnie'));
        chicaPlush = new FunkinSprite(375, 512).loadGraphic(Paths.image('office/plushies/chica'));
        foxyPlush = new FunkinSprite(510, 515).loadGraphic(Paths.image('office/plushies/foxy'));
        bbPlush = new FunkinSprite(691, 517).loadGraphic(Paths.image('office/plushies/balloonboy'));
        toyBonniePlush = new FunkinSprite(738, 476).loadGraphic(Paths.image('office/plushies/toybonnie'));
        cupcakePlush = new FunkinSprite(822, 509).loadGraphic(Paths.image('office/plushies/cupcake'));
        goldenFreddyPlush = new FunkinSprite(920, 522).loadGraphic(Paths.image('office/plushies/goldenfreddy'));
        microphone = new FunkinSprite(570, 613).loadGraphic(Paths.image('office/plushies/microphone'));

        for (sprite in [freddyPlush, bonniePlush, chicaPlush, foxyPlush, bbPlush, toyBonniePlush, cupcakePlush, goldenFreddyPlush, microphone])
        {
            sprite.visible = false;
            sprite.antialiasing = true;
        }

        antialiasing = true;

        for (sprite in [officeAnimatronic, leftVentView, rightVentView, leftVentAnimatronic, rightVentAnimatronic, toyFreddy, goldenFreddy, balloonBoy, mangleOffice, desk])
            sprite.antialiasing = true;
    }

    function getCachedGraphic(path:String):FlxGraphic
        return cachedGraphics.get(path);

    public function addToState(state)
    {
        state.add(this);

        state.add(hallway);
        state.add(leftVentView);
        state.add(rightVentView);

        state.add(balloonBoy);
        state.add(goldenFreddy);

        state.add(leftVentAnimatronic);
        state.add(rightVentAnimatronic);

        state.add(officeAnimatronic);

        state.add(toyFreddy);
        state.add(jj);
        state.add(desk);

        state.add(goldenFreddyPlush);
        state.add(freddyPlush);
        state.add(bonniePlush);
        state.add(chicaPlush);
        state.add(foxyPlush);
        state.add(toyBonniePlush);
        state.add(bbPlush);
        state.add(cupcakePlush);
        state.add(microphone);

        state.add(mangleOffice);
        state.add(paperpal);
    }

    var currentView:String = 'normal';

    public function setView(view:String, animManager:AnimatronicManager)
    {
        if (currentView == view)
        {
            switch (view)
            {
                case 'hallway':
                    updateHallway(animManager);

                case 'leftVent':
                    updateVent(animManager, 'leftvent');

                case 'rightVent':
                    updateVent(animManager, 'rightvent');
            }

            return;
        }

        currentView = view;

        visible = false;
        hallway.visible = false;
        leftVentView.visible = false;
        rightVentView.visible = false;

        leftVentAnimatronic.visible = false;
        rightVentAnimatronic.visible = false;

        switch (view)
        {
            case 'normal':
                visible = true;

            case 'hallway':
                hallway.visible = true;
                updateHallway(animManager);

            case 'leftVent':
                leftVentView.visible = true;
                updateVent(animManager, 'leftvent');

            case 'rightVent':
                rightVentView.visible = true;
                updateVent(animManager, 'rightvent');
        }
    }

    function updateHallway(animManager:AnimatronicManager)
        hallway.setAnimatronics(animManager.animatronics, animManager.goldenFreddyHallway);

    function updateVent(animManager:AnimatronicManager, vent:String)
    {
        var foundAnimatronic:String = '';

        for (anim in animManager.animatronics)
        {
            if (anim.camera != vent)
                continue;

            var path:String = 'office/office_' + anim.name + '_' + vent;
            var graphic:FlxGraphic = getCachedGraphic(path);

            if (graphic == null)
                continue;

            foundAnimatronic = anim.name;

            if (vent == 'leftvent')
            {
                if (currentLeftVentAnimatronic != anim.name)
                {
                    currentLeftVentAnimatronic = anim.name;

                    leftVentAnimatronic.loadGraphic(graphic);
                    leftVentAnimatronic.screenCenter();
                }

                leftVentAnimatronic.visible = true;
            }
            else
            {
                if (currentRightVentAnimatronic != anim.name)
                {
                    currentRightVentAnimatronic = anim.name;

                    rightVentAnimatronic.loadGraphic(graphic);
                    rightVentAnimatronic.screenCenter();
                }

                rightVentAnimatronic.visible = true;
            }

            break;
        }

        if (foundAnimatronic == '')
        {
            if (vent == 'leftvent')
            {
                leftVentAnimatronic.visible = false;
                currentLeftVentAnimatronic = '';
            }
            else
            {
                rightVentAnimatronic.visible = false;
                currentRightVentAnimatronic = '';
            }
        }
    }

    public function updateOfficeOverlays(animManager:AnimatronicManager, flash:Bool, paperpalMoved:Bool)
    {
        toyFreddy.visible = false;
        officeAnimatronic.visible = false;
        mangleOffice.visible = false;
        balloonBoy.visible = false;
        paperpal.visible = paperpalMoved;

        if (animManager.goldenFreddyOffice)
        {
            if (!goldenFreddyWasVisible)
            {
                goldenFreddyWasVisible = true;
                goldenFreddyFading = false;

                FlxTween.cancelTweensOf(goldenFreddy);

                goldenFreddy.visible = true;
                goldenFreddy.alpha = 1;
            }

            if (flash && !goldenFreddyFading)
            {
                goldenFreddyFading = true;

                FlxTween.tween(goldenFreddy, {alpha: 0}, 1.13, {ease: FlxEase.linear,
                    onComplete: function(_)
                    {
                        goldenFreddy.visible = false;
                        goldenFreddyFading = false;

                        if (goldenFreddyTweenDone != null)
                            goldenFreddyTweenDone();
                    }
                });
            }
        }
        else
        {
            if (goldenFreddyWasVisible && !goldenFreddyFading)
            {
                goldenFreddyWasVisible = false;
                goldenFreddyFading = true;

                FlxTween.cancelTweensOf(goldenFreddy);

                FlxTween.tween(goldenFreddy, {alpha: 0}, 1.13, { ease: FlxEase.linear,
                    onComplete: function(_)
                    {
                        goldenFreddy.visible = false;
                        goldenFreddyFading = false;
                    }
                });
            }
        }

        if (hideAnimatronicOverlays)
            return;

        var foundOfficeAnimatronic:String = '';

        for (anim in animManager.animatronics)
        {
            if (anim.name == 'mangle')
            {
                mangleOffice.visible = anim.mangleInOffice;
                continue;
            }

            if (anim.name == 'balloonboy')
            {
                balloonBoy.visible = anim.bbInOffice;
                continue;
            }

            if (!anim.inOffice)
                continue;

            if (anim.name == 'freddy')
            {
                toyFreddy.visible = true;
                continue;
            }

            foundOfficeAnimatronic = anim.name;

            if (currentOfficeAnimatronic != anim.name)
            {
                var path:String = 'office/office_' + anim.name;
                var graphic:FlxGraphic = getCachedGraphic(path);

                if (graphic == null)
                    continue;

                currentOfficeAnimatronic = anim.name;

                officeAnimatronic.loadGraphic(graphic);
                officeAnimatronic.screenCenter();
            }

            officeAnimatronic.visible = true;

            break;
        }

        if (foundOfficeAnimatronic == '')
        {
            officeAnimatronic.visible = false;
            currentOfficeAnimatronic = '';
        }
    }
}