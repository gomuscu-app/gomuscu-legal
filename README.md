# gomuscu-legal

Site de l'application iOS **Gomuscu**, servi par GitHub Pages sur <https://gomuscuapp.com> :
la vitrine à la racine, et les pages légales.

- `index.html` + `assets/` — la vitrine (page d'accueil, indexée) ; `assets/cookies.js` y gère le
  consentement et ne charge Google Analytics qu'après « Accepter »
- `mentions-legales/` — mentions légales du site, données et cookies, en `noindex`
- `confidentialite/` — politique de confidentialité **de l'app** (FR + EN), en `noindex`
- `support/` — page d'assistance (FR + EN), en `noindex`
- `robots.txt`, `sitemap.xml`, `llms.txt` — référencement ; le sitemap ne liste que la vitrine
- `check-autonomie.sh` — garde-fou : échoue si une page peut émettre une requête avant le consentement

Ce dépôt est **public** parce que GitHub Pages l'exige pour servir un site sans plan payant.
Il ne contient **que** ce site : le code source de l'application reste privé.

⚠️ **Aucune requête sortante avant le consentement.** Seule la vitrine mesure son audience (Google
Analytics 4, `G-M0FDVT393T`), et `assets/cookies.js` ne télécharge `gtag.js` qu'après « Accepter »
(mode « de base » du Consent Mode). Les autres pages — dont la politique de l'app et l'assistance,
qu'ouvrent l'app et App Store Connect — n'émettent **jamais** rien : ni script, ni police, ni feuille
de style distante. Ne **jamais** coller l'extrait fourni par Google dans le `<head>` : il chargerait
Google avant tout choix. `check-autonomie.sh` n'admet que deux balises `<script>`, sous forme
exacte : le JSON-LD de la vitrine (jamais exécuté) et `<script src="assets/cookies.js" defer></script>`,
sur la vitrine seulement ; dans un script, la seule adresse absolue admise est celle de `gtag.js`.
Jouer `./check-autonomie.sh` après toute modification ; le « après Accepter », lui, se vérifie au
navigateur (requêtes réseau et cookies, avant et après le choix).

L'app et le site ont deux politiques distinctes : `/confidentialite/` (l'app ne collecte rien) et
`/mentions-legales/#donnees` (le site, avec Google Analytics).

🛑 Jamais de `Disallow` dans `robots.txt` : il empêcherait les moteurs de lire le `noindex` des
pages légales.

## Tenir la vitrine à jour

- **Prix** (3,99 € / mois, 29,99 € / an, essai de 7 jours sur l'annuel) : écrits dans `index.html`
  — cartes Pro Mensuel et Pro Annuel (avec « soit 2,50 € par mois »), question « Gomuscu est-elle
  gratuite ? » et sa copie dans le JSON-LD — et dans `llms.txt`. La seule source est App Store
  Connect : les recopier à chaque changement de palier.
- **Réponses de la FAQ** : chaque texte existe deux fois, dans la page et dans le JSON-LD. Les
  garder identiques mot pour mot.
- **`sitemap.xml`** : mettre `lastmod` à la date de la modification.
- **Image de partage** (`assets/og.png`) : sa source vit dans le dépôt de l'application,
  `docs/marketing/vitrine/`.
- **Google Search Console** : la balise `google-site-verification` du `<head>` de `index.html`
  prouve la propriété de `https://gomuscuapp.com/` (préfixe d'URL). Ne jamais la retirer :
  Google la relit, et son absence fait perdre l'accès. Elle ne dépose rien, aucun consentement.
- **Google Analytics** : l'identifiant vit dans `assets/cookies.js` **et** dans le tableau des
  cookies de `mentions-legales/` (le cookie s'appelle `_ga_<identifiant sans G->`) : changer les deux.

Éditeur : Joris Jovancevic · contact@gomuscuapp.com
