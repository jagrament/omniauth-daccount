#!/usr/bin/python
# -*- coding: utf-8 -*-

import urllib, json, base64, urllib2, base64
from flask import session, redirect, url_for, escape, request, current_app
from flask import Blueprint, render_template
from uds.utils import auth
import hashlib

app = Blueprint("login", __name__, url_prefix="/login")


@app.route('/google')
def google():
    # return redirect('/login/google_check')
    # set the secret key.  keep this really secret:
    client_id = current_app.config['GOOGLE_CLIENT_ID']

    if request.host == 'localhost:5000':
        redirect_uri = 'http://localhost:5000/login/google_check'
        openidrealm = 'http://localhost:5000'
    else:
        redirect_uri = 'https://' + request.host + '/login/google_check'
        openidrealm = 'https://' + request.host

    return redirect('https://accounts.google.com/o/oauth2/auth?{}'.format(urllib.urlencode({
        'client_id': client_id,
        'scope': 'email profile',
        'redirect_uri': redirect_uri,
        'state': auth.issue_state(),
        'openid.realm': openidrealm,
        'response_type': 'code',
        'access_type': 'offline'
    })))

@app.route('/google_check')
def google_check():
    # set the secret key.  keep this really secret:
    client_id = current_app.config['GOOGLE_CLIENT_ID']
    client_secret = current_app.config['GOOGLE_CLIENT_SECRET']

    if auth.check_state(request.args.get('state')) != "OK":
        return 'invalid state'

    if request.host == 'localhost:5000':
        redirect_uri = 'http://localhost:5000/login/google_check'
    else:
        redirect_uri = 'https://' + request.host + '/login/google_check'

    dat = urllib.urlopen('https://www.googleapis.com/oauth2/v4/token', urllib.urlencode({
        'code': request.args.get('code'),
        'client_id': client_id,
        'client_secret': client_secret,
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code'
    }).encode('ascii')).read()

    print dat
    print

    dat = json.loads(dat.decode('utf-8'))

    id_token = dat['id_token'].split('.')[1]  # 署名はとりあえず無視する
    id_token += '=' * (4 - len(id_token) % 4)  # パディングが足りなかったりするっぽいので補う
    print id_token
    id_token = id_token.replace("-", "+").replace("_", "/")     # urlsafeのBase64エンコードのためReplace
    id_token_dec = base64.b64decode(id_token)
    print id_token_dec
    id_token = json.loads(id_token_dec.decode('utf-8'))     # 漢字名の名称に対応

    email_address = id_token['email']
    email_address_hash = email_address + "sebastien"
    email_address_sha256 = hashlib.sha256(email_address_hash.encode('utf-8')).hexdigest()
    user_id = auth.get_user_id(email_address_sha256)

    print user_id

    if user_id is None:
        user_id = auth.issue_new_user(email_address_sha256, name=id_token['name'], open_id_provider="google")
    # session['username'] = email_address
    session['user_id'] = user_id
    session['name'] = id_token['name']
    session['picture'] = id_token['picture']
    session.permanent = True
    # flash("ログインしました")
    # return redirect('/dashboard')

    return render_template("message.html", message=u'ログインしました. <br><br> こんにちは, {}さん'.format(session['name']),
                           redirect_uri="/dashboard")

@app.route('/docomo')
def docomo():
    # return redirect('/login/google_check')
    # set the secret key.  keep this really secret:
    client_id = current_app.config['DOCOMO_CLIENT_ID']

    if request.host == 'localhost:5000':
        redirect_uri = 'http://localhost:5000/login/docomo_check'
    else:
        redirect_uri = 'https://' + request.host + '/login/docomo_callback'
    # 認可エンドポイントへのリクエスト
    return redirect('https://id.smt.docomo.ne.jp/cgi8/oidc/authorize?{}'.format(urllib.urlencode({
                        'client_id': client_id,
                        'scope': 'openid',
                        'redirect_uri': redirect_uri,
                        'state': auth.issue_state(),
                        'nonce': auth.issue_state(),
                        'response_type': 'code'
                    })))



@app.route('/docomo_callback')
def docomo_callback():
    if auth.check_state(request.args.get('state')) != "OK":
        return 'invalid state'

    if request.host == 'localhost:5000':
        redirect_uri = 'http://localhost:5000/login/docomo_callback'
    else:
        redirect_uri = 'https://' + request.host + '/login/docomo_callback'
    # トークンエンドポイントへのリクエスト、取得した認可コードを設定
    url = "https://conf.uw.docomo.ne.jp/token"
    params = urllib.urlencode({
            'code': request.args.get('code'),
            'redirect_uri': redirect_uri,
            'grant_type': 'authorization_code'})
    headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Basic " + base64.b64encode(current_app.config['DOCOMO_CLIENT_ID']+":"+current_app.config['DOCOMO_CLIENT_SECRET']),
      "Content-Length": str(len(params))
    }
    req = urllib2.Request(url, params, headers)
    dat = urllib2.urlopen(req)
    dat = json.loads(dat.read().decode('utf-8'))
    current_app.logger.debug(dat)

    # レスポンスの処理、アクセストークンの取得
    access_token = dat['access_token']  # アクセストークンを取得

    # 利用者情報取得要求、この際返却されるsub, issをベースにユーザを作成
    url = "https://conf.uw.docomo.ne.jp/userinfo"
    req = urllib2.Request(url)
    req.add_header('Content-Type', 'application/x-www-form-urlencoded')
    req.add_header('Authorization', 'Bearer ' + access_token)
    res = urllib2.urlopen(req).read()

    current_app.logger.debug(res)
    res = json.loads(res)
    current_app.logger.debug(res)

    hash_sha256 = hashlib.sha256(res['sub']+res['iss']).hexdigest()
    user_id = auth.get_user_id(hash_sha256)

    current_app.logger.debug(user_id)

    if user_id is None:
        user_id = auth.issue_new_user(hash_sha256, name=res.get('name', ''), open_id_provider="docomo")

    session['user_id'] = user_id
    session['name'] = res.get('name', '')
    session['picture'] = res.get('picture', '')
    session.permanent = True

    return render_template("message.html", message=u'ログインしました. <br><br> こんにちは, {}さん'.format(session['name']),
                           redirect_uri="/dashboard")

# TODO: 後で削除する
@app.route('/development')
def development():
    user_id = "253df647-86d1-41c7-93e9-28104b0d446a"
    name = u"開発"

    session['user_id'] = user_id
    session['name'] = name
    session['picture'] = url_for('static', filename='img/user.png')
    session.permanent = True

    return render_template(
        "message.html",
        message=u'ログインしました. <br><br> こんにちは, {}さん'.format(session['name']),
        redirect_uri="/dashboard"
    )


@app.route('/')
def index():
    auth.migrate_db()
    if 'user_id' in session:
        return render_template("message.html", message=u'ログインしています. <br><br> %s さん' % escape(session['name']),
                               redirect_uri="/dashboard")
    return redirect('/login/login')


@app.route('/login', methods=['GET', 'POST'])
def login():
    # if request.method == 'POST':
    #     session['username'] = request.form['username']
    #     return redirect(url_for('index'))
    # print
    if request.host == current_app.config.get('PRODUCTION_URL'):
        production = True
    else:
        production = False
    return render_template("login.html", title="Login", production=production)

    return render_template("login.html", title="Login")


@app.route('/logout')
def logout():
    # remove the username from the session if its there
    session.clear()
    return render_template("message.html", message=u'ログアウトしました',
                           redirect_uri=url_for('index'))
