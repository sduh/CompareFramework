# Hotfix 3.7.3.1-D4 — Détection de Round()

## Cause

L'expression régulière :

```python
r"\bRound\s*\("
```

détectait aussi le suffixe `Round(` dans `CF_RoundCompat(`.

## Correction

Le contrôle utilise désormais :

```python
r"(?<![A-Za-z0-9_])Round\s*\("
```

Il bloque le vrai appel `Round(...)`, mais accepte `CF_RoundCompat(...)`.

## Test

Depuis la racine du dépôt :

```bash
python3 tools/build_monolith.py
```
