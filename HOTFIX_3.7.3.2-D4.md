# Hotfix 3.7.3.2-D4

Le correctif précédent n'avait pas modifié la ligne `ROUND_RE`.

La ligne effective est maintenant :

```python
ROUND_RE = re.compile(r"(?<![A-Za-z0-9_])Round\s*\(", re.IGNORECASE)
```

Cette expression :

- détecte `Round(...)` ;
- ne détecte pas `CF_RoundCompat(...)` ;
- ne détecte pas un identifiant dont `Round` est seulement un suffixe.
