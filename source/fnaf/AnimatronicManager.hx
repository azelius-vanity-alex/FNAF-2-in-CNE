// caution: the movements here are VERY hardcoded

import fnaf.Animatronic;
import fnaf.WindUpBox;

class AnimatronicManager
{
    public var animatronics:Array<Animatronic>;

    public var nightNumber:Int = 1;
    var moveTimer:Float = 0;
    var movementInterval:Float = 5.0;

    var cameraSystem:CameraSystem;

    var cameraWasFlipped:Bool = false;

    var hour:Int;

    public var blackoutActive:Bool = false;

    var officeAttackQueue:Array<Animatronic> = [];
    var currentOfficeAttacker:Animatronic = null;

    var previousMonitorOpen:Bool = false;

    var windUpBox:WindUpBox;

    // mangle
    var mangleKillTimer:Float = 0;
    var mangleCanKill:Bool = false;

    // withered foxy
    var witheredFoxyD:Float = 0;
    var witheredFoxyDOffset:Float = 0; // clickteam quirk lmfao
    var witheredFoxyDTimer:Float = 0;
    var witheredFoxyFlashCounter:Float = 0;
    var witheredFoxyFlashTimer:Float = 0;

    var witheredFoxyAttackTimer:Float = 0;
    var foxyCanKill:Bool = false;
    var foxyTenSecondKill:Bool = false;

    // toy bonnie
    var toyBonnieBlackoutTimer:Float = 0;
    var toyBonnieVentTimer:Float = 0;
    var toyBonnieBlackoutActive:Bool = false;
    var toyBonnieBlackoutUsed:Bool = false;

    // puppet
    var puppetStageTimer:Float = 0;
    var puppetEmptyTimer:Float = 0;
    var puppetStage:Int = 0;
    var puppetHasLeftBox:Bool = false;
    var puppetMoveTimer:Float = 0;
    var puppetPath:Array<String> = [];
    var puppetPathIndex:Int = 0;
    var puppetOfficeTimer:Float = 0;
    var puppetCanKill:Bool = false;

    // golden freddy
    public var goldenFreddyHallway:Bool = false;
    public var goldenFreddyOffice:Bool = false;

    var goldenFreddyHallwayTimer:Float = 0;
    var goldenFreddyExposure:Int = 0;
    var goldenFreddyExposureTimer:Float = 0;

    var goldenFreddyRollTimer:Float = 0;
    var goldenFreddyPendingOffice:Bool = false;

    public var goldenFreddyCanKill:Bool = false;

    var ventSound:FlxSound;

    var firstMovementDone:Bool = false;

