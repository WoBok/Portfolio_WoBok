using UnityEngine;

public class OrbitRotator : MonoBehaviour
{
    public float radius;
    public float hight;
    public float speed;
    public Transform target;
    void Update()
    {
        var x = radius * Mathf.Cos(Time.time * speed);
        var y = hight * Mathf.Cos(Time.time * speed);
        var z = radius * Mathf.Sin(Time.time * speed);
        transform.position = target.position + new Vector3(x, y, z);
        var targetPos = new Vector3(target.position.x, transform.position.y, target.position.z);
        transform.LookAt(targetPos);
    }
}