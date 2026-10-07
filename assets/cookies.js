/* Gomuscu — consentement à la mesure d'audience du site (Google Analytics 4).
 *
 * Règle du site : AUCUNE requête vers Google avant « Accepter ». C'est le mode « de base » du
 * Consent Mode de Google : gtag.js n'est même pas téléchargé tant que le visiteur n'a pas accepté.
 * Le choix, oui comme non, est retenu 180 jours dans le navigateur, puis redemandé.
 *
 * check-autonomie.sh n'admet ce fichier que sur la vitrine (index.html) et le blog (blog/, depuis le
 * 2026-10-07), et n'admet dans un script aucune adresse absolue autre que celle de gtag.js — n'en
 * écrire aucune autre, même en commentaire. La bannière (#consentement) et ses styles vivent dans
 * index.html, et pour le blog dans son générateur (dépôt de l'app, docs/marketing/vitrine/blog/) :
 * changer l'un, c'est changer l'autre. L'identifiant apparaît aussi
 * dans le tableau des cookies de mentions-legales/ (cookie _ga_<identifiant>) : changer les deux.
 */
(function () {
  'use strict';

  var ID = 'G-M0FDVT393T';
  var CLE = 'gomuscu-consentement';
  var VALIDITE_MS = 180 * 24 * 60 * 60 * 1000; // 6 mois : durée de vie d'un choix (CNIL)
  var COOKIES_S = 390 * 24 * 60 * 60;          // 13 mois de 30 jours, au lieu des 2 ans de Google

  window.dataLayer = window.dataLayer || [];
  function gtag() { window.dataLayer.push(arguments); }
  gtag('consent', 'default', {
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied'
  });

  var banniere = document.getElementById('consentement');
  var retourFocus = null;
  var gaCharge = false;

  function lireChoix() {
    try {
      var choix = JSON.parse(localStorage.getItem(CLE));
      if (!choix || choix.v !== 1 || typeof choix.mesure !== 'boolean') return null;
      var age = Date.now() - Date.parse(choix.date);
      return age >= 0 && age < VALIDITE_MS ? choix : null;
    } catch (e) {
      return null;
    }
  }

  function retenirChoix(mesure) {
    try {
      localStorage.setItem(CLE, JSON.stringify({ v: 1, mesure: mesure, date: new Date().toISOString() }));
    } catch (e) {
      // Stockage indisponible (navigation privée stricte…) : le choix ne vaut que pour cette page.
    }
  }

  function activerMesure() {
    window['ga-disable-' + ID] = false;
    gtag('consent', 'update', { analytics_storage: 'granted' });
    if (gaCharge) return;
    gaCharge = true;
    var s = document.createElement('script');
    s.async = true;
    s.src = 'https://www.googletagmanager.com/gtag/js?id=' + ID;
    document.head.appendChild(s);
    gtag('js', new Date());
    gtag('config', ID, {
      cookie_expires: COOKIES_S,
      allow_google_signals: false,
      allow_ad_personalization_signals: false
    });
  }

  // Refuser après avoir accepté : GA se tait et ses cookies disparaissent, sur l'hôte comme sur
  // chaque domaine parent (gtag les pose sur .gomuscuapp.com). Joué même si GA n'a pas été chargé
  // dans cette page : les cookies peuvent venir d'une visite précédente.
  function couperMesure() {
    window['ga-disable-' + ID] = true;
    gtag('consent', 'update', { analytics_storage: 'denied' });
    var parties = location.hostname.split('.');
    var domaines = [''];
    for (var i = 0; i < parties.length - 1; i++) domaines.push('; domain=.' + parties.slice(i).join('.'));
    document.cookie.split(';').forEach(function (c) {
      var nom = c.split('=')[0].trim();
      if (nom !== '_ga' && nom.indexOf('_ga_') !== 0) return;
      domaines.forEach(function (d) {
        document.cookie = nom + '=; Max-Age=0; path=/' + d;
      });
    });
  }

  function ouvrir(avecFocus) {
    if (!banniere) return;
    banniere.hidden = false;
    if (avecFocus) {
      retourFocus = document.activeElement;
      banniere.querySelector('[data-choix]').focus();
    }
  }

  function fermer() {
    if (!banniere) return;
    var focusDedans = banniere.contains(document.activeElement);
    banniere.hidden = true;
    if (focusDedans && retourFocus && retourFocus.isConnected) retourFocus.focus();
    retourFocus = null;
  }

  function choisir(mesure) {
    retenirChoix(mesure);
    fermer();
    if (mesure) activerMesure(); else couperMesure();
  }

  // « Gérer les cookies » : tout lien vers #cookies (pied de la vitrine et du blog, /mentions-legales/) rouvre
  // la bannière, même après un choix. Le fragment est retiré aussitôt : un second clic la rouvre.
  function surFragment() {
    if (location.hash !== '#cookies') return;
    history.replaceState(null, '', location.pathname + location.search);
    ouvrir(true);
  }

  if (banniere) {
    banniere.addEventListener('click', function (e) {
      var bouton = e.target.closest('[data-choix]');
      if (bouton) choisir(bouton.getAttribute('data-choix') === 'oui');
    });
  }
  window.addEventListener('hashchange', surFragment);

  var choix = lireChoix();
  if (choix && choix.mesure) activerMesure();
  if (!choix) ouvrir(false);
  surFragment();
})();
