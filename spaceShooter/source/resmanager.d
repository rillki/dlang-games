module resmanager;

import raylib;

import data: getFullPath, mainPath, test;

// Singleton
class ResManager(T) {
    private static ResManager instance;                     // instance
    private static bool initialized = false;

    // associative array
    private T[string] list;

    private this() {}

    ~this() {
        freeAll();                                          // free all resources
    }

    // function for freeing/unloading resources
    T function(const string filepath) loadResource;
    void function(T t) unloadResource;

    // creating an instance of ResManager, if the function is called for the first time
    static ResManager getInstance() {
        if(!initialized) {
            instance = new ResManager();
            initialized = true;
        }

        return instance;
    }

    // initializes the respective function for freeing resources of type T
    void init(T function(const string filepath) loadResource, void function(T t) unloadResource) {
        this.loadResource = loadResource;
        this.unloadResource = unloadResource;
    }

    // optional: loads up all textures and assigns
    // respective keys from a file(csv, txt): key,filepath
    void loadFromFile(const string filepath) {
        import std.stdio: File;
        import std.algorithm.iteration: joiner;
        import std.csv: csvReader;
        import std.typecons: Tuple;

        File file = File(getFullPath(filepath), "r");
        Tuple!(string, string)[] data;

        foreach(record; file.byLine.joiner("\n").csvReader!(Tuple!(string, string))) {
            add(record[1], record[0]);
        }
    }

    // both init and initByFile
    void initAndLoadFromFile(const string filepath, T function(const string filepath) loadResource, void function(T t) unloadResource) {
        init(loadResource, unloadResource);
        loadFromFile(filepath);
    }

    // adding an element
    void add(const string filepath, const string key) {
        import std.string: toStringz;

        if((key in list) !is null) {                         // quick look-up, if key doesn't exist, then = null, we can continue
            return;                                         // if it != null, then the key already exists
        }

        list[key] = loadResource(getFullPath(filepath));
    }

    // remove an element
    void remove(const string key) {
        if((key in list) is null) {
            return;
        }

        list.remove(key);
    }

    // free and remove an element
    void freeRemove(const string key) {
        if((key in list) is null) {
            return;
        }

        unloadResource(list[key]);
        list.remove(key);
    }

    // return an element by key
    T get(const string key) {
        import std.conv: text;

        if(!test((key in list) !is null, text("ERROR: texture => [", key, "] key does not exist!"))) {
            return T();
        }

        return list[key];
    }

    // free all resources
    void freeAll() {
        foreach(ref l; list) {
            unloadResource(l);
        }
    }
}

//*********LOAD / UNLOAD FUNCTIONS*********//

// FONT
Font loadFont(const string filepath) {
    import std.string: toStringz;
    return LoadFont(filepath.toStringz);
}

void unloadFont(Font f) {
    UnloadFont(f);
}

// TEXTURE
Texture2D loadTexture(const string filepath) {
    import std.string: toStringz;
    return LoadTexture(filepath.toStringz);
}

void unloadTexture(Texture t) {
    UnloadTexture(t);
}
