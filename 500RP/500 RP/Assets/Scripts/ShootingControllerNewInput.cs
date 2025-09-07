using UnityEngine;

public class ShootingControllerNewInput : MonoBehaviour
{
    [Header("Referencias")]
    public NewInputController inputController;
    public ArmControllerNewInput armController;
    public PowerMeterController powerMeter;
    public Transform shootPoint;
    public GameObject projectilePrefab;

    [Header("Configuración de Disparo")]
    public float minForce = 5f;
    public float maxForce = 20f;
    public float maxChargeTime = 2f;

    private float currentChargeTime = 0f;
    private bool isCharging = false;

    void Update()
    {
        if (inputController == null || powerMeter == null) return;

        // Iniciar carga
        if (inputController.chargePressed)
        {
            StartCharging();
        }

        // Durante la carga
        if (isCharging)
        {
            ContinueCharging();
        }

        // Liberar disparo
        if (inputController.chargeReleased && isCharging)
        {
            ReleaseShot();
        }
    }

    private void StartCharging()
    {
        isCharging = true;
        currentChargeTime = 0f;
        powerMeter.SetPower(0);
    }

    private void ContinueCharging()
    {
        currentChargeTime += Time.deltaTime;
        float chargeRatio = Mathf.Clamp01(currentChargeTime / maxChargeTime);
        
        int powerLevel = Mathf.RoundToInt(chargeRatio * 5f);
        powerMeter.SetPower(powerLevel);
    }

    private void ReleaseShot()
    {
        float chargeRatio = Mathf.Clamp01(currentChargeTime / maxChargeTime);
        float force = Mathf.Lerp(minForce, maxForce, chargeRatio);
        
        Shoot(force);
        powerMeter.SetPower(0);
        isCharging = false;
    }

    private void Shoot(float force)
    {
        if (projectilePrefab == null || shootPoint == null) return;

        GameObject projectile = Instantiate(projectilePrefab, shootPoint.position, shootPoint.rotation);
        Rigidbody2D rb = projectile.GetComponent<Rigidbody2D>();
        
        if (rb != null)
        {
            Vector2 shootDirection = shootPoint.right;
            rb.AddForce(shootDirection * force, ForceMode2D.Impulse);
        }
    }
}