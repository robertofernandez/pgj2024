using UnityEngine;
using Sodhium.Geometry;

namespace Sodhium.Utils
{
    public static class TilesUtils
    {
        public static TilesetCoordinatesCalculator GetTilesetCoordinatesCalculator(float centerX, float centerY, float tilesX, float tilesY, float tileSizeX, float tileSizeY)
        {
            return new TilesetCoordinatesCalculator(centerX, centerY, tilesX, tilesY, tileSizeX, tileSizeY);
        }
    }

    public class TilesetCoordinatesCalculator
    {
        private float centerX;
        private float centerY;
        private float tilesX;
        private float tilesY;
        private float tileSizeX;
        private float tileSizeY;

        public TilesetCoordinatesCalculator(float centerX, float centerY, float tilesX, float tilesY, float tileSizeX, float tileSizeY)
        {
            this.centerX = centerX;
            this.centerY = centerY;
            this.tilesX = tilesX;
            this.tilesY = tilesY;
            this.tileSizeX = tileSizeX;
            this.tileSizeY = tileSizeY;
        }

        public Vector2 GetTileCenterCoordinates(int tileX, int tileY)
        {
            float offsetX = ((float)tileX - tilesX) * tileSizeX;
            float offsetY = ((float)tileY - tilesY) * tileSizeY;

            return new Vector2(centerX + offsetX, centerY + offsetY);
        }

        public Vector2 GetTileCoordinates(float anchorX, float anchorY, int tileX, int tileY)
        {
            float offsetX = ((float)tileX - tilesX / 2 + anchorX / 2) * tileSizeX;
            float offsetY = ((float)tileY - tilesY / 2 + anchorY / 2) * tileSizeY;

            return new Vector2(centerX + offsetX, centerY + offsetY);
        }

        public Vector2 GetTileCoordinatesHalfTileLeft(float anchorX, float anchorY, int tileX, int tileY)
        {
            float offsetX = ((float)tileX - tilesX / 2 + anchorX / 2 - 1/4) * tileSizeX;
            float offsetY = ((float)tileY - tilesY / 2 + anchorY / 2) * tileSizeY;

            return new Vector2(centerX + offsetX, centerY + offsetY);
        }

        public Vector2 GetTileCoordinatesHalfTileRight(float anchorX, float anchorY, int tileX, int tileY)
        {
            float offsetX = ((float)tileX - tilesX / 2 + anchorX / 2 - 1/4) * tileSizeX;
            float offsetY = ((float)tileY - tilesY / 2 + anchorY / 2) * tileSizeY;

            return new Vector2(centerX + offsetX, centerY + offsetY);
        }

    }
}
