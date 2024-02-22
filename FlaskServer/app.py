import os

from flask import (Flask, redirect, render_template, request,
                   send_from_directory, url_for,jsonify)

from flask_cors import CORS

app = Flask(__name__)
CORS(app)

pisteet__data = []

@app.route('/')
def index():
   print('Request for index page received')
   return render_template('index.html')

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'),
                               'favicon.ico', mimetype='image/vnd.microsoft.icon')

@app.route('/hello', methods=['POST'])
def hello():
   name = request.form.get('name')

   if name:
       print('Request for hello page received with name=%s' % name)
       return render_template('hello.html', name = name)
   else:
       print('Request for hello page received with no name or blank name -- redirecting')
       return redirect(url_for('index'))


@app.route('/laheta_aika', methods=['POST'])
def laheta_pisteet():
    try:
        data = request.get_json(force=True)
        aika = data['aika']
        pelaaja = data['pelaaja']

        if aika is None:
            return jsonify({"error":"Väärää dataa"}), 400
        
        if len(pisteet__data) != 0:
            for i in range(len(pisteet__data)):
                vertailuaika:int = pisteet__data[i][1]
                if aika < vertailuaika:
                    pisteet__data.insert(i, (pelaaja, aika))
                    break
                elif i+1 == len(pisteet__data):
                    pisteet__data.append((pelaaja, aika))
        else:
            pisteet__data.append((pelaaja, aika))

        return jsonify({"message": "Pisteet lähetetty onnistuneesti"}), 200
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/hae_nopeimmat_ajat", methods=["GET"])
def hae_nopeimmat_ajat():
    try:
        if not pisteet__data:
            return jsonify({"message": "Ei dataa saatavilla"})
        
        lista = []

        kierrokset = len(pisteet__data)
        if kierrokset > 10:
            kierrokset = 10
        
        for i in range(kierrokset):
            pelaaja:str = pisteet__data[i][0]
            aika:int = pisteet__data[i][1]
            minuutit, sekunnit = divmod(aika, 60)
            sanakirja = {"pelaaja" : str(pelaaja), "aika" : F"Aika {minuutit} minuuttia ja {sekunnit} sekuntia"}
            lista.append(sanakirja)

        return jsonify(lista)
    except Exception as e:
        pass

if __name__ == '__main__':
   app.run()
