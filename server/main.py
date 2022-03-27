from flask import Flask, Response
from werkzeug.utils import secure_filename
from flask import request

import pathlib
from pathlib import Path

from nn import nn
import asyncio, os, json
import pymysql

app = Flask(__name__)

not_used_ids = [0]
dir_path = pathlib.Path.cwd()

UPLOAD_FOLDER = Path(dir_path, 'uploads')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/api/upload', methods=['POST'])
async def upload_file():
    file = request.files['file']

    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

    await asyncio.sleep(1)

    res = await nn.nn(os.path.join(app.config['UPLOAD_FOLDER']))
    return Response(str(res), 200)

@app.route('/api/login', methods=['POST'])
async def login():
    email = str(request.json['email'])
    password = str(request.json['password'])

    print(email, password)
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')

    with con:
        cur = con.cursor()
        cur.execute(f'SELECT password FROM users WHERE email = "{email}"')
        result = cur.fetchone()

        if result == None: 
            cur.close()
            return Response(str("Invalid data"), 200)

        else:
            result = tuple(result)
            password_res = result[0]

            if password_res != password:
                cur.close()
                return Response(str("Invalid data"), 200)

            elif password_res == password: 
                cur.close()
                return Response(str("True"), 200)

@app.route('/api/register', methods=['POST'])
async def register():
    email = str(request.json['email'])
    password = str(request.json['password'])

    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')
    with con:
        cur = con.cursor()
        cur.execute(f'INSERT INTO users(email, password, email_submit, pass_rescure_key) VALUES ("{email}", "{password}", 0, 0)')

        print(f'INSERT INTO users(email, password, email_submit, pass_rescure_key) VALUES ("{email}", "{password}", 0, 0)')
        
        result = cur.fetchone()
        if result == None:
            con.commit()
            cur.close()
            return Response(str("True"), 200)
        else:
            cur.close()
            return Response(str("Invalid data"), 200)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(app.run(host='0.0.0.0', port=5000))
