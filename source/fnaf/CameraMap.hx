import fnaf.CameraMapButton;
import fnaf.CameraSystem;
import fnaf.WindUpBox;
import flixel.effects.FlxFlicker;

class CameraMap
{
    var buttons:Array<CameraMapButton>;

    var cameraSystem:CameraSystem;
    var hudCamera:FlxCamera;

    public var musicBoxWarning:FunkinSprite;
    var musicBoxFlickering:Bool = false;

    var musicBoxWarningOrange:FlxGraphic;
    var musicBoxWarningRed:FlxGraphic;

    public var musicBoxWarningHUD:FunkinSprite;

    var musicBoxWarningHUDOrange:FlxGraphic;
    var musicBoxWarningHUDRed:FlxGraphic;

    var musicBoxWarningState:Int = 0;
    var musicBoxWarningHUDState:Int = 0;

    public var windUpBox:WindUpBox;
    
    var enabled:Bool = false;

    public function new(cameraSystem:CameraSystem)
    {
        this.cameraSystem = cameraSystem;

        buttons = [];

        createButtons();

        musicBoxWarningOrange = Paths.image('ui/cautionSign_orange_small');
        musicBoxWarningRed = Paths.image('ui/cautionSign_red_small');

        musicBoxWarning = new FunkinSprite(884, 449, musicBoxWarningOrange);
        musicBoxWarning.visible = false;

        musicBoxWarningHUDOrange = Paths.image('ui/cautionSign_orange_big');
        musicBoxWarningHUDRed = Paths.image('ui/cautionSign_red_big');

        musicBoxWarningHUD = new FunkinSprite(918, 632, musicBoxWarningHUDOrange);
        musicBoxWarningHUD.visible = false;

        for (sprite in [musicBoxWarning, musicBoxWarningHUD])
            sprite.antialiasing = true;
    }

    var cameraPositions = [
        "cam09" => [892, 376],
        "cam11" => [920, 445],
        "cam12" => [903, 538],
        "cam10" => [824, 495],
        "cam07" => [728, 411],
        "cam04" => [707, 471],
        "cam01" => [572, 537],
        "cam05" => [578, 631],
        "cam03" => [572, 471],
        "cam08" => [573, 400],
        "cam02" => [704, 538],
        "cam06" => [693, 631]
    ];

    function createButtons()
    {
        for (id in cameraPositions.keys())
        {
            var pos = cameraPositions.get(id);
            buttons.push(new CameraMapButton(id, pos[0], pos[1], "Gray"));
        }

        windUpBox = new WindUpBox();
    }

    public function isMusicBoxEmpty():Bool
    {
        return windUpBox.isEmpty();
    }

    public function setCamera(cam:FlxCamera)
    {
        hudCamera = cam;

        windUpBox.setCamera(cam);
        musicBoxWarning.camera = cam;
        musicBoxWarningHUD.camera = cam;

        for (button in buttons)
        {
            button.button.camera = cam;
            button.label.camera = cam;
        }
    }

    public function selectCamera(id:String)
    {
        FlxG.sound.play(Paths.sound("blip"));

        windUpBox.setVisible(id == 'cam11');

        for (button in buttons)
        {
            button.setSelected(button.id == id);
        }
    }

    public function setVisible(value:Bool)
    {
        enabled = value;

        windUpBox.setVisible(value && cameraSystem.currentCamera == 'cam11');

        for (button in buttons)
        {
            button.setVisible(value);
        }
    }

    public function addToState(state)
    {
        state.add(windUpBox.sprite);
        state.add(windUpBox.text);
        state.add(windUpBox.clickAndHold);
        state.add(windUpBox.circle);
        state.add(musicBoxWarning);

        for (button in buttons)
        {
            state.add(button.button);
            state.add(button.label);
        }
    }

