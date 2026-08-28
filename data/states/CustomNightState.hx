import flixel.text.FlxTextBorderStyle;
import SaveData;

class AnimatronicIcon
{
    public var sprites:Array<FunkinSprite> = [];

    public var icon:FunkinSprite;
    public var text:FunkinSprite;
    public var aiText:Array<FunkinSprite> = [];

    var aiYOffset:Float;

    var leftArrow:FunkinSprite;
    var rightArrow:FunkinSprite;

    public var aiLevel:Int;

    var holdTimer:Float = 0;
    var holdDelay:Float = 0.4;
    var holdInterval:Float = 0.08;

    public function new(name:String, ai:Int, x:Float, y:Float, aiYOffset:Float = 5)
    {
        this.aiYOffset = aiYOffset;
        aiLevel = ai;

        icon = new FunkinSprite(x, y);
        icon.antialiasing = true;
        icon.loadGraphic(Paths.image('customNight/icons/' + name));

        text = new FunkinSprite(x, y + 140);
        text.loadGraphic(Paths.image('customNight/icons/names/' + name));

        text.x = icon.x + (icon.width - text.width) / 2;

        leftArrow = new FunkinSprite(x, y, Paths.image('customNight/left'));
        rightArrow = new FunkinSprite(x, y, Paths.image('customNight/right'));

        leftArrow.x = icon.x - 10;
        rightArrow.x = icon.x + 100;

        sprites.push(icon);
        sprites.push(text);
        sprites.push(leftArrow);
        sprites.push(rightArrow);

        setAI(ai, aiYOffset);
    }

    function setAI(ai:Int, aiYOffset:Float)
    {
        var digits = Std.string(ai);

        var digitSpacing:Float = 25;
        var totalWidth:Float = digits.length * digitSpacing;

        var startX:Float = icon.x + (icon.width - totalWidth) / 2;
        var digitY:Float = text.y + aiYOffset;

        leftArrow.y = digitY-2;

        rightArrow.y = digitY-2;

        for (i in 0...digits.length)
        {
            var digit = new FunkinSprite(startX + (i * digitSpacing) + 10, digitY);
            digit.frames = Paths.getSparrowAtlas('customNight/numbers');

            for (n in 0...10)
                digit.animation.addByPrefix(Std.string(n), Std.string(n), 1, false);

            digit.animation.play(digits.charAt(i), true);

            aiText.push(digit);
            sprites.push(digit);
        }

        icon.alpha = (aiLevel == 0) ? 0.1 : 1.0;
    }

    public function changeAI(amount:Int)
    {
        aiLevel += amount;

        if (aiLevel > 20)
            aiLevel = 0;
        else if (aiLevel < 0)
            aiLevel = 20;

        var oldDigits = aiText.copy();

        aiText = [];
        setAI(aiLevel, aiYOffset);

        return oldDigits;
    }

    public function setAILevel(value:Int)
    {
        aiLevel = value;

        var oldDigits = aiText.copy();

        aiText = [];
        setAI(aiLevel, aiYOffset);

        return oldDigits;
    }

    public function update(elapsed:Float)
    {
        var mousePos = FlxG.mouse.getWorldPosition();
        var oldDigits:Array<FunkinSprite> = [];

        if (!FlxG.mouse.pressed)
        {
            holdTimer = 0;
            return oldDigits;
        }

        var direction:Int = 0;

        if (leftArrow.overlapsPoint(mousePos))
            direction = -1;
        else if (rightArrow.overlapsPoint(mousePos))
            direction = 1;

        if (direction == 0)
        {
            holdTimer = 0;
            return oldDigits;
        }

        if (FlxG.mouse.justPressed)
        {
            oldDigits = changeAI(direction);
            FlxG.sound.play(Paths.sound('coin'), 1, false);

            holdTimer = -holdDelay;
            return oldDigits;
        }

        holdTimer += elapsed;

        if (holdTimer >= holdInterval)
        {
            holdTimer = 0;

            oldDigits = changeAI(direction);
            FlxG.sound.play(Paths.sound('coin'), 1, false);
        }

        return oldDigits;
    }
}

// presets

var currentPreset:Int = 0;
var four20:Array<Int> = [20, 20, 20, 20, 0, 0, 0, 0, 0, 0];
var newAndShiny:Array<Int> = [0, 0, 0, 0, 10, 10, 10, 10, 10, 0];
var doubleTrouble:Array<Int> = [0, 20, 0, 5, 0, 0, 20, 0, 0, 0];
var nightOfMisfits:Array<Int> = [0, 0, 0, 0, 20, 0, 0, 0, 20, 10];
var foxyFoxy:Array<Int> = [0, 0, 0, 20, 0, 0, 0, 0, 20, 0];
var ladiesNight:Array<Int> = [0, 0, 20, 0, 0, 0, 0, 20, 20, 0];
var freddysCircus:Array<Int> = [20, 0, 0, 10, 10, 20, 0, 0, 0, 10];
var cupcakeChallenge:Array<Int> = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
var fazbearFever:Array<Int> = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
var goldenFreddy:Array<Int> = [20, 20, 20, 20, 20, 20, 20, 20, 20, 20];
var original:Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

var presets:Array<Array<Int>> = [
    four20,
    newAndShiny,
    doubleTrouble,
    nightOfMisfits,
    foxyFoxy,
    ladiesNight,
    freddysCircus,
    cupcakeChallenge,
    fazbearFever,
    goldenFreddy
];

