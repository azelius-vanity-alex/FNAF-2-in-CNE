import flixel.FlxCamera;

import fnaf.VentLight;
import fnaf.CameraButton;
import fnaf.MaskButton;
import fnaf.FreddyMask;
import fnaf.Monitor;
import fnaf.Office;
import fnaf.CameraSystem;
import fnaf.CameraMap;
import fnaf.Jumpscare;
import fnaf.Flashlight;
import fnaf.NightLoader;
import SaveData;

// cameras

var camWorld:FlxCamera;
var camHUD:FlxCamera;

var camMonitor:FlxCamera;
var cameraSystem:CameraSystem;

var office:Office;

// camera movement

var camBaseX:Float;
var camBaseY:Float;

var camRangeX:Float = 288; // max left/right movement

var deadZone:Float = 150; // center area where camera doesn't move
var camSpeed:Float = 950;

var camVelocityX:Float = 0;

var camFrozen:Bool = false;

// cam movement (cmera state ok)

var monitorMoveRange:Float = 288;
var monitorMoveSpeed:Float = 70;

var monitorDirection:Int = 1;
var monitorPauseTime:Float = 3;
var monitorPauseTimer:Float = 0;

// vent lights

var currentOfficeView:String = 'normal';

var leftVent:VentLight;
var rightVent:VentLight;
var heldVent:VentLight = null;

// ui stuff

var freddyMask:FreddyMask;
var monitor:Monitor;

var cameraButton:CameraButton;
var maskButton:MaskButton;

var monitorOpen:Bool = false;
var maskOn:Bool = false;

var animManager:AnimatronicManager;
var cameraMap:CameraMap;

// THE BLACKOUT SEQUENCE, WOW!

var blackoutMaskChanceTimer:Float = 0;
var blackoutMaskChanceActive:Bool = false;

var maskLock:Bool = false;

var animatronicAttack:Bool = false;

var blackoutOverlay:FunkinSprite;

var blackoutActive:Bool = false;
var blackoutRolloutPending:Bool = false;

var blackOutProgress:Int = 0; // blackout progression
var flickerRoll:Int = 0; // flicker roll

var blackoutReactionTimer:Float = 0; // defaults to 0.75 seconds, will decrease each night
var blackoutReactionActive:Bool = false;
var blackoutAnim:Animatronic;

var toyBonnieOverlay:FunkinSprite;

var flashlight:Flashlight;

public var shadowBonnie:FunkinSprite;
var shadowBonnieTimer:Float = 0;
var shadowBonnieAppear:Bool = false;

var bbInOffice:Bool = false;

// idk 

var holdFlashlightSprite:FunkinSprite;
var holdFlashlightFrames:Int = 0;

var hideCameraButtonsUntilLeave:Bool = false;

var nightNumber:Int;
var nightTimer:Int = 0;
var currentHour:Int = 12;
var nightLength:Float = 420; // 420 seconds
var hourLength:Float = nightLength / 6; // 70 seconds

var openingCams:Bool = false;

var nightSprite:FunkinSprite;
var nightNumberSprite:FunkinSprite;
var amSprite:FunkinSprite;

var hourTens:FunkinSprite;
var hourOnes:FunkinSprite;

var freddyNoseHitbox:FunkinSprite;

var camMaxTimer:Float = 0;
var camMaxTime:Float;

var cameraAttackTimer:Float = 0;
var ventCameraTimer:Float = 0;
var ventCameraAttacker:Animatronic = null;

var jumpscare:Jumpscare;
var pendingJumpscare:Bool = false;
var dying:Bool = false;

var jumpscareAnim:Animatronic = null;

var muteCallTmr:FlxTimer;

// sousnds ok br
var staticSound:FlxSound;
var hallwayAmbience:FlxSound;
var cameraNoise:FlxSound;
var lightSound:FlxSound;
var ventSound:FlxSound;
var lastVentLocation:String = '';
var blockedSound:FlxSound;
var errorSound:FlxSound; // uh oh battery odin din done
var garbledSound:FlxSound;
var breathingSound:FlxSound;
var bbOfficeSound:FlxSound;
var normalAmbience:FlxSound;
var callSound:FlxSound;

var freddyMaskTimer:Float = 0;

// night loader (json)
var nightLoader:NightLoader;

var customNightAI:Array<Int>;

var aiNames:Array<String> = [
    'WFreddy',
    'WBonnie',
    'WChica',
    'WFoxy',
    'balloonboy',
    'freddy',
    'bonnie',
    'chica',
    'mangle',
    'goldenfreddy',
    'puppet'
];

var presetDoneKeys:Array<String> = [
    'four20Done',
    'newAndShinyDone',
    'doubleTroubleDone',
    'nightOfMisfitsDone',
    'foxyFoxyDone',
    'ladiesNightDone',
    'freddysCircusDone',
    'cupcakeChallengeDone',
    'fazbearFeverDone',
    'goldenFreddyDone'
];

var preset:Int = -1;
var presetName:String = '';

// paperpal ai LMAO
var paperpalAI:Int = 0;
var paperpalMoveTimer:Float = 0;
var paperpalMoveInterval:Float = 5.0;
var paperpalMovePending:Bool = false;
var paperpalPosition:Int = 0;

// todo: seperate these into functions

