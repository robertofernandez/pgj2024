package com.willdom.games.bomberman.Explosions
{
    import flash.geom.Point;

    public class ExplosionArea
    {
        
        public var explodingCells:Array;
        private var explodingCellsMap:Object;
        
        public function ExplosionArea()
        {
            explodingCells = new Array();
            explodingCellsMap = new Object();
        }
        
        public function containsCell(x:int, y:int):Boolean
        {
            return explodingCellsMap[x + "_" + y] != null;
        }

        public function containsTile(tile:Point):Boolean
        {
            return containsCell(tile.x, tile.y);
        }

        public function addCell(cell:ExplodingCell):void
        {
            explodingCells.push(cell);
            explodingCellsMap[cell.x + "_" + cell.y] = cell;
        }
        
        public function getCell(x:int, y:int):ExplodingCell
        {
            return explodingCellsMap[x + "_" + y];
        }
        
        public function getCellInTile(tile:Point):ExplodingCell
        {
            return getCell(tile.x, tile.y);
        }
    }
}