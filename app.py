from flask import Flask
import os
app = Flask(__name__)

@app.route('/')
def home():
    return "peleg says hello world!"

@app.route('/v1/test')
def test():
    return "this is salt security"

@app.route('/v1/health')
def health():
    return ""


if __name__ == "__main__":
    print("start")
    app.run(debug=True, host='0.0.0.0', port='5011')
