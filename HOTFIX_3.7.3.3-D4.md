# Hotfix 3.7.3.3-D4

Le contrôle `Round()` analyse maintenant uniquement le code Basic exécutable.

Les commentaires et les chaînes de caractères sont ignorés. En cas de véritable
appel interdit, le rapport indique la ligne et le code source concerné dans
`forbidden_round_calls`.

Commande :

```bash
python3 tools/build_monolith.py
```
