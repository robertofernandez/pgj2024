using UnityEngine;
using System.Collections;

public class Character : MonoBehaviour {
    private Rigidbody2D body;

    public float maxVelocity = 10;

    public float currentVelocity = 0;

    public float xInput = 0;
    public float yInput = 0;

    public float velocityIncreaseRate = 0.4f;
    public float velocityDesacelerationDecreaseRate = 0.3f;
    public float velocityBrakeDecreaseRate = 0.55f;
    public float velocityThreshold = 0.01f;

    public CharactersManager manager;

    string terrain = TerrainConstants.ROAD;

    void Start () {
        //animator = GetComponent<Animator>();
        body = GetComponent<Rigidbody2D>();
        //healthLevel = transform.Find("HealthBar").Find("HealthLevel").GetComponent<HealthLevel>();
		body.gravityScale = 0;
    }

    void FixedUpdate()
    {
        if(terrain == TerrainConstants.SAND)
        {
            if(currentVelocity > maxVelocity)
            {
                currentVelocity = Mathf.Max(maxVelocity, currentVelocity / 1.1f);
            }
        }

        // Obtener la entrada del jugador
        xInput = Input.GetAxis("Horizontal");
        yInput = Input.GetAxis("Vertical");

        if (currentVelocity > 0)
        {
            if (yInput > 0)
            {
                //Debug.Log("Acelerando");
                currentVelocity += velocityIncreaseRate;
                if(currentVelocity > maxVelocity)
                {
                    currentVelocity = maxVelocity;
                }
            }
            else if (yInput == 0)
            {
                //Debug.Log("Desacelerando");
                currentVelocity -= velocityDesacelerationDecreaseRate;
                if(currentVelocity < 0)
                {
                    currentVelocity = 0;
                }
            }
            else
            {
                //Debug.Log("Frenando");
                currentVelocity -= velocityBrakeDecreaseRate;
                if(currentVelocity < 0)
                {
                    currentVelocity = 0;
                }
            }
        }
        else if(currentVelocity <0)
        {
            if (yInput > 0)
            {
                //Debug.Log("Frenando para adelante");
                currentVelocity += velocityBrakeDecreaseRate;
                if(currentVelocity > 0)
                {
                    currentVelocity = 0;
                }
            }
            else if (yInput == 0)
            {
                //Debug.Log("Desacelerando marcha atras");
                currentVelocity += velocityDesacelerationDecreaseRate;
                if(currentVelocity > 0)
                {
                    currentVelocity = 0;
                }
            }
            else
            {
                //Debug.Log("Acelerando para atras");
                currentVelocity -= velocityIncreaseRate;
                if(currentVelocity < -maxVelocity)
                {
                    currentVelocity = -maxVelocity;
                }
            }
        }
        else //es 0
        {
            if (yInput > 0)
            {
                //Debug.Log("Acelerando");
                currentVelocity += velocityIncreaseRate;
                if(currentVelocity > maxVelocity)
                {
                    currentVelocity = maxVelocity;
                }
            }
            else if (yInput < 0)
            {
                //Debug.Log("Acelerando para atras");
                currentVelocity -= velocityIncreaseRate;
                if(currentVelocity < -maxVelocity)
                {
                    currentVelocity = -maxVelocity;
                }
            }
        }

        // Ajustar la rotación del auto basado en la entrada horizontal
        //float rotationAmount = xInput * 10f * Time.fixedDeltaTime * Mathf.Abs(currentVelocity); // Ajustar el valor para cambiar la sensibilidad del giro
        float rotationAmount = xInput * 10f * Time.fixedDeltaTime * currentVelocity;
        body.rotation -= rotationAmount;

        // Mover el auto hacia adelante en la dirección de su rotación actual
        Vector2 forward = transform.up; // La dirección hacia la que "mira" el auto en 2D es el eje 'up'
        body.velocity = forward * currentVelocity;
    }

    public string GetUnitName()
    {
        return "Car";
    }

    public void SetRoadSpeed()
    {
        terrain = TerrainConstants.ROAD;
        maxVelocity = 20;
    }

    public void SetSandSpeed()
    {
        terrain = TerrainConstants.SAND;
        maxVelocity = 8;
        if(currentVelocity > maxVelocity)
        {
            currentVelocity = Mathf.Max(maxVelocity, currentVelocity / 1.5f);
        }
    }


}