    function updateMusicBoxHUDWarning()
    {
        if (windUpBox == null)
            return;

        if (cameraSystem.animManager.puppetHasLeftBox)
        {
            musicBoxWarningHUDState = 0;
            FlxFlicker.stopFlickering(musicBoxWarningHUD);
            musicBoxWarningHUD.visible = false;
            return;
        }

        if (enabled)
        {
            if (musicBoxWarningHUDState != 0)
            {
                musicBoxWarningHUDState = 0;

                FlxFlicker.stopFlickering(musicBoxWarningHUD);
                musicBoxWarningHUD.visible = false;
            }

            return;
        }

        var newState:Int = 0;

        if (windUpBox.level <= 200)
        {
            newState = 2;
        }
        else if (windUpBox.level <= 400)
        {
            newState = 1;
        }

        if (newState == 0)
        {
            if (musicBoxWarningHUDState != 0)
            {
                musicBoxWarningHUDState = 0;

                FlxFlicker.stopFlickering(musicBoxWarningHUD);
                musicBoxWarningHUD.visible = false;
            }

            return;
        }

        if (newState != musicBoxWarningHUDState)
        {
            musicBoxWarningHUDState = newState;

            FlxFlicker.stopFlickering(musicBoxWarningHUD);

            if (newState == 1)
            {
                musicBoxWarningHUD.loadGraphic(musicBoxWarningHUDOrange);
                musicBoxWarningHUD.visible = true;

                FlxFlicker.flicker(musicBoxWarningHUD, 0, 0.3, true, false);
            }
            else if (newState == 2)
            {
                musicBoxWarningHUD.loadGraphic(musicBoxWarningHUDRed);
                musicBoxWarningHUD.visible = true;

                FlxFlicker.flicker(musicBoxWarningHUD, 0, 0.1, true, false);
            }
        }
    }
    
    function updateMusicBoxWarning()
    {
        if (windUpBox == null)
            return;

        if (cameraSystem.animManager.puppetHasLeftBox)
        {
            musicBoxWarningState = 0;
            musicBoxFlickering = false;
            FlxFlicker.stopFlickering(musicBoxWarning);
            musicBoxWarning.visible = false;
            return;
        }

        if (!enabled)
        {
            musicBoxWarningState = 0;
            musicBoxFlickering = false;

            FlxFlicker.stopFlickering(musicBoxWarning);

            musicBoxWarning.visible = false;
            return;
        }

        var newState:Int = 0;

        if (windUpBox.level <= 200)
        {
            newState = 2;
        }
        else if (windUpBox.level <= 400)
        {
            newState = 1;
        }

        if (newState == 0)
        {
            if (musicBoxFlickering)
            {
                musicBoxFlickering = false;
                FlxFlicker.stopFlickering(musicBoxWarning);
            }

            musicBoxWarning.visible = false;
            musicBoxWarningState = 0;
            return;
        }

        if (newState != musicBoxWarningState)
        {
            musicBoxWarningState = newState;

            FlxFlicker.stopFlickering(musicBoxWarning);

            if (newState == 1)
            {
                musicBoxWarning.loadGraphic(musicBoxWarningOrange);

                musicBoxWarning.visible = true;
                musicBoxFlickering = true;

                FlxFlicker.flicker(musicBoxWarning, 0, 0.3, true, false);
            }
            else if (newState == 2)
            {
                musicBoxWarning.loadGraphic(musicBoxWarningRed);

                musicBoxWarning.visible = true;
                musicBoxFlickering = true;

                FlxFlicker.flicker(musicBoxWarning, 0, 0.1, true, false);
            }
        }
    }

    public function update(elapsed:Float)
    {
        windUpBox.update(elapsed);
        updateMusicBoxWarning();
        updateMusicBoxHUDWarning();
        
        if (!enabled)
            return;

        for (button in buttons)
        {
            if (button.isMouseOver(hudCamera) && FlxG.mouse.justPressed)
            {
                cameraSystem.setCamera(button.id);
                selectCamera(button.id);
            }
        }
    }
}