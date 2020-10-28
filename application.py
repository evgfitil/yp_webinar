from flask import Flask
app = Flask(__name__)


@app.route('/')
def say_hello():
    return 'Здесь должно быть приложение'


if __name__ == '__main__':
    app.run(host='0.0.0.0')
