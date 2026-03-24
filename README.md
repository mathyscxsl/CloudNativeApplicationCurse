# README.md du Projet

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=mathyscxsl_CloudNativeApplicationCurse&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=mathyscxsl_CloudNativeApplicationCurse)
![CI Status](https://github.com/mathyscxsl/CloudNativeApplicationCurse/actions/workflows/ci.yml/badge.svg)
![Docker Pulls Backend](https://img.shields.io/docker/pulls/maathbluee/cloudnative-backend.svg)
![Docker Pulls Frontend](https://img.shields.io/docker/pulls/maathbluee/cloudnative-frontend.svg)

---

Ce TP documente les règles Git, la convention de commit, les hooks activés dans ce dépôt, et présente l’application Gym Management System.

---

# ✔ TP1 Git & Workflow Rules

## ✔ Règles Git utilisées

- Branches principales : `main`, `develop`
- Branches de feature : `feature/<nom>` (ex. `feature/init-husky`)
- PR obligatoire vers `develop`
- Pas de commit direct sur `main` ou `develop`

## ✔ Convention de commit

Exemples :

- `feat: ajout de l’authentification`
- `fix: correction de la connexion Postgres`
- `chore: mise à jour des dépendances NestJS`

## ✔ Hooks actifs

- `pre-commit` : lint front + back
- `commit-msg` : vérification commitlint

---

# ✔ TP2 – CI, SonarCloud & Quality Gate

## 📸 Captures d’écran

### SonarCloud – Overview du projet

![SonarCloud Overview](docs/screenshots/sonar-dashboard.png)

### SonarCloud – Détails Quality Gate

![SonarCloud Not Computed Details](docs/screenshots/quality-gate.png)

### GitHub – Pull Request avec Quality Gate failed (Security Hotspots)

![PR Quality Gate Failed](docs/screenshots/quality-gate-failed-pr.png)

### GitHub – Tous les checks passent (CI build, lint, test, SonarCloud)

![PR Checks Passed](docs/screenshots/jobs-quality-gate-success.png)

### GitHub – Branch Protection Rules (main & develop)

![Branch Protection](docs/screenshots/regles-branches.png)

---

# ✔ TP3 – CI/CD Docker & Publication des images sur Docker Hub

### 🔐 Secrets utilisés

| Nom du Secret       | Utilité                  |
| ------------------- | ------------------------ |
| `DOCKER_USERNAME`   | Nom du compte Docker Hub |
| `DOCKER_PAT`        | Token d’accès Docker Hub |
| `SONAR_TOKEN`       | Analyseur SonarCloud     |
| `POSTGRES_PASSWORD` | CI + tests               |

### 🐳 Images générées et poussées

- `mathyscxsl/cloudnative-backend:latest`
- `mathyscxsl/cloudnative-backend:<sha>`
- `mathyscxsl/cloudnative-frontend:latest`
- `mathyscxsl/cloudnative-frontend:<sha>`

---

## 📸 Captures d’écran TP3 – Docker Hub

### Application

![Login](docs/screenshots/login.png)
![Dashboard](docs/screenshots/dashboard.png)

---

### Commande "docker compose ps"

![Commande docker compose ps](docs/screenshots/docker-compose-ps.png)

---

### Pipeline Docker

![Pipeline Docker](docs/screenshots/pipeline-docker.png)

---

### Docker Hub – Images poussées dans le registre (frontend)

![Registre Frontend](docs/screenshots/registre-front.png)

---

### Docker Hub – Images poussées dans le registre (backend)

![Registre Backend](docs/screenshots/registre-back.png)

---

# ✔ TP4 – Déploiement local automatisé

## 🔄 Déploiement local automatisé

### Fonctionnement

Le stage `deploy` est un job GitHub Actions distinct qui s'exécute automatiquement **après la publication des images Docker** dans le registre (Docker Hub).

Workflow complet :

```
build → test → lint → sonarcloud → build images → push registry → deploy
```

Le job `deploy` exécute le script `scripts/deploy.ps1` qui :

1. Arrête les conteneurs en cours (`docker compose down`) — **sans détruire les volumes Postgres**
2. Télécharge les nouvelles images depuis Docker Hub (`docker pull`)
3. Retag les images en `:latest`
4. Relance toute la stack (`docker compose up -d`)

### Conditions d'exécution

Pour que le deploiement s'enclenche automatiquement, les éléments suivants sont requis :

- **Un runner GitHub Actions self-hosted actif** sur la machine locale
- **Les secrets GitHub configurés** :
  - `DOCKER_USERNAME` — nom du compte Docker Hub
  - `DOCKER_PAT` — token d'accès Docker Hub
  - `SONAR_TOKEN` — pour l'analyse SonarCloud
  - `POSTGRES_PASSWORD` — pour les tests

### Dans quelles branches le déploiement est actif

- Le déploiement automatique ne s'exécute **que sur les PR vers `develop`**
- Cela correspond au workflow du TP : toute livraison validée sur `develop` déclenche le pipeline en entier jusqu'au redémarrage automatique de l'application

### Idempotence

Le script `scripts/deploy.ps1` peut être exécuté **autant de fois que nécessaire** sans risque :

- Aucun volume Postgres n'est supprimé (pas de `--volumes`)
- Aucune donnée n'est écrasée
- L'application redémarre toujours dans un état propre

---

## 📸 Captures d'écran TP4

### Pipeline complet jusqu'au stage deploy

![Pipeline Deploy](docs/screenshots/tp4-pipeline-deploy.png)

### Conteneurs relancés après déploiement

![Conteneurs Running](docs/screenshots/tp4-containers-running.png)

### Application accessible localement après déploiement

![Application Accessible](docs/screenshots/tp4-app-accessible.png)

### Images pull depuis le registre (`docker images`)

![Docker Images](docs/screenshots/tp4-docker-images.png)

---

# Gym Management System

A complete fullstack gym management application built with modern web technologies.

## Features

### User Features

- **User Dashboard**: View stats, billing, and recent bookings
- **Class Booking**: Book and cancel fitness classes
- **Subscription Management**: View subscription details and billing
- **Profile Management**: Update personal information

### Admin Features

- **Admin Dashboard**: Overview of gym statistics and revenue
- **User Management**: CRUD operations for users
- **Class Management**: Create, update, and delete fitness classes
- **Booking Management**: View and manage all bookings
- **Subscription Management**: Manage user subscriptions

### Business Logic

- **Capacity Management**: Classes have maximum capacity limits
- **Time Conflict Prevention**: Users cannot book overlapping classes
- **Cancellation Policy**: 2-hour cancellation policy
- **Billing System**: Dynamic pricing with no-show penalties
- **Subscription Types**: Standard (€30), Premium (€50), Student (€20)

## Tech Stack

### Backend

- Node.js + Express.js
- Prisma ORM + PostgreSQL
- MVC + Repository pattern

### Frontend

- Vue.js 3
- Pinia
- Vue Router
- Responsive CSS

### DevOps

- Docker
- Docker Compose
- PostgreSQL
- Nginx

---

# Quick Start

Instructions d’installation et exécution (inchangées)...

---

# Contributing

1. Fork
2. Branch feature
3. PR
4. Tests
5. Merge

---

# License

MIT

---

# Support

Pour toute question, merci d’ouvrir une issue.
