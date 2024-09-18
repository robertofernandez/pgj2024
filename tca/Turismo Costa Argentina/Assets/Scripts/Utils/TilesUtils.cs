using UnityEngine;
using Sodhium.Geometry;

namespace Sodhium.Utils
{
    public static class TilesUtils
    {
        public static TilesetCoordinatesCalculator GetTilesetCoordinatesCalculatorFromCenter(float centerX, float centerY, float tilesX, float tilesY, float tileSizeX, float tileSizeY)
        {
            float leftLimit = centerX - (tileSizeX * tilesX / 2);
            float bottomLimit = centerY - (tileSizeY * tilesY / 2);
            return new TilesetCoordinatesCalculator(leftLimit, bottomLimit, tilesX, tilesY, tileSizeX, tileSizeY);
        }

        public static TilesetCoordinatesCalculator GetTilesetCoordinatesCalculator(float leftLimit, float bottomLimit, float tilesX, float tilesY, float tileSizeX, float tileSizeY)
        {
            return new TilesetCoordinatesCalculator(leftLimit, bottomLimit, tilesX, tilesY, tileSizeX, tileSizeY);
        }
    }

    public class TilesetCoordinatesCalculator
    {
        private float leftLimit;
        private float bottomLimit;
        private float tilesX;
        private float tilesY;
        private float tileSizeX;
        private float tileSizeY;

        public TilesetCoordinatesCalculator(float leftLimit, float bottomLimit, float tilesX, float tilesY, float tileSizeX, float tileSizeY)
        {
            this.leftLimit = leftLimit;
            this.bottomLimit = bottomLimit;
            this.tilesX = tilesX;
            this.tilesY = tilesY;
            this.tileSizeX = tileSizeX;
            this.tileSizeY = tileSizeY;
        }

        public Vector2 GetTileCenterCoordinates(int tileX, int tileY)
        {
            float offsetX = (float)tileX * tileSizeX + tileSizeX / 2;
            float offsetY = (float)tileY * tileSizeY + tileSizeY / 2;

            return new Vector2(leftLimit + offsetX, bottomLimit + offsetY);
        }

        public Vector2 GetTileCoordinates(float anchorY, float anchorX, int tileX, int tileY)
        {
            float offsetX = (float)tileX * tileSizeX + tileSizeX / 2 + (anchorX) * tileSizeX / 2;
            float offsetY = (float)tileY * tileSizeY + tileSizeY / 2 + (anchorY) * tileSizeY / 2;

            return new Vector2(leftLimit + offsetX, bottomLimit + offsetY);
        }

        public Vector2 GetTileCoordinatesHalfTileLeft(float anchorY, float anchorX, int tileX, int tileY)
        {
            float offsetX = (float)tileX * tileSizeX + tileSizeX / 2 + (anchorX) * tileSizeX / 2 - tileSizeX / 4;
            float offsetY = (float)tileY * tileSizeY + tileSizeY / 2 + (anchorY) * tileSizeY / 2;

            return new Vector2(leftLimit + offsetX, bottomLimit + offsetY);
        }

        public Vector2 GetTileCoordinatesHalfTileRight(float anchorY, float anchorX, int tileX, int tileY)
        {
            float offsetX = (float)tileX * tileSizeX + tileSizeX / 2 + (anchorX) * tileSizeX / 2 + tileSizeX / 4;
            float offsetY = (float)tileY * tileSizeY + tileSizeY / 2 + (anchorY) * tileSizeY / 2;

            return new Vector2(leftLimit + offsetX, bottomLimit + offsetY);
        }

    }
}
