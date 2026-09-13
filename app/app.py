import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST")
DB_NAME = os.getenv("POSTGRES_DB")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASS = os.getenv("POSTGRES_PASSWORD")

def check_db():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            connect_timeout=3
        )
        conn.close()
        return "Connected"
    except Exception as e:
        return f"Unavailable: {str(e)}"

@app.route("/")
def index():
    db_status = check_db()
    return jsonify({
        "status": "online",
        "service": "Flask Backend",
        "database": db_status
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
