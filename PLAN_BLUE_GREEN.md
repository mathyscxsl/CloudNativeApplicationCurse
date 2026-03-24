# PLAN_BLUE_GREEN.md – Stratégie de déploiement Blue/Green

## 1. Principe général

Le déploiement blue/green consiste à maintenir **deux environnements applicatifs identiques** :

- **Blue** : version actuellement en production, reçoit le trafic utilisateur
- **Green** : nouvelle version à déployer, inactive jusqu'à la bascule

Le **reverse proxy (Nginx)** décide vers qui router le trafic.  
La **base de données Postgres** est unique et partagée entre les deux couleurs.

```
[Client] --> [Reverse Proxy :80] --> [Blue]   (version active)
                                 \-> [Green]  (version candidate)
```

---

## 2. Organisation des fichiers Docker Compose

### Choix retenu : 3 fichiers de composition

| Fichier                   | Contenu                                              |
|---------------------------|------------------------------------------------------|
| `docker-compose.base.yml` | Postgres, seeder, reverse proxy Nginx                |
| `docker-compose.blue.yml` | `app-back-blue` (backend blue) + `app-front-blue`    |
| `docker-compose.green.yml`| `app-back-green` (backend green) + `app-front-green` |

### Pourquoi cette séparation ?

- La DB et le proxy sont des **composants d'infrastructure** — ils ne changent pas à chaque déploiement
- Blue et green sont des **instances applicatives** — on peut en lancer une sans toucher l'autre
- `docker compose -f base -f blue up -d` ne touche pas green et inversement

---

## 3. Strategy de routage Nginx

### Choix retenu : Option 1 — deux upstreams + fichier de config dynamique

```nginx
upstream app_blue  { server app-back-blue:3000;  }
upstream app_green { server app-back-green:3000; }
```

Un fichier `nginx/active_color.conf` (monté en volume) contient une seule ligne :

```nginx
# active_color.conf
proxy_pass http://app_blue;   # ou http://app_green
```

Ce fichier est inclus dans `nginx.conf` via `include /etc/nginx/active_color.conf;`.

**Pour basculer** : on remplace le contenu de `active_color.conf` puis on fait un `nginx -s reload` dans le conteneur — **sans downtime, sans redémarrer le proxy**.

### Pourquoi pas l'Option 2 (alias) ?

L'alias Docker (`app-active → blue/green`) nécessite de recréer le réseau pour prendre effet,
ce qui implique un redémarrage. La solution fichier de config + reload est plus fiable.

---

## 4. Commandes de déploiement

### Démarrage de l'infra de base
```bash
docker compose -f docker-compose.base.yml up -d
```

### Déploiement de la version blue (initial)
```bash
docker compose -f docker-compose.base.yml -f docker-compose.blue.yml up -d
```

### Déploiement d'une nouvelle version sur green
```bash
docker compose -f docker-compose.base.yml -f docker-compose.green.yml up -d
```

### Bascule du proxy vers green
```powershell
# scripts/switch.ps1 GREEN
```

### Rollback vers blue
```powershell
# scripts/switch.ps1 BLUE
```

---

## 5. Scénario complet de déploiement

| Étape | Action |
|-------|--------|
| 0 | Blue est en prod. Le trafic passe par blue. |
| 1 | CI build + push la nouvelle image tagguée avec le SHA |
| 2 | CI déploie la nouvelle version sur green (`docker compose ... green up -d`) |
| 3 | Green tourne mais ne reçoit pas de trafic |
| 4 | CI modifie `active_color.conf` → `proxy_pass http://app_green;` |
| 5 | CI exécute `docker exec reverse-proxy nginx -s reload` |
| 6 | Le trafic bascule vers green — **sans coupure** |
| 7 | Blue reste actif pour permettre un rollback immédiat |

### Rollback

Si green est défectueux :
1. Remettre `active_color.conf` → `proxy_pass http://app_blue;`
2. `docker exec reverse-proxy nginx -s reload`
3. Trafic retourne sur blue en quelques secondes

---

## 6. Où est stockée la couleur active ?

Dans le fichier `nginx/active_color.conf`, versionné dans le repo.  
Le pipeline lit ce fichier pour déterminer quelle couleur est active, et déploie sur l'autre.

---

## 7. Critère de validation

> La nouvelle version peut être déployée **sans arrêter l'ancienne**.  
> Le retour en arrière est **quasi instantané**
> Aucune donnée Postgres n'est perdue (DB partagée, jamais supprimée).