function create()
{
    SaveData.load();

    if (data != null)
    {
        if (data.night != null)
            nightNumber = data.night;

        if (data.sixthNight != null)
            sixthNight = data.sixthNight;

        if (data.ai != null)
            customNightAI = data.ai;

        if (data.preset != null)
            preset = data.preset;

        if (data.presetName != null)
            presetName = data.presetName;
    }
    else
    {
        nightNumber = SaveData.getInt('night', 1);
    }

    camMaxTime = 20 - (nightNumber * 2);

    nightLoader = new NightLoader(nightNumber);

    camWorld = new FlxCamera();
    FlxG.cameras.add(camWorld);

    camBaseX = camWorld.scroll.x;
    camBaseY = camWorld.scroll.y;

    camMonitor = new FlxCamera();
    camMonitor.bgColor = 0x000000;
    FlxG.cameras.add(camMonitor);

    camHUD = new FlxCamera();
    camHUD.bgColor = 0x000000;
    FlxG.cameras.add(camHUD);

    FlxCamera.defaultCameras = [camWorld];

    if (nightNumber < 7)
    {
        muteCall = new FunkinSprite(172, 42, Paths.image('ui/muteCall'));
        muteCall.alpha = 0.5;
        muteCall.visible = false;
        muteCall.antialiasing = true;
        muteCall.camera = camHUD;
        add(muteCall);
    }

    if (nightNumber < 7)
    {
        callSound = FlxG.sound.load(Paths.sound('calls/night' + nightNumber), 1, false);

        new FlxTimer().start(2, function() muteCall.visible = true);
	    muteCallTmr = new FlxTimer().start(29, function() muteCall.visible = false);
    }

    animManager = new AnimatronicManager();
    animManager.nightNumber = nightNumber;
    animManager.rollGoldenFreddy();
    animManager.setGoldenFreddyAI();

    nightLoader.applyStartingAI(animManager.animatronics);

    cameraSystem = new CameraSystem();
    cameraSystem.setCameraLayer(camMonitor);
    cameraSystem.setAnimatronicManager(animManager);
    cameraSystem.setHUDCamera(camHUD);
    cameraSystem.setVisible(false);
    cameraSystem.setHUDVisible(false);

    for (name in aiNames)
    {
        if (name == 'balloonboy')
            continue;

        graphicCache.cache(Paths.image('jumpscare/${name}_jumpscare'));
    }

    if (customNightAI != null)
    {
        cameraSystem.customNight = true;
        cameraSystem.lastViewedCamera = 'cam07';

        for (i in 0...aiNames.length)
        {
            for (anim in animManager.animatronics)
            {
                if (anim.name == 'puppet')
                {
                    anim.aiLevel = 15;
                    continue;
                }

                if (anim.name == aiNames[i])
                {
                    anim.aiLevel = FlxMath.bound(customNightAI[i], 0, anim.aiCap);
                    break;
                }
            }
        }
    }

    // i am stupid to not have cameramap be added inside camerasystem lmaooo
    cameraMap = new CameraMap(cameraSystem);

    cameraMap.setCamera(camHUD);
    cameraMap.setVisible(false);

    animManager.setCameraSystem(cameraSystem);
    animManager.setWindUpBox(cameraMap.windUpBox);
    cameraSystem.setWindUpBox(cameraMap.windUpBox);

    switch(nightNumber)
    {
        case 1, 2:
            cameraMap.windUpBox.drainAmount = 2;
        case 3, 4, 5:
            cameraMap.windUpBox.drainAmount = nightNumber;
        case 6, 7:
            cameraMap.windUpBox.drainAmount = 6;
    }

    office = new Office();
    office.addToState(this);

    if (FlxG.random.int(1, 100) == 1 && nightNumber == 7)
    {
        paperpalAI = 1;
    }

    office.goldenFreddyTweenDone = function()
    {
        animManager.goldenFreddyCanKill = true;
    };

    // uh oh
    office.freddyPlush.visible = SaveData.getBool('freddysCircusDone');
    office.bonniePlush.visible = SaveData.getBool('doubleTroubleDone');
    office.chicaPlush.visible = SaveData.getBool('ladiesNightDone');
    office.foxyPlush.visible = SaveData.getBool('foxyFoxyDone');
    office.bbPlush.visible = SaveData.getBool('nightOfMisfitsDone');
    office.toyBonniePlush.visible = SaveData.getBool('newAndShinyDone');
    office.cupcakePlush.visible = SaveData.getBool('cupcakeChallengeDone');
    office.microphone.visible = SaveData.getBool('fazbearFeverDone');
    office.goldenFreddyPlush.visible = SaveData.getBool('goldenFreddyDone');

    leftVent = new VentLight('left');
    rightVent = new VentLight('right');

    leftVent.light.x = -185;
    leftVent.light.y = 361;

    rightVent.light.x = 1108;
    rightVent.light.y = 361;

    add(leftVent.light);
    add(rightVent.light);

    toyBonnieOverlay = new FunkinSprite(1500, -80, Paths.image('office/toybonnie'));
    toyBonnieOverlay.antialiasing = true;
    toyBonnieOverlay.visible = false;
    add(toyBonnieOverlay);

    blackoutOverlay = new FunkinSprite(0, 0);
    blackoutOverlay.makeGraphic(1024, 768);
    blackoutOverlay.color = 0x000006;
    blackoutOverlay.scrollFactor.set();
    blackoutOverlay.camera = camHUD;
    blackoutOverlay.alpha = 0;

    freddyMask = new FreddyMask();
    freddyMask.sprite.camera = camHUD;

    monitor = new Monitor();
    monitor.sprite.camera = camHUD;

    nightSprite = new FunkinSprite(863, 34, Paths.image('ui/nightSprite'));
    nightSprite.camera = camHUD;
    add(nightSprite);

    nightNumberSprite = new FunkinSprite(973, 30, Paths.image('ui/night/' + nightNumber));
    nightNumberSprite.camera = camHUD;
    add(nightNumberSprite);

    hourTens = new FunkinSprite(900, 74);
    hourTens.camera = camHUD;
    add(hourTens);

    hourOnes = new FunkinSprite(920, 74);
    hourOnes.camera = camHUD;
    add(hourOnes);

    setHour(currentHour);

    amSprite = new FunkinSprite(956, 78, Paths.image('ui/AM'));
    amSprite.camera = camHUD;
    add(amSprite);

    flashlight = new Flashlight(nightNumber);   
    flashlight.sprite.cameras = [camHUD];
    flashlight.text.cameras = [camHUD];

    maskButton = new MaskButton();
    maskButton.sprite.camera = camHUD;
    cameraButton = new CameraButton();
    cameraButton.sprite.camera = camHUD;

    maskButton.sprite.setPosition(3, 706);
    cameraButton.sprite.setPosition(489, 705);

    cameraButton.cooldownTime = 0.25;
    maskButton.cooldownTime = 0.18;

    freddyNoseHitbox = new FunkinSprite(-145, 168).makeSolid(15, 5, FlxColor.WHITE);
    freddyNoseHitbox.alpha = 0;
    add(freddyNoseHitbox);

    shadowBonnie = new FunkinSprite(0, 0, Paths.image('office/rwqfsfasxc'));
    shadowBonnie.visible = false;
    add(shadowBonnie);

    if (nightNumber == 1)
    {
        holdFlashlightSprite = new FunkinSprite(39, 672, Paths.image('ui/tutorial'));
        holdFlashlightSprite.camera = camHUD;
        add(holdFlashlightSprite);
    }

    add(blackoutOverlay);

    flashlight.addToState(this);

    cameraSystem.addToState(this);
    cameraMap.addToState(this);

    add(cameraSystem.cameraBlip);

    add(cameraButton.sprite);
    add(maskButton.sprite);

    add(monitor.sprite);
    add(freddyMask.sprite);

    add(cameraMap.musicBoxWarningHUD);

    var cameraPanelHovered:Bool = false;

    cameraButton.onHover = function()
    {
        if (dying) return;

        if (blackoutActive) return;

        if (monitor.isAnimating) return;

        if (maskOn)
        {
            hideCameraButtonsUntilLeave = true;
            pullMaskUp();
            return;
        }

        cameraPanelHovered = true;

        if (monitor.isOpen)
        {
            dropCameras();
        }
        else
        {
            openingCams = true;

            FlxG.sound.play(Paths.sound('cams up'));

            if (shadowBonnieAppear)
            {
                shadowBonnieAppear = false;
                FlxTween.tween(shadowBonnie, {alpha: 0}, 1.13, {
                    onComplete: function()
                    {
                        shadowBonnieAppear = false;
                        shadowBonnie.visible = false;
                    }
                });
            }

            monitor.onOpenFinished = function()
            {
                openingCams = false;
                cameraSystem.setMonitorOpen(true);

                office.jj.visible = false;

                if (cameraPanelHovered)
                {
                    maskButton.sprite.visible = false;
                    cameraButton.sprite.visible = false;
                }
                else
                {
                    maskButton.sprite.visible = false;
                    cameraButton.sprite.visible = true;
                }

                if (!cameraNoise.playing)
                    cameraNoise.play();
                else
                    cameraNoise.volume = 1;

                cameraSystem.setVisible(true);
                cameraMap.setVisible(true);
                cameraSystem.setHUDVisible(true);
                cameraSystem.setCamera(cameraSystem.lastViewedCamera);
                cameraMap.selectCamera(cameraSystem.lastViewedCamera);
                
                FlxTween.cancelTweensOf(blackoutOverlay);
                blackoutOverlay.alpha = 0;
            };

            monitor.open();
            camFrozen = true;

            hideCameraButtonsUntilLeave = false;
        }
    };

    cameraButton.onLeave = function()
    {
        cameraPanelHovered = false;

        if (hideCameraButtonsUntilLeave && !openingCams)
        {
            maskButton.sprite.visible = true;
            cameraButton.sprite.visible = true;
            hideCameraButtonsUntilLeave = false;
        }
    };

    var hideMaskButtonUntilLeave:Bool = false;

    breathingSound = FlxG.sound.load(Paths.sound('breathing'), 0, true);
    breathingSound.play();

    hallwayAmbience = FlxG.sound.load(Paths.sound('hallway ambience'), 1, true);
    cameraNoise = FlxG.sound.load(Paths.sound('camera noise'), 1, true);
    lightSound = FlxG.sound.load(Paths.sound('buzz light'), 1, true);
    blockedSound = FlxG.sound.load(Paths.sound('pop static'), 1, true);
    ventSound = FlxG.sound.load(Paths.sound('vent walk'), 1, false);
    garbledSound = FlxG.sound.load(Paths.sound('elec garble'), 0, true);
    bbOfficeSound = FlxG.sound.load(Paths.sound('echo3'), 1, true);
    errorSound = FlxG.sound.load(Paths.sound('error'), 1, false);
    honk = FlxG.sound.load(Paths.sound('honk'), 1, false);
    maskDownSound = FlxG.sound.load(Paths.sound('mask down'), 1, false);
    maskUpSound = FlxG.sound.load(Paths.sound('mask up'), 1, false);

    garbledSound.play();

    maskButton.onHover = function()
    {
        if (dying) return;

        if (monitor.isOpen)
        {
            hideMaskButtonUntilLeave = true;
            maskButton.sprite.visible = false;
            cameraButton.sprite.visible = false;

            dropCameras();
            return;
        }

        if (maskLock && maskOn)
            return;

        if (maskOn)
        {
            maskOn = false;

            maskUpSound?.stop();
            maskUpSound?.play();

            breathingSound.volume = 0;
            freddyMask.takeOff();

            freddyMask.onTakeOffComplete = function()
            {

                if (flashlight.battery > 0)
                {
                    flashlight.canFlicker = true;
                    flashlight.text.visible = true;
                }

                nightSprite.visible = true;
                nightNumberSprite.visible = true;
                amSprite.visible = true;
                hourOnes.visible = true;
                if (currentHour == 12)
                    hourTens.visible = true;
                if (nightNumber == 1 && holdFlashlightFrames <= 100)
                    holdFlashlightSprite.visible = true;
            };

            hideMaskButtonUntilLeave = true;

            if (blackoutMaskChanceActive)
            {
                blackoutMaskChanceActive = false;

                triggerDeath();
                return;
            }

            checkPendingJumpscare();
            return;
        }
        
        if (heldVent != null)
        {
            heldVent.turnOff();
            heldVent = null;
        }

        maskOn = true;

        maskDownSound?.stop();
        maskDownSound?.play();

        if (shadowBonnieAppear)
        {
            shadowBonnieAppear = false;
            FlxTween.tween(shadowBonnie, {alpha: 0}, 1.13, {
                onComplete: function()
                {
                    shadowBonnieAppear = false;
                    shadowBonnie.visible = false;
                }
            });
        }

        maskDownSound.onComplete = function()
        {
            if (maskOn)
                breathingSound.volume = 1;
        };

        freddyMask.putOn();
        flashlight.canFlicker = false;
        for (sprite in [flashlight.sprite, flashlight.text, maskButton.sprite, cameraButton.sprite, nightSprite, nightNumberSprite, amSprite, hourOnes])
            sprite.visible = false;
        if (currentHour == 12)
            hourTens.visible = false;
        if (nightNumber == 1)
            holdFlashlightSprite.visible = false;
    };

    maskButton.onLeave = function()
    {
        if (hideMaskButtonUntilLeave)
        {
            maskButton.sprite.visible = true;
            cameraButton.sprite.visible = true;
            hideMaskButtonUntilLeave = false;
        }
    };

    staticSound = FlxG.sound.load(Paths.sound('stare'), 0, true);
    staticSound.play(true);

    camWorld.addShader(new CustomShader('perspective'));
    camMonitor.addShader(new CustomShader('perspective'));
}

