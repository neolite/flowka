import json, subprocess, os
S=os.path.dirname(os.path.abspath(__file__))
D=os.path.join(S,"corpus"); os.makedirs(D, exist_ok=True)
items=json.load(open(os.path.join(S,"corpus.json")))
for it in items:
    aiff=os.path.join(D, it["id"]+".aiff"); wav=os.path.join(D, it["id"]+".wav")
    subprocess.run(["say","-v",it["voice"],"-o",aiff,it["text"]],check=True)
    subprocess.run(["afconvert","-f","WAVE","-d","LEI16@16000","-c","1",aiff,wav],check=True)
    os.remove(aiff)
print(f"generated {len(items)} clips")
