#define PI 3.141592653
#define TMIN 0.1
#define TMAX 20.
#define RAYMARCH_STEP 128
#define PRECISION .001
#define AA 3
vec2 fixuv(vec2 c)
{
    return 1.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}

float sdfSphere(in vec3 p)
{
    return length(p-vec3(0.0,0.0,2.0))-1.5;
}

float raymarch(in vec3 ro ,in vec3 rd)
{
    float t=TMIN;
    for(int i=0;i<RAYMARCH_STEP&&t<TMAX;i++)
    {
        vec3 ray=ro+t*rd;
        float d=sdfSphere(ray);
        if(d<PRECISION)
        {
            break;
        }
        // if(t>=TMAX)
        // {
        //     break;
        // }
        t+=d;
    }
    return t;
}

vec3 calcNormal(in vec3 p)
{
    const float h=0.0001;
    const vec2 k=vec2(1,-1);
    return normalize( k.xyy*sdfSphere( p + k.xyy*h ) + 
                      k.yyx*sdfSphere( p + k.yyx*h ) + 
                      k.yxy*sdfSphere( p + k.yxy*h ) + 
                      k.xxx*sdfSphere( p + k.xxx*h ) );
}
vec3 render(vec2 uv)
{
    vec3 color=vec3(0.0);
    vec3 ro =vec3(0.,0.,-1.5);
    vec3 rd=normalize(vec3(uv,0.0)-ro);
    float t=raymarch(ro,rd);
    // color=vec3(smoothstep(TMAX,TMIN,t));
    if(t<TMAX)
    {
        vec3 p=ro+t*rd;
        vec3 n=calcNormal(p);
        vec3 light=vec3(cos(iTime),2.0,sin(iTime));
        float diff=clamp(dot(normalize(light-p),n),0.,1.);
        float amb=0.5;
        color=amb*vec3(0.25,0.23,0.23)+diff*vec3(1.0);

    }
    // if(t<TMAX)
    // {
    //     color=vec3(1.0);
    // }
    return sqrt(color);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec3 color=vec3(0.0);
    for(int m=0;m<AA;m++)
    {
        for(int n=0;n<AA;n++)
        {
            vec2 offset=2.0*(vec2(float(m),float(n))/float(AA)-0.5);
            vec2 uv=fixuv(fragCoord+offset);
            color+=render(uv);
        }
    }

    fragColor=vec4(color/float(AA*AA),1.0);
}