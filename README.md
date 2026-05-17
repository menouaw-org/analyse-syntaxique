# Analyse syntaxique

Outil Bash d’analyse de logs Apache. Il extrait les entrées `error` et `notice`, permet de filtrer les résultats, détecte les accès refusés et produit une sortie CSV exploitable.

## Prérequis

- Docker
- Docker Compose

## Lancer l’environnement

```bash
docker compose run --rm analyse
```

Le projet est monté dans le conteneur sous `/workspace`.

## Utilisation

Rendre le script exécutable:

```bash
chmod +x scripts/analyse_logs.sh
```

Lancer l’analyse:

```bash
./scripts/analyse_logs.sh logs/apache_sample.log all
./scripts/analyse_logs.sh logs/apache_sample.log error
./scripts/analyse_logs.sh logs/apache_sample.log notice
```

Modes disponibles:

- `all`: affiche les entrées `error` et `notice`;
- `error`: affiche uniquement les erreurs;
- `notice`: affiche uniquement les notices.

## Export CSV

Le script écrit le résultat sur la sortie standard. Pour générer un fichier CSV:

```bash
mkdir -p exports
./scripts/analyse_logs.sh logs/apache_sample.log all > exports/analyse_logs.csv
```

Format de sortie:

```
timestamp;type;message;is_forbidden;client_ip
```

## Vérifications utiles

```bash
bash -n scripts/analyse_logs.sh
grep "\[error\]" logs/apache_sample.log
grep "\[notice\]" logs/apache_sample.log
grep "Directory index forbidden by rule" logs/apache_sample.log
```