function pullMaskUp()
{
    if (!maskOn)
        return;

    maskOn = false;

    FlxG.sound.play(Paths.sound('mask up'));
    breathingSound.volume = 0;
    freddyMask.takeOff();

    freddyMask.onTakeOffComplete = function()
    {
        if (flashlight.battery > 0)
        {
            flashlight.canFlicker = true;
            flashlight.text.visible = true;
        }

        nightSprite.visible = true;
        nightNumberSprite.visible = true;
        amSprite.visible = true;
        hourOnes.visible = true;

        if (currentHour == 12)
            hourTens.visible = true;
    };

    hideMaskButtonUntilLeave = true;

    if (blackoutMaskChanceActive)
    {
        blackoutMaskChanceActive = false;
        triggerDeath();
        return;
    }

    checkPendingJumpscare();
}

function dropCameras()
{
    if (!monitor.isOpen)
        return false;

    cameraAttackTimer = 0;

    FlxG.sound.play(Paths.sound('cams down'));
    cameraNoise.volume = 0;

    cameraSystem.clearSignalInterruption();

    cameraSystem.setVisible(false);
    cameraSystem.setHUDVisible(false);
    cameraMap.setVisible(false);

    monitor.close();
    cameraSystem.setMonitorOpen(false);
    camFrozen = false;

    if (FlxG.random.int(1, 1000) == 1)
        office.jj.visible = true;

    if (FlxG.random.int(1, 16384) == 1)
    {
        FlxTween.cancelTweensOf(shadowBonnie);
        shadowBonnieTimer = 0;
        shadowBonnieAppear = true;
        shadowBonnie.visible = true;
        shadowBonnie.alpha = 1;
    }

    for (anim in animManager.animatronics)
    {
        if (anim.isAtVent() && anim.ventAttackReady)
        {
            anim.ventAttackReady = false;
            anim.ventAttackActive = false;
            anim.ventCanKill = false;

            triggerDeath(anim);
            return true;
        }
    }

    var attacker = animManager.cameraFlip();

    if (attacker != null)
    {
        triggerDeath(attacker);
        return true;
    }

    if (cameraSystem.paperpalMovePending)
    {
        cameraSystem.paperpalMovePending = false;
        cameraSystem.paperpalMoved = true;
    }

    if (blackoutMaskChanceActive)
    {
        blackoutMaskChanceActive = false;
        pendingJumpscare = false;

        triggerDeath();
        return true;
    }

    checkPendingJumpscare();

    if (!dying)
    {
        maskButton.sprite.visible = false;
        cameraButton.sprite.visible = false;
        hideCameraButtonsUntilLeave = true;
    }

    return true;
}

