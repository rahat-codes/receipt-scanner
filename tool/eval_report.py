#!/usr/bin/env python3
import json
import glob
import os

def normalize_merchant(name):
    if not name:
        return ""
    return name.lower().replace(" ", "").replace("(주)", "").replace("주식회사", "").replace("inc", "").replace("store", "")

def loose_match_merchant(label, pred):
    l_norm = normalize_merchant(label)
    p_norm = normalize_merchant(pred)
    if not l_norm and not p_norm:
        return True
    if not l_norm or not p_norm:
        return False
    return l_norm in p_norm or p_norm in l_norm

def main():
    fixture_files = sorted(glob.glob("test/fixtures/ocr/*.label.json"))
    if not fixture_files:
        print("==================================================")
        print("            EVALUATION REPORT                     ")
        print("==================================================")
        print("Total receipts evaluated : 0")
        print("Merchant Accuracy        : 0.0%")
        print("Date Accuracy            : 0.0%")
        print("Total Amount Accuracy    : 0.0%")
        print("--------------------------------------------------")
        print("CALIBRATION ANALYSIS:")
        print("Avg Confidence (All Correct)      : N/A")
        print("Avg Confidence (At Least 1 Wrong) : N/A")
        print("==================================================")
        return

    total_count = 0
    merchant_correct = 0
    date_correct = 0
    total_correct = 0

    correct_confidences = []
    wrong_confidences = []

    failed_receipts = []

    for label_path in fixture_files:
        base_name = os.path.basename(label_path).replace(".label.json", "")
        pred_path = os.path.join("eval/predictions", f"{base_name}.json")
        txt_path = os.path.join("test/fixtures/ocr", f"{base_name}.txt")

        with open(label_path, "r", encoding="utf-8") as f:
            label = json.load(f)

        pred = {}
        if os.path.exists(pred_path):
            with open(pred_path, "r", encoding="utf-8") as f:
                pred = json.load(f)

        ocr_lines = []
        if os.path.exists(txt_path):
            with open(txt_path, "r", encoding="utf-8") as f:
                ocr_lines = [line.strip() for line in f.readlines() if line.strip()][:3]

        total_count += 1

        m_match = loose_match_merchant(label.get("merchant", ""), pred.get("merchant", ""))
        d_match = (label.get("date") == pred.get("date"))
        t_match = (label.get("total_minor") == pred.get("total_minor"))

        if m_match: merchant_correct += 1
        if d_match: date_correct += 1
        if t_match: total_correct += 1

        confidence = pred.get("confidence", 0.0)
        all_correct = m_match and d_match and t_match

        if all_correct:
            correct_confidences.append(confidence)
        else:
            wrong_confidences.append(confidence)
            failed_receipts.append({
                "id": base_name,
                "label": label,
                "pred": pred,
                "ocr_first_3": ocr_lines,
                "confidence": confidence
            })

    m_acc = (merchant_correct / total_count) * 100 if total_count > 0 else 0.0
    d_acc = (date_correct / total_count) * 100 if total_count > 0 else 0.0
    t_acc = (total_correct / total_count) * 100 if total_count > 0 else 0.0

    avg_corr_conf = (sum(correct_confidences) / len(correct_confidences)) if correct_confidences else None
    avg_wrong_conf = (sum(wrong_confidences) / len(wrong_confidences)) if wrong_confidences else None

    print("==================================================")
    print("            EVALUATION REPORT                     ")
    print("==================================================")
    print(f"Total receipts evaluated : {total_count}")
    print(f"Merchant Accuracy        : {m_acc:.1f}% ({merchant_correct}/{total_count})")
    print(f"Date Accuracy            : {d_acc:.1f}% ({date_correct}/{total_count})")
    print(f"Total Amount Accuracy    : {t_acc:.1f}% ({total_correct}/{total_count})")
    print("--------------------------------------------------")
    print("CALIBRATION ANALYSIS:")
    print(f"Avg Confidence (All Correct)      : {f'{avg_corr_conf:.2f}' if avg_corr_conf is not None else 'N/A'}")
    print(f"Avg Confidence (At Least 1 Wrong) : {f'{avg_wrong_conf:.2f}' if avg_wrong_conf is not None else 'N/A'}")
    print("==================================================")

    if failed_receipts:
        print("\nFAILED RECEIPTS TABLE:")
        print(f"{'ID':<8} | {'Field':<10} | {'Label':<20} | {'Prediction':<20} | {'Confidence'}")
        print("-" * 75)
        for item in failed_receipts:
            b_id = item["id"]
            lbl = item["label"]
            prd = item["pred"]
            conf = item["confidence"]

            if not loose_match_merchant(lbl.get("merchant", ""), prd.get("merchant", "")):
                print(f"{b_id:<8} | {'merchant':<10} | {str(lbl.get('merchant')):<20} | {str(prd.get('merchant')):<20} | {conf:.2f}")
            if lbl.get("date") != prd.get("date"):
                print(f"{b_id:<8} | {'date':<10} | {str(lbl.get('date')):<20} | {str(prd.get('date')):<20} | {conf:.2f}")
            if lbl.get("total_minor") != prd.get("total_minor"):
                print(f"{b_id:<8} | {'total_minor':<10} | {str(lbl.get('total_minor')):<20} | {str(prd.get('total_minor')):<20} | {conf:.2f}")

if __name__ == "__main__":
    main()
