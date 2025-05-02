import pandas as pd
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestRegressor, RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, accuracy_score
import joblib

# Load and clean dataset
df = pd.read_csv("nutrition_dataset.csv")
df.columns = [col.strip() for col in df.columns]
df = df[df['Age'] != 'Age']  # remove repeated header rows

# Convert to appropriate types
numeric_columns = ['Age', 'Height', 'Weight', 'Daily Calorie Target']
for col in numeric_columns:
    df[col] = pd.to_numeric(df[col], errors='coerce')
df.dropna(subset=numeric_columns, inplace=True)

# Normalize strings for dietary preference
df['Dietary Preference'] = df['Dietary Preference'].astype(str).str.strip().str.title()

# === Helper to Clean Meals Before Encoding ===
def clean_meal_training(df, column):
    df = df.copy()
    df[column] = df[column].astype(str).str.strip()
    df['Dietary Preference'] = df['Dietary Preference'].astype(str).str.strip().str.title()

    non_veg_keywords = ['chicken', 'fish', 'egg', 'meat']
    dairy_keywords = ['milk', 'yogurt', 'paneer']

    def is_invalid(row):
        meal = row[column].lower()
        pref = row['Dietary Preference'].lower()
        if pref == 'vegetarian':
            return any(k in meal for k in non_veg_keywords)
        if pref == 'vegan':
            return any(k in meal for k in non_veg_keywords + dairy_keywords)
        return False

    return df[~df.apply(is_invalid, axis=1)]

# === Save unencoded encoders from original ===
categorical_columns = ['Gender', 'Activity Level', 'Fitness Goal', 'Dietary Preference']
encoders = {}
original_df = df.copy()  # Save before encoding for later re-encoding in meal training
for col in categorical_columns:
    df[col] = df[col].astype(str).str.strip()
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    encoders[col] = le

# Features and base X
target_features = ['Age', 'Gender', 'Height', 'Weight', 'Activity Level', 'Fitness Goal', 'Dietary Preference']
X = df[target_features]
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# === Calorie Model ===
y_calories = df['Daily Calorie Target']
X_train_c, X_test_c, y_train_c, y_test_c = train_test_split(X_scaled, y_calories, test_size=0.2, random_state=42)
calorie_model = RandomForestRegressor(n_estimators=100, random_state=42)
calorie_model.fit(X_train_c, y_train_c)
cal_pred = calorie_model.predict(X_test_c)
print("✅ Calories model MSE:", mean_squared_error(y_test_c, cal_pred))

# === Meal Models ===
def train_classifier(target_column, filename_prefix):
    clean_df = clean_meal_training(original_df.copy(), target_column)

    # Encode categorical columns
    for col in categorical_columns:
        le = encoders[col]
        clean_df[col] = le.transform(clean_df[col].astype(str).str.strip())

    y = clean_df[target_column].astype(str).str.strip()
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)
    X_meal = clean_df[target_features]
    X_meal_scaled = scaler.transform(X_meal)
    X_train, X_test, y_train, y_test = train_test_split(X_meal_scaled, y_encoded, test_size=0.2, random_state=42)

    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)
    y_pred = clf.predict(X_test)

    print(f"✅ {target_column} accuracy:", accuracy_score(y_test, y_pred))
    joblib.dump(clf, f"{filename_prefix}_model.pkl")
    joblib.dump(le, f"{filename_prefix}_label_encoder.pkl")

train_classifier("Breakfast Suggestion", "breakfast")
train_classifier("Lunch Suggestion", "lunch")
train_classifier("Dinner Suggestion", "dinner")
train_classifier("Snack Suggestion", "snack")

# Save core models
joblib.dump(calorie_model, "calorie_model.pkl")
joblib.dump(scaler, "scaler.pkl")
joblib.dump(encoders, "encoders.pkl")
print("✅ All models trained and saved with dietary safety checks.")
