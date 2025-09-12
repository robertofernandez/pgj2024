using UnityEngine;

public class Cage : MonoBehaviour
{
    public GameObject balloonPrefab;
    public GameObject brokenCageEffect;

    [Header("Configuración caída")]
    public float gravity = -9.8f;
    private float groundLevel = -4.3f;
    public float slowDownDistance = 0.5f; // cuando se acerca al suelo, desacelera

    [Header("Elevación con globo")]
    public float riseSpeed = 2f;

    private float verticalVelocity = 0f;
    private bool hasLanded = false;
    private bool hasCaptured = false;

    private Hamster trappedHamster;
    private GameObject balloonInstance;

    public HamsterGameManager hamsterManager;

    void Update()
    {
        if (!hasCaptured)
        {
            if (!hasLanded)
            {
                HandleFalling();
            }
            else
            {
                TryCaptureHamster();
            }
        }
        else
        {
            HandleBalloonRise();
        }
    }

    private void HandleFalling()
    {
        float distanceToGround = transform.position.y - groundLevel;

        if (distanceToGround > 0f)
        {
            if (distanceToGround <= slowDownDistance)
            {
                // Desacelerar suavemente al acercarse al suelo
                verticalVelocity = Mathf.Lerp(verticalVelocity, -1f, Time.deltaTime * 5f);
            }
            else
            {
                // Caída acelerada normal
                verticalVelocity += gravity * Time.deltaTime;
            }

            transform.position += Vector3.up * verticalVelocity * Time.deltaTime;

            // Clampeo por si pasa el suelo
            if (transform.position.y <= groundLevel)
            {
                LandOnGround();
            }
        }
    }

    private void LandOnGround()
    {
        hasLanded = true;
        verticalVelocity = 0f;
        transform.position = new Vector3(transform.position.x, groundLevel, transform.position.z);
    }

    private void TryCaptureHamster()
    {
        Hamster nearest = hamsterManager.GetNearestHamster(transform.position.x);

        if (nearest != null && !nearest.isTrapped)
        {
            float distance = Mathf.Abs(transform.position.x - nearest.transform.position.x);

            if (distance < 0.1f)
            {
                trappedHamster = nearest;
                trappedHamster.Capture(transform);
                hasCaptured = true;

                // Crear globo
                if (balloonPrefab != null)
                {
                    balloonInstance = Instantiate(balloonPrefab, transform);
                    balloonInstance.transform.localPosition = Vector3.up * 1.1f;
                }

                Debug.Log("Hamster atrapado!");
            }
        }
    }

    private void HandleBalloonRise()
    {
        if (balloonInstance != null)
        {
            transform.position += Vector3.up * riseSpeed * Time.deltaTime;
            if (transform.position.y >= 0.56f)
            {
                if (trappedHamster != null)
                {
                    Destroy(trappedHamster.gameObject);
                    trappedHamster = null;
                }

                if (balloonInstance != null)
                {
                    Destroy(balloonInstance);
                    balloonInstance = null;
                }

                Destroy(gameObject); // destruir la jaula
            }
        }
        else
        {
            // Globo destruido → cae y se destruye la jaula
            verticalVelocity += gravity * Time.deltaTime;
            transform.position += Vector3.up * verticalVelocity * Time.deltaTime;

            if (transform.position.y <= groundLevel)
            {
                ReleaseHamster();
            }
        }
    }

    public void ReleaseHamster()
    {
        if (trappedHamster != null)
        {
            trappedHamster.Release();
            trappedHamster = null;
        }

        if (brokenCageEffect != null)
        {
            Instantiate(brokenCageEffect, transform.position, Quaternion.identity);
        }

        Destroy(gameObject);
    }
}