    public function new()
    {
        animatronics = [];

        // name, starting camera, order, AI, path, return camera, can use vent, causes blackout, office attack camera
        animatronics.push(new Animatronic('freddy', 'cam09', 0, 0, ['cam09', 'cam10', 'hallway1', 'hallway2'], 'cam09', false, true, 'hallway2'));
        animatronics.push(new Animatronic('bonnie', 'cam09', 1, 0, ['cam09', 'cam03', 'cam04', 'cam02', 'cam06', 'rightvent'], 'cam03'));
        animatronics.push(new Animatronic('chica', 'cam09', 2, 0, ['cam09', 'cam07', 'cam04', 'hallway1', 'cam01', 'cam05', 'leftvent'], 'cam07'));
        animatronics.push(new Animatronic('puppet', 'cam11', 3, 0, ['cam09']));
        animatronics.push(new Animatronic('mangle', 'cam12', 4, 0, ['cam12', 'cam11', 'cam10', 'cam07', 'hallway1', 'cam02', 'cam06', 'rightvent'], 'cam07', false, false, null, 'cam06', 'rightvent'));
        animatronics.push(new Animatronic('balloonboy', 'cam10', 5, 0, ['cam10', 'cam07', 'cam03', 'cam01', 'cam05'], 'cam10', false, false,  null, 'cam05', 'leftvent'));
        animatronics.push(new Animatronic('WFreddy', 'cam08', 6, 0, ['cam08', 'cam07', 'hallway2', 'cam03'], 'cam08', false, true));
        animatronics.push(new Animatronic('WBonnie', 'cam08', 7, 0, ['cam08', 'cam07', 'hallway1', 'cam01', 'cam05'], 'cam07', true, true, 'cam05'));
        animatronics.push(new Animatronic('WChica', 'cam08', 8, 0, ['cam08', 'cam04', 'cam02', 'cam06'], 'cam04', true, true, 'cam06'));
        animatronics.push(new Animatronic('WFoxy', 'cam08', 9, 0, ['cam08', 'hallway1'], 'cam08', false, false));
        animatronics.push(new Animatronic('goldenfreddy', 'office', 0, 0, []));

        // he was gonna go split path but i wasn't bothered to code it in ahah
        puppetPath = [
            'cam11',
            'cam10',
            'cam07',
            'cam04',
            'cam02',
            'office'
        ];

        for (anim in animatronics)
        {
            if (anim.name == 'WFoxy')
                anim.aiCap = 17;
            else if (anim.name == 'goldenfreddy')
                anim.aiCap = 10;
            else
                anim.aiCap = 15;
        }

        ventSound = FlxG.sound.load(Paths.sound('vent walk'), 1, false);
    }

    public function setBlackout(state:Bool)
    {
        if (state && !blackoutActive)
        {
            witheredFoxyDOffset += 1.0 / 60.0;
        }
        blackoutActive = state;
        if (!state)
        {
            toyBonnieBlackoutUsed = false;
            toyBonnieBlackoutTimer = 0;
            toyBonnieVentTimer = 0;
        }
    }

    public function setWindUpBox(box:WindUpBox)
    {
        windUpBox = box;
    }

    public function setCameraSystem(system:CameraSystem)
    {
        cameraSystem = system;
    }
    
    public function getCameraEntities(camera:String):Array<Animatronic>
    {
        var entities:Array<Animatronic> = [];

        for (anim in animatronics)
        {
            if (anim.isInCamera(camera))
                entities.push(anim);
        }

        entities.sort(function(a:Animatronic, b:Animatronic)
        {
            return a.order - b.order;
        });

        var names:Array<String> = [];

        for (anim in entities)
            names.push(anim.name);

        return names;
    }

    public function isInOffice(name:String):Bool
    {
        for (anim in animatronics)
        {
            if (anim.name == name)
                return anim.inOffice;
        }

        return false;
    }

    function anyAnimatronicInOffice():Bool
    {
        for (anim in animatronics)
        {
            if (anim.inOffice)
                return true;
        }

        return false;
    }

    function getGoldenFreddy():Animatronic
    {
        for (anim in animatronics)
        {
            if (anim.name == 'goldenfreddy')
                return anim;
        }

        return null;
    }

    function setGoldenFreddyAI()
    {
        var goldenFreddy = getGoldenFreddy();

        if (goldenFreddy == null)
            return;

        switch (nightNumber)
        {
            case 2, 3:
                goldenFreddy.aiLevel = FlxG.random.int(1, 1000) == 1 ? 1 : 0;
            case 4, 5:
                goldenFreddy.aiLevel = FlxG.random.int(1, 100) == 1 ? 1 : 0;
        }
    }

    public function rollGoldenFreddy()
    {
        var goldenFreddy = getGoldenFreddy();

        if (goldenFreddy == null)
            return;

        var roll:Int = FlxG.random.int(1, 20);

        if (roll <= goldenFreddy.getCappedAI())
        {
            goldenFreddyPendingOffice = true;
        }
    }