function startBlackout(anim:Animatronic)
{   
    if (monitor.isOpen)
        dropCameras();

    staticSound.volume = 1;

    blackoutAnim = anim;
    jumpscareAnim = anim;

    animManager.setBlackout(true);
    blackoutActive = true;
    maskLock = true;
    blackOutProgress = 0;

    switch (nightNumber)
    {
        case 1:
            blackoutReactionTimer = 1.667;
        case 2:
            blackoutReactionTimer = 1.333;
        case 3:
            blackoutReactionTimer = 1;
        case 4:
            blackoutReactionTimer = 0.917;
        case 5, 6:
            blackoutReactionTimer = 0.833;
        case 7:
            blackoutReactionTimer = 0.75;
        default:
            blackoutReactionTimer = 0.75;
    }

    blackoutReactionActive = true;

    FlxTween.cancelTweensOf(toyBonnieOverlay);
    FlxTween.cancelTweensOf(blackoutOverlay);
    blackoutOverlay.visible = true;
    blackoutOverlay.alpha = 0;
}

function updateBlackout(elapsed:Float)
{
    if (!blackoutActive && !blackoutMaskChanceActive)
        return;

    if (blackoutReactionActive)
    {
        blackoutReactionTimer -= elapsed;

        if (maskOn)
        {
            blackoutReactionActive = false;
        }
        else if (blackoutReactionTimer <= 0)
        {
            blackoutReactionActive = false;
            pendingJumpscare = true;

            blackoutRolloutPending = true;

            blackoutMaskChanceActive = true;
            blackoutMaskChanceTimer = 0;

            if (blackoutAnim != null)
            {
                blackoutAnim.camera = 'office';
            }
        }
    }

    /*
    if (blackoutMaskChanceActive && maskOn && !dying)
    {
        blackoutMaskChanceTimer += elapsed;

        if (blackoutMaskChanceTimer >= 1)
        {
            blackoutMaskChanceTimer -= 1;

            var roll:Int = FlxG.random.int(1, 2);

            if (roll == 1)
            {
                blackoutMaskChanceActive = false;
                pendingJumpscare = false;

                triggerDeath();
            }
            else
            {
                blackoutMaskChanceActive = false;
                pendingJumpscare = false;
            }
        }
    }*/

    blackOutProgress += elapsed * 60;

    if (blackOutProgress >= 21 && blackOutProgress <= 99)
    {
        blackoutOverlay.alpha = FlxG.random.bool(50) ? 1 : 0;
    }
    else if (blackOutProgress >= 100 && blackOutProgress <= 199)
    {
        blackoutOverlay.alpha = FlxG.random.bool(7) ? 0 : 1;
    }
    else if (blackOutProgress >= 200 && blackOutProgress < 300)
    {
        blackoutOverlay.alpha = 1;
    }

    if (blackOutProgress >= 300)
    {
        blackoutActive = false;
        startFade();
    }
}

