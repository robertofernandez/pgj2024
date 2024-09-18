using UnityEngine;

namespace Sodhium.Geometry
{
    public class RoadMapTileDescriptor
    {
        private float bottomLeftX;
        private float bottomLeftY;
        private float sizeX;
        private float sizeY;

        public RoadMapTileDescriptor(float bottomLeftX, float bottomLeftY, float sizeX, float sizeY)
        {
            this.bottomLeftX = bottomLeftX;
            this.bottomLeftY = bottomLeftY;
            this.sizeX = sizeX;
            this.sizeY = sizeY;
        }

        public Vector2 GetCoordinates(float anchorY, float anchorX)
        {
            float posX = bottomLeftX + (anchorX + 1) * 0.5f * sizeX;
            float posY = bottomLeftY + (anchorY + 1) * 0.5f * sizeY;

            return new Vector2(posX, posY);
        }

        public Vector2 GetCoordinatesHalfTileLeft(float anchorY, float anchorX)
        {
            float posX = bottomLeftX + (anchorX + 1) * 0.5f * sizeX - sizeX / 4;
            float posY = bottomLeftY + (anchorY + 1) * 0.5f * sizeY;

            return new Vector2(posX, posY);
        }

        public Vector2 GetCoordinatesHalfTileRight(float anchorY, float anchorX)
        {
            float posX = bottomLeftX + (anchorX + 1) * 0.5f * sizeX + sizeX / 4;
            float posY = bottomLeftY + (anchorY + 1) * 0.5f * sizeY;

            return new Vector2(posX, posY);
        }        
    }
}
