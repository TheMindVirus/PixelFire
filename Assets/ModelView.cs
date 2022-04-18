using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class ModelView : MonoBehaviour
{
    float speed = 2.0f;
    float velocity = 0.5f;
    float sensitivity = 2.0f;
    float deadzone = 0.1f;
    Vector2 rightStick = new Vector2(0, 0);

    void Update()
    {
        var mouse = Mouse.current;
        if ((mouse != null) && (mouse.leftButton.isPressed))
        {
            transform.Rotate(new Vector3(mouse.delta.y.ReadValue() * -speed, 0, 0), Space.World);
            transform.Rotate(new Vector3(0, 0, mouse.delta.x.ReadValue() * speed), Space.Self);
        }

        var touchscreen = Touchscreen.current;
        if (touchscreen != null)
        {
            transform.Rotate(new Vector3(touchscreen.touches[0].delta.y.ReadValue() * -velocity, 0, 0), Space.World);
            transform.Rotate(new Vector3(0, 0, touchscreen.touches[0].delta.x.ReadValue() * velocity), Space.Self);
        }

        var gamepad = Gamepad.current;
        if (gamepad != null)
        {
            rightStick = gamepad.rightStick.ReadValue();
            rightStick = new Vector2((Mathf.Abs(rightStick.x) > deadzone) ? rightStick.x * sensitivity : 0.0f,
                                     (Mathf.Abs(rightStick.y) > deadzone) ? rightStick.y * sensitivity : 0.0f);
            transform.Rotate(new Vector3(rightStick.y * -speed, 0, 0), Space.World);
            transform.Rotate(new Vector3(0, 0, rightStick.x * speed), Space.Self);
        }
    }
}