function startFade()
{
    blackoutActive = false;
    staticSound.volume = 0;

    animManager.finishOfficeAttack();
    FlxTween.cancelTweensOf(toyBonnieOverlay);
    toyBonnieOverlay.visible = false;
    toyBonnieOverlay.x = 1500;
    
    if (blackoutReactionTimer <= 0)
    {
        office.hideAnimatronicOverlays = true;
    }
    endBlackout();

    FlxTween.tween(blackoutOverlay, {alpha: 0}, 3, {
        ease: FlxEase.linear,
        onComplete: function(_)
        {
            blackoutOverlay.visible = false;

            if (blackoutRolloutPending)
            {
                blackoutRolloutPending = false;
                blackoutMaskChanceActive = true;
                blackoutMaskChanceTimer = 0;
            }
        }
    });
}

function endBlackout()
{
    animatronicAttack = false;
    maskLock = false;

    animManager.setBlackout(false);
    if (blackoutAnim != null)
    {
        if (blackoutAnim.name == 'bonnie')
        {
            blackoutAnim.inOffice = false;
            blackoutAnim.pendingOfficeAttack = false;
            blackoutAnim.canAttackOffice = false;

            blackoutAnim.ventAttackTimer = 0;
            blackoutAnim.ventAttackReady = false;
            blackoutAnim.ventAttackActive = false;
            blackoutAnim.ventCanKill = false;
            blackoutAnim.ventKillTimer = 0;
            blackoutAnim.ventMaskTimer = 0;

            if (blackoutAnim.attackReturnCam != null && blackoutAnim.attackReturnCam != '')
                blackoutAnim.moveTo(blackoutAnim.attackReturnCam);
        }
        else if (pendingJumpscare)
        {
            blackoutAnim.camera = 'office';
        }
        else
        {
            blackoutAnim.inOffice = false;
            blackoutAnim.pendingOfficeAttack = false;
            blackoutAnim.canAttackOffice = false;

            if (blackoutAnim.attackReturnCam != null && blackoutAnim.attackReturnCam != '')
                blackoutAnim.moveTo(blackoutAnim.attackReturnCam);
        }

        blackoutAnim = null;
    }

    for (anim in animManager.animatronics)
    {
        if (!anim.inOffice)
            continue;

        if (anim.name == 'balloonboy')
        {
            anim.camera = 'office';
            anim.inOffice = true;
            anim.officeVisible = true;
            continue;
        }

        if (pendingJumpscare)
        {
            anim.camera = 'office';
        }
        else
        {
            anim.inOffice = false;

            if (anim.attackReturnCam != null && anim.attackReturnCam != '')
            {
                anim.moveTo(anim.attackReturnCam);
            }
            else
            {
                anim.moveTo(anim.previousCamera);
            }

            if (anim.name == 'freddy')
            {
                anim.stun((500 / nightNumber) / 60);
            }

            if (anim.name == 'bonnie')
            {
                anim.stun(FlxG.random.int(1, 499) / 60);
            }
        }
    }
}

function forceAnimatronicAttack()
{
    for (anim in animManager.animatronics)
    {
        if (anim.inOffice)
            return;

        anim.inOffice = true;
        anim.camera = 'office';
        break;
    }
}

function checkPendingJumpscare()
{
    if (!pendingJumpscare)
        return;

    if (blackoutMaskChanceActive)
        return;

    pendingJumpscare = false;

    triggerDeath(jumpscareAnim);
}

function shakeCamera()
{
    var centerX:Float = camWorld.scroll.x;
    var amount:Float = 5;

    function shake()
    {
        FlxTween.tween(camWorld.scroll, {x: centerX + amount}, 0.05, {
            ease: FlxEase.linear,
            onComplete: function(_)
            {
                FlxTween.tween(camWorld.scroll, {x: centerX - amount}, 0.05, {
                    ease: FlxEase.linear,
                    onComplete: function(_)
                    {
                        shake();
                    }
                });
            }
        });
    }

    shake();
}

function triggerDeath(anim:Animatronic = null)
{
    if (dying)
        return;

    if (anim == null)
        anim = jumpscareAnim;

    if (anim == null)
        return;

    jumpscareAnim = anim;

    camFrozen = true;

    shakeCamera();

    if (maskOn)
        pullMaskUp();

    if (monitor.isOpen)
        dropCameras();

    dying = true;

    jumpscare = new Jumpscare(anim.name);
    jumpscare.camera = camHUD;
    insert(members.indexOf(monitor.sprite), jumpscare);

    jumpscare.start();
}

function hasPendingAttack():Bool
{
    for (anim in animManager.animatronics)
    {
        if (anim.pendingOfficeAttack)
            return true;
    }

    return false;
}

function checkAnimatronicAttack()
{
    if (openingCams)
        return;

    if (animatronicAttack || pendingJumpscare || dying)
        return;

    for (anim in animManager.animatronics)
    {
        if (anim.inOffice && anim.name != 'puppet' && anim.causesBlackout)
        {
            animatronicAttack = true;
            startBlackout(anim);
            return;
        }
    }
}

