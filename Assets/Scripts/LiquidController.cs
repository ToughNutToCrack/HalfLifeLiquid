using UnityEngine;

// [ExecuteInEditMode]
public class LiquidController : MonoBehaviour {

    public GameObject bottle;
    public GameObject plane;
    public Material liquid;
    public Material topLiquidSurface;
    [Space]
    public Vector3 offset;
    public float bottleHeight;
    [Space]
    public float recoveryTime = 10;
    public float facingScale = 20;
    public float velocitySpeed = 10;

    Vector3 normal;
    Vector3 pos;
    Vector3 lastPos;
    Vector3 velocity;
    Vector3 lastVelocity;
    Vector3 lastRot;  
    Vector3 angularVelocity;
    Vector3 lastAngularVelocity;
    Vector3 facing;

    float stopElapsedTime = 0f;
    float moveElapsedTime = 0f;
    float stopAngularElapsedTime = 0f;
    float moveAngularElapsedTime = 0f;

    void Start () {
        initMovement();
        updatePlaneTransform();
        updateShaderProperties();
    }

    void Update (){
        updatePlaneTransform();
        updateShaderProperties();
    }

    void initMovement(){
        facing = Vector3.zero;
        normal = plane.transform.TransformVector(new Vector3(0,0,-1));
        pos = plane.transform.position;
        lastPos = transform.position;
        velocity = (lastPos - transform.position) / Time.deltaTime;
        velocity = Vector3.ClampMagnitude(velocity, 1f);
        lastRot = transform.eulerAngles;
        angularVelocity = (lastRot - transform.eulerAngles) / Time.deltaTime;
        angularVelocity = Vector3.ClampMagnitude(angularVelocity, 1f);
    }

    void updatePlaneTransform(){
        //plane position
        Vector3 planePos = bottle.transform.position + offset;

        Vector3 a = bottle.transform.position;
        Vector3 b = bottle.transform.position + transform.TransformDirection(Vector3.up) * bottleHeight;

        float dist = offset.y;
        if(b.y < a.y){
            a = b;
            b = bottle.transform.position;
        }

        Vector3 heading = b - a;
        float distance = heading.magnitude;
        Vector3 direction = heading / distance;
        
        planePos = a + direction * dist;
        plane.transform.position = planePos;

        //plane rotation
        
        if(velocity.magnitude == 0){
            moveElapsedTime = 0;
            stopElapsedTime += Time.deltaTime;
            float t = Mathf.PingPong(stopElapsedTime * recoveryTime, 1);
            Vector3 ppFacing = Vector3.Lerp(-lastVelocity, lastVelocity, t);
            facing = Vector3.Lerp(ppFacing, Vector3.zero, stopElapsedTime / lastVelocity.magnitude);
        }else{
            stopElapsedTime = 0;
            moveElapsedTime += Time.deltaTime;
            facing = facingScale * velocity * moveElapsedTime * lastVelocity.magnitude;
            lastVelocity = velocity * Mathf.Clamp(moveElapsedTime * velocitySpeed, .1f, 1.5f);
            angularVelocity = Vector3.zero;
            lastAngularVelocity = Vector3.zero;
        }

        if(angularVelocity.magnitude == 0){
            moveAngularElapsedTime = 0;
            stopAngularElapsedTime += Time.deltaTime;
            float t = Mathf.PingPong(stopAngularElapsedTime * recoveryTime, 1);
            Vector3 ppFacing = Vector3.Lerp(-lastAngularVelocity, lastAngularVelocity, t);
            facing += Vector3.Lerp(ppFacing, Vector3.zero, stopAngularElapsedTime / lastAngularVelocity.magnitude);           
        }else{
            stopAngularElapsedTime = 0;
            moveAngularElapsedTime += Time.deltaTime;
            lastAngularVelocity = angularVelocity * Mathf.Clamp(moveAngularElapsedTime * velocitySpeed, .1f, 1.5f);
        }

        if(lastVelocity.magnitude > 0 ){
            facing = new Vector3(
                facing.x + facing.y,
                0,
                facing.z + facing.y
            );
        }

        if(lastAngularVelocity.magnitude > 0 ){
            facing = Quaternion.AngleAxis(transform.localRotation.eulerAngles.y + 90, Vector3.up) * facing;
            facing = new Vector3(
                facing.x + facing.y/2,
                0,
                facing.z + facing.y/2
            );
        }


        velocity = (lastPos - transform.position) / Time.deltaTime;
        velocity = Vector3.ClampMagnitude(velocity, 1f);

        angularVelocity = (lastRot - transform.eulerAngles) / Time.deltaTime;
        angularVelocity = Vector3.ClampMagnitude(angularVelocity, 1f);

        lastPos = transform.position;
        lastRot = transform.eulerAngles;

        plane.transform.LookAt(plane.transform.position - Vector3.up + facing);

    }

    void updateShaderProperties(){
        pos = plane.transform.position;
        normal = -plane.transform.forward;


        liquid.SetVector("_PlanePosition", pos);
        liquid.SetVector("_PlaneNormal", normal);

        liquid.SetVector("_Inertia", facing);
        topLiquidSurface.SetVector("_Inertia", facing);

    }

    void OnDrawGizmos() {
        Gizmos.color = Color.red;
        Vector3 topD = transform.TransformDirection(Vector3.up) * bottleHeight;
        Gizmos.DrawRay(transform.position, topD);
        // Gizmos.color = Color.yellow;
        // Vector3 liquidLevel = -facing * bottleHeight;
        // Gizmos.DrawRay(plane.transform.position, liquidLevel);
    }
}