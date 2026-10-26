import r25_import as ri, animset, struct, math, itertools
K6=2.1580503016593866e-05
def dec6(k):
    w0,w1,w2=struct.unpack("<3H",k); v=(w0<<32)|(w1<<16)|w2
    def f(v):
        t=(v&0xffff)*2&0xffff; return (t-0x10000 if t&0x8000 else t)*K6
    a=f(v); v>>=15; b=f(v); v>>=15; c=f(v); v>>=15
    idx=v&3; neg=(v>>2)&1; w=math.sqrt(max(0,1-a*a-b*b-c*c)); w=-w if neg else w
    return {3:(c,b,a,w),2:(c,b,w,a),1:(c,w,b,a),0:(w,c,b,a)}[idx]
def dect6(k,a): return tuple(((u&0x7fff)/32767*a)*(1 if u&0x8000 else -1) for u in struct.unpack("<3H",k))
def tracks(raw,a,clipname):
    names=a.names()
    for c in a.clips:
        if a.clip_name(c)!=clipname: continue
        dur,ntr,n2,N,stride=struct.unpack_from("<fHHHH",c.head,0); out={}
        for i in range(ntr):
            aa,b,j,k,e,z=struct.unpack_from("<IHHHHI",raw,c.streams[3]+i*16)
            sc=struct.unpack('<f',struct.pack('<I',aa))[0]
            vals=[]
            for f in range(N):
                kb=raw[c.streams[0]+f*stride+b:c.streams[0]+f*stride+b+(e&0xff)]
                if k==1: vals.append(struct.unpack("<4f",kb) if (e&0xff)==16 else dec6(kb))
                elif k==2: vals.append(struct.unpack("<3f",kb[:12]) if (e&0xff)==16 else dect6(kb,sc) if (e&0xff)==6 else None)
            out[(names[j] if j<len(names) else j,k)]=(e,vals)
        return c,out
def mirname(n):
    if n.startswith("left"): return "right"+n[4:]
    if n.startswith("right"): return "left"+n[5:]
    if n.startswith("worldleft"): return "worldright"+n[9:]
    if n.startswith("worldright"): return "worldleft"+n[10:]
    return n
