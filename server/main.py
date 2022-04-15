from flask import Flask, Response
from werkzeug.utils import secure_filename
from flask import request

import pathlib
from pathlib import Path

from nn import nn
import asyncio, os, json
import pymysql
import secrets, string

from send import send_mail_async

app = Flask(__name__)

not_used_ids = [0]
dir_path = pathlib.Path.cwd()

UPLOAD_FOLDER = Path(dir_path, 'uploads', 'folder1')
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/api/upload', methods=['POST'])
async def upload_file():
    file = request.files['file']

    filename = secure_filename(file.filename)
    file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

    await asyncio.sleep(1)

    res = await nn.nn(os.path.join(app.config['UPLOAD_FOLDER']))

    return Response(str("Храм Василия Блаженного. Собо́р Покрова́ Пресвято́й Богоро́дицы, что на Рву (Покро́вский собо́р, собо́р Покрова́ на Рву, разговорное — собо́р (храм) Васи́лия Блаже́нного) — православный храм на Красной площади в Москве, памятник русской архитектуры. Строительство собора велось с 1555 по 1561 год."), 200)

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

@app.route('/api/email_exist', methods=['POST'])
async def email_exist():
    email = str(request.json['email'])

    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')
    with con:
        cur = con.cursor()
        cur.execute(f'SELECT * FROM users WHERE email = "{email}"')

        result = cur.fetchone()
        if result == None:
            cur.close()
            return Response(str("False"), 200)
        else:
            cur.close()
            return Response(str("True"), 200)

@app.route('/api/send_code', methods=['POST'])
async def send_code():
    alphabet = "1234567890"
    email = str(request.json['email'])
    key = ''.join(secrets.choice(alphabet) for i in range(6))

    if key[0] == '0': key[0] = "1"

    await send_mail_async("gaiercop@gmail.com", [email], "Your submit code", f"Your code: {key}") 
    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')
    with con:
        cur = con.cursor()
        cur.execute(f'UPDATE users SET pass_rescure_key = {key} WHERE email = "{email}"')

        cur.close()
        con.commit()

    return Response(str("True"), 200)

@app.route('/api/change_password', methods=['POST'])
async def change_password():
    email = str(request.json['email'])
    password = str(request.json['password'])
    code = str(request.json['code'])

    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')

    with con:
        cur = con.cursor()
        cur.execute(f'SELECT email FROM users WHERE pass_rescure_key = {code}')

        result = cur.fetchone()
        if result == None:
            cur.close()
            return Response(str("Invalid data"), 200)
        elif result[0] == email: 
            cur.execute(f'UPDATE users SET password = "{password}" WHERE email = "{email}"')
            cur.close()
            con.commit()

            return Response(str("True"), 200)
        else:
            print(result[0])
            return Response(str("Invalid data"), 200)

@app.route('/api/add_attraction', methods=['POST'])
async def change_password():
    title = str(request.json['title'])
    filename = str(request.json['title'])

    con = pymysql.connect(host = 'localhost', user = 'root',
    password = '523523523g', database = 'touristic_helper')

    with con:
        cur = con.cursor()
        cur.execute(f'INSERT INTO attractions (name, filename, northern_latitude, eastern_longitude, article_link) VALUES ({title}, {title}, 0.0, 0.0, ""')

        cur.close()
        con.commit()
        
        return Response(str("True"), 200)



if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(app.run(host='0.0.0.0', port=5000))
