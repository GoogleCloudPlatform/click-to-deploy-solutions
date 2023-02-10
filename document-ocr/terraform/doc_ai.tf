resource "google_document_ai_processor" "processor" {
  location     = var.location
  display_name = "ocr-processor-${var.location}"
  type         = "OCR_PROCESSOR"
}
