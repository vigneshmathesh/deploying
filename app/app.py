from flask import Flask
app = Flask(__name__)
@app.route('/')
def home():
    return "🚀 Flask App Deployed with Terraform and GitHub Actions!"
