import fnaf.AnimatronicManager;
import fnaf.CameraMapButton;
import flixel.effects.FlxFlicker;

using StringTools;

class CameraSystem
{
    public var currentCamera:String = '';
    public var currentEntity:String = 'default';

    var cameraIDs:Array<String>;
    var cameras:Array<FunkinSprite>;

    // sprites OKAY OKA
    var mangleOverlay:FunkinSprite;

    public var windUpBox:WindUpBox;

    var ribbon:FunkinSprite;

    var camLine1:FunkinSprite;
    var camLine2:FunkinSprite;
    var camLine3:FunkinSprite;
    
    var cameraBlip:FunkinSprite;
    var camBoxOverlay:FunkinSprite;
    var camStatic:FunkinSprite;
    var mapImg:FunkinSprite;
    var camName:FunkinSprite;
    var redButton:FunkinSprite;
    var signalInterruptedSprite:FunkinSprite;

    var signalFlickerVisible:Bool = false;
    
    var redButtonFlickering:Bool = false;

    var cameraHUD:Array<FunkinSprite>;

    var cameraEntities:Map<String, Array<String>>;
    var cameraButtons:Array<CameraMapButton>;

    var animManager:AnimatronicManager;

    var signalInterrupted:Bool = false;
    var permanentSignalInterrupted:Bool = false;
    var signalInterruptTimer:Float = 0;
    var signalInterruptDuration:Float = 0;

    var signalFlickerTimer:Float = 0;

    public var monitorOpen:Bool = false;

    public var lastViewedCamera:String = 'cam09';

    var staticSound:FlxSound;
    var musicBox:FlxSound;

    var musicBoxPlayed:Bool = true;
    
    public var currentState:String = 'static';
    var cameraLayer:FlxCamera;
    var perspectiveCamera:FlxCamera;

    var secretFlashActive:Bool = false;
    var secretFreddyActive:Bool = false;
    var secretPuppetActive:Bool = false;

    var secretFreddyTimer:Float = 0;

    var unscrollableCameras:Array<String> = [
        'cam01',
        'cam04',
        'cam05',
        'cam03',
        'cam02',
        'cam06'
    ];

    var customNight:Bool = false;

    var customNightBlockedCameras:Array<String> = [
        'cam08',
        'cam09'
    ];

    var puppetStaticTimer:Float = 0;
    var puppetStaticActive:Bool = false;
    var puppetTimer:FlxTimer = new FlxTimer();
    var puppetAdvanceStarted:Bool = false;

    var paperpalMoved:Bool = false;
    var paperpalMovePending:Bool = false;
    var paperpalStunTimer:Int = 50;

