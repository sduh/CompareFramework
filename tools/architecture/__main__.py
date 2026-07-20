from .engine import run
if __name__=="__main__":
    d=run()
    print(f"Generated architecture.json for {d['statistics']['module_count']} modules.")
