"""Architecture analyzer entrypoint."""
from .parser import parse_repository
from .analyzer import analyze
from .reports import generate_reports

def main():
    model=parse_repository()
    results=analyze(model)
    generate_reports(results)

if __name__=="__main__":
    main()
