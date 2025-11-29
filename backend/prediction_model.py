from ultralytics import YOLO

# Load a model
model = YOLO("runs/classify/train/weights/last.pt")  # pretrained YOLO11n model

class_map = {
        0: "Apple",
        1: "Beef Noodle Soup",
        2: "Dumplings",
        3: "Fried Chicken",
        4: "Fried Rice",
        5: "Grilled Meat Skewer",
        6: "Hot Pot",
        7: "Lychee",
        8: "Mixed Asian Crusine",
        9: "Noodle Soup",
        10: "Pizza",
        11: "Stir-fried Noodles",
        12: "Watermelon"
    }

def model_predict(image):
    pred = model(image)
    cls = pred[0].probs.top1
    return class_map[cls]