    function updateGoldenFreddy(elapsed:Float, flash:Bool, maskOn:Bool)
    {
        if (cameraSystem == null)
            return;

        var goldenFreddy = getGoldenFreddy();

        if (goldenFreddy == null)
            return;

        if (goldenFreddyHallway)
        {
            if (maskOn)
            {
                clearGoldenFreddyHallway();
            }
            else if (flash)
            {
                goldenFreddyExposure += elapsed * 60;

                if (goldenFreddyExposure >= 100)
                {
                    goldenFreddyCanKill = true;
                }
            }
        }

        if (!goldenFreddyHallway && !goldenFreddyOffice)
        {
            if (goldenFreddy.getCappedAI() > 0 && !flash)
            {
                goldenFreddyHallwayTimer += elapsed;

                if (goldenFreddyHallwayTimer >= 1)
                {
                    goldenFreddyHallwayTimer -= 1;

                    var hallwayRoll:Int = FlxG.random.int(0, 9);

                    if (hallwayRoll == 1 && !isHallwayOccupied())
                    {
                        goldenFreddyHallway = true;
                        goldenFreddyExposure = 0;
                    }
                }
            }
            else
            {
                goldenFreddyHallwayTimer = 0;
            }
        }

        if (cameraSystem.monitorOpen && !goldenFreddyOffice)
        {
            goldenFreddyRollTimer += elapsed;

            if (goldenFreddyRollTimer >= 5)
            {
                goldenFreddyRollTimer -= 5;

                var roll:Int = FlxG.random.int(1, 20);

                if (goldenFreddy.getCappedAI() > roll)
                {
                    goldenFreddyPendingOffice = true;
                }
            }
        }
        else if (!cameraSystem.monitorOpen)
        {
            goldenFreddyRollTimer = 0;
        }

        if (previousMonitorOpen && !cameraSystem.monitorOpen)
        {
            if (goldenFreddyPendingOffice && !goldenFreddyOffice)
            {
                goldenFreddyPendingOffice = false;
                goldenFreddyOffice = true;
                goldenFreddyHallway = false;
                goldenFreddyExposure = 0;
                goldenFreddyCanKill = false;

                goldenFreddy.officeVisible = true;
                goldenFreddy.camera = 'office';
            }
        }

        if (goldenFreddyOffice && maskOn)
        {
            goldenFreddyOffice = false;
            goldenFreddyPendingOffice = false;

            goldenFreddy.officeVisible = false;
        }
    }

    function clearGoldenFreddyHallway()
    {
        goldenFreddyHallway = false;
        goldenFreddyExposure = 0;
        goldenFreddyCanKill = false;
    }

    function isHallwayOccupied():Bool
    {
        for (anim in animatronics)
        {
            if (anim.name == 'goldenfreddy')
                continue;

            if (anim.camera == 'hallway1' || anim.camera == 'hallway2')
                return true;
        }

        return false;
    }

    public function stunHallwayAnimatronics()
    {
        for (anim in animatronics)
        {
            if (anim.name != 'chica')
                continue;

            if (anim.camera == 'hallway1' || anim.camera == 'hallway2')
            {
                anim.stun(0.6667);
            }
        }
    }

    public function stunBonnieAtVent(nightNumber:Int)
    {
        for (anim in animatronics)
        {
            if (anim.name == 'bonnie' && anim.isAtVent())
            {
                var stunFrames:Int = 1000 - (nightNumber * 100);
                var stunSeconds:Float = stunFrames / 60;

                anim.bonnieVentStun = true;
                anim.ventAttackReady = false;

                anim.stun(stunSeconds);
                break;
            }
        }
    }

