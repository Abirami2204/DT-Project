import joblib
import numpy as np

# Load the trained model and supporting files
model = joblib.load("calorie_model.pkl")
scaler = joblib.load("scaler.pkl")
encoders = joblib.load("encoders.pkl")

# Optional: Load meal recommendation model(s) if available
try:
    breakfast_model = joblib.load("breakfast_model.pkl")
    breakfast_encoder = joblib.load("breakfast_label_encoder.pkl")
except:
    breakfast_model = None
    breakfast_encoder = None

def predict_calories_and_meal(age, gender, height, weight, activity_level, fitness_goal, dietary_preference):
    try:
        # Encode categorical features
        gender_encoded = encoders['Gender'].transform([gender])[0]
        activity_encoded = encoders['Activity Level'].transform([activity_level])[0]
        goal_encoded = encoders['Fitness Goal'].transform([fitness_goal])[0]
        diet_encoded = encoders['Dietary Preference'].transform([dietary_preference])[0]

        # Prepare input vector
        features = np.array([[age, gender_encoded, height, weight, activity_encoded, goal_encoded, diet_encoded]])
        scaled_features = scaler.transform(features)

        # Predict calories
        calories = model.predict(scaled_features)[0]

        # Optional: Predict meal suggestions
        breakfast = None
        if breakfast_model and breakfast_encoder:
            breakfast_idx = breakfast_model.predict(scaled_features)[0]
            breakfast = breakfast_encoder.inverse_transform([breakfast_idx])[0]

        return {
            "daily_calories": round(calories),
            "breakfast": breakfast or "Oats and fruit",
            "lunch": "Grilled chicken with vegetables",
            "dinner": "Lentil soup and brown rice",
            "snack": "Greek yogurt or nuts"
        }

    except Exception as e:
        return {"error": str(e)}
