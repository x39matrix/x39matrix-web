"""
Backend tests for public pitch deck & Cámara de Sevilla download endpoints.
All endpoints are PUBLIC (no auth).
"""
import os
import hashlib
import pytest
import requests

BASE_URL = os.environ.get("REACT_APP_BACKEND_URL", "https://estado-protocolo.preview.emergentagent.com").rstrip("/")

EXPECTED_PITCH_SHA256 = "9bf4f6eacc2ada98e538352632ed3eae905604a29cef39771b14a07b4f123b4e"


@pytest.fixture
def client():
    s = requests.Session()
    return s


# ---- Pitch v4.1 PDF ----
class TestPitchPDF:
    def test_pitch_pdf_status_and_content_type(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf", timeout=30)
        assert r.status_code == 200, f"Status was {r.status_code}"
        assert r.headers.get("content-type", "").startswith("application/pdf"), \
            f"content-type was {r.headers.get('content-type')}"

    def test_pitch_pdf_magic_bytes_and_size(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf", timeout=30)
        assert r.status_code == 200
        body = r.content
        assert body.startswith(b"%PDF"), f"Magic bytes wrong: {body[:8]!r}"
        # Size should be ~95952 bytes (allow +/- 5% tolerance)
        assert 90000 <= len(body) <= 100000, f"Size was {len(body)} bytes"

    def test_pitch_pdf_sha256_matches_expected(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf", timeout=30)
        assert r.status_code == 200
        actual = hashlib.sha256(r.content).hexdigest()
        assert actual == EXPECTED_PITCH_SHA256, \
            f"SHA-256 mismatch. Expected {EXPECTED_PITCH_SHA256}, got {actual}"

    def test_pitch_pdf_content_disposition(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf", timeout=30)
        assert r.status_code == 200
        cd = r.headers.get("content-disposition", "")
        assert "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf" in cd, \
            f"Content-Disposition missing expected filename: {cd}"


# ---- Pitch v4.1 .ots ----
class TestPitchOTS:
    def test_pitch_ots_status_and_content_type(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf.ots", timeout=30)
        assert r.status_code == 200
        assert r.headers.get("content-type", "").startswith("application/octet-stream"), \
            f"content-type was {r.headers.get('content-type')}"

    def test_pitch_ots_size_and_non_html(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf.ots", timeout=30)
        assert r.status_code == 200
        body = r.content
        assert len(body) > 0, "OTS file is empty"
        # ~630 bytes — allow tolerance
        assert 200 <= len(body) <= 2000, f"OTS size out of range: {len(body)}"
        # NOT HTML error page
        lower = body[:200].lower()
        assert b"<html" not in lower, "OTS returned HTML error page"
        assert b"<!doctype" not in lower, "OTS returned HTML error page"

    def test_pitch_ots_magic_bytes(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf.ots", timeout=30)
        assert r.status_code == 200
        body = r.content
        # OpenTimestamps file header magic: starts with 0x004f70 'OpenTimestamps' style.
        # ots files begin with the bytes: \x00OpenTimestamps\x00\x00Proof\x00\xbf\x89\xe2\xe8\x84\xe8\x92\x94
        assert body[:1] == b"\x00" and b"OpenTimestamps" in body[:32], \
            f"OTS magic not found in first 32 bytes: {body[:32]!r}"


# ---- Pitch v4.1 SHA256 JSON ----
class TestPitchSHA256:
    def test_sha256_endpoint_status(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.sha256", timeout=30)
        assert r.status_code == 200
        assert "application/json" in r.headers.get("content-type", "")

    def test_sha256_payload(self, client):
        r = client.get(f"{BASE_URL}/api/pitch/v4_1.sha256", timeout=30)
        assert r.status_code == 200
        data = r.json()
        assert "filename" in data
        assert "sha256" in data
        assert "size_bytes" in data
        assert data["sha256"] == EXPECTED_PITCH_SHA256, \
            f"sha256 mismatch in JSON: {data['sha256']}"
        assert data["filename"] == "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf"
        assert isinstance(data["size_bytes"], int) and data["size_bytes"] > 0

    def test_sha256_consistent_with_pdf_download(self, client):
        pdf = client.get(f"{BASE_URL}/api/pitch/v4_1.pdf", timeout=30)
        sha_json = client.get(f"{BASE_URL}/api/pitch/v4_1.sha256", timeout=30).json()
        actual = hashlib.sha256(pdf.content).hexdigest()
        assert actual == sha_json["sha256"], \
            "PDF content SHA-256 does not match SHA-256 endpoint value"
        assert len(pdf.content) == sha_json["size_bytes"], \
            f"PDF size mismatch: got {len(pdf.content)} vs reported {sha_json['size_bytes']}"


# ---- Cámara email PDF ----
class TestCamaraPDF:
    def test_camara_pdf_status_and_content_type(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.pdf", timeout=30)
        assert r.status_code == 200
        assert r.headers.get("content-type", "").startswith("application/pdf")

    def test_camara_pdf_magic_and_size(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.pdf", timeout=30)
        assert r.status_code == 200
        body = r.content
        assert body.startswith(b"%PDF")
        assert 50000 <= len(body) <= 65000, f"Size was {len(body)}"


# ---- Cámara email .ots ----
class TestCamaraOTS:
    def test_camara_ots_status_content_type(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.pdf.ots", timeout=30)
        assert r.status_code == 200
        assert r.headers.get("content-type", "").startswith("application/octet-stream")

    def test_camara_ots_size_and_magic(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.pdf.ots", timeout=30)
        assert r.status_code == 200
        body = r.content
        assert 200 <= len(body) <= 2000
        assert b"<html" not in body[:200].lower()
        assert body[:1] == b"\x00" and b"OpenTimestamps" in body[:32], \
            f"OTS magic missing: {body[:32]!r}"


# ---- Cámara HTML ----
class TestCamaraHTML:
    def test_camara_html_status_and_type(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.html", timeout=30)
        assert r.status_code == 200
        ct = r.headers.get("content-type", "")
        assert "text/html" in ct
        assert "charset=utf-8" in ct.lower()

    def test_camara_html_contains_keywords(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.html", timeout=30)
        assert r.status_code == 200
        text = r.text
        for needle in ["X-39MATRIX", "Francisco Leal", "TIC Negocios"]:
            assert needle in text, f"Missing '{needle}' in HTML"


# ---- Cámara TXT ----
class TestCamaraTXT:
    def test_camara_txt_status_and_type(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.txt", timeout=30)
        assert r.status_code == 200
        ct = r.headers.get("content-type", "")
        assert "text/plain" in ct
        assert "charset=utf-8" in ct.lower()

    def test_camara_txt_contains_keywords(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.txt", timeout=30)
        assert r.status_code == 200
        text = r.text
        for needle in ["X-39MATRIX", "Francisco Leal", "+34 643 105 983"]:
            assert needle in text, f"Missing '{needle}' in TXT"


# ---- Cámara MD ----
class TestCamaraMD:
    def test_camara_md_status_and_type(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.md", timeout=30)
        assert r.status_code == 200
        ct = r.headers.get("content-type", "")
        assert "text/markdown" in ct
        assert "charset=utf-8" in ct.lower()

    def test_camara_md_contains_keywords(self, client):
        r = client.get(f"{BASE_URL}/api/camara/email.md", timeout=30)
        assert r.status_code == 200
        text = r.text
        assert "## 1. Qué es X-39MATRIX" in text, "Missing section header in MD"
        assert "Capa 10" in text, "Missing 'Capa 10' in MD"
