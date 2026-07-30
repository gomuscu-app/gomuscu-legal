#!/bin/sh
# Échoue si la page référence une ressource externe.
# Un LIEN hypertexte (<a href>) est autorisé : il n'émet aucune requête au chargement.
# Sont interdits : script, feuille de style externe, police distante, image distante, @import.
F=confidentialite/index.html
test -f "$F" || { echo "ÉCHEC : $F absent"; exit 1; }
if grep -nEi '<script|<link[^>]+stylesheet|@import|src=["'"'"']https?:|url\(https?:' "$F"; then
  echo "ÉCHEC : ressource externe ci-dessus"; exit 1
fi
echo "OK : page autonome"
