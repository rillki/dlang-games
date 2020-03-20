module texturemanager;

import raylib;

// Singleton
class TextureManager {
    private static TextureManager tmanager_instance;        // instance
    private Texture[string] tex;                            // associative array

    private static bool initSuccess = false;

    private this() {}

    ~this() {
        forceDeleteAll();                                   // mem clean up
    }

    // creating an instance of TextureManager, if the function is called for the first time
    public static TextureManager getInstance() {
        if(!initSuccess) {
             tmanager_instance = new TextureManager();
             initSuccess = true;
        }

        return tmanager_instance;
    }

    // adding a texture
    public void add(const char* path, string id) {
        Texture2D* temp = (id in tex);                      // quick look-up, if id doesn't exist, then temp = null
        if(temp !is null) {
            return;
        }

        tex[id] = LoadTexture(path);
    }

    // removing a texture
    public bool deleteFromMemory(string id) {
        return tex.remove(id);
    }

    // return a texture by id
    public Texture2D get(string id) {
        return tex[id];
    }

    // force remove all
    public void forceDeleteAll() {
        foreach(ref t; tex) {
            UnloadTexture(t);
        }
    }
}