    public function new()
    {
        cameras = [];
        cameraIDs = [];
        cameraHUD = [];

        cameraEntities = [
            'cam09' => ['default']
        ];

        for (i in 1...13)
        {
            var id = 'cam' + StringTools.lpad(Std.string(i), '0', 2);

            var atlas = Paths.getSparrowAtlas('cameras/' + id);

            if (atlas == null)
            {
                continue;
            }

            var sprite = new FunkinSprite();
            sprite.antialiasing = true;
            sprite.frames = atlas;

            setupAnimations(sprite);

            sprite.visible = false;
            sprite.screenCenter();

            cameras.push(sprite);
            cameraIDs.push(id);
        }

        mangleOverlay = new FunkinSprite();
        mangleOverlay.visible = false;

        camStatic = new FunkinSprite();
        camStatic.frames = Paths.getSparrowAtlas('ui/static');
        camStatic.alpha = 0.4;
        camStatic.blend = 0;
        camStatic.antialiasing = true;
        camStatic.animation.addByPrefix('static', 'frame', 60, true);
        for (i in 1...4)
            camStatic.animation.addByPrefix('puppet$i', 'puppet$i', 1, false);
        
        camStatic.animation.play('static');

        mapImg = new FunkinSprite(545, 347, Paths.image('cameras/cameraMap'));

        camBoxOverlay = new FunkinSprite(0, 0, Paths.image('cameras/camBorderOverlay'));

        camName = new FunkinSprite(553, 307);

        redButton = new FunkinSprite(49, 96, Paths.image('cameras/redButton'));
        redButton.antialiasing = true;

        signalInterruptedSprite = new FunkinSprite(341, 80, Paths.image('ui/signalInterrupted'));
        signalInterruptedSprite.visible = false;

        cameraBlip = new FunkinSprite();
        cameraBlip.frames = Paths.getSparrowAtlas('camBlip');
        cameraBlip.animation.addByPrefix('blip', 'frame', 24, false);

        staticSound = FlxG.sound.load(Paths.sound('stare'), 0, true);
        staticSound.play();
        musicBox = FlxG.sound.load(Paths.sound('music box'), 0, true);
        musicBox.play(true);

        ribbon = new FunkinSprite(133, -7);
        ribbon.frames = Paths.getSparrowAtlas('cameras/ribbons');
        ribbon.animation.addByPrefix('ribbon', 'ribbon', 24, true);
        ribbon.animation.play('ribbon');
        ribbon.blend = 0;
        ribbon.antialiasing = true;
        ribbon.visible = false;

        camLine1 = new FunkinSprite(0, -35, Paths.image('ui/camLine1'));
        camLine2 = new FunkinSprite(0, -35, Paths.image('ui/camLine2'));
        camLine3 = new FunkinSprite(0, -35, Paths.image('ui/camLine3'));
        for (i in [camLine1, camLine2, camLine3])
        {
            i.alpha = 0.1;
            i.blend = 0;
        }   

        cameraBlip.screenCenter();

        cameraHUD.push(camStatic);
        cameraHUD.push(ribbon);
        cameraHUD.push(camBoxOverlay);
        cameraHUD.push(mapImg);
        cameraHUD.push(camName);
        cameraHUD.push(redButton);
        cameraHUD.push(cameraBlip);
        cameraHUD.push(signalInterruptedSprite);
        for (i in [camLine1, camLine2, camLine3])
            cameraHUD.push(i);

        perspectiveCamera = new FlxCamera();
        perspectiveCamera.bgColor = 0x00000000;

        FlxG.cameras.add(perspectiveCamera, false);

        camLine1.camera = perspectiveCamera;
        camLine2.camera = perspectiveCamera;
        camLine3.camera = perspectiveCamera;

        perspectiveCamera.addShader(new CustomShader('perspective'));
    }

    public function setWindUpBox(box:WindUpBox)
    {
        windUpBox = box;
    }

    function getEntityPrefix(entities:Array<String>, cam:FunkinSprite)
    {
        if (entities.length == 0)
            return 'default';

        var bestCombined:String = '';
        var bestScore:Int = -1;

        for (animName in cam.animation.getNameList())
        {
            if (!StringTools.endsWith(animName, '_' + currentState))
                continue;

            var prefix = animName.substr(0, animName.length - (currentState.length + 1));
            var matched:Int = 0;

            for (entity in entities)
            {
                if (prefix.contains(entity))
                    matched++;
            }

            if (matched == entities.length)
            {
                var score = prefix.length;

                if (bestCombined == '' || score < bestScore)
                {
                    bestCombined = prefix;
                    bestScore = score;
                }
            }
        }

        if (bestCombined != '')
            return bestCombined;

        return entities[0];
    }

    function setupAnimations(sprite:FunkinSprite)
    {
        var prefixes:Array<String> = [];

        for (frame in sprite.frames.frames)
        {
            var name = frame.name;
            var prefix = name.substr(0, name.length - 4);

            if (!prefixes.contains(prefix))
                prefixes.push(prefix);
        }

        for (prefix in prefixes)
        {
            sprite.animation.addByPrefix(prefix, prefix, 1, false);
        }
    }
    
    public function setMonitorOpen(value:Bool)
    {
        monitorOpen = value;

        if (!value)
        {
            clearSignalInterruption();

            mangleOverlay.visible = false;
            staticSound.volume = 0;
            camStatic.visible = false;
            signalInterruptedSprite.visible = false;
        }
        else
        {
            secretFlashActive = animManager != null && animManager.getCameraEntities('cam05').length == 0 && FlxG.random.int(1, 1000) == 1;
            secretFreddyActive = animManager != null && animManager.getCameraEntities('cam08').length == 0 && FlxG.random.int(1, 10) == 1;
            secretPuppetActive = animManager != null && animManager.puppetStage >= 1 && FlxG.random.int(1, 100) == 1;

            updateMangleOverlay();

            if (signalInterrupted)
            {
                camStatic.visible = true;
                camStatic.alpha = 1;
                staticSound.volume = 1;

                signalInterruptedSprite.visible = signalFlickerVisible;
            }
        }
    }

