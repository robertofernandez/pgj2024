using UnityEngine;

public class ArmControllerNewInput : MonoBehaviour
{
    [Header("Referencias")]
    public Transform armPivot;

    public Transform pipoAndElevator;

    public NewInputController inputController; // Ahora usa el nuevo controller

    [Header("Configuración")]
    public float minAngle = -45f;
    public float maxAngle = 45f;
    public float rotationSpeed = 180f;
    public float minHeight = -2f;
    public float maxHeight = 2f;
    public float moveSpeed = 3f;

    private float currentAngle = 0f;
    private float currentHeight = 0f;

    void Update()
    {
        if (inputController == null) return;

        // Rotación del brazo
        float targetAngle = currentAngle + (inputController.aimAngle * rotationSpeed * Time.deltaTime);
        currentAngle = Mathf.Clamp(targetAngle, minAngle, maxAngle);
        
        if (armPivot != null)
        {
            armPivot.localEulerAngles = new Vector3(0, 0, currentAngle);
        }

        // Movimiento vertical
        float targetHeight = currentHeight + (inputController.moveY * moveSpeed * Time.deltaTime);
        currentHeight = Mathf.Clamp(targetHeight, minHeight, maxHeight);
        
        pipoAndElevator.position = new Vector3(pipoAndElevator.position.x, currentHeight, pipoAndElevator.position.z);
    }

    public float GetNormalizedAngle()
    {
        return Mathf.InverseLerp(minAngle, maxAngle, currentAngle);
    }

    public float GetNormalizedHeight()
    {
        return Mathf.InverseLerp(minHeight, maxHeight, currentHeight);
    }
}