function updateCamAttackTimer(elapsed:Float)
{
    cameraAttackTimer += elapsed;

    if (cameraAttackTimer >= 10)
    {
        cameraAttackTimer -= 10;

        if (hasPendingAttack() && monitor.isOpen && !openingCams)
            dropCameras();
    }
}

function updateMaxTimer(elapsed:Float)
{
    for (anim in animManager.animatronics)
    {
        if (!anim.inOffice)
            continue;

        if (monitor.isOpen)
        {
            anim.camMaxTimer += elapsed;

            if (anim.camMaxTimer >= camMaxTime)
            {
                anim.camMaxTimer = camMaxTime;
            }
        }
        else if (anim.camMaxTimer >= camMaxTime)
        {
            triggerDeath(anim);
            return;
        }
    }
}

function setHour(hour:Int)
{
    if (hour == 12)
    {
        if (nightNumber < 7)
            callSound.play();

        FlxG.sound.play(Paths.sound('fan'), 1, true);
        FlxG.sound.play(Paths.sound('in the depths'), 1, true);

        hourTens.loadGraphic(Paths.image('ui/night/1'));
        hourTens.visible = true;

        hourOnes.loadGraphic(Paths.image('ui/night/2'));
        hourOnes.visible = true;
    }
    else
    {
        hourTens.visible = false;

        hourOnes.loadGraphic(Paths.image('ui/night/' + hour));
        hourOnes.visible = true;
    }
}

function updateNightTime(elapsed:Float):Bool
{
    nightTimer += elapsed;

    if (nightTimer >= nightLength)
    {
        nightTimer = nightLength;
        currentHour = 6;
        setHour(6);

        persistentUpdate = false;
        persistentDraw = true;

        FlxG.sound.music.stop();

        FlxG.sound.list.forEach(function(sound:FlxSound)
        {
            sound.stop();
        });

        hallwayAmbience.stop();

        if (preset >= 0 && preset < presetDoneKeys.length)
        {
            SaveData.setBool(presetDoneKeys[preset], true);
            SaveData.save();
        }   

        openSubState(new ModSubState('winState', {night: nightNumber, sixthNight: sixthNight}));

        return true;
    }

    var hourIndex:Int = Math.floor(nightTimer / hourLength);
    var newHour:Int = hourIndex == 0 ? 12 : hourIndex;

    if (newHour != currentHour)
    {
        currentHour = newHour;
        setHour(newHour);

        nightLoader.applyHourAI(animManager.animatronics, currentHour);
    }

    if (nightNumber == 1)
    {
        cameraMap.windUpBox.canDrainBox = currentHour >= 2 && currentHour != 12;
    }


    animManager.hour = currentHour;

    return false;
}

function playVentSound()
{
    var currentVentLocation:String = '';

    for (anim in animManager.animatronics)
    {
        if (anim.camera == 'cam05' || anim.camera == 'cam06' || anim.camera == 'leftvent' || anim.camera == 'rightvent')
        {
            currentVentLocation = anim.camera;
            break;
        }
    }

    if (currentVentLocation != '' && currentVentLocation != lastVentLocation)
    {
        ventSound.play();
    }

    if (currentVentLocation == '' && lastVentLocation != '')
    {
        ventSound.play();
    }

    lastVentLocation = currentVentLocation;
}

function playBalloonBoySound()
{
    for (anim in animManager.animatronics)
    {
        if (anim.name == 'balloonboy' && anim.bbInOffice)
        {
            bbInOffice = true;
            flashlight.battery = 0;
            break;
        }
    }

    if (bbInOffice)
    {
        if (!bbOfficeSound.playing)
            bbOfficeSound.play(true);
    }
    else
    {
        if (bbOfficeSound.playing)
            bbOfficeSound.stop();
    }
}

function playMangleSound()
{
    var mangleInCurrentCamera = false;
    var mangleInOffice = false;

    if (monitor.isOpen)
    {
        for (anim in animManager.animatronics)
        {
            if (anim.name == 'mangle' && anim.camera == cameraSystem.currentCamera)
            {
                mangleInCurrentCamera = true;
            }
        }
    }

    for (anim in animManager.animatronics)
    {
        if (anim.name == 'mangle' && (anim.camera == 'rightvent' || anim.mangleInOffice))
        {
            mangleInOffice = true;
        }
    }

    if (mangleInCurrentCamera || mangleInOffice)
        garbledSound.volume = 1;
    else
        garbledSound.volume = 0;    
}

function updateCamera(elapsed:Float)
{   
    if (camFrozen) return;

    var mouseX = FlxG.mouse.screenX;
    var centerX = FlxG.width / 2;
    var mouseOffset = mouseX - centerX;
    var moveSpeed:Float = 0;

    if (Math.abs(mouseOffset) > deadZone)
    {
        var distance = Math.abs(mouseOffset) - deadZone;
        var strength = distance / (centerX - deadZone);
        strength *= 2;
        strength = FlxMath.bound(strength, 0, 1);
        moveSpeed = FlxMath.signOf(mouseOffset) * strength * camSpeed;
    }

    camWorld.scroll.x += moveSpeed * elapsed;
    camWorld.scroll.x = FlxMath.bound(camWorld.scroll.x, camBaseX - camRangeX, camBaseX + camRangeX);
}

var monitorScroll:Float = 0;
var wasUnscrollable:Bool = false;

