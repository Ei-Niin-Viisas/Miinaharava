Kansiossa FlaskServer on palvelin, joka pyörii osoitteessa: https://parasflaskserver.azurewebsites.net
Palvelimen pohja on kopioitu Microsoftin Azuren flask-esimerkistä.

Kansiossa Miinaharava on flutterilla tehty lähdekoodi miinaharavapelille.
Luokkien selitykset:
Future<void> lahetaAikaPalvelimelle lähettää dataa palvelimelle
Future<List<dynamic>?> haeKeskiarvoPalvelimelta() hakee dataa palvelimelta ja palauttaa data listassa
PlayerNameModel tallentaa pelaajan nimen
MyApp on projektin root
StartScreen on pelin aloitussivu
HavioRuutu on ruutu, joka tulee näkyviin, kun pelaaja häviää
VoittoRuutu on ruutu, joka tulee näkyviin, kun pelaaja voittaa
MineSweeper on widget, jolla on tila _MineSweeperState
_MineSweeperState on tila, jossa itse pelin logiikka toimii
MyHome on leaderboardin näytön root
ArviointiNakyma on widget, jolla on tila _ArviointiNakymaTila
_ArviointiNakymaTila näyttää palvelimelta haetun leaderboardin
