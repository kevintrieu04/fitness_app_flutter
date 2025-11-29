import io

import numpy as np
from PIL import Image
from flask import Flask, request, jsonify

from prediction_model import model_predict

app = Flask(__name__)

# ----------------------
# Exercise database
# ----------------------


# ----------------------
# Helper functions
# ----------------------
def bmi_category(bmi):
    if bmi < 18.5: return "underweight"
    if bmi < 25: return "normal"
    if bmi < 30: return "overweight"
    return "obese"

def goal_from_bmi(bmi):
    cat = bmi_category(bmi)
    if cat == "underweight": return "gain"
    if cat == "normal": return "maintain_build"
    return "fat_loss"

def choose_split(freq, experience):
    if freq <= 2:
        return ["full"] * freq
    if freq == 3:
        return ["full","upper","full"]
    if freq == 4:
        return ["upper","lower","upper","lower"]
    if freq == 5:
        return ["push","pull","legs","upper_accessory","conditioning"]
    if freq == 6:
        return ["push","pull","legs","push","pull","legs"]
    return ["push","pull","legs","push","pull","legs","active_recovery"]

def sets_reps_for_goal(goal, experience):
    if goal == "gain":
        return 3, "5-8"
    if goal == "maintain_build":
        return 3, "6-12"
    return 3, "8-15"

def select_exercises_for_day(day_type, goal):
    if day_type == "full":
        return ["squat","bench","row","plank"]
    if day_type == "upper":
        return ["bench","ohp","row","rb_curl","tricep_push"]
    if day_type == "lower":
        return ["squat","deadlift","lunges","plank"]
    if day_type == "push":
        return ["bench","ohp","tricep_push","plank"]
    if day_type == "pull":
        return ["row","pullup","rb_curl","plank"]
    if day_type == "legs":
        return ["squat","deadlift","lunges","plank"]
    if day_type == "conditioning":
        return ["bike"]
    if day_type == "active_recovery":
        return ["plank","bike"]
    return ["plank"]

# ----------------------
# Core plan generator
# ----------------------
def generate_week_plan(bmi, experience, freq):
    goal = goal_from_bmi(bmi)
    split = choose_split(freq, experience)

    plan = []
    for day_idx, day_type in enumerate(split, start=1):
        ex_ids = select_exercises_for_day(day_type, goal)
        day_exs = []

        for ex_id in ex_ids:
            sets, reps = sets_reps_for_goal(goal, experience)

            # Lower sets for beginners
            if experience == "beginner":
                sets = max(2, sets - 1)

            day_exs.append({
                "exercise": ex_id,
                "sets": sets,
                "reps": reps,
                "rest_seconds": 90
            })

        plan.append({
            "day": day_idx,
            "type": day_type,
            "exercises": day_exs
        })

    return {
        "goal": goal,
        "weekly_frequency": freq,
        "plan": plan
    }

# ----------------------
# API ROUTES
# ----------------------
@app.route("/generate", methods=["POST"])
def generate():
    data = request.get_json()

    bmi = data.get("bmi")
    experience = data.get("experience")
    freq = data.get("weekly_frequency")

    if bmi is None or experience is None or freq is None:
        return jsonify({"error": "Missing fields: bmi, experience, weekly_frequency"}), 400

    result = generate_week_plan(bmi, experience, freq)
    return jsonify(result), 200

@app.route("/predict", methods=["POST"])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400
    file = request.files['image']

    # Read image bytes
    image_bytes = file.read()

    # Load image for YOLO
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    np_image = np.array(image)
    result = model_predict(image)
    return jsonify({"result" : result}), 200


@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "Backend is running!"})

# ----------------------
# Run server
# ----------------------
if __name__ == "__main__":
    app.run(debug=True)