function updateMonitorMovement(elapsed:Float)
{
    var unscrollable = cameraSystem.isCameraUnscrollable();

    if (unscrollable && !wasUnscrollable)
    {
        monitorScroll = camMonitor.scroll.x;
        camMonitor.scroll.x = 0;
    }

    if (unscrollable)
    {
        if (monitorPauseTimer > 0)
        {
            monitorPauseTimer -= elapsed;

            if (monitorPauseTimer <= 0)
            {
                monitorDirection *= -1;
            }
        }
        else
        {
            monitorScroll += monitorDirection * monitorMoveSpeed * elapsed;

            if (monitorScroll >= monitorMoveRange)
            {
                monitorScroll = monitorMoveRange;
                monitorPauseTimer = monitorPauseTime;
            }
            else if (monitorScroll <= -monitorMoveRange)
            {
                monitorScroll = -monitorMoveRange;
                monitorPauseTimer = monitorPauseTime;
            }
        }

        wasUnscrollable = true;
        return;
    }

    if (wasUnscrollable)
        camMonitor.scroll.x = monitorScroll;

    wasUnscrollable = false;

    if (monitorPauseTimer > 0)
    {
        monitorPauseTimer -= elapsed;

        if (monitorPauseTimer <= 0)
        {
            monitorDirection *= -1;
        }

        return;
    }

    camMonitor.scroll.x += monitorDirection * monitorMoveSpeed * elapsed;

    if (camMonitor.scroll.x >= monitorMoveRange)
    {
        camMonitor.scroll.x = monitorMoveRange;
        monitorPauseTimer = monitorPauseTime;
    }
    else if (camMonitor.scroll.x <= -monitorMoveRange)
    {
        camMonitor.scroll.x = -monitorMoveRange;
        monitorPauseTimer = monitorPauseTime;
    }

    monitorScroll = camMonitor.scroll.x;
}

var lastFlashState:Bool = false;
var lastHallwayAnims:Array<String> = [];

function updateHallwayBlocked()
{
    var hallwayAnims:Array<String> = [];

    for (anim in animManager.animatronics)
    {
        if (anim.camera == 'hallway1' || anim.camera == 'hallway2')
        {
            hallwayAnims.push(anim.name + '_' + anim.camera);
        }
    }

    hallwayAnims.sort(function(a:String, b:String)
    {
        return a < b ? -1 : (a > b ? 1 : 0);
    });

    if (hallwayAnims.join('|') != lastHallwayAnims.join('|'))
    {
        office.hallway.triggerBlocked();
    }

    lastHallwayAnims = hallwayAnims.copy();
}

var hallwayCameras:Array<String> = [
    'hallway1',
    'hallway2',
    'cam01',
    'cam02',
    'cam05',
    'cam06',
    'leftvent',
    'rightvent'
];

function updateHallwayAmbience()
{
    var inHallway = false;

    for (anim in animManager.animatronics)
    {
        if (hallwayCameras.contains(anim.camera) || anim.mangleInOffice || anim.inOffice)
        {
            inHallway = true;
            break;
        }
    }

    if (inHallway)
    {
        if (!hallwayAmbience.playing)
            hallwayAmbience.play(true);
    }
    else
    {
        if (hallwayAmbience.playing)
            hallwayAmbience.stop();
    }
}

function updateFreddyMask(elapsed:Float)
{
    var freddy = null;

    for (anim in animManager.animatronics)
    {
        if (anim.name == 'freddy')
        {
            freddy = anim;
            break;
        }
    }

    if (freddy == null)
        return;

    if (freddy.camera != 'hallway2' || !maskOn)
    {
        freddyMaskTimer = 0;
        return;
    }

    freddyMaskTimer += elapsed;

    if (freddyMaskTimer >= 1)
    {
        freddyMaskTimer -= 1;

        var roll:Int = FlxG.random.int(1, 10);

        if (roll == 1)
        {
            animManager.cancelOfficeAttack(freddy);
            freddy.moveTo('cam09');
        }
    }
}

var errorPlayed:Bool = false;

