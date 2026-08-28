import fnaf.minigame.BaseMinigame;
import fnaf.minigame.FoxyMinigame;

var minigame:Int = 1;
var currentMinigame:BaseMinigame;

function create()
{
    if (data != null)
        minigame = data.minigame;

    switch (minigame)
    {
        case 1:
            currentMinigame = new FoxyMinigame();
    }

    add(currentMinigame);
}