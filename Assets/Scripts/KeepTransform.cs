using UnityEngine;

public class KeepTransform : MonoBehaviour{

    void Update(){
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.identity;
    }
}
