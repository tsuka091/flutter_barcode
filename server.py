from flask import Flask, jsonify, request
app = Flask(__name__)
app.config["JSON_AS_ASCII"] = False

out_data = [
    {'id': 0, 'address': '大阪府'},
    {'id': 1, 'address': '大阪府大阪市'},
    {'id': 2, 'address': '京都府'},
    {'id': 3, 'address': '京都府京都市'},
    {'id': 4965854613133, 'address': '北陸'},
]

@app.route('/')
def api_route():
    return 'Hello!!'

@app.route('/list', methods=['GET'])
def api_list():
    return jsonify({
        "list": out_data
    })

@app.route('/list/<int:id>', methods=['GET'])
def api_get_item(id):
    if id in [d.get('id') for d in out_data]:
        return jsonify({
            "status": 0,
            "id": id,
            "address": out_data[[d.get('id') for d in out_data].index(id)]['address'],
        })
    else:
        return jsonify({
            "status": -1,
            "id": id,
            "address": "Specify ID not be found.",
        })

@app.route('/add', methods=['POST'])
def api_add():
    if request.method == 'POST':
        msgs = request.get_json()
        for msg in msgs:
            id = out_data.count + 1
            address = msg['address']
            out_data.append({'id':id, 'address':address})
        return jsonify({
            'status': 'OK'
        })
    else:
        return jsonify({
            'status': 'NG'
        })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)