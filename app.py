from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"


if __name__ == "__main__":
    # uWSGIで実行されるときは処理されないとこだヨ
    # docker内でapp.pyを動かす場合はdockerのip 0.0.0.0を指定
    app.run('0.0.0.0', port=5000)





