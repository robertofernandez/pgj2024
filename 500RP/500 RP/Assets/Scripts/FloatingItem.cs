using UnityEngine;

public class FloatingItem : MonoBehaviour
{
    public float bobbingAmplitude = 0.1f;
    public float bobbingSpeed = 2f;

    Vector3 startPos;

    void Start()
    {
        startPos = transform.localPosition;
    }

    void Update()
    {
        // bobbing senoidal
        float newY = startPos.y + Mathf.Sin(Time.time * bobbingSpeed) * bobbingAmplitude;
        transform.localPosition = new Vector3(startPos.x, newY, startPos.z);
    }
}
