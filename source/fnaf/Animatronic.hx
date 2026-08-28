class Animatronic
{
    public var name:String;
    public var camera:String;
    public var order:Int;
    public var aiLevel:Int;
    public var aiCap:Int = 15;
    public var path:Array<String>;
    public var pathIndex:Int = 0;
    public var attackReturnCam:String;

    public var office:String = 'office';
    public var inOffice:Bool = false;

    public var previousCamera:String;
    public var pendingOfficeAttack:Bool = false;
    public var canAttackOffice:Bool = false;

    public var camMaxTimer:Float = 0;

    public var cameraAttackTimer:Float = 0;
    public var cameraAttackTime:Float = 10;
    public var cameraAttackReady:Bool = false;

    public var stunned:Bool = false;
    public var stunTimer:Float = 0;

    public var cameraStunned:Bool = false;

    public var officeAttackCamera:String;

    // VENT ATTACK
    public var ventAttackTimer:Float = 0;
    public var ventAttackReady:Bool = false;
    public var ventAttackActive:Bool = false;

    public var ventKillTimer:Float = 0;
    public var ventCanKill:Bool = false;

    public var ventMaskTimer:Float = 0;
    public var maskWasOnInVent:Bool = false;
    
    public var canUseVent:Bool = false;
    public var causesBlackout:Bool = false;

    public var freddyMaskTimer:Float = 0;

    public var pendingMangleVentMove:Bool = false;

    public var pendingCameraFlipMove:Bool = false;
    public var cameraFlipMoveFrom:String = null;
    public var cameraFlipMoveTo:String = null;

    public var blockedByHallwayFlash:Bool = false;

    public var officeVisible:Bool = false;

    // mangle vars
    public var mangleInOffice:Bool = false;
    var manglePath:String = null;
    var manglePathDIfferent:Bool = false; // idk what to call this ok

    // bonnie
    public var bonnieVentStun:Bool = false;
    
    var bbInOffice:Bool = false;

    public function new(name:String, camera:String, order:Int, aiLevel:Int, path:Array<String>, ?returnCam:String, ?canUseVent:Bool = false, ?causesBlackout:Bool = false, ?officeAttackCamera:String = null, ?cameraFlipMoveFrom:String = null, ?cameraFlipMoveTo:String = null)
    {
        this.name = name;
        this.camera = camera;
        this.order = order;
        this.aiLevel = aiLevel;
        this.path = path;
        this.attackReturnCam = returnCam;
        this.canUseVent = canUseVent;
        this.causesBlackout = causesBlackout;
        this.officeAttackCamera = officeAttackCamera;
        this.cameraFlipMoveFrom = cameraFlipMoveFrom;
        this.cameraFlipMoveTo = cameraFlipMoveTo;
    }

    public function isInCamera(cam:String):Bool
    {
        return camera == cam;
    }

    public function cameraAttackReady():Bool
    {
        return pendingOfficeAttack && cameraAttackTimer >= cameraAttackTime;
    }

    public function getCappedAI():Int
    {
        return Std.int(Math.min(aiLevel, aiCap));
    }

    public function tryMove():Bool
    {
        return FlxG.random.int(1, 20) <= getCappedAI();
    }

    public function moveTo(cam:String)
    {
        camera = cam;

        var index = path.indexOf(cam);

        if (index != -1)
            pathIndex = index;
    }

    public function move()
    {
        if (stunned)
            return;

        if (name == 'WFreddy' && camera == 'cam03')
        {
            if (FlxG.random.bool(50))
            {
                moveTo('hallway2');
                canAttackOffice = true;
            }
            else
            {
                moveTo('cam07');
            }

            return;
        }

        if (name == 'mangle')
        {
            if (camera == 'cam02')
            {
                if (!manglePathDIfferent)
                {
                    manglePathDIfferent = true;

                    if (FlxG.random.bool(50))
                    {
                        manglePath = 'cam01';
                    }
                    else
                    {
                        manglePath = 'cam06';
                    }
                }

                moveTo(manglePath);

                return;
            }

            if (camera == 'cam01')
            {
                moveTo('cam02');

                manglePathDIfferent = false;
                manglePath = null;

                return;
            }
        }

        if (pathIndex < path.length - 1)
        {
            pathIndex++;
            camera = path[pathIndex];

            if (causesBlackout && officeAttackCamera != null && camera == officeAttackCamera)
            {
                canAttackOffice = true;
            }
        }
    }

    public function stun(duration:Float)
    {
        stunned = true;
        stunTimer = duration;
    }

    public function isAtVent():Bool
    {
        return camera == 'leftvent' || camera == 'rightvent';
    }

    public function isAtLeftVent():Bool
    {
        return camera == 'leftvent';
    }

    public function isAtRightVent():Bool
    {
        return camera == 'rightvent';
    }

    public function canMove():Bool
    {
        if (inOffice)
            return false;

        if (name == 'WFreddy' && camera == 'cam03')
            return true;

        return pathIndex < path.length - 1;
    }

    public function canEnterOffice():Bool
    {
        return causesBlackout ? camera == officeAttackCamera : camera == 'hallway2';
    }

    public function enterOffice()
    {
        previousCamera = camera;

        inOffice = true;
        camera = office;

        camMaxTimer = 0;
    }

    public function leaveOffice()
    {
        inOffice = false;
        moveTo(attackReturnCam);
        officeVisible = false;
    }

    public function startVentAttackTimer()
    {
        if (!isAtVent())
            return;

        ventAttackTimer = 0;
        ventAttackReady = false;
        ventMaskTimer = 0;
    }

    public function updateVentAttack(elapsed:Float, maskOn:Bool, monitorOpen:Bool)
    {
        if (name != 'bonnie')
        {
            if (maskOn)
            {
                var oldSecond:Int = Math.floor(ventMaskTimer);
                ventMaskTimer += elapsed;
                var newSecond:Int = Math.floor(ventMaskTimer);

                if (newSecond > oldSecond && newSecond < 5)
                {
                    var roll:Int = FlxG.random.int(1, 10);

                    if (roll == 1)
                    {
                        leaveVent();
                        return;
                    }
                }

                if (ventMaskTimer >= 5)
                {
                    leaveVent();
                    return;
                }
            }
            else
            {
                ventMaskTimer = 0;
            }
        }
        
        if (name == 'balloonboy' || name == 'mangle')
            return;

        if (!isAtVent())
        {
            ventAttackTimer = 0;
            ventMaskTimer = 0;
            ventKillTimer = 0;

            ventAttackReady = false;
            ventCanKill = false;
            ventAttackActive = false;

            return;
        }

        if (!ventAttackReady)
        {
            ventAttackTimer += elapsed;

            if (ventAttackTimer >= 5)
            {
                ventAttackTimer = 5;
                ventAttackReady = true;
                ventAttackActive = true;
            }
        }

        if (ventAttackReady)
        {
            if (!monitorOpen)
            {
                ventCanKill = true;
            }
        }
    }

    public function leaveVent()
    {
        ventAttackTimer = 0;
        ventAttackReady = false;
        bonnieVentStun = false;

        if (attackReturnCam != null && attackReturnCam != '')
        {
            moveTo(attackReturnCam);
        }
    }

    public function update(elapsed:Float, monitorOpen:Bool)
    {
        if (stunTimer > 0)
        {
            stunTimer -= elapsed;

            if (stunTimer <= 0)
            {
                stunTimer = 0;
                stunned = false;

                if (bonnieVentStun && name == 'bonnie' && isAtVent())
                {
                    bonnieVentStun = false;
                    ventAttackReady = true;
                }
            }
        }

        if (name != 'mangle' && name != 'balloonboy' && pendingOfficeAttack && monitorOpen)
            cameraAttackTimer += elapsed;
        else
            cameraAttackTimer = 0;
    }
}