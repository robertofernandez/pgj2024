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

    public float maxFuelAmount;
    public float fuelAmount;

    void Start () {
        //animator = GetComponent<Animator>();
        maxFuelAmount = 5000f;
        fuelAmount = maxFuelAmount;
        body = GetComponent<Rigidbody2D>();
        body.drag = 1f;
        body.angularDrag = 2f;
        //healthLevel = transform.Find("HealthBar").Find("HealthLevel").GetComponent<HealthLevel>();
		body.gravityScale = 0;
    }

    public void SetManager(CharactersManager charactersManager)
    {
        manager = charactersManager;
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

        bool acelerando = false;

        if (currentVelocity > 0)
        {
            if (yInput > 0)
            {
                //Debug.Log("Acelerando");
                acelerando = true;
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
                acelerando = true;
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
                acelerando = true;
                currentVelocity += velocityIncreaseRate;
                if(currentVelocity > maxVelocity)
                {
                    currentVelocity = maxVelocity;
                }
            }
            else if (yInput < 0)
            {
                //Debug.Log("Acelerando para atras");
                acelerando = true;
                currentVelocity -= velocityIncreaseRate;
                if(currentVelocity < -maxVelocity)
                {
                    currentVelocity = -maxVelocity;
                }
            }
        }
        if (acelerando)
        {
            fuelAmount = fuelAmount - 2;
        }

        // Ajustar la rotación del auto basado en la entrada horizontal
        //float rotationAmount = xInput * 10f * Time.fixedDeltaTime * Mathf.Abs(currentVelocity); // Ajustar el valor para cambiar la sensibilidad del giro
        float realVelocity = body.velocity.magnitude;
        manager.SetCurrentSpeed(realVelocity);

        Debug.Log("real velocity: " + realVelocity);
        if(currentVelocity < 0) {
            realVelocity = -1 * realVelocity;
        }
        float rotationAmount = xInput * 10f * Time.fixedDeltaTime * realVelocity;
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

    public float GetFuelAmount()
    {
        return fuelAmount;
    }

    public void FuelPickedUp()
    {
        fuelAmount = Mathf.Min(maxFuelAmount, fuelAmount + 500);
    }


}