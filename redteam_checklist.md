# redteam_checklist.md – Checklist de revue contradictoire

## Objectif
Effectuer une revue Red‑Team systématique avant toute décision critique ou chaque itération de code afin de satisfaire le Commandement 2.

## Étapes
1. **Définir les perspectives d’attaquant**
   - *Attaque externe* (exfiltration, injection)
   - *Attaque interne* (privilege escalation, data leakage)
   - *Attaque modèle* (adversarial prompt, data poisoning)
2. **Lister les invariants du système** (ex. `no git usage`, `UTF‑8 enforced`).
3. **Vérifier chaque invariant** – cochez ✅ si respecté, ❌ sinon.
4. **Documenter les écarts** – notez le risque, la gravité et le plan de mitigation.
5. **Post‑mortem** – en cas d’échec d’un outil (≥ 3 fois), rédigez un court rapport (cause, actions correctives) avant de ré‑exécuter.

## Exemple de tableau
| Invariant | ✅/❌ | Commentaire |
|-----------|------|-------------|
| Aucun appel `git` | ✅ | Utilisation du `snapshot_guard.py` uniquement |
| UTF‑8 boot‑strap appliqué | ✅ | `utf8_bootstrap.py` importé |
| Red‑Team effectué | ❌ | À réaliser avant le merge |

> **Note** : Conservez ce fichier au root du projet (`/redteam_checklist.md`). Ajoutez‑le dans le workflow CI pour bloquer le merge si la case « Red‑Team effectué » reste ❌.
