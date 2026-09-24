#!/bin/sh
# Échoue si UNE page référence une ressource externe.
# Un LIEN hypertexte (<a href>) est autorisé : il n'émet aucune requête au chargement.
# Sont interdits : script, feuille de style externe, police distante, image distante, @import.
#
# Une seule exception, et elle est exacte : l'ouverture `<script type="application/ld+json">`
# (données structurées pour les moteurs de recherche, sur la vitrine). Ce type n'est jamais
# exécuté par un navigateur, il ne peut donc émettre aucune requête. On l'efface du texte AVANT
# le balayage : tout autre `<script` — module, src, casse différente, attribut en plus — reste
# refusé, y compris un second `<script>` caché derrière un bloc JSON-LD.
#
# ⚠️ Ce script balaie TOUTES les pages et ne cite plus aucun chemin en dur : la version
# précédente ne regardait que confidentialite/index.html et aurait rendu « OK : page autonome »
# sans avoir jamais ouvert support/. Un garde-fou qui ignore une page neuve est pire que pas de
# garde-fou — il se lit comme un vert.
set -u

PAGES=$(find . -name '*.html' -not -path './.git/*' | sort)

# Un balayage qui ne trouve rien doit ROUGIR, pas féliciter : sinon un mauvais répertoire de
# travail ou un dépôt vide rendraient un vert qui ne prouve rien.
if [ -z "$PAGES" ]; then
  echo "ÉCHEC : aucune page .html trouvée — le contrôle n'a rien vérifié"
  exit 1
fi

FAIL=0
for F in $PAGES; do
  if sed 's#<script type="application/ld+json">##g' "$F" \
     | grep -nEi '<script|<link[^>]+stylesheet|@import|src=["'"'"']https?:|url\(https?:'; then
    echo "ÉCHEC : ressource externe ci-dessus, dans $F"
    FAIL=1
  fi
done

[ "$FAIL" -eq 0 ] || exit 1

echo "OK : pages autonomes ($(echo "$PAGES" | wc -l | tr -d ' ') vérifiées)"
echo "$PAGES" | sed 's/^/  /'
