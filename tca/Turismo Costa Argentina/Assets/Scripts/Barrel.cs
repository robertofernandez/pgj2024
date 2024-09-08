using UnityEngine;

public class Barrel : MonoBehaviour
{
    bool setToDissapear = false;
    int ciclesToDissapear = 0;
    private SpriteRenderer spriteRenderer;
    //private Collider2D collider2D;
    void Start () {
        spriteRenderer = GetComponent<SpriteRenderer>();
        //collider2D = GetComponent<Collider2D>();
    }

    void FixedUpdate()
    {
        if(setToDissapear)
        {
            ciclesToDissapear--;
            if(ciclesToDissapear < 1)
            {
                setToDissapear = false;
                spriteRenderer.enabled = false;
                GetComponent<Collider2D>().enabled = false;
            }
        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        Debug.Log("algo colisiono: " + collision.gameObject.name);
        if (collision.gameObject.CompareTag("Player")) // Puedes cambiar "Player" por cualquier etiqueta que desees detectar
        {
            Debug.Log("El jugador ha chocado.");
            /*
            spriteRenderer.enabled = false;
            collider2D.enabled = false;
            */
            if(!setToDissapear)
            {
                ciclesToDissapear = 10;
                setToDissapear = true;
            }
        }
    }

    // Este método se llama cuando otro objeto entra en el trigger
    private void OnTriggerEnter2D(Collider2D other)
    {
        if (other.CompareTag("Player")) // Puedes cambiar "Player" por cualquier etiqueta que desees detectar
        {
            Debug.Log("El jugador ha chocado.");
            // Agrega aquí la lógica que quieras ejecutar cuando el jugador entre en el trigger
        }
    }

    // Este método se llama mientras otro objeto permanece dentro del trigger
    private void OnTriggerStay2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            Character character = other.GetComponent<Character>();
            character.SetRoadSpeed();
            Debug.Log(character.GetUnitName() + " está dentro de la calzada.");
            // Agrega la lógica que se ejecuta mientras el jugador esté dentro del trigger
        }
    }

    // Este método se llama cuando otro objeto sale del trigger
    private void OnTriggerExit2D(Collider2D other)
    {
        if (other.CompareTag("Player"))
        {
            Character character = other.GetComponent<Character>();
            character.SetSandSpeed();
            Debug.Log(character.GetUnitName() + " está fuera de la calzada.");
        }
    }
}
