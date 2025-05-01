import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

data = {}
collections = db.collections()
for collection in collections:
    docs = collection.stream()
    data[collection.id] = {doc.id: doc.to_dict() for doc in docs}

# Save to file
with open('firestore_backup.json', 'w') as f:
    json.dump(data, f, indent=2)

print("✅ Firestore data exported to firestore_backup.json")
