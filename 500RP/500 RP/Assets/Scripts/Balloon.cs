using UnityEngine;

public class Balloon : MonoBehaviour
{
    [Header("Configuración del Globo")]
    public float health = 1f;
    public GameObject popEffect;
    public int scoreValue = 10;

    public void TakeDamage(float damage)
    {
        health -= damage;
        
        if (health <= 0)
        {
            PopBalloon();
        }
    }

    private void PopBalloon()
    {
        // Efecto de reventón
        if (popEffect != null)
        {
            Instantiate(popEffect, transform.position, Quaternion.identity);
        }

        // Sonido, score, etc.
        // GameManager.Instance.AddScore(scoreValue);

        Destroy(gameObject);
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        // Si algo choca con el globo, puede reventarlo
        if (collision.relativeVelocity.magnitude > 2f)
        {
            PopBalloon();
        }
    }
}