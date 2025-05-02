from flask import Flask, request, jsonify
from flask_cors import CORS
from diet_model import predict_calories_and_meal

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route("/get_diet", methods=["POST"])
def get_diet():
    try:
        data = request.get_json()

        result = predict_calories_and_meal(
            age=data["age"],
            gender=data["gender"],
            height=data["height"],
            weight=data["weight"],
            activity_level=data["activity_level"],
            fitness_goal=data["fitness_goal"],
            dietary_preference=data["dietary_preference"]
        )

        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(debug=True)