    var paperpalMoved:Bool = false;

    public function setPaperpalMoved(value:Bool)
    {
        paperpalMoved = value;
        updateCameraAnimation();
    }

    function isCustomNightBlockedCamera(id:String):Bool
    {
        return customNight && customNightBlockedCameras.contains(id);
    }

    public function setCameraLayer(cam:FlxCamera)
    {
        for (sprite in cameras)
        {
            sprite.camera = cam;
        }

        mangleOverlay.camera = cam;
    }

    public function addToState(state)
    {   
        for (cam in cameras)
            state.add(cam);

        state.add(mangleOverlay);

        for (sprite in cameraHUD)
        {
            if (sprite == cameraBlip || sprite == camLine1 || sprite == camLine2 || sprite == camLine3)
                continue;

            state.add(sprite);
        }

        state.add(camLine1);
        state.add(camLine2);
        state.add(camLine3);
    }

    public function setHUDCamera(cam:FlxCamera)
    {
        for (sprite in cameraHUD)
        {
            if (sprite == camLine1 || sprite == camLine2 || sprite == camLine3)
                continue;

            sprite.camera = cam;
        }
    }

    public function isCameraUnscrollable():Bool
    {
        return unscrollableCameras.contains(currentCamera);
    }

    public function updateCameraName()
    {
        if (currentCamera == '')
            return;

        camName.loadGraphic(Paths.image('cameras/camText/' + currentCamera));
    }

    public function playPuppetStageTransition()
    {
        if (currentCamera != 'cam11')
            return;

        var cam = getCurrent();

        if (cam == null)
            return;

        if (!cam.animation.exists('puppet_static'))
        {
            updateCameraAnimation();
            return;
        }

        puppetStaticActive = true;
        puppetStaticTimer = 0.7;

        cam.animation.play('puppet_static', true);
    }

    public function updateMangleOverlay()
    {
        mangleOverlay.visible = false;

        if (!monitorOpen || animManager == null)
            return;

        for (anim in animManager.animatronics)
        {
            if (anim.name != 'mangle' || anim.camera != currentCamera)
                continue;

            if (currentCamera != 'cam12' && currentCamera != 'cam06')
                mangleOverlay.loadGraphic(Paths.image('cameras/mangle/' + currentCamera));

            switch (currentCamera)
            {
                case 'cam11':
                    mangleOverlay.setPosition(410, -10);
                case 'cam10':
                    mangleOverlay.setPosition(-300, -10);
                case 'cam07':
                    mangleOverlay.setPosition(390, 455);
                case 'cam01':
                    mangleOverlay.setPosition(680, 450);
                case 'cam02':
                    mangleOverlay.setPosition(0, 185);

                case 'cam12':
                    return;

                default:
                    return;
            }

            mangleOverlay.visible = true;
            return;
        }
    }

    public function triggerSignalInterrupted()
    {
        if (!monitorOpen)
            return;

        signalInterrupted = true;

        signalFlickerTimer = 0;
        signalFlickerVisible = true;
        signalInterruptedSprite.visible = true;

        signalInterruptDuration = FlxG.random.int(20, 119);
        signalInterruptTimer = signalInterruptDuration;

        camStatic.visible = true;
        camStatic.alpha = 1;

        for (camera in cameras)
        {
            camera.color = FlxColor.BLACK;
        }

        mangleOverlay.color = FlxColor.BLACK;

        staticSound.volume = 1;

        playBlip();
    }

    function triggerPermanentSignalInterrupted()
    {
        if (!monitorOpen)
            return;

        signalInterrupted = true;
        permanentSignalInterrupted = true;

        signalFlickerTimer = 0;
        signalFlickerVisible = true;
        signalInterruptedSprite.visible = true;

        camStatic.visible = true;
        camStatic.alpha = 1;

        for (camera in cameras)
            camera.color = FlxColor.BLACK;

        mangleOverlay.color = FlxColor.BLACK;

        staticSound.volume = 1;
        playBlip();
    }   

