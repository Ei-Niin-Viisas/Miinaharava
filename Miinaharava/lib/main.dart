import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



void main() {
  runApp(const MyApp());
}


Future<void> lahetaAikaPalvelimelle(int sekunnit, String pelaaja) async {
  var uri = Uri.http('parasflaskserver.azurewebsites.net', 'laheta_aika');

  try {
    final vastaus = await http.post(
      uri,
      body: jsonEncode({'aika': sekunnit, 'pelaaja': pelaaja}),
    );

    if (vastaus.statusCode == 200) {
      print("Pisteiden lähetys onnistui");
    }
    else{
      print(vastaus.body);
    }
  }
  catch (e) {
    print("Virhe: $e");
  }
}

Future<List<dynamic>?> haeKeskiarvoPalvelimelta() async {
  var uri = Uri.http('parasflaskserver.azurewebsites.net', 'hae_nopeimmat_ajat');

  try {
    final vastaus = await http.get(uri);
    
    if (vastaus.statusCode == 200) {
      final List<dynamic> data = jsonDecode(vastaus.body);


      if (data.isNotEmpty) { 
        return data; 
      } else {
        print('Palvelimen vastaus ei sisältänyt tietoa: keskiarvo');
        return null;
      }
    } else {
      print('Keskiarvon haku epäonnistui. Virhe: ${vastaus.reasonPhrase}');
      return null;
    }
  }
  catch (e) {
    print('HTTP request epäonnistui: $e');
    return null;
  }
}

class PlayerNameModel extends ChangeNotifier {
  String _name = '';

  String get name => _name;

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlayerNameModel(),
      child: MaterialApp(
        initialRoute: '/startscreen',
        routes: {
          '/home': (context) => MyHome(),
          '/startscreen' :(context) => StartScreen(),
          '/minesweeper' :(context) => MineSweeper(),
          '/havioruutu' :(context) => HavioRuutu(),
          '/voittoruutu' :(context) => VoittoRuutu(),
        },
        theme: ThemeData(
          // Määritä haluamasi väri täällä
          scaffoldBackgroundColor: Colors.purple,
        ),
      ),
    );  
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    final playerNameModel = context.watch<PlayerNameModel>();
    return Scaffold(
      appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          title: const Text('Päävalikko'),
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Miinaharava',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Syötä nimesi',
                  ),
                  onChanged: (value) {
                    playerNameModel.setName(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30), 
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/minesweeper');
              }, 
              child: const Text('Pelaa peliä')
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamed(context, '/home');
              }, 
              child: const Text('Näytä leaderboard')
            ),
          ]
        )
      ),
    );
  }
}

class HavioRuutu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          title: const Text('Peli'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hävisit pelin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Väli napin ja tekstin välille
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/minesweeper");
                },
                child: const Text('Uusi peli'),
              ),
              const SizedBox(height: 10), // Väli napin ja tekstin välille
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/startscreen");
                },
                child: const Text('Päävalikko'),
              ),
            ],
          ),
        ),
      );
  }
}

class VoittoRuutu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          title: const Text('Peli'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Voitit pelin :)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Väli napin ja tekstin välille
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/minesweeper");
                },
                child: const Text('Uusi peli'),
              ),
              const SizedBox(height: 10), // Väli napin ja tekstin välille
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/startscreen");
                },
                child: const Text('Päävalikko'),
              ),
            ],
          ),
        ),
      );
  }
}

class MineSweeper extends StatefulWidget {
  @override
  _MineSweeperState createState() => _MineSweeperState();
}

class _MineSweeperState extends State<MineSweeper>{

  List<bool> _tilat = [];
  List<int> pommit = [];
  List<int> numerot = [];
  List<String> sisallot = [];
  List<bool> liput = [];

  final int rivit = 18;
  final int sarakkeet = 10;
  final int pommien_lkm = 20;
  bool liputus = false;
  bool havitty = false;

  Timer? ajastin;
  int kuluneetSekunnit = 0;

  _MineSweeperState(){
    final random = Random();

    for (int i = 0; i < pommien_lkm; i++) {
      int luku = random.nextInt(sarakkeet*rivit);

      if (!pommit.contains(luku)) {
        pommit.add(luku);
      }
      else {
        i--;
      }
    }

    for (int i = 0; i < rivit*sarakkeet; i++) {
      _tilat.add(false);
      numerot.add(0);
      liput.add(false);
    }

    for (int i = 0; i < pommit.length; i++) {
      int pommi = pommit[i];

      if ((pommi-1 >= 0) && (((pommi-1)%sarakkeet) != (sarakkeet-1))) {
        numerot[pommi-1]++;
      }
      if ((pommi+1 < rivit*sarakkeet) && (((pommi+1)%sarakkeet) != 0)){
        numerot[pommi+1]++;
      }
      if (pommi-sarakkeet >= 0){
        numerot[pommi-sarakkeet]++;
      }
      if ((pommi-sarakkeet+1 >= 0) && (((pommi-sarakkeet+1)%sarakkeet) != 0)){
        numerot[pommi-sarakkeet+1]++;
      }
      if ((pommi-sarakkeet-1 >= 0) && (((pommi-sarakkeet-1)%sarakkeet) != (sarakkeet-1))){
        numerot[pommi-sarakkeet-1]++;
      }
      if (pommi+sarakkeet < rivit*sarakkeet){
        numerot[pommi+sarakkeet]++;
      }
      if ((pommi+sarakkeet-1 < rivit*sarakkeet) && (((pommi+sarakkeet-1)%sarakkeet) != (sarakkeet-1))){
        numerot[pommi+sarakkeet-1]++;
      }
      if ((pommi+sarakkeet+1 < rivit*sarakkeet) && (((pommi+sarakkeet+1)%sarakkeet) != 0)){
        numerot[pommi+sarakkeet+1]++;
      }
    }

    for (int i = 0; i < rivit*sarakkeet; i++) {
      if (pommit.contains(i)) {
        sisallot.add("*");
      }
      else if (numerot[i] != 0){
        sisallot.add(numerot[i].toString());
      }
      else {
        sisallot.add(" ");
      }
    }
  }

