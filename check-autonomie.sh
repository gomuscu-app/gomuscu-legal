#!/bin/sh
# Garde-fou de gomuscuapp.com — règle : AUCUNE requête sortante avant le consentement.
#
# Pages (*.html) : aucune ressource externe dans le HTML — script, feuille de style, police ou
# image distante, @import, url(…) distante, <link> distant (préchargement, préconnexion, icône…).
# Un LIEN hypertexte (<a href>) reste permis, comme <link rel="canonical"> et
# <link rel="alternate"> : ils n'émettent rien au chargement.
#
# Deux balises <script> seulement, chacune sous une forme EXACTE, effacée du texte AVANT le
# balayage — toute autre forme (module, casse différente, attribut en plus) reste refusée :
#   · `<script type="application/ld+json">` : données structurées, jamais exécutées ; partout ;
#   · cookies.js, la mesure d'audience après consentement, sur la vitrine et le blog SEULEMENT :
#     `<script src="assets/cookies.js" defer></script>` sur ./index.html,
#     `<script src="/assets/cookies.js" defer></script>` sur ./blog/ (chemin absolu, comme toutes
#     ses ressources ; depuis le 2026-10-07). Chaque forme ne vaut que là : posée ailleurs — pages
#     légales et assistance, qu'ouvrent l'app et App Store Connect —, elle est refusée comme
#     n'importe quel script.
#
# Scripts (*.js) : la seule adresse absolue admise est celle de gtag.js, que cookies.js ne charge
# qu'après « Accepter ». Ce « après » ne se prouve pas par grep : il se vérifie au navigateur
# (requêtes et cookies avant et après le choix — spec du 2026-09-28, dépôt de l'app, A3 à A7).
#
# ⚠️ Balaie TOUTES les pages et TOUS les scripts du répertoire COURANT, sans chemin en dur : un
# garde-fou qui ignore un fichier neuf est pire que pas de garde-fou — il se lit comme un vert.
# Le répertoire courant est voulu : pour contrôler le site EN LIGNE, y télécharger les fichiers
# servis (mêmes chemins) et lancer ce script depuis là.
set -u

PAGES=$(find . -name '*.html' -not -path './.git/*' | sort)
SCRIPTS=$(find . -name '*.js' -not -path './.git/*' | sort)

# Un balayage qui ne trouve rien doit ROUGIR, pas féliciter : sinon un mauvais répertoire de
# travail ou un dépôt vide rendraient un vert qui ne prouve rien.
if [ -z "$PAGES" ]; then
  echo "ÉCHEC : aucune page .html trouvée — le contrôle n'a rien vérifié"
  exit 1
fi

JSONLD='<script type="application/ld+json">'
COOKIES_VITRINE='<script src="assets/cookies\.js" defer></script>'
COOKIES_BLOG='<script src="/assets/cookies\.js" defer></script>'
MOTIF="<script|<link[^>]+(stylesheet|href=[\"']?https?:)|@import|(src|srcset|poster)=([\"'][^\"']*)?https?:|[[:space:]]data=[\"']https?:|url\\([\"']?https?:"

FAIL=0
for F in $PAGES; do
  case "$F" in
    ./index.html) TEXTE=$(sed -e "s#$JSONLD##g" -e "s#$COOKIES_VITRINE##g" "$F") ;;
    ./blog/*)     TEXTE=$(sed -e "s#$JSONLD##g" -e "s#$COOKIES_BLOG##g" "$F") ;;
    *)            TEXTE=$(sed -e "s#$JSONLD##g" "$F") ;;
  esac
  TEXTE=$(printf '%s\n' "$TEXTE" | sed -E 's#<link rel="(canonical|alternate)"[^>]*>##g')
  if printf '%s\n' "$TEXTE" | grep -nEi "$MOTIF"; then
    echo "ÉCHEC : ressource externe ci-dessus, dans $F"
    FAIL=1
  fi
done

for J in $SCRIPTS; do
  if grep -noE "https?://[^\"'[:space:])]*" "$J" \
     | grep -vE '^[0-9]+:https://www\.googletagmanager\.com/gtag/js(\?|$)'; then
    echo "ÉCHEC : adresse externe non admise ci-dessus, dans $J"
    FAIL=1
  fi
  if grep -nE "[\"'\`]//[A-Za-z0-9]" "$J"; then
    echo "ÉCHEC : adresse sans protocole (//hôte) ci-dessus, dans $J"
    FAIL=1
  fi
done

if [ ! -f ./assets/cookies.js ] && grep -lE 'src="/?assets/cookies\.js"' $PAGES; then
  echo "ÉCHEC : les pages ci-dessus chargent assets/cookies.js, qui n'existe pas"
  FAIL=1
fi

[ "$FAIL" -eq 0 ] || exit 1

NB_PAGES=$(printf '%s\n' "$PAGES" | grep -c .)
NB_SCRIPTS=$(printf '%s\n' "$SCRIPTS" | grep -c .)
echo "OK : rien ne sort avant le consentement ($NB_PAGES pages, $NB_SCRIPTS script(s) vérifiés)"
printf '%s\n' "$PAGES" "$SCRIPTS" | grep . | sed 's/^/  /'
