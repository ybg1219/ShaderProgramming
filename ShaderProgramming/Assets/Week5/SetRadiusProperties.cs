using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetRadiusProperties : MonoBehaviour
{
    public Material RadiusMat;// material 연결 해주기
    public float radius = 1;
    public Color color= Color.white;
    
    void Update()
    {
        RadiusMat.SetVector("_Center", transform.position);
        RadiusMat.SetFloat("_Radius", radius);
        RadiusMat.SetColor("_RadiusColor", color);
    }
}