function update(elapsed:Float)
{
    if (updateNightTime(elapsed))
        return;

    if (FlxG.keys.justPressed.B)
    {
        for (anim in animManager.animatronics)
        {
            if (anim.name == 'WFoxy')
            {
                triggerDeath(anim);
            }
        }
    }

    flashlight.update(FlxG.keys.pressed.CONTROL && !maskOn && !blackoutActive, elapsed);

    var flash = FlxG.keys.pressed.CONTROL && !blackoutActive && !maskOn && monitor.isOpen && flashlight.battery > 0;
    var hallwayLight = FlxG.keys.pressed.CONTROL && !blackoutActive && !maskOn && !monitor.isOpen && flashlight.battery > 0;

    var flashlightInputActive = FlxG.keys.pressed.CONTROL && !blackoutActive && !maskOn;
    var ventInputActive = heldVent != null;

    var lightInputActive = flashlightInputActive || ventInputActive;
    var lightActive = lightInputActive && flashlight.battery > 0;

    if (nightNumber == 1)
    {
        if (hallwayLight || flash)
        {
            holdFlashlightFrames += 1;
            if (holdFlashlightFrames >= 100)
                holdFlashlightSprite.visible = false;
        }
    }
        
    updateCamera(elapsed);
    updateMonitorMovement(elapsed);
    updateBlackout(elapsed);
    updateCamAttackTimer(elapsed);

    updateHallwayAmbience();

    leftVent.update(elapsed);
    rightVent.update(elapsed);

    cameraButton.update(elapsed, camHUD);
    maskButton.update(elapsed, camHUD);

    office.updateOfficeOverlays(animManager, hallwayLight, cameraSystem.paperpalMoved);
    office.update(elapsed);

    animManager.update(elapsed, hallwayLight, maskOn, rightVent.isOn);
    animManager.updateVentTimers(elapsed, maskOn, cameraSystem.monitorOpen);
    cameraSystem.update(elapsed);
    updateFreddyMask(elapsed);

    checkAnimatronicAttack();
    playMangleSound();
    playBalloonBoySound();

    if (animManager.toyBonnieBlackout() && !blackoutActive)
    {
        for (anim in animManager.animatronics)
        {
            if (anim.name == 'bonnie')
            {
                toyBonnieOverlay.visible = true;
                startBlackout(anim);
                toyBonnieOverlay.x = 1500;
                FlxTween.cancelTweensOf(toyBonnieOverlay);
                FlxTween.tween(toyBonnieOverlay, {x: 500}, 3);
            }
        }
    }

    freddyMask.update(elapsed);
    cameraMap.update(elapsed);

    office.hallway.update(elapsed);
    office.hallway.updateAnimatronics(animManager.animatronics);

    updateHallwayBlocked();

    var killFlags:Map<String, Bool> = [
        'mangle' => animManager.mangleCanKill,
        'WFoxy' => animManager.foxyCanKill,
        'puppet' => animManager.puppetCanKill,
        'goldenfreddy' => animManager.goldenFreddyCanKill
    ];

    for (anim in animManager.animatronics)
    {
        if (killFlags.exists(anim.name) && killFlags[anim.name])
        {
            triggerDeath(anim);
            dropCameras();
        }
    }

    if (animManager.foxyTenSecondKill)
    {
        for (anim in animManager.animatronics)
        {
            if (anim.name == 'WFoxy')
            {
                triggerDeath(anim);
                dropCameras();
            }
        }
    }

    var mousePos = FlxG.mouse.getWorldPosition(camWorld);
    var mousePosHUD = FlxG.mouse.getWorldPosition(camHUD);

    if (nightNumber < 7)
    {
        if ((muteCall.overlapsPoint(mousePosHUD) && FlxG.mouse.justPressed) && muteCall.visible)
        {
            callSound.stop();
            muteCall.visible = false;
        }   
    }

    if (shadowBonnieAppear)
        shadowBonnieTimer += elapsed;
    else 
        shadowBonnieTimer = 0;

    if (shadowBonnieTimer >= 4)
    {
        lime.system.System.exit(1);
    }

    // i genuinely don't know if it works because i can't do it sob
    var skipNightStep:Int = 0;

    if (FlxG.keys.justPressed.C && skipNightStep == 0)
    {
        skipNightStep = 1;
    }
    else if (FlxG.keys.justPressed.D && skipNightStep == 1)
    {
        skipNightStep = 2;
    }
    else if (FlxG.keys.justPressed.PLUS && skipNightStep == 2)
    {
        skipNightStep = 3;
    }

    if (freddyNoseHitbox.overlapsPoint(mousePos) && FlxG.mouse.justPressed)
    {
        if (skipNightStep == 3)
        {
            persistentUpdate = false;
            persistentDraw = true;

            FlxG.sound.music.stop();

            FlxG.sound.list.forEach(function(sound:FlxSound)
            {
                sound.stop();
            });

            hallwayAmbience.stop();

            openSubState(new ModSubState('winState', {night: nightNumber, sixthNight: sixthNight}));
        }
        else
        {
            honk?.stop();
            honk.play();
        }
    }

    if (bbInOffice && heldVent != null)
    {
        heldVent.turnOff();
        heldVent = null;
    }

    var ventInputAttempted:Bool = false;

    if (FlxG.mouse.justPressed)
    {
        if (maskOn) return;
        if (monitor.isOpen) return;

        if (leftVent.isMouseOver(camWorld))
        {
            ventInputAttempted = true;

            if (!bbInOffice)
            {
                heldVent = leftVent;
                leftVent.turnOn();
            }
        }
        else if (rightVent.isMouseOver(camWorld))
        {
            ventInputAttempted = true;

            if (!bbInOffice)
            {
                heldVent = rightVent;
                rightVent.turnOn();
            }
        }
    }

    if (FlxG.mouse.justReleased)
    {
        if (heldVent != null)
        {
            heldVent.turnOff();
            heldVent = null;
        }
    }

    if (heldVent != null)
    {        
        if (heldVent == leftVent)
            currentOfficeView = 'leftVent';

        else if (heldVent == rightVent)
            currentOfficeView = 'rightVent';
    }
    else if (hallwayLight)
    {
        if (shadowBonnieAppear)
        {
            FlxTween.tween(shadowBonnie, {alpha: 0}, 1.13, {
                onComplete: function()
                {
                    shadowBonnieAppear = false;
                    shadowBonnie.visible = false;
                }
            });
        }

        animManager.stunHallwayAnimatronics();
        currentOfficeView = 'hallway';
    }
    else
    {
        currentOfficeView = 'normal';
    }

    if (hallwayLight)
    {
        animManager.flashWitheredFoxy(nightNumber, elapsed);
    }

    if (flashlight.battery > 0)
    {
        errorPlayed = false;

        if (lightActive)
        {
            if (!lightSound.playing)
                lightSound.play(true);
        }
        else
        {
            if (lightSound.playing)
                lightSound.stop();
        }
    }
    else
    {
        if (lightSound.playing)
            lightSound.stop();

        if (flashlightInputActive || (ventInputAttempted && bbInOffice))
        {
            if (!errorPlayed)
            {
                errorSound.play();
                errorPlayed = true;
            }
        }
        else
        {
            errorPlayed = false;
        }
    }
    

    if (office.hallway.hallwayBlocked && hallwayLight)
    {
        if (!blockedSound.playing)
            blockedSound.play(true);
        else 
            blockedSound.volume = 1;
    }
    else
    {
        if (blockedSound.playing)
            blockedSound.volume = 0;
    }

    if (flash != lastFlashState)
    {
        lastFlashState = flash;
        cameraSystem.setState(flash ? 'flash' : 'static');

        for (anim in animManager.animatronics)
        {
            if (anim.name == 'chica' || anim.name == 'bonnie' || anim.name == 'mangle' || anim.name == 'freddy')
            {
                if (anim.camera != 'cam09' && anim.camera == cameraSystem.lastViewedCamera)
                {
                    anim.stun(400 / 60);
                }
            }
        }
    }

    office.setView(currentOfficeView, animManager);

    if (paperpalAI > 0)
    {
        if (cameraSystem.paperpalStunTimer > 0)
            return;

        paperpalMoveTimer += elapsed;

        if (paperpalMoveTimer >= paperpalMoveInterval)
        {
            paperpalMoveTimer -= paperpalMoveInterval;

            var roll:Int = FlxG.random.int(1, 20);

            if (roll <= paperpalAI && monitor.isOpen && cameraSystem.currentCamera != 'cam04')
            {
                cameraSystem.paperpalMoved = true;
            }
        }
    }
}