    public function cameraFlip():Animatronic
    {
        for (anim in animatronics)
        {
            if (anim.name == 'WFoxy')
                continue;

            if (anim.cameraAttackReady())
            {
                if (anim.cameraAttackTimer >= 10)
                {
                    return anim;
                }
            }
        }

        for (anim in animatronics)
        {
            if (anim.name == 'WFoxy')
                continue;

            if (anim.cameraAttackReady())
            {
                anim.cameraAttackTimer = 0;
                anim.pendingOfficeAttack = false;
                return anim;
            }
        }

        for (anim in animatronics)
        {
            if (anim.name == 'mangle' || anim.name == 'balloonboy')
                continue;

            if (anim.isAtVent() && anim.ventAttackReady)
            {
                anim.ventAttackReady = false;
                anim.ventAttackActive = false;

                return anim;
            }
        }

        for (anim in animatronics)
        {
            if (!anim.ventAttackReady)
                continue;

            if (anim.name == 'mangle' || anim.name == 'balloonboy')
                continue;

            anim.ventAttackReady = false;

            return anim;
        }

        if (currentOfficeAttacker == null && officeAttackQueue.length > 0)
        {
            currentOfficeAttacker = officeAttackQueue.shift();

            currentOfficeAttacker.enterOffice();
            currentOfficeAttacker.pendingOfficeAttack = false;
        }

        return null;
    }

    public function finishOfficeAttack()
    {
        if (currentOfficeAttacker != null)
        {
            currentOfficeAttacker = null;
        }
    }

    public function cancelOfficeAttack(anim:Animatronic)
    {
        anim.pendingOfficeAttack = false;
        anim.canAttackOffice = false;

        officeAttackQueue.remove(anim);

        if (currentOfficeAttacker == anim)
            currentOfficeAttacker = null;
    }

    public function updateVentTimers(elapsed:Float, maskOn:Bool, monitorOpen:Bool)
    {
        for (anim in animatronics)
        {
            if (!anim.isAtVent())
                continue;

            var oldCamera = anim.camera;

            anim.updateVentAttack(elapsed, maskOn, monitorOpen);

            if (anim.camera != oldCamera)
                playMovementSound(anim, oldCamera);
        }
    }

    var movementVolume:Map<String, Float> = [
        'cam08' => 0.2,
        'cam09' => 0.2,
        'cam10' => 0.6,
        'cam07' => 0.5,
        'cam04' => 0.6,
        'cam03' => 0.6,
        'cam01' => 0.7,
        'cam02' => 0.7,
        'cam05' => 0.9,
        'cam06' => 0.9,
        'leftvent' => 1,
        'hallway1' => 0.6,
        'hallway2' => 1.0
    ];

    function playMovementSound(anim:Animatronic, oldCamera:String)
    {
        var newCamera = anim.camera;

        if (oldCamera == newCamera)
            return;

        var volume:Float = movementVolume.exists(newCamera) ? movementVolume.get(newCamera) : 1.0;
        var enteringVent:Bool = newCamera == 'cam05' || newCamera == 'cam06' || newCamera == 'leftvent' || newCamera == 'rightvent';
        var leavingVent:Bool = oldCamera == 'leftvent' || oldCamera == 'rightvent';

        if (enteringVent || leavingVent)
        {
            if (newCamera == 'leftvent' || newCamera == 'cam05')
                ventSound.pan = -1;
            else if (newCamera == 'rightvent' || newCamera == 'cam06')
                ventSound.pan = 1;
            else if (oldCamera == 'leftvent')
                ventSound.pan = -1;
            else if (oldCamera == 'rightvent')
                ventSound.pan = 1;
            
            ventSound?.stop();
            ventSound?.play();
        }

        if (anim.name == 'balloonboy')
        {
            if (!leavingVent)
                FlxG.sound.play(Paths.soundRandom('echo', 1, 3), volume, false);

            FlxG.sound.play(Paths.soundRandom('walk', 1, 5), volume, false);
            return;
        }

        if (anim.name == 'mangle')
        {
            FlxG.sound.play(Paths.soundRandom('metalwalk', 1, 4), volume, false);
            return;
        }

        if (enteringVent || leavingVent)
            return;

        FlxG.sound.play(Paths.soundRandom('walk', 1, 5), volume, false);
    }

    public function flashWitheredFoxy(currentNight:Int):Animatronic
    {
        for (anim in animatronics)
        {
            if (anim.name != 'WFoxy' || anim.camera != 'hallway1')
                continue;

            if (foxyCanKill)
            {
                foxyCanKill = false;
                witheredFoxyAttackTimer = 0;
                return anim;
            }

            witheredFoxyD = 0;
            witheredFoxyFlashCounter++;

            anim.stun(50 / 60);
        }

        return null;
    }

    function updateToyBonnieBlackout(elapsed:Float, maskOn:Bool)
    {
        var toyBonnie:Animatronic = null;

        for (anim in animatronics)
        {
            if (anim.name == 'bonnie')
            {
                toyBonnie = anim;
                break;
            }
        }

        if (toyBonnie == null)
            return;

        if (toyBonnie.camera == 'rightvent' && maskOn && !toyBonnieBlackoutUsed)
        {
            toyBonnieBlackoutTimer += elapsed;

            if (toyBonnieBlackoutTimer >= 0.5)
            {
                toyBonnieBlackoutTimer -= 0.5;

                if (FlxG.random.bool(50))
                {
                    toyBonnieBlackoutActive = true;
                    toyBonnieBlackoutUsed = true;
                }
            }
        }
        else if (toyBonnie.camera != 'rightvent' || !maskOn)
        {
            toyBonnieBlackoutTimer = 0;
        }

        if (toyBonnie.camera == 'rightvent' && maskOn && blackoutActive)
        {
            toyBonnieVentTimer += elapsed;

            if (toyBonnieVentTimer >= 1)
            {
                toyBonnieVentTimer -= 1;

                if (FlxG.random.int(1, 3) == 1)
                {
                    toyBonnie.leaveVent();
                    toyBonnieVentTimer = 0;
                }
            }
        }
        else
        {
            toyBonnieVentTimer = 0;
        }
    }

    public function toyBonnieBlackout():Bool
    {
        if (!toyBonnieBlackoutActive)
            return false;

        toyBonnieBlackoutActive = false;
        return true;
    }

    function updatePuppet(elapsed:Float)
    {
        var puppet:Animatronic = null;

        for (anim in animatronics)
        {
            if (anim.name == 'puppet')
            {
                puppet = anim;
                break;
            }
        }

        if (puppet == null)
            return;

        if (!windUpBox.isEmpty())
        {
            puppetEmptyTimer = 0;
            puppetStageTimer = 0;
            return;
        }

        puppetEmptyTimer += elapsed;

        if (puppetEmptyTimer < 5)
            return;

        if (puppetStage >= 4)
            return;

        puppetStageTimer += elapsed;

        if (puppetStageTimer < 1)
            return;

        puppetStageTimer -= 1;
        puppetStage++;

        if (cameraSystem != null && cameraSystem.currentCamera == 'cam11')
            cameraSystem.playPuppetStageTransition();

        if (puppetStage == 4)
        {
            puppetHasLeftBox = true;

            if (cameraSystem != null)
            {
                cameraSystem.stopMusicBox();
                cameraSystem.playPuppetStageTransition();
            }

            FlxG.sound.play(Paths.sound('jackinthebox'), 1, true);

            puppet.moveTo('cam09');
        }
    }

    function updatePuppetBuildingPath(elapsed:Float)
    {
        if (!puppetHasLeftBox)
            return;

        var puppet:Animatronic = null;

        for (anim in animatronics)
        {
            if (anim.name == 'puppet')
            {
                puppet = anim;
                break;
            }
        }

        if (puppet == null)
            return;

        if (puppetPathIndex >= puppetPath.length - 1)
            return;

        puppetMoveTimer += elapsed;

        if (puppetMoveTimer < 1)
            return;

        puppetMoveTimer -= 1;

        var roll = FlxG.random.int(1, 20);

        if (roll > puppet.getCappedAI() + 1)
            return;

        puppetPathIndex++;

        var oldCamera = puppet.camera;
        var newCamera = puppetPath[puppetPathIndex];

        puppet.moveTo(newCamera);

        if (newCamera == 'office')
        {
            puppet.inOffice = true;
            return;
        }
    }

    public function update(elapsed:Float, flash:Bool, maskOn:Bool, rightVentLightOn:Bool)
    {
        foxyTenSecondKill = false;
        var foxyInHallway:Bool = false;

        for (anim in animatronics)
        {
            if (anim.name == 'WFoxy' && anim.camera == 'hallway1')
                foxyInHallway = true;
        }

        if (foxyCanKill && foxyInHallway && !blackoutActive)
        {
            witheredFoxyAttackTimer += elapsed;

            if (witheredFoxyAttackTimer >= 10)
            {
                witheredFoxyAttackTimer = 0;
                foxyCanKill = false;
                foxyTenSecondKill = true;
            }
        }
        else if (!blackoutActive)
        {
            witheredFoxyAttackTimer = 0;
        }

        trace('Withered Foxy Attack Timer :' + witheredFoxyAttackTimer + ' Withered Foxy D Timer:' + witheredFoxyDTimer);

        for (anim in animatronics)
        {
            anim.update(elapsed, cameraSystem != null && cameraSystem.monitorOpen);
        }

        for (anim in animatronics)
        {
            if (anim.name == 'WFoxy' && anim.camera == 'hallway1' && witheredFoxyFlashCounter > 100 * nightNumber && !anim.stunned)
            {
                foxyCanKill = false;
                foxyTenSecondKill = false;
                witheredFoxyAttackTimer = 0;
                witheredFoxyD = 0;
                witheredFoxyFlashCounter = 0;

                anim.moveTo('cam08');

                var stunFrames:Int = FlxG.random.int(500, 999);
                anim.stun(stunFrames / 60);

                break;
            }
        }

        updateGoldenFreddy(elapsed, flash, maskOn);
        updatePuppet(elapsed);
        updatePuppetBuildingPath(elapsed);

        if (puppetHasLeftBox && isInOffice('puppet'))
        {
            puppetOfficeTimer += elapsed;

            if (puppetOfficeTimer >= 1)
            {
                puppetOfficeTimer -= 1;

                if (FlxG.random.int(1, 10) == 1)
                {
                    puppetCanKill = true;
                }
            }
        }
        else
        {
            puppetOfficeTimer = 0;
        }

        if (blackoutActive)
            return;
        
        updateToyBonnieBlackout(elapsed, maskOn);

        if (nightNumber == 1)
        {
            witheredFoxyD = 0;
            witheredFoxyDTimer = 0;
        }
        else
        {
            if (flash && foxyInHallway)
            {
                witheredFoxyD = 0;
            }

            witheredFoxyDTimer += elapsed;

            var dInterval:Float = Math.max(1.0 / 60.0, 1.0 - witheredFoxyDOffset);

            if (witheredFoxyDTimer >= dInterval)
            {   
                witheredFoxyDTimer -= dInterval;

                if (!flash)
                {
                    if (maskOn && !anyAnimatronicInOffice())
                        witheredFoxyD += 2;
                    else
                        witheredFoxyD += 1;
                }
            }
        }

       if (!foxyInHallway && flash)
        {
            witheredFoxyFlashTimer += elapsed;

            if (witheredFoxyFlashTimer >= 0.5)
            {
                witheredFoxyFlashTimer -= 0.5;

                if (witheredFoxyD > 0)
                {
                    witheredFoxyD -= 1;

                    if (witheredFoxyD < 0)
                        witheredFoxyD = 0;
                }
            }
        }
        else
        {
            witheredFoxyFlashTimer = 0;
        }

        if (nightNumber == 2 && hour == 12)
        {
            witheredFoxyD = 0;
            witheredFoxyDTimer = 0;
        }

        if (cameraSystem != null && cameraSystem.monitorOpen)
        {
            for (anim in animatronics)
            {
                if (anim.name == 'mangle' && anim.mangleInOffice)
                {
                    mangleKillTimer += elapsed;

                    if (mangleKillTimer >= 1)
                    {
                        mangleKillTimer -= 1;

                        if (FlxG.random.bool(5))
                        {
                            mangleCanKill = true;
                            mangleKillTimer = 0;
                        }
                    }
                }
            }
        }
        else
        {
            mangleKillTimer = 0;
        }

        if (cameraSystem != null && cameraSystem.monitorOpen && !previousMonitorOpen)
        {

            for (anim in animatronics)
            {
                var oldCamera = anim.camera;

                if (anim.name == 'mangle' && anim.camera == 'rightvent')
                {
                    anim.camera = 'office';
                    anim.mangleInOffice = true;
                    anim.officeVisible = true;
                    playMovementSound(anim, oldCamera);
                }

                if (anim.name == 'balloonboy' && anim.camera == 'leftvent')
                {
                    anim.camera = 'office';
                    anim.bbInOffice = true;
                    anim.officeVisible = true;
                    playMovementSound(anim, oldCamera);
                }

                if (!anim.pendingCameraFlipMove)
                    continue;

                anim.pendingCameraFlipMove = false;

                anim.moveTo(anim.cameraFlipMoveTo);

                if (anim.isAtVent() && anim.name != 'mangle' && anim.name != 'balloonboy')
                {
                    anim.startVentAttackTimer();
                    if (anim.name == 'bonnie' && anim.isAtVent())
                    {
                        var stunFrames:Int = 1000 - (nightNumber * 100);
                        var stunSeconds:Float = stunFrames / 60;

                        anim.bonnieVentStun = true;
                        anim.ventAttackReady = false;

                        anim.stun(stunSeconds);
                    }
                }

                if (cameraSystem.monitorOpen)
                {
                    var wasOnCurrentCamera = oldCamera == cameraSystem.currentCamera;
                    var movedToCurrentCamera = anim.camera == cameraSystem.currentCamera;

                    if (wasOnCurrentCamera || movedToCurrentCamera)
                        cameraSystem.triggerSignalInterrupted();
                }

                cameraSystem.updateMangleOverlay();
                cameraSystem.updateCameraAnimation();

                if (anim.camera != oldCamera)
                    playMovementSound(anim, oldCamera);
            }
        }

        if (cameraSystem != null)
            previousMonitorOpen = cameraSystem.monitorOpen;

        moveTimer += elapsed;

        if (moveTimer < movementInterval)
            return;

        moveTimer -= movementInterval;

        for (anim in animatronics)
        {
            if (anim.name == 'WFreddy' || anim.name == 'WBonnie' || anim.name == 'WChica')
            {
                if (cameraSystem.monitorOpen && cameraSystem.currentCamera == anim.camera)
                {   
                    anim.stunned = true;
                }
                else if (!cameraSystem.monitorOpen || cameraSystem.currentCamera != anim.camera)
                {
                    anim.stunned = false;
                }
            }

            if (anim.stunned)
                continue;

            if (anim.inOffice)
                continue;

            if (anim.pendingOfficeAttack)
                continue;

            if (anim.name == 'puppet' || anim.name == 'goldenfreddy')
                continue;

            var getsMovementOpportunity:Bool = false;

            if (anim.name == 'mangle' && flash)
            {
                getsMovementOpportunity = false;
            }  
            else if (anim.name == 'WFoxy')
            {  
                var foxyRoll:Float = 21 + FlxG.random.int(0, 4) - witheredFoxyD;
                getsMovementOpportunity = foxyRoll < anim.getCappedAI();
            }
            else
            {
                if (nightNumber == 1 && !firstMovementDone)
                {
                    if (anim.name == 'bonnie')
                    {
                        getsMovementOpportunity = anim.tryMove();

                        if (getsMovementOpportunity)
                            firstMovementDone = true;
                    }
                    else
                    {
                        getsMovementOpportunity = false;
                    }
                }
                else
                {
                    getsMovementOpportunity = anim.tryMove();
                }
            }

            if (!getsMovementOpportunity)
                continue;

            if (anim.name == 'balloonboy' && anim.camera == 'cam05')
            {
                anim.pendingCameraFlipMove = true;
                continue;
            }

            if (anim.name == 'WFoxy' && anim.camera == 'hallway1')
            {
                foxyCanKill = true;
                witheredFoxyAttackTimer = 0;
                continue;
            }
   
            if (anim.name == 'WFoxy' && anim.camera != 'hallway1')
            {
                if (flash)
                {
                    getsMovementOpportunity = false;
                    continue;
                }

                var oldCamera = anim.camera;

                anim.moveTo('hallway1');

                foxyCanKill = false;
                foxyTenSecondKill = false;
                witheredFoxyD = 0;
                witheredFoxyAttackTimer = 0;

                if (cameraSystem != null && cameraSystem.monitorOpen)
                {
                    var wasOnCurrentCamera = oldCamera == cameraSystem.currentCamera;
                    var movedToCurrentCamera = anim.camera == cameraSystem.currentCamera;

                    if (wasOnCurrentCamera || movedToCurrentCamera)
                        cameraSystem.triggerSignalInterrupted();
                }

                if (anim.camera != oldCamera)
                {
                    playMovementSound(anim, oldCamera);

                    if (cameraSystem != null)
                        cameraSystem.updateCameraAnimation();
                }

                continue;
            }

            if (anim.cameraFlipMoveFrom != null && anim.cameraFlipMoveTo != null && anim.camera == anim.cameraFlipMoveFrom)
            {
                anim.pendingCameraFlipMove = true;
                continue;
            }

            if (anim.name != 'balloonboy' && anim.name != 'mangle' && anim.canAttackOffice) 
            {
                anim.pendingOfficeAttack = true;
                anim.canAttackOffice = false;

                if (!officeAttackQueue.contains(anim))
                    officeAttackQueue.push(anim);
            }
            else if (anim.canMove())
            {
                var oldCamera = anim.camera;

                if (anim.name == 'balloonboy' && anim.camera == 'cam05')
                {
                    anim.pendingCameraFlipMove = true;
                    continue;
                }

                if (anim.name == 'bonnie' && anim.camera == 'cam06' && !cameraSystem.monitorOpen)
                {
                    if (!rightVentLightOn)
                        anim.moveTo('rightvent');
                }
                else
                {
                    anim.move();

                    if (anim.isAtVent() && oldCamera != 'leftvent' && oldCamera != 'rightvent')
                        anim.startVentAttackTimer();
                    
                    if (anim.name == 'bonnie' && anim.camera == 'cam06' && oldCamera != 'cam06')
                    {
                        var stunFrames:Int = 50;
                        var stunSeconds:Float = stunFrames / 60;

                        anim.stun(stunSeconds);
                    }
                }

                if (cameraSystem != null && cameraSystem.monitorOpen)
                {
                    var wasOnCurrentCamera = oldCamera == cameraSystem.currentCamera;
                    var movedToCurrentCamera = anim.camera == cameraSystem.currentCamera;

                    if (wasOnCurrentCamera || movedToCurrentCamera)
                        cameraSystem.triggerSignalInterrupted();
                }

                if (cameraSystem != null)
                    cameraSystem.updateMangleOverlay();

                if (anim.camera != oldCamera)
                {
                    playMovementSound(anim, oldCamera);

                    if (cameraSystem != null)
                        cameraSystem.updateCameraAnimation();
                }
            }
        }
    }
}