    public function setCamera(id:String)
    {
        if (currentCamera != id && customNight && isCustomNightBlockedCamera(currentCamera) && !isCustomNightBlockedCamera(id))
            clearSignalInterruption();

        hideAll();

        for (i in 0...cameraIDs.length)
        {
            if (cameraIDs[i] == id)
            {
                currentCamera = id;
                lastViewedCamera = id;

                cameras[i].visible = true;

                updateCameraName();
                updateMangleOverlay();

                playBlip();
                updateCameraAnimation();

                if (isCustomNightBlockedCamera(id))
                {
                    triggerPermanentSignalInterrupted();
                }
                else if (!signalInterrupted)
                {  
                    camStatic.visible = true;
                    camStatic.alpha = currentCamera == 'cam11' ? 1 : 0.4;
                }

                if (musicBoxPlayed)
                {
                    if (currentCamera == 'cam11')
                        musicBox.volume = 1;
                    else if (currentCamera == 'cam09')
                        musicBox.volume = 0.5;
                    else if (currentCamera == 'cam10' || currentCamera == 'cam12')
                        musicBox.volume = 0.8;
                    else
                        musicBox.volume = 0;
                }
                else
                {
                    musicBox.volume = 0;
                }

                if (!customNight)
                {
                    camStatic.alpha = currentCamera == 'cam11' ? 1 : 0.4;
                }

                ribbon.visible = currentCamera == 'cam06';

                return;
            }
        }

        trace('Camera not found: ' + id);
    }

    function getCurrent()
    {
        for (i in 0...cameraIDs.length)
        {
            if (cameraIDs[i] == currentCamera)
                return cameras[i];
        }

        return null;
    }

    function playBlip()
    {
        cameraBlip.visible = true;
        cameraBlip.animation.play('blip', true);

        cameraBlip.animation.finishCallback = function(name:String)
        {
            if (name == 'blip')
            {
                cameraBlip.visible = false;
                updateCameraAnimation();
            }
        };
    }

    public function stopMusicBox()
    {
        musicBox.stop();
        musicBoxPlayed = false;
    }

    public function setEntities(name:String)
    {
        currentEntity = name;
        updateCameraAnimation();
    }

    public function setAnimatronicManager(manager:AnimatronicManager)
    {
        animManager = manager;
    }

    var puppetFaceimer:Float = 0;
    var puppetFaceActive:Bool = false;

    public function setState(state:String)
    {
        var oldState = currentState;
        currentState = state;

        if (oldState == 'flash' && state == 'static' && currentCamera != 'cam11')
        {
            for (anim in animManager.animatronics)
            {
                if (anim.name == 'puppet' && anim.camera == currentCamera && FlxG.random.int(1, 50) == 1)
                {
                    camStatic.animation.play('puppet' + FlxG.random.int(1, 3), true);
                    puppetFaceActive = true;
                    puppetFaceTimer = 0.1;
                    updateCameraAnimation();
                    return;
                }
            }
        }

        camStatic.animation.play('static');
        updateCameraAnimation();
    }

    public function updateCameraAnimation()
    {
        if (currentCamera == '')
            return;

        if (animManager == null)
        {
            return;
        }

        var cam = getCurrent();

        var entities = animManager.getCameraEntities(currentCamera);

        if (currentCamera != 'cam06' && currentCamera != 'cam12')
        {
            entities = entities.filter(function(entity:String)
            {
                return entity != 'mangle';
            });
        }

        if (currentCamera == 'cam08' && entities.contains('WFoxy') && entities.length > 1)
        {
            entities = entities.filter(function(entity:String)
            {
                return entity != 'WFoxy';
            });
        }

        var entityPrefix = getEntityPrefix(entities, cam);

        if (currentCamera == 'cam05' && secretFlashActive)
        {
            if (currentState == 'flash')
            {
                if (cam.animation.exists('secret_flash'))
                    cam.animation.play('secret_flash');

                return;
            }
        }

        if (currentCamera == 'cam08' && secretFreddyActive)
        {
            if (currentState == 'flash')
            {
                if (cam.animation.exists('secret_flash'))
                    cam.animation.play('secret_flash');

                return;
            }
        }

        if (currentCamera == 'cam04' && paperpalMoved)
        {
            if (currentState == 'flash')
            {
                if (cam.animation.exists('secret_flash'))
                    cam.animation.play('secret_flash');

                paperpalStunTimer = 50;
                return;
            }
        }

        if (currentCamera == 'cam11' && secretPuppetActive)
        {
            if (currentState == 'flash')
            {
                if (cam.animation.exists('secret_flash'))
                    cam.animation.play('secret_flash');

                return;
            }
        }

        if (currentCamera == 'cam11' && entities.contains('puppet'))
        {
            if (currentState == 'flash')
            {
                if (animManager.puppetStage >= 1 && animManager.puppetStage <= 4)
                {
                    cam.animation.play('puppet_stage' + animManager.puppetStage);
                }
                else
                {
                    cam.animation.play('puppet_flash');
                }

                return;
            }
        }

        var anim = entityPrefix + '_' + currentState;

        if (cam.animation.exists(anim))
            cam.animation.play(anim);
        else
            cam.animation.play('default_' + currentState);
    }

    public function onSignalInterruptionFinished()
    {        
        for (camera in cameras)
        {
            camera.color = FlxColor.WHITE;
        }
        mangleOverlay.color = FlxColor.WHITE;
        updateCameraAnimation();
        staticSound.volume = 0;
        if (currentCamera == 'cam11')
            camStatic.alpha = 1;
        else
            camStatic.alpha = 0.4;
    }

    public function clearSignalInterruption()
    {
        signalInterrupted = false;
        permanentSignalInterrupted = false;
        signalInterruptTimer = 0;
        signalInterruptDuration = 0;
        signalFlickerTimer = 0;
        signalFlickerVisible = false;

        signalInterruptedSprite.visible = false;
        camStatic.visible = false;
        mangleOverlay.visible = false;

        staticSound.volume = 0;

        for (camera in cameras)
            camera.color = FlxColor.WHITE;

        mangleOverlay.color = FlxColor.WHITE;
    }

    function hideAll()
    {
        for (cam in cameras)
            cam.visible = false;
    }

    public function setVisible(value:Bool)
    {
        for (cam in cameras)
            cam.visible = value;

        mangleOverlay.visible = value;
        musicBox.volume = 0;
    }

    var cameraHUDVisible:Bool = false;

    public function setHUDVisible(value:Bool)
    {
        cameraHUDVisible = value;

        for (sprite in cameraHUD)
        {
            if (sprite == signalInterruptedSprite)
                continue;

            sprite.visible = value;
        }

        signalInterruptedSprite.visible = value && signalInterrupted && signalFlickerVisible;
    }

    function updateRedButton()
    {
        if (!cameraHUDVisible)
        {
            if (redButtonFlickering)
            {
                redButtonFlickering = false;
                FlxFlicker.stopFlickering(redButton);
            }

            redButton.visible = false;
            return;
        }

        if (!redButtonFlickering)
        {
            redButtonFlickering = true;
            redButton.visible = true;

            FlxFlicker.flicker(redButton, 0, 1, true, false);
        }
    }

    public function update(elapsed:Float)
    {
        updateRedButton();

        paperpalStunTimer--;

        if (puppetFaceActive)
        {
            puppetFaceTimer -= elapsed;

            if (puppetFaceTimer <= 0)
            {
                puppetFaceTimer = 0;
                puppetFaceActive = false;

                camStatic.animation.play('static');
            }
        }

        camLine1.y += 0.6;
        if (camLine1.y > FlxG.height + 35) camLine1.y = -35;

        camLine2.y += 2;
		if (camLine2.y > FlxG.height + 35) camLine2.y = -35;

		camLine3.y += 3.4;
		if (camLine3.y > FlxG.height + 35) camLine3.y = -35;

        if (windUpBox != null)
        {
            if (windUpBox.level <= 0)
            {
                musicBox.stop();
            }
            else if (!musicBox.playing)
            {
                musicBox.play(true);
            }
        }

        if (puppetStaticActive)
        {
            puppetStaticTimer -= elapsed;

            if (puppetStaticTimer <= 0)
            {
                puppetStaticTimer = 0;
                puppetStaticActive = false;

                updateCameraAnimation();
            }
        }

        if (!signalInterrupted)
            return;

        signalFlickerTimer += elapsed;

        if (signalFlickerTimer >= 0.7)
        {
            signalFlickerTimer -= 0.7;

            signalFlickerVisible = !signalFlickerVisible;
            signalInterruptedSprite.visible = signalFlickerVisible && monitorOpen;
        }

        if (permanentSignalInterrupted)
            return;

        signalInterruptTimer -= elapsed * 60;

        if (signalInterruptTimer <= 0)
        {
            signalInterruptTimer = 0;
            signalInterrupted = false;

            signalFlickerVisible = false;
            signalInterruptedSprite.visible = false;

            onSignalInterruptionFinished();
        }
    }
}