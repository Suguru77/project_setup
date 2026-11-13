# snapshot_guard_usage.md

## Pourquoi un wrapper ?
Le `snapshot_guard.py` est le seul moyen autorisé d’interagir avec le système de version (interdiction de `git`). Il fournit des commandes sûres : `--add`, `--commit`, `--status`, `--log`.

## Mapping des commandes Git classiques
| Action Git | Commande `snapshot_guard.py` équivalente |
|------------|------------------------------------------|
| `git add <file>` | `snapshot_guard.py --add "<file>"` |
| `git commit -m "msg"` | `snapshot_guard.py --commit "msg"` |
| `git status` | `snapshot_guard.py --status` |
| `git log` | `snapshot_guard.py --log` |
| `git diff` | `snapshot_guard.py --diff` |

## Exemple d’utilisation dans un workflow CI
```powershell
# Ajouter les nouveaux fichiers de configuration
snapshot_guard.py --add "project_setup/utf8_bootstrap.py"
snapshot_guard.py --add "project_setup/redteam_checklist.md"
# Committer avec un message explicite
snapshot_guard.py --commit "Add UTF‑8 bootstrap and Red‑Team checklist"
# Vérifier l’état avant le build
snapshot_guard.py --status
```

> **Rappel** : chaque fois que vous modifiez un fichier versionné, passez obligatoirement par ce wrapper pour que le `system_health_watchdog.py` puisse valider l’intégrité.
