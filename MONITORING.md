# MONITORING.md – Observabilité de l'application Gym Management

## 1. Concepts fondamentaux

### Monitoring vs Observabilité

| Monitoring | Observabilité |
|---|---|
| Surveiller des métriques connues à l'avance | Comprendre l'état interne d'un système depuis ses sorties |
| Réactif : alertes sur seuils | Proactif : comprendre *pourquoi* quelque chose se passe |
| "Est-ce que ça marche ?" | "Pourquoi est-ce que ça ne marche pas ?" |

### Les 3 piliers de l'observabilité

- **Métriques** : données numériques agrégées dans le temps (CPU, latence, nombre de requêtes)
- **Logs** : événements textuels horodatés produits par l'application
- **Traces** : suivi du parcours d'une requête à travers les services (non implémenté ici)

---

## 2. Rôle de chaque composant

| Composant | Rôle |
|---|---|
| **Prometheus** | Scrape (tire) les métriques depuis les endpoints `/metrics` exposés par les services. Stocke les séries temporelles en local. |
| **Grafana** | Interface de visualisation. Lit Prometheus (métriques) et Loki (logs). Permet de créer des dashboards. |
| **Loki** | Base de données de logs. Indexe uniquement les labels (pas le contenu), très léger. |
| **Promtail** | Agent de collecte de logs. Lit les fichiers de logs Docker, les étiquette et les envoie à Loki. |

---

## 3. Architecture globale

```
┌─────────────────────────────────────────────────────────────────┐
│                        STACK APPLICATIVE                        │
│                                                                  │
│   [app-back-blue:3000]  ──/metrics──>  [Prometheus:9090]        │
│   [app-back-green:3000] ──/metrics──>       │                   │
│                                             │                   │
│   [Docker containers]  ──logs──>  [Promtail] ──> [Loki:3100]   │
│                                                        │        │
│                                             [Grafana:3000]      │
│                                          reads ↑       ↑ reads  │
│                                       Prometheus      Loki      │
└─────────────────────────────────────────────────────────────────┘
```

**Flux des données :**

1. Le backend NestJS expose `/metrics` (format Prometheus)
2. Prometheus scrape `/metrics` toutes les 15 secondes
3. Les conteneurs Docker écrivent leurs logs sur stdout
4. Promtail lit les logs Docker via le socket Docker
5. Promtail envoie les logs à Loki
6. Grafana interroge Prometheus (métriques) et Loki (logs) pour construire les dashboards

---

## 4. Ports d'exécution

| Service | Port | URL |
|---|---|---|
| Grafana | 3030 | http://localhost:3030 |
| Prometheus | 9090 | http://localhost:9090 |
| Loki | 3100 | interne uniquement |
| Promtail | — | pas d'UI |
| Backend `/metrics` | 3000 | http://localhost:3000/metrics |

> Grafana est sur le port **3030** pour éviter le conflit avec le backend (3000).

---

## 5. Intégration avec l'application

Le backend Express expose un endpoint `/metrics` qui retourne les métriques au format **Prometheus text** via la librairie `prom-client` :

- `http_requests_total` : compteur de toutes les requêtes HTTP par méthode et route
- `http_request_duration_seconds` : histogramme de la durée des requêtes
- `nodejs_heap_size_used_bytes` : mémoire Node.js utilisée
- métriques par défaut Node.js (CPU, event loop, GC…)

Prometheus est configuré pour scraper le backend blue et green.  
Promtail collecte les logs de tous les conteneurs Docker via le socket Docker.
