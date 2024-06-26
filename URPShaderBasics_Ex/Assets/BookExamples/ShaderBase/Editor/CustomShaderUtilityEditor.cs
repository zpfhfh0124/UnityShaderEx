using UnityEditor;

public class CustomShaderUtilityEditor : Editor
{
    // ������Ƽ �迭���� �̸����� �ε��� ����
    public static int GetPropertyIndex(MaterialProperty[] properties, string name)
    {
        for (int i = 0; i < properties.Length; i++)
        {
            if (properties[i].name == name)
                return i;
        }
        return -1; // ���� ������ ������ -1 ����
    }
}
