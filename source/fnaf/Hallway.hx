import fnaf.Animatronic;
import flixel.graphics.FlxGraphic;

class Hallway extends FunkinSprite
{
    var currentGraphic:String = '';
    var blockedFrames:Int = 0;
    var hallwayBlocked:Bool = false;

    var graphicPaths:Array<String> = [
        'office/office_hallway_static',
        'office/office_hallway_blocked',

        'office/office_hallway_freddy',
        'office/office_hallway_freddy_close',

        'office/office_hallway_chica',

        'office/office_hallway_WFreddy_close',

        'office/office_hallway_WBonnie',
        'office/office_hallway_WFoxy',

        'office/office_hallway_mangle',

        'office/office_hallway_WBonnie_WFoxy',
        'office/office_hallway_WFoxy_mangle',

        'office/office_hallway_goldenfreddy',
    ];

    var cachedGraphics:Array<FlxGraphic> = [];

    public function new()
    {
        for (path in graphicPaths)
        {
            cachedGraphics.push(Paths.image(path));
            FlxG.state.graphicCache.cache(Paths.image(path));
        }

        super(0, 0, cachedGraphics[0]);

        currentGraphic = 'office/office_hallway_static';
        antialiasing = true;
    }

    function changeGraphic(path:String)
    {
        if (currentGraphic == path)
            return;

        var index = graphicPaths.indexOf(path);

        if (index != -1)
        {
            currentGraphic = path;
            loadGraphic(cachedGraphics[index]);
        }
    }

    public function triggerBlocked()
    {
        changeGraphic('office/office_hallway_blocked');
        blockedFrames = 300;
        hallwayBlocked = true;
    }

    public function update(elapsed:Float)
    {
        if (blockedFrames > 0)
        {
            blockedFrames--;

            if (blockedFrames <= 0)
            {
                blockedFrames = 0;
                hallwayBlocked = false;
            }
            else
            {
                hallwayBlocked = true;
            }
        }
        else
        {
            hallwayBlocked = false;
        }
    }

    public function updateAnimatronics(animatronics:Array<Animatronic>)
    {
        if (blockedFrames <= 0)
            setAnimatronics(animatronics);
    }

    var hallwayCombinations:Map<String, String> = [
        'WBonnie+WFoxy' => 'office/office_hallway_WBonnie_WFoxy',
        'WFoxy+mangle' => 'office/office_hallway_WFoxy_mangle'
    ];

    function sortNames(array:Array<String>):Array<String>
    {
        var result:Array<String> = array.copy();

        for (i in 0...result.length)
        {
            for (j in i + 1...result.length)
            {
                if (result[j] < result[i])
                {
                    var temp = result[i];
                    result[i] = result[j];
                    result[j] = temp;
                }
            }
        }

        return result;
    }

    public function setAnimatronics(animatronics:Array<Animatronic>, goldenFreddyHallway:Bool = false)
    {
        if (blockedFrames > 0)
            return;

        if (goldenFreddyHallway)
        {
            changeGraphic('office/office_hallway_goldenfreddy');
            return;
        }

        var hallway2:Array<Animatronic> = [];
        var hallway1:Array<Animatronic> = [];

        for (anim in animatronics)
        {
            if (anim.camera == 'hallway2')
                hallway2.push(anim);

            if (anim.camera == 'hallway1')
                hallway1.push(anim);
        }

        hallway2.sort(function(a:Animatronic, b:Animatronic)
        {
            return a.order - b.order;
        });

        hallway1.sort(function(a:Animatronic, b:Animatronic)
        {
            return a.order - b.order;
        });

        var graphic:String = 'office/office_hallway_static';

        if (hallway2.length > 0)
        {
            var name:String = hallway2[0].name;

            var closePath:String = 'office/office_hallway_' + name + '_close';
            var normalPath:String = 'office/office_hallway_' + name;

            if (graphicPaths.contains(closePath))
                graphic = closePath;
            else if (graphicPaths.contains(normalPath))
                graphic = normalPath;
        }
        else if (hallway1.length > 0)
        {
            var bestAnim:Animatronic = hallway1[0];

            var bestCombinationGraphic:String = '';
            var bestCombinationOrder:Int = 999999;

            for (combinationKey in hallwayCombinations.keys())
            {
                var combination:Array<String> = combinationKey.split('+');
                var allPresent:Bool = true;
                var combinationOrder:Int = 999999;

                for (name in combination)
                {
                    var found:Bool = false;

                    for (anim in hallway1)
                    {
                        if (anim.name == name)
                        {
                            found = true;

                            if (anim.order < combinationOrder)
                                combinationOrder = anim.order;
                        }
                    }

                    if (!found)
                        allPresent = false;
                }

                if (allPresent && combinationOrder < bestCombinationOrder)
                {
                    bestCombinationOrder = combinationOrder;
                    bestCombinationGraphic = hallwayCombinations.get(combinationKey);
                }
            }

            if (bestCombinationGraphic != '' && bestCombinationOrder <= bestAnim.order)
            {
                graphic = bestCombinationGraphic;
            }    
            else
            {
                var name:String = bestAnim.name;

                var closePath:String = 'office/office_hallway_' + name + '_close';
                var normalPath:String = 'office/office_hallway_' + name;

                if (graphicPaths.contains(closePath))
                    graphic = closePath;
                else if (graphicPaths.contains(normalPath))
                    graphic = normalPath;
            }
        }

        changeGraphic(graphic);
    }
}