var presetNames:Array<String> = [
    "20/20/20/20",
    "New & Shiny",
    "Double Trouble",
    "Night of Misfits",
    "Foxy Foxy",
    "Ladies Night",
    "Freddy's Circus",
    "Cupcake Challenge",
    "Fazbear Fever",
    "Golden Freddy"
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

var difficultiesSprite:FunkinSprite;
var customizeNightSprite:FunkinSprite;
var presetText:FunkinText;

var presetLeftArrow:FunkinSprite;
var presetRightArrow:FunkinSprite;
var readySprite:FunkinSprite;

var leftStar:FunkinSprite;
var rightStar:FunkinSprite;

var animIcons:Array<AnimatronicIcon> = [
    // top row
    new AnimatronicIcon('WFreddy', 20, 68, 78, 40),
    new AnimatronicIcon('WBonnie', 20, 252, 78, 40),
    new AnimatronicIcon('WChica', 20, 436, 78, 40),
    new AnimatronicIcon('WFoxy', 20, 622, 78, 40),
    new AnimatronicIcon('balloonboy', 20, 814, 80, 40),

    // bottom row
    new AnimatronicIcon('freddy', 20, 64, 342, 80),
    new AnimatronicIcon('bonnie', 20, 250, 340, 80),
    new AnimatronicIcon('chica', 20, 432, 342, 80),
    new AnimatronicIcon('mangle', 20, 616, 340, 80),
    new AnimatronicIcon('goldenfreddy', 20, 806, 340, 80)
];

function updateStarVisibility()
{
    var done = SaveData.getBool(presetDoneKeys[currentPreset], false);

    leftStar.visible = done;
    rightStar.visible = done;
}

function create()
{
    SaveData.load();

    difficultiesSprite = new FunkinSprite(93, 625, Paths.image('customNight/difficulty'));
    add(difficultiesSprite);

    customizeNightSprite = new FunkinSprite(68, 18, Paths.image('customNight/customizeNight'));
    add(customizeNightSprite);

    presetText = new FunkinText(-69, 690, FlxG.width, 'Custom Mode');
    presetText.setFormat(Paths.font('times.ttf'), 52, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE);
    presetText.antialiasing = true;
    presetText.borderSize = 0.3;
    presetText.borderColor = FlxColor.WHITE;
    add(presetText);

    presetLeftArrow = new FunkinSprite(159, 700, Paths.image('customNight/presetLeft'));
    add(presetLeftArrow);

    presetRightArrow = new FunkinSprite(696, 700, Paths.image('customNight/presetRight'));
    add(presetRightArrow);

    readySprite = new FunkinSprite(823, 696, Paths.image('customNight/ready'));
    add(readySprite);

    for (animIcon in animIcons)
    {
        for (sprite in animIcon.sprites)
            add(sprite);
    }

    applyPreset(presets[currentPreset]);
    presetText.text = presetNames[currentPreset];

    leftStar = new FunkinSprite(90, 697).loadGraphic(Paths.image('title/star'));
    add(leftStar);

    rightStar = new FunkinSprite(741, 697).loadGraphic(Paths.image('title/star'));
    add(rightStar);

    updateStarVisibility();
}

var customNightAI:Array<Int> = [];

var presetModified:Bool = false;

function isCurrentPresetModified():Bool
{
    var preset = presets[currentPreset];

    for (i in 0...animIcons.length)
    {
        if (animIcons[i].aiLevel != preset[i])
            return true;
    }

    return false;
}

function updatePresetTextAlpha()
{
    if (presetModified)
        return;

    if (isCurrentPresetModified())
    {
        presetModified = true;
        presetText.alpha = 0.1;
    }
}

function update(elapsed:Float)
{
    for (animIcon in animIcons)
    {
        var oldDigits = animIcon.update(elapsed);

        for (sprite in oldDigits)
            remove(sprite);

        for (sprite in animIcon.aiText)
        {
            if (!members.contains(sprite))
                add(sprite);
        }
    }
    
    updatePresetTextAlpha();

    if (FlxG.mouse.justPressed)
    {
        var mousePos = FlxG.mouse.getWorldPosition();

        if (presetLeftArrow.overlapsPoint(mousePos))
        {
            currentPreset--;

            if (currentPreset < 0)
                currentPreset = presets.length - 1;

            applyPreset(presets[currentPreset]);
            presetText.text = presetNames[currentPreset];

            presetModified = false;
            presetText.alpha = 1;
            updateStarVisibility();

            FlxG.sound.play(Paths.sound('coin'), 1, false);
        }

        if (presetRightArrow.overlapsPoint(mousePos))
        {
            currentPreset++;

            if (currentPreset >= presets.length)
                currentPreset = 0;

            applyPreset(presets[currentPreset]);
            presetText.text = presetNames[currentPreset];

            presetModified = false;
            presetText.alpha = 1;
            updateStarVisibility();

            FlxG.sound.play(Paths.sound('coin'), 1, false);
        }
    }

    if (FlxG.mouse.justPressed)
    {
        var mousePos = FlxG.mouse.getWorldPosition();

        if (readySprite.overlapsPoint(mousePos))
        {
            var customNightAI:Array<Int> = [];

            for (animIcon in animIcons)
                customNightAI.push(animIcon.aiLevel);

            FlxG.sound.music.stop();
            FlxG.switchState(new ModState("NightState", {night: 7, ai: customNightAI, preset: currentPreset, presetName: presetNames[currentPreset]}));
        }   
    }
}

function applyPreset(preset:Array<Int>)
{
    for (i in 0...animIcons.length)
    {
        var oldDigits = animIcons[i].setAILevel(preset[i]);

        for (sprite in oldDigits)
            remove(sprite);
    }

    for (animIcon in animIcons)
    {
        for (sprite in animIcon.aiText)
        {
            if (!members.contains(sprite))
                add(sprite);
        }
    }
}