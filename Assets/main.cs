using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class main : MonoBehaviour {
    public RenderTexture TexturePass0;
    public RenderTexture TexturePass1;
    public RenderTexture TexturePass2;
    public RenderTexture TextureDenoise;

    public Shader Pass1;
    public Shader Pass2;
    public Shader DenoisePass;

    public Material Pass1Material;
    public Material Pass2Material;
    public Material DenoiseMaterial;

    const float eye_step = 0.05f;
    const int width = 1024;
    const int height = 1024;

    float sigma;
    float alpha;
    float eyeX;
    float eyeY;
    int iApplyLogMap1;
    int iApplyLogMap2;
    // Use this for initialization
    void Start () {
        sigma = 1.6f;
        alpha = 4.0f;
        eyeX = 0.5f;
        eyeY = 0.5f;
        iApplyLogMap1 = 1;
        iApplyLogMap2 = 1;
    }
	
	// Update is called once per frame
	void Update () {
        Pass1Main();
        Pass2Main();
        Pass2Denoise();
        keyControl();
    }

    void Pass1Main()
    {
        Pass1Material.SetFloat("_iResolutionX", width);
        Pass1Material.SetFloat("_iResolutionY", height);
        Pass1Material.SetFloat("_eyeX", eyeX);
        Pass1Material.SetFloat("_eyeY", eyeY);
        Pass1Material.SetFloat("_scaleRatio", sigma);
        Pass1Material.SetFloat("_kernel", alpha);
        Pass1Material.SetInt("_iApplyLogMap1", iApplyLogMap1);
        Graphics.Blit(TexturePass0, TexturePass1, Pass1Material);
    }
    void Pass2Main()
    {
        Pass2Material.SetFloat("_iResolutionX", width);
        Pass2Material.SetFloat("_iResolutionY", height);
        Pass2Material.SetFloat("_eyeX", eyeX);
        Pass2Material.SetFloat("_eyeY", eyeY);
        Pass2Material.SetFloat("_scaleRatio", sigma);
        Pass2Material.SetFloat("_kernel", alpha);
        Pass2Material.SetInt("_iApplyLogMap2", iApplyLogMap2);
        Pass2Material.SetTexture("_LogTex", TexturePass1);
        Graphics.Blit(TexturePass1, TexturePass2, Pass2Material);
    }

    void Pass2Denoise()
    {
        DenoiseMaterial.SetFloat("_iResolutionX", width);
        DenoiseMaterial.SetFloat("_iResolutionY", height);
        DenoiseMaterial.SetFloat("_eyeX", eyeX);
        DenoiseMaterial.SetFloat("_eyeY", eyeY);
        DenoiseMaterial.SetTexture("_Pass2Tex", TexturePass2);
        Graphics.Blit(TexturePass2, TextureDenoise, DenoiseMaterial);
    }
    void keyControl()
    {
        if (Input.GetKeyDown(KeyCode.D))
            sigma = sigma >= 2.6f ? 2.6f: sigma + 0.2f;
        if (Input.GetKeyDown(KeyCode.A))
            sigma = sigma <= 1.0f ? 1.0f: sigma - 0.2f;
        if (Input.GetKeyDown(KeyCode.W))
            alpha = alpha >= 4.0f ? 4.0f : alpha + 0.2f;
        if (Input.GetKeyDown(KeyCode.S))
            alpha = alpha <= 1.0f ? 1.0f : alpha - 0.2f;

        if (Input.GetKeyDown(KeyCode.F1))
            iApplyLogMap1 = 1 - iApplyLogMap1;
        if (Input.GetKeyDown(KeyCode.F2))
            iApplyLogMap2 = 1 - iApplyLogMap2;
        if (Input.GetKeyDown(KeyCode.F9))
            SaveToFile(TextureDenoise, "Assets/Result/sigma_" + 
                sigma.ToString() + "alpha_" + alpha.ToString() + ".png");
        if (Input.GetKeyDown(KeyCode.LeftArrow))
            eyeX = eyeX >= 1.0f - eye_step ? 1.0f : eyeX + eye_step;
        if (Input.GetKeyDown(KeyCode.RightArrow))
            eyeX = eyeX >= eye_step ? eyeX - eye_step : 0.0f;
        if (Input.GetKeyDown(KeyCode.DownArrow))
            eyeY = eyeY >= eye_step ? eyeY - eye_step : 0.0f;
        if (Input.GetKeyDown(KeyCode.UpArrow))
            eyeY = eyeY >= 1.0f - eye_step ? 1.0f : eyeY + eye_step;
    }
    void DispText(int idx, float variable, string name)
    {
        string text = string.Format(name + " = {0}", variable);
        GUI.Label(new Rect(0, idx * 20, Screen.width, Screen.height), text);
    }
    void OnGUI()
    {
        int idx = 0;
        DispText(idx++, alpha, "alpha");
        DispText(idx++, sigma, "sigma");
        DispText(idx++, eyeX, "eyeX");
        DispText(idx++, eyeY, "eyeY");
    }
    public void SaveToFile(RenderTexture renderTexture, string name)
    {
        RenderTexture currentActiveRT = RenderTexture.active;
        RenderTexture.active = renderTexture;
        Texture2D tex = new Texture2D(renderTexture.width, renderTexture.height);
        tex.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
        var bytes = tex.EncodeToPNG();
        System.IO.File.WriteAllBytes(name, bytes);
        UnityEngine.Object.Destroy(tex);
        RenderTexture.active = currentActiveRT;
    }
}
