# gomuscu-legal

Site de l'application iOS **Gomuscu**, servi par GitHub Pages sur <https://gomuscuapp.com> :
la vitrine à la racine, et les pages légales.

- `index.html` + `assets/` — la vitrine (page d'accueil, indexée)
- `confidentialite/` — politique de confidentialité (FR + EN), en `noindex`
- `support/` — page d'assistance (FR + EN), en `noindex`
- `robots.txt`, `sitemap.xml`, `llms.txt` — référencement ; le sitemap ne liste que la vitrine
- `check-autonomie.sh` — garde-fou : échoue si une page acquiert une ressource externe

Ce dépôt est **public** parce que GitHub Pages l'exige pour servir un site sans plan payant.
Il ne contient **que** ce site : le code source de l'application reste privé.

⚠️ Aucune page ne doit **jamais** émettre de requête sortante — ni script, ni police, ni feuille de
style distante, ni mesure d'audience. Une politique de confidentialité qui pisterait son lecteur se
contredirait elle-même, et la vitrine l'affiche : « Ce site ne dépose aucun cookie et ne mesure pas
son audience. » Seule exception, exacte : le bloc de données structurées
`<script type="application/ld+json">` de la vitrine, qu'un navigateur n'exécute jamais.
Jouer `./check-autonomie.sh` après toute modification.

🛑 Jamais de `Disallow` dans `robots.txt` : il empêcherait les moteurs de lire le `noindex` des
pages légales.

## Tenir la vitrine à jour

- **Prix** (3,99 € / mois, 29,99 € / an, essai de 7 jours sur l'annuel) : écrits dans `index.html`
  — carte Pro, question « Gomuscu est-elle gratuite ? » et sa copie dans le JSON-LD — et dans
  `llms.txt`. La seule source est App Store Connect : les recopier à chaque changement de palier.
- **Réponses de la FAQ** : chaque texte existe deux fois, dans la page et dans le JSON-LD. Les
  garder identiques mot pour mot.
- **`sitemap.xml`** : mettre `lastmod` à la date de la modification.
- **Image de partage** (`assets/og.png`) : sa source vit dans le dépôt de l'application,
  `docs/marketing/vitrine/`.

Éditeur : Joris Jovancevic · contact@gomuscuapp.com
