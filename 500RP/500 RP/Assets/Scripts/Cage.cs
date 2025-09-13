using UnityEngine;

public class Cage : MonoBehaviour
{
    public GameObject balloonPrefab;
    public GameObject brokenCageEffect;

    [Header("Configuración caída")]
    public float gravity = -9.8f;
    private float groundLevel = -4.3f;
    public float slowDownDistance = 0.5f;

    [Header("Elevación con globo")]
    public float riseSpeed = 2f;
    public float maxRiseHeight = 3.4f;

    private float verticalVelocity = 0f;
    private bool hasLanded = false;
    private bool hasCaptured = false;

    private Hamster trappedHamster;
    private Balloon balloonInstance;

    public HamsterGameManager hamsterManager;

    public int laneIndex;
    public bool laneFree = false;
    public bool balloonPopped = false;

    void Update()
    {
        if (balloonPopped)
        {
            HandleFallingPopped();
        }
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
                verticalVelocity = Mathf.Lerp(verticalVelocity, -1f, Time.deltaTime * 5f);
            }
            else
            {
                verticalVelocity += gravity * Time.deltaTime;
            }

            transform.position += Vector3.up * verticalVelocity * Time.deltaTime;

            if (transform.position.y <= groundLevel)
            {
                LandOnGround();
            }
        }
    }

    private void HandleFallingPopped()
    {
        float distanceToGround = transform.position.y - groundLevel;

        if (distanceToGround > 0f)
        {
            verticalVelocity += gravity * Time.deltaTime;

            transform.position += Vector3.up * verticalVelocity * Time.deltaTime;

            if (transform.position.y <= groundLevel)
            {
                CrashOnGround();
            }
        }
    }

    private void LandOnGround()
    {
        hasLanded = true;
        verticalVelocity = 0f;
        transform.position = new Vector3(transform.position.x, groundLevel, transform.position.z);
    }

    private void CrashOnGround()
    {
        hasLanded = true;
        verticalVelocity = 0f;
        transform.position = new Vector3(transform.position.x, groundLevel, transform.position.z);
        ReleaseHamster();
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
                    GameObject balloonGO = Instantiate(balloonPrefab, transform);
                    balloonGO.transform.localPosition = Vector3.up * 1.1f;
                    balloonInstance = balloonGO.GetComponent<Balloon>();
                }

                //Debug.Log("Hamster atrapado!");
            }
        }
    }

    public void JoinSpaceship()
    {
        laneFree = true;

        if (trappedHamster != null)
        {
            Destroy(trappedHamster.gameObject);
            trappedHamster = null;
        }

        if (balloonInstance != null)
        {
            Destroy(balloonInstance.gameObject);
            balloonInstance = null;
        }

        Destroy(gameObject);
    }

    private void HandleBalloonRise()
    {
        if (balloonInstance != null && balloonInstance.gameObject.activeSelf)
        {
            if (transform.position.y >= maxRiseHeight)
            {
                laneFree = true;
                return; // espera a la nave
            }

            transform.position += Vector3.up * riseSpeed * Time.deltaTime;
        }
        else
        {
            // Globo destruido → cae
            verticalVelocity += gravity * Time.deltaTime;
            transform.position += Vector3.up * verticalVelocity * Time.deltaTime;

            if (transform.position.y <= groundLevel)
            {
                ReleaseHamster();
            }
        }
    }

    public void OnBalloonDestroyed()
    {
        balloonInstance = null; // cage ahora sabe que ya no hay globo
        balloonPopped = true;
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
