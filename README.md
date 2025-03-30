
# ✍️ MATLAB Handwriting Style Analysis (Group 24)

This project is a MATLAB-based GUI application designed for analyzing handwriting styles — specifically **Cursive** and **Print** — using six distinctive image-based features.

Developed as part of the **Image Processing, Computer Vision and Pattern Recognition (122024-SIV)** assignment at APU.

---

## 👨‍💻 Author
**Luai**  

---

## 🧠 Features Extracted

The GUI extracts three features for each handwriting style:

### ✒️ Cursive:
1. **Pen-Lift Frequency** – Number of disconnected strokes (skeleton components).
2. **Intersection Density** – Frequency of intersections in the skeletonized image.
3. **Proportion of Merged Letters** – Ratio of wide bounding boxes indicating letter merging.

### 🔤 Print:
1. **Character Rectangularity** – Compactness of letters within their bounding boxes.
2. **Width Variance** – Variation in character widths.
3. **Avg. Black-White Transitions** – Horizontal pixel intensity transitions per row.

---

## 🖼️ GUI Overview

The app allows users to:
- Load a handwriting image.
- Choose the writing style (Cursive or Print).
- View the **original** and **processed** (binary) image.
- Extract and display relevant features in a text panel.

---

## 🧪 How to Use

1. Open the `Group24.m` script in MATLAB.
2. Run the file to launch the GUI.
3. Click **"Pick Image"** to upload a handwriting sample (JPG/PNG).
4. Select the style: **Cursive** or **Print**.
5. Click **"Extract Features"** to analyze the image.

---

## 📂 Folder Structure

```
📁 Handwriting Style/
├── Group24.m               # Main GUI + logic
├── README.md               # This file
├── /images/                # Handwriting samples (add your own)
```

---

## 🛠 Requirements

- MATLAB R2021a or later
- Image Processing Toolbox

---


## 📘 License

This project is for educational purposes and is not licensed for commercial use.
