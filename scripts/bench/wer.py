import json, subprocess, os, sys, re, unicodedata
S=os.path.dirname(os.path.abspath(__file__))
CLI=f"{S}/FluidAudio/.build/release/fluidaudiocli"
items=json.load(open(f"{S}/corpus.json"))
def norm(t):
    t=unicodedata.normalize("NFKC",t).lower().replace("ё","е")
    t=re.sub(r"[^\w\s]"," ",t,flags=re.UNICODE)
    return [w for w in t.split() if w]
def wer(ref,hyp):
    r,h=norm(ref),norm(hyp)
    if not r: return (0.0,0,0)
    d=[[0]*(len(h)+1) for _ in range(len(r)+1)]
    for i in range(len(r)+1): d[i][0]=i
    for j in range(len(h)+1): d[0][j]=j
    for i in range(1,len(r)+1):
        for j in range(1,len(h)+1):
            d[i][j]=min(d[i-1][j]+1,d[i][j-1]+1,d[i-1][j-1]+(r[i-1]!=h[j-1]))
    return (d[len(r)][len(h)]/len(r), d[len(r)][len(h)], len(r))
out={}
tot_e=tot_n=0
for it in items:
    wav=f"{S}/corpus/{it['id']}.wav"
    r=subprocess.run([CLI,"transcribe",wav],capture_output=True)
    hyp=r.stdout.decode("utf-8","replace").strip()
    w,e,n=wer(it["text"],hyp); tot_e+=e; tot_n+=n
    out[it["id"]]={"ref":it["text"],"hyp":hyp,"wer":round(w,3),"err":e,"words":n}
    print(f"{it['id']} WER {w*100:5.1f}%  {hyp[:70]}")
agg=tot_e/tot_n
print(f"=== AGG WER {agg*100:.2f}%  ({tot_e} errors / {tot_n} words) ===")
json.dump({"agg_wer":agg,"errors":tot_e,"words":tot_n,"items":out},
          open(sys.argv[1],"w"),ensure_ascii=False,indent=1)
