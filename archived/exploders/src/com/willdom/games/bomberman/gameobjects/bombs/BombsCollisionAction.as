package com.willdom.games.bomberman.gameobjects.bombs
{
    import com.gq.moveobject.Bomb;

    public interface BombsCollisionAction
    {
        function applyToBomb(bomb:Bomb):void;
    }
}