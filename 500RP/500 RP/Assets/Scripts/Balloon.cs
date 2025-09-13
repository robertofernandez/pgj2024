using UnityEngine;

public class Balloon : MonoBehaviour
{
    [Header("Configuración del Globo")]
    public float health = 1f;
    public GameObject popEffect;
    public int scoreValue = 10;

    private bool isPopped = false;
    private Cage parentCage;

    void Start()
    {
        parentCage = GetComponentInParent<Cage>();
    }

    public void TakeDamage(float damage)
    {
        if (isPopped) return;
/*
        health -= damage;
        if (health <= 0)
        {
        */
        PopBalloon();
        //}
    }

    private void PopBalloon()
    {
        isPopped = true;

        if (popEffect != null)
        {
            Instantiate(popEffect, transform.position, Quaternion.identity);
        }

        // Desactivar globo visual
        gameObject.SetActive(false);

        // Avisar a la jaula que el globo ya no existe
        if (parentCage != null)
        {
            Debug.Log("cage en caida");
            parentCage.OnBalloonDestroyed();
        }
        else
        {
            Debug.Log("no hay cage para liberar");
            parentCage = GetComponentInParent<Cage>();
            if (parentCage != null)
            {
                Debug.Log("ahora cage en caida");
                parentCage.OnBalloonDestroyed();
            }
            else
            {
                Debug.Log("aun no cage para liberar");
            }
        }
    }
}
