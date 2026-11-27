# OCR Fixtures

- `NNN.txt`: Raw OCR text copied from the debug screen.
- `NNN.label.json`: Expected labels matching the schema:
  ```json
  {"merchant": "...", "date": "YYYY-MM-DD", "total_minor": 1234, "currency": "KRW"}
  ```
- OcrResult is constructed from `.txt` with each line's `top = lineIndex / lineCount`.
