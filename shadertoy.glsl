/* quad vertex shader */
@vs vs
in vec4 position;
in vec4 color0;
out vec4 color;

///////////////////
///== UNIFORM ==///
uniform vs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec3 iResolution; // viewport resolution (in pixels)
   float iTime;      // shader playback time (in seconds)
   float iTimeDelta; // render time (in seconds)
   float iFrameRate; // shader frame rate
   //int   iFrame;   // shader playback frame
   //float iChannelTime[4];
   //vec3  iChannelResolution[4];
   //samplerXX iChannel0..3;
   //vec4 iDate        //(year, month, day, time in seconds)
};

void main() {
    gl_Position = position;
    color = color0;
}
@end

/* quad fragment shader */
@fs fs
///////////////////
///== UNIFORM ==///
uniform fs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec3 iResolution; // viewport resolution (in pixels)
   float iTime;      // shader playback time (in seconds)
   float iTimeDelta; // render time (in seconds)
   float iFrameRate; // shader frame rate
   //int   iFrame;   // shader playback frame
   //float iChannelTime[4];
   //vec3  iChannelResolution[4];
   //samplerXX iChannel0..3;
   //vec4 iDate        //(year, month, day, time in seconds)
};

in vec4 color;
out vec4 frag_color;


/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////
/////////////////////////////

// Cette macro génère des couleurs basées sur le cosinus d'une valeur, qui change au fil du temps
#define cor(a) (cos(a * 6.3 + vec4(0, 23, 21, 0)) * 0.5 + 0.5)

// Cette macro génère une matrice de rotation 2D pour faire pivoter un vecteur autour de l'origine
#define rot(a) mat2(cos(a + vec4(0, 11, 33, 0)))

// Temps du shader
#define t iTime

// Fonction qui définit la forme d'un tore (une sorte de beignet 3D)
float torus(vec3 q) {
    return length(
        vec2(
            length(q.xy) - 0.6                          // Distance radiale dans le plan XY réduite de 0.6
            - tanh(cos(atan(q.x, q.y) * 5.0) * 2.0)     // Torsion ajoutée pour distordre le tore
            * 0.08,                                     // Ajustement de la torsion
            q.z                                         // Composante Z (hauteur)
        )
    ) - 0.09;                                           // Épaisseur du tore
}

// Fonction qui applique des rotations 2D à l'objet en fonction du temps
void rotObj(inout vec3 p) {
    // Rotation sur le plan YZ avec un facteur dépendant du temps
    p.yz *= rot(tanh(cos(t * 1.3) * 4.0 - 3.0)); 
    // Rotation sur le plan XY avec un autre facteur temporel
    p.xy *= rot(tanh(cos(t * 1.2) * 3.0) * 0.7);
}

// Fonction de "distance" qui mappe la position dans l'espace 3D à un objet
float map(vec3 p) {
    rotObj(p);  // Applique des rotations à l'objet

    vec3 q;     // Copie temporaire de p
    float s = 1.0, j = 0.0, d = 0.0; // Variables pour la boucle

    // Boucle qui génère plusieurs couches de l'objet
    while(j++ < 5.0) {
        q = p;  // Reinitialise q à chaque itération
        q.xy *= rot(j * 6.28 / 5.0); // Rotation XY avec un angle basé sur j
        q.xz *= rot(6.28 / 6.0);     // Rotation XZ avec un angle fixe

        // Calcule la distance au tore
        d = torus(q); 

        // Si on est dans les premières itérations, on prend la distance normale, sinon on prend la valeur absolue
        d = j < 4.0 ? d : abs(d); 

        // On garde la plus petite distance à l'objet (s est donc la surface visible la plus proche)
        s = min(s, d);
    }
    return s;  // Renvoie la distance la plus proche de l'objet
}




void main() {
    frag_color = color;
    frag_color.x += iTime;

    vec4 o;
    vec2 u = color.xy * iResolution.xy;
    //////////////////
    //////////////////
    
     float d = 0.0, layers, s = 0.0, i = 0.0, b = 0.0;
    float t = iTime;

    vec2 r = iResolution.xy;
    u = (u - r * 0.5) / r.y;  // Centre l'écran et normalise les coordonnées

    // Vecteur directionnel D normalisé, à partir de u et la profondeur de la caméra (z=1)
    vec3 D = normalize(vec3(u, 1.0)), p;

    // Initialiser la couleur de sortie à 0 (noir)
    o *= 0.0;

    // Boucle de raymarching (trace des rayons à travers la scène)
    while(i++ < 55.0) {
        // Appelle la fonction map pour déterminer la distance la plus proche à l'objet
        s = map(p);
        
        // Avance dans la direction du rayon d'une distance dépendant de s
        // max(s, 2e-3) => Si s est trop petit, on le limite à 0.002 pour éviter de rester coincé
        d += max(s, 0.002) * 0.6;  

        // Met à jour la position du rayon
        p = d * D;
        p.z += -1.8;  // Translation vers l'arrière (profondeur)

        // Si la distance s est petite, on considère que le rayon frappe l'objet
        if (s < 0.02) {
            // Calcule la contribution à la couleur basée sur la distance et la profondeur
            o += (0.01 - s) / d * i / 41.0 + cor(i / 25.0) / 75.0;
        }
    }
    
    
    /////////////////
    /////////////////
    frag_color=o;
   // frag_color.xy=color.xy;
   //frag_color.x=color.x;
    
}
@end

/* quad shader program */
@program quad vs fs