  void tarkistaTyhjat(index) {

    List<int> viereiset = [index-sarakkeet,index+sarakkeet];

    if (index%sarakkeet != (sarakkeet-1)) {
      viereiset.add(index+1);
      viereiset.add(index+1+sarakkeet);
      viereiset.add(index+1-sarakkeet);
    }
    if (index%sarakkeet != 0) {
      viereiset.add(index-1);
      viereiset.add(index-1+sarakkeet);
      viereiset.add(index-1-sarakkeet);
    }
    
    if ((sisallot[index] == " ") && (_tilat[index] == false)) {
      for (int i = 0; i < viereiset.length; i++) {
        _tilat[index] = true;
        if ((0 <= viereiset[i]) && (viereiset[i] < sisallot.length)) {
          tarkistaTyhjat(viereiset[i]);
        }
      }
    }
    else {
      _tilat[index] = true;
    }
  }

  void ruutuaPainettu(index) {
    
    if (ajastin == null) {
      ajastin = Timer.periodic(Duration(seconds: 1), (ajastin) {
        setState(() {
          kuluneetSekunnit++;
        });
      });
    }

    tarkistaTyhjat(index);
    int avatut = 0;

    for (int i = 0; i < _tilat.length; i++) {
      if (_tilat[i]){avatut++; print(avatut);}
    }

    if (sisallot[index] == "*") {
      havitty = true;
      ajastin?.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushNamed(context, '/havioruutu');
      });
    }
    else if ((avatut >= (rivit*sarakkeet)-pommien_lkm) && !havitty) {
      final playerNameModel = context.read<PlayerNameModel>();
      ajastin?.cancel();
      lahetaAikaPalvelimelle(kuluneetSekunnit, playerNameModel.name);    
      Navigator.pushNamed(context, '/voittoruutu');
    }

  }

  String liputettu(int index) {
    if (liput[index]) {
      return "X";
    }
    else{
      return "";
    }
  }


  Widget buildRuutu(BuildContext context, int index, Color vari) {
    return TextButton(
      onPressed:() {
        setState(() {
          if ((_tilat[index] == false) && (!liputus) && (!liput[index]) && !havitty) {
            ruutuaPainettu(index);
          }
          else if (liputus) {
            liput[index] = !liput[index];
          }
        });
      },
      style: ElevatedButton.styleFrom(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: _tilat[index] ? vari : Colors.grey,  
        textStyle: const TextStyle(fontSize: 16)
      ),
      child: _tilat[index] ? Text(sisallot[index]) : Text(liputettu(index)),
    );
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: const Text('Miinaharava'),
      ),
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      liputus = !liputus;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: liputus ?Colors.red : Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: Text(
                    liputus ? "Liputus päällä" : "Liputus poissa", 
                  ),
                ),
                const SizedBox(width: 20), 
                Text(
                  kuluneetSekunnit.toString(),
                  style: const TextStyle(
                    color: Colors.black, // Tekstin väri
                    fontSize: 16, // Tekstin koko
                  ),
                ),
              ]
            ),
          ),

            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: sarakkeet, // 20 saraketta
                  mainAxisSpacing: 4.0, // Väli rivien välillä
                  crossAxisSpacing: 4.0, // Väli sarakkeiden välillä
                ),
                itemBuilder: (BuildContext context, int index) {
                  Color vari = Colors.white;
                  if (sisallot[index] == "*") {
                    vari = Colors.red;
                  } else if (sisallot[index] == "1") {
                    vari = Colors.blue;
                  } else if (sisallot[index] == "2") {
                    vari = Colors.green;
                  } else if (sisallot[index] == "3") {
                    vari = Colors.yellow;
                  } else if (sisallot[index] == "4") {
                    vari = Colors.orange;
                  }
                  return buildRuutu(context, index, vari);
                },
                itemCount: sarakkeet * rivit, // Ruutujen määrä
              ),
            ),
          ],
        ),
    );
  }
}
 
class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arvioi palvelu")),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
        },
        child: Container(
          color: Colors.blueGrey,
          child: ArviointiNakyma(),
        ),
      ),
    );
  }
}

class ArviointiNakyma extends StatefulWidget {
  @override
  _ArviointiNakymaTila createState() => _ArviointiNakymaTila();
}


class _ArviointiNakymaTila extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<List<dynamic>?>(
              future: haeKeskiarvoPalvelimelta(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var lista = snapshot.data;
                  String leaderboard = "";
                  if(lista != null) {
                    for(int i = 0; i < lista.length; i++) {
                      leaderboard += "${i+1}. ${lista[i]["pelaaja"]}: ${lista[i]["aika"]}\n";
                    }
                  }
                  else {
                    leaderboard = "Ei vielä yrityksiä";
                  }
                  return Text(
                    leaderboard,
                    style: const TextStyle(fontSize: 16),
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/startscreen");
              },
              child: const Text('Päävalikko'),
            )
          ],
        ),
      );   
  }
}