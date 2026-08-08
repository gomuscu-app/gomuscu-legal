# gomuscu-legal

Pages légales de l'application iOS **Gomuscu**, servies par GitHub Pages sur
<https://gomuscuapp.com>.

- `confidentialite/` — politique de confidentialité (FR + EN)
- `check-autonomie.sh` — garde-fou : échoue si la page acquiert une ressource externe

Ce dépôt est **public** parce que GitHub Pages l'exige pour servir un site sans plan payant.
Il ne contient **que** ces pages : le code source de l'application reste privé.

⚠️ La page ne doit **jamais** émettre de requête sortante — ni script, ni police, ni feuille de style
distante. Une politique de confidentialité qui pisterait son lecteur se contredirait elle-même.
Jouer `./check-autonomie.sh` après toute modification.

Éditeur : Joris Jovancevic · contact@gomuscuapp.com
