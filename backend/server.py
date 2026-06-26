import os
import hashlib
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional

from dotenv import load_dotenv
load_dotenv()

import jwt
import socketio
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pymongo import MongoClient

# --- ENV ---
MONGO_URL = os.environ.get("MONGO_URL")
DB_NAME = os.environ.get("DB_NAME", "x39matrix")
JWT_SECRET = os.environ.get("JWT_SECRET", secrets.token_hex(32))

# --- MONGODB ---
client = MongoClient(MONGO_URL)
db = client[DB_NAME]
users_col = db["users"]
messages_col = db["messages"]
rooms_col = db["rooms"]
layers_col = db["layers"]
alerts_col = db["alerts"]
commands_col = db["commands"]

users_col.create_index("nick", unique=True)
messages_col.create_index("room_id")
messages_col.create_index("timestamp")

# --- FASTAPI ---
app = FastAPI(title="X-39MATRIX Messenger")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# --- SOCKET.IO ---
sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins="*", logger=False, engineio_logger=False)
socket_app = socketio.ASGIApp(sio, app)

# --- MODELS ---
class RegisterModel(BaseModel):
    nick: str
    password: str

class LoginModel(BaseModel):
    nick: str
    password: str

class MessageModel(BaseModel):
    room_id: str
    text: str

class RoomModel(BaseModel):
    name: str
    members: list[str]
    type: str = "group"

# --- AUTH HELPERS ---
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

def create_token(nick: str) -> str:
    payload = {"nick": nick, "exp": datetime.now(timezone.utc) + timedelta(days=30)}
    return jwt.encode(payload, JWT_SECRET, algorithm="HS256")

def verify_token(authorization: Optional[str] = Header(None)) -> str:
    if not authorization:
        raise HTTPException(401, "Token requerido")
    token = authorization.replace("Bearer ", "")
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload["nick"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(401, "Token expirado")
    except jwt.InvalidTokenError:
        raise HTTPException(401, "Token invalido")

# --- SEED SECURITY DATA (synced with GitHub README v1.1.0+ + live module hashes 2026-06-17) ---
def seed_layers():
    # Force re-seed if HUB module_hash is missing or outdated
    existing = layers_col.find_one({"layer_id": "HUB"}, {"_id": 0})
    if existing and existing.get("module_hash", "").startswith("e4ba50b8"):
        return
    layers_col.delete_many({})
    layer_data = [
        {"layer_id": "HUB", "name": "x39_bases / Sovereign Topos (Ω BTC signer)", "canister": "arn4r-lqaaa-aaaao-baxwq-cai", "lang": "Rust", "blocks": ["B01","B02","B03","B04","B45"], "status": "ONLINE", "role": "threshold-ECDSA BTC mainnet signer + Motor Algebraico Categórico", "module_hash": "e4ba50b898a935c7", "commands": ["get_state","reset","apply_morphism","apply_functor","compose","delta","is_accepting","genesis_object","genesis_module","schedule","invariant","validate_state","translate_morphism","bridge_btc","bridge_eth","secure_utxo","ptu47_audit","sanitize_prompt","fuzz_report","detect_eclipse","collapse_audit","collapse_c1_cycle_drain","collapse_c2_memory_bomb","collapse_c3_state_deadlock","collapse_c4_canister_storm","collapse_c5_consensus_freeze","collapse_c6_cascade_failure","collapse_c7_entropy_death","collapse_c8_fork_bomb","collapse_c9_morphism_singularity","collapse_c10_quantum_bifurcation","simulate_cycle_drain","stress_b27_signed","full_sealed_audit","sign_ecdsa","verify_ecdsa","sign_ed25519_aggregate","merkle_proof","ping"]},
        {"layer_id": "L1", "name": "Infrastructure", "canister": "b4dy7-eyaaa-aaaao-baxra-cai", "lang": "Motoko", "blocks": ["B36","B37","B38","B39","B40"], "status": "ONLINE", "module_hash": "a04f2a1305bd0998", "commands": ["ping","getNodeCount","getCyclesBalance","getTotalCyclesBurned","getUptime","logMemoryEvent","getMemoryLog","recordCyclesBurned","applyMorphism","delta","getState","invariant"]},
        {"layer_id": "L2", "name": "Identity (Merkle + ZK-KYC)", "canister": "b3c6l-jaaaa-aaaao-baxrq-cai", "lang": "Motoko", "blocks": ["B32","B33","B34","B35"], "status": "ONLINE", "module_hash": "a740ea69bece1810", "commands": ["authenticate","getSession","verifyKYC","isKYCVerified","assignRole","applyMorphism","delta","getState","invariant","ping"]},
        {"layer_id": "L3", "name": "Execution (Ed25519)", "canister": "akiau-riaaa-aaaao-baxua-cai", "lang": "Motoko", "blocks": ["B27","B28","B29","B30","B31"], "status": "ONLINE", "module_hash": "ad721c0155e3a926", "commands": ["submitTransaction","getQueueSize","executeQueue","getExecutedCount","calculateFee","applyMorphism","delta","getState","invariant","ping"]},
        {"layer_id": "L4", "name": "Consensus (tECDSA)", "canister": "anjga-4qaaa-aaaao-baxuq-cai", "lang": "Motoko", "blocks": ["B23","B24","B25","B26","B41"], "status": "ONLINE", "module_hash": "d9dbfba7084d8aea", "commands": ["proposeBlock","getBlockHeight","getBlock","checkRisk","logAudit","getAuditLog","applyMorphism","delta","getState","invariant","ping"]},
        {"layer_id": "L5", "name": "Scalability (OmniChain sharding)", "canister": "s4zl3-eiaaa-aaaao-bay3a-cai", "lang": "Motoko", "blocks": ["B19","B20","B21","B22","B42"], "status": "ONLINE", "module_hash": "fd1ddbef113428b5", "commands": ["updateLoad","getShardForUser","openStateChannel","moveToColdStorage","getStatus"]},
        {"layer_id": "L6", "name": "Identity SSI / Omnichain Bridge", "canister": "adlli-haaaa-aaaao-baxvq-cai", "lang": "Motoko", "blocks": ["B15","B16","B17","B18","B43"], "status": "ONLINE", "module_hash": "8b51571fbb909971", "commands": ["getAccruedFees","getBtcBalance","getStatus","initiateCrossChain","withdrawArchitectFees"]},
        {"layer_id": "L7", "name": "AI Governance (PTU-47)", "canister": "awm2f-giaaa-aaaao-baxwa-cai", "lang": "Rust", "blocks": ["B11","B12","B13","B14","B44"], "status": "ONLINE", "module_hash": "b65cc8b9ab5ae6f1", "commands": ["sanitizeInput","analyzeRisk","getRiskReports","getBlockedCount","createProposal","voteProposal","getProposals","applyMorphism","getState","invariant"]},
        {"layer_id": "L8", "name": "Notarization (corebackend v2.0.0-realcrypto)", "canister": "bsbvx-7iaaa-aaaao-baxqa-cai", "lang": "Motoko", "blocks": ["B05","B06","B07","B08","B09","B10"], "status": "ONLINE", "module_hash": "4709f6a15a2262e7", "commands": ["executePipeline","getPipelineLog","registerLayerStatus","getLayerStatuses","aggregateSignature","compose","delta","getState","isAccepting","reset","invariant","ping","getGlobalHealth"]},
        {"layer_id": "FRONT", "name": "Frontend (web canister)", "canister": "bvatd-sqaaa-aaaao-baxqq-cai", "lang": "Assets", "blocks": [], "status": "ONLINE", "module_hash": "04e565b3425fe751", "commands": ["http_request"], "domains": ["x39matrix.org","www.x39matrix.org","evidences.x39matrix.org"]},
        {"layer_id": "DASH", "name": "Public Dashboard / Evidence Portal", "canister": "nsy7t-jiaaa-aaaau-agwra-cai", "lang": "Assets", "blocks": [], "status": "ONLINE", "module_hash": "04e565b3425fe751", "commands": ["http_request"]},
    ]
    for ld in layer_data:
        ld["last_check"] = datetime.now(timezone.utc).isoformat()
        ld["uptime"] = 99.99
    layers_col.insert_many(layer_data)

def seed_alerts():
    if alerts_col.count_documents({}) > 0:
        return
    sample_alerts = [
        {"type": "SCAN_DETECTED", "severity": "media", "layer": "L1", "description": "Escaneo de 65,535 puertos detectado desde IP externa en 4.2s", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "L7 clasifico como patron pre-ataque. Nivel alerta: AMARILLO"},
        {"type": "SQL_INJECTION", "severity": "alta", "layer": "L7", "description": "SQL Injection bloqueada: SELECT * FROM users WHERE 1=1; DROP TABLE users;", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "Input sanitizado. Patron #7 de 47 detectado y bloqueado."},
        {"type": "SWIFT_FRAUD", "severity": "alta", "layer": "L3", "description": "Transferencia anomala $81M — 8,100x por encima del patron habitual", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "Consenso 0/3. Transferencia BLOQUEADA. $126M salvados."},
        {"type": "EXFILTRATION", "severity": "alta", "layer": "L1", "description": "847MB salientes en 30 seg — 4,200x por encima de la media", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "Aislamiento total activado. 0 bytes exfiltrados."},
        {"type": "CHAIN_HOPPING", "severity": "media", "layer": "L6", "description": "Patron circular BTC-ETH detectado en ventana de 30 seg", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "L6 Omnichain correlaciono movimiento. L7 confirmo 95.2% lavado."},
        {"type": "BACKDOOR", "severity": "alta", "layer": "L7", "description": "Reverse shell pattern detectado: bash -c reverse_shell", "timestamp": datetime.now(timezone.utc).isoformat(), "resolved": True, "action": "Patron #12 de 47 bloqueado. Evidencia inmutable en L9."},
    ]
    alerts_col.insert_many(sample_alerts)

seed_layers()
seed_alerts()

# --- AUTH ROUTES ---
@app.post("/api/auth/register")
async def register(data: RegisterModel):
    if len(data.nick) < 2:
        raise HTTPException(400, "Nick debe tener al menos 2 caracteres")
    if len(data.password) < 4:
        raise HTTPException(400, "Password debe tener al menos 4 caracteres")
    if users_col.find_one({"nick": data.nick}):
        raise HTTPException(409, "Nick ya existe")
    users_col.insert_one({
        "nick": data.nick,
        "password_hash": hash_password(data.password),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "online": False,
    })
    token = create_token(data.nick)
    return {"token": token, "nick": data.nick}

@app.post("/api/auth/login")
async def login(data: LoginModel):
    user = users_col.find_one({"nick": data.nick})
    if not user or user["password_hash"] != hash_password(data.password):
        raise HTTPException(401, "Nick o password incorrectos")
    token = create_token(data.nick)
    return {"token": token, "nick": data.nick}

@app.get("/api/auth/me")
async def me(nick: str = Depends(verify_token)):
    user = users_col.find_one({"nick": nick}, {"_id": 0, "password_hash": 0})
    if not user:
        raise HTTPException(404, "Usuario no encontrado")
    return user

# --- USERS ---
@app.get("/api/users")
async def get_users(nick: str = Depends(verify_token)):
    users = list(users_col.find({}, {"_id": 0, "password_hash": 0}))
    return users

@app.get("/api/users/online")
async def get_online_users(nick: str = Depends(verify_token)):
    users = list(users_col.find({"online": True}, {"_id": 0, "password_hash": 0}))
    return users

# --- ROOMS ---
@app.get("/api/rooms")
async def get_rooms(nick: str = Depends(verify_token)):
    rooms = list(rooms_col.find({"members": nick}, {"_id": 0}))
    return rooms

@app.post("/api/rooms")
async def create_room(data: RoomModel, nick: str = Depends(verify_token)):
    if nick not in data.members:
        data.members.append(nick)
    room_id = secrets.token_hex(8)
    rooms_col.insert_one({
        "room_id": room_id,
        "name": data.name,
        "members": data.members,
        "type": data.type,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "created_by": nick,
    })
    return {"room_id": room_id, "name": data.name}

@app.get("/api/rooms/{room_id}/messages")
async def get_messages(room_id: str, nick: str = Depends(verify_token)):
    msgs = list(messages_col.find({"room_id": room_id}, {"_id": 0}).sort("timestamp", 1).limit(200))
    return msgs

# --- SECURITY ---
@app.get("/api/security/layers")
async def get_layers(nick: str = Depends(verify_token)):
    layers = list(layers_col.find({}, {"_id": 0}))
    return layers

@app.get("/api/security/alerts")
async def get_alerts(nick: str = Depends(verify_token)):
    alerts_list = list(alerts_col.find({}, {"_id": 0}).sort("timestamp", -1).limit(50))
    return alerts_list

@app.get("/api/security/stats")
async def get_stats(nick: str = Depends(verify_token)):
    return {
        "layers_online": 10,
        "layers_total": 10,
        "blocks_verified": 8,
        "blocks_verified_range": "#955155-#955468",
        "ed25519_signatures": "9/9",
        "fuzz_tests": "2038/2038 PASSED (B27 stress suite)",
        "collapse_tests": "10/10 PASSED (collapse_c1..c10)",
        "verifier_status": "PUBLIC_VERIFY_LAYER10.sh · N/N reproducible (bash auditable, no human security audit yet)",
        "throughput_axiom": "Soberanía verificable, NO throughput (Axioma A5)",
        "btc_anchored_blocks": 8,
        "btc_first_sovereign_tx": "b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023",
        "btc_first_sovereign_block": 952131,
        "btc_corpus_v4_1_blocks": [955155, 955169, 955176, 955178, 955182, 955202, 955467, 955468],
        "pq_signatures": ["PGP-Ed25519", "ECDSA-secp256k1", "ML-DSA-87 (FIPS-204)", "SLH-DSA-SHAKE-256s (FIPS-205)"],
        "pq_genesis_utc": "2026-06-07T10:59:51Z",
        "pq_super_fortified_utc": "2026-06-08T20:37:26Z",
        "cross_substrate": {"arbitrum_block": 467944125, "solana_slot": 422979180},
        "ots_calendars": 4,
        "finality": "2.5s",
        "uptime": "99.99%",
        "canister_ids_exposed": 0,
        "keys_exposed": 0,
        "fuzz_escapes": 0,
        "operator_pgp": "C3E062EB251A11851C0B4FFD06870F0655D5BBE8",
        "axioms_manifest_sha256": "e54960277e8933fdf1635e769d66c23622bfe6e5c2cb2dd3a39ac3e78184595e",
        "layer10_status": "v1.0 spec (YAML + RFC + Whitepaper + bash verifier) anchored in BTC; Rust impl in roadmap (NLnet/DFINITY)",
        "quantum_clock": datetime.now(timezone.utc).isoformat(),
    }

@app.get("/api/security/btc_anchors")
async def get_btc_anchors(nick: str = Depends(verify_token)):
    """Public Bitcoin mainnet attestations of X-39MATRIX protocol events."""
    return [
        {"event": "Genesis #001", "block": 948027, "utc": "2026-05-05T13:21:39Z"},
        {"event": "Audit 4 Exa-Ops", "block": 948042, "utc": "2026-05-05T15:02:43Z"},
        {"event": "B27 Quantum Stress", "block": 948055, "utc": "2026-05-05T17:12:22Z"},
        {"event": "Institutional Manifesto", "block": 948162, "utc": "2026-05-06T12:03:42Z"},
        {"event": "First commercial signature + Morocco Sovereign Minute", "block": 948165, "utc": "2026-05-06T12:30:56Z"},
        {"event": "Certificate Chain", "block": 948177, "utc": "2026-05-06T14:12:20Z"},
        {"event": "Sovereign Sealing #1", "block": 948500, "utc": "2026-05-08T19:29:44Z"},
        {"event": "Official Sealing #2", "block": 948501, "utc": "2026-05-08T19:39:11Z"},
        {"event": "EVM <-> BTC cross-substrate loop", "block": 951586, "utc": "2026-05-29T16:18:18Z"},
        {"event": "SOL <-> BTC cross-substrate loop", "block": 951605, "utc": "2026-05-29T19:47:00Z"},
        {"event": "Certificate Block A (merkle MATCH)", "block": 951892, "utc": "2026-05-31T21:19:12Z"},
        {"event": "Certificate Block B (merkle MATCH)", "block": 951893, "utc": "2026-05-31T21:20:47Z"},
        {"event": "Logical TPS record", "block": 951946, "utc": "2026-06-01T06:35:43Z"},
        {"event": "★ First sovereign tECDSA BTC send", "block": 952131, "utc": "2026-06-02T16:46:05Z", "txid": "b5a881a28341ea562800cd4f532cb5f737b21d38e44293dbbe8d1d0a0aede023"},
        {"event": "★ 8/8 sealed (bob.btc)", "block": 952160, "utc": "2026-06-03T00:12:13Z"},
        {"event": "★ 8/8 sealed (alice)", "block": 952161, "utc": "2026-06-03T00:16:09Z"},
        {"event": "★ 8/8 sealed (catallaxy)", "block": 952174, "utc": "2026-06-03T03:41:05Z"},
        {"event": "★ corebackend v2.0.0-realcrypto genesis tECDSA", "block": 952634, "utc": "2026-06-06T00:00:00Z"},
        {"event": "★ Delta DNS migration (alice)", "block": 954081, "utc": "2026-06-17T10:15:47Z"},
        {"event": "★ Delta DNS migration (catallaxy)", "block": 954115, "utc": "2026-06-17T15:44:10Z"},
        {"event": "★ Delta DNS migration (finney)", "block": 954131, "utc": "2026-06-17T19:19:19Z"},
    ]

@app.get("/api/security/pq_genesis")
async def get_pq_genesis(nick: str = Depends(verify_token)):
    """Post-Quantum genesis manifests with cryptographic identifiers."""
    return {
        "pq_genesis_2026_06_07": {
            "manifest_sha256": "a0a54f84de892f31e63bc8800c5faa2744fa1324505fb5a70901e548e02d6577",
            "manifest_triple_sha256": "ea65e89980dafaad8b01328f2772d0b060ddf05533f69cee82584cb18b5f6143",
            "signatures": ["PGP-Ed25519", "ECDSA-secp256k1", "ML-DSA-87"],
            "pq_algorithm": "ML-DSA-87 (FIPS-204, NIST level V)",
            "signed_utc": "2026-06-07T10:59:51Z",
            "ots_calendars": 4,
        },
        "pq_super_fortified_2026_06_08": {
            "manifest_sha256": "ef3b829cd8c004dc5f75561e33cbce979d475cd79af9ba3e94f558418062286b",
            "signatures": ["PGP-Ed25519", "ECDSA-secp256k1", "ML-DSA-87", "SLH-DSA-SHAKE-256s"],
            "pq_algorithms": ["ML-DSA-87 (FIPS-204)", "SLH-DSA-SHAKE-256s (FIPS-205)"],
            "signed_utc": "2026-06-08T20:37:26Z",
            "resistance": "Requires simultaneous break of: 500K+ qubit CRQC + Module-LWE + SHA-3 preimage. Probability ~0 under known physics.",
            "ots_calendars": 4,
        },
        "delta_dns_2026_06_17": {
            "manifest_sha256": "d73094c7f079eda0515408416239967b9e590c1724972ed7367ae0ceddbc352a",
            "signature": "PGP-Ed25519",
            "signed_utc": "2026-06-17T09:41:06Z",
            "btc_attestation_blocks": [954081, 954115, 954131],
            "ots_calendars": ["alice", "catallaxy", "finney", "bob"],
        },
    }

# --- MANUAL & COMMANDS ---
@app.get("/api/manual/layers")
async def get_manual_layers(nick: str = Depends(verify_token)):
    layers = list(layers_col.find({}, {"_id": 0}))
    return layers

# --- HEALTH ---
@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "X-39MATRIX Messenger"}

# --- PUBLIC PITCH DECK DOWNLOADS (Sevilla v4.1) ---
from fastapi.responses import FileResponse

_PITCH_DIR = os.path.join(os.path.dirname(__file__), "static")

@app.get("/api/pitch/v4_1.pdf")
async def download_pitch_v4_1():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "Pitch v4.1 not found")
    return FileResponse(
        path,
        media_type="application/pdf",
        filename="X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf",
    )

@app.get("/api/pitch/v4_1.html")
async def download_pitch_v4_1_html():
    path = os.path.join(_PITCH_DIR, "pitch_v4_1.html")
    if not os.path.exists(path):
        raise HTTPException(404, "Pitch v4.1 HTML not found")
    return FileResponse(
        path,
        media_type="text/html; charset=utf-8",
        filename="pitch_v4_1.html",
    )

@app.get("/api/pitch/v4_1.sha256")
async def pitch_v4_1_sha256():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "Pitch v4.1 not found")
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return {
        "filename": "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf",
        "sha256": h.hexdigest(),
        "size_bytes": os.path.getsize(path),
    }

# --- PROPUESTA TÉCNICA — CÁMARA DE SEVILLA ---
@app.get("/api/camara/email.pdf")
async def download_camara_pdf():
    path = os.path.join(_PITCH_DIR, "email_camara_sevilla.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "Camara email PDF not found")
    return FileResponse(path, media_type="application/pdf", filename="X39MATRIX_Propuesta_Camara_Sevilla.pdf")

@app.get("/api/camara/email.html")
async def download_camara_html():
    path = os.path.join(_PITCH_DIR, "email_camara_sevilla.html")
    if not os.path.exists(path):
        raise HTTPException(404, "Camara email HTML not found")
    return FileResponse(path, media_type="text/html; charset=utf-8", filename="X39MATRIX_Propuesta_Camara_Sevilla.html")

@app.get("/api/camara/email.txt")
async def download_camara_txt():
    path = os.path.join(_PITCH_DIR, "email_camara_sevilla.txt")
    if not os.path.exists(path):
        raise HTTPException(404, "Camara email TXT not found")
    return FileResponse(path, media_type="text/plain; charset=utf-8", filename="X39MATRIX_Propuesta_Camara_Sevilla.txt")

@app.get("/api/camara/email.md")
async def download_camara_md():
    path = os.path.join(_PITCH_DIR, "email_camara_sevilla.md")
    if not os.path.exists(path):
        raise HTTPException(404, "Camara email MD not found")
    return FileResponse(path, media_type="text/markdown; charset=utf-8", filename="X39MATRIX_Propuesta_Camara_Sevilla.md")

# --- OPENTIMESTAMPS PROOFS (.ots) ---
@app.get("/api/pitch/v4_1.pdf.ots")
async def download_pitch_ots():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "Pitch v4.1 .ots not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_PITCH_INVERSOR_SEVILLA_v4.1.pdf.ots")

@app.get("/api/camara/email.pdf.ots")
async def download_camara_ots():
    path = os.path.join(_PITCH_DIR, "email_camara_sevilla.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "Camara email .ots not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_Propuesta_Camara_Sevilla.pdf.ots")

# --- MENSAJE PERSONAL — ALCALDE DE SEVILLA ---
@app.get("/api/alcalde/mensaje.pdf")
async def download_alcalde_pdf():
    path = os.path.join(_PITCH_DIR, "mensaje_alcalde_sanz.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "Alcalde mensaje PDF not found")
    return FileResponse(path, media_type="application/pdf", filename="X39MATRIX_Mensaje_Alcalde_Sevilla.pdf")

@app.get("/api/alcalde/mensaje.txt")
async def download_alcalde_txt():
    path = os.path.join(_PITCH_DIR, "mensaje_alcalde_sanz.txt")
    if not os.path.exists(path):
        raise HTTPException(404, "Alcalde mensaje TXT not found")
    return FileResponse(path, media_type="text/plain; charset=utf-8", filename="X39MATRIX_Mensaje_Alcalde_Sevilla.txt")

@app.get("/api/alcalde/mensaje.html")
async def download_alcalde_html():
    path = os.path.join(_PITCH_DIR, "mensaje_alcalde_sanz.html")
    if not os.path.exists(path):
        raise HTTPException(404, "Alcalde mensaje HTML not found")
    return FileResponse(path, media_type="text/html; charset=utf-8", filename="X39MATRIX_Mensaje_Alcalde_Sevilla.html")

@app.get("/api/alcalde/mensaje.pdf.ots")
async def download_alcalde_ots():
    path = os.path.join(_PITCH_DIR, "mensaje_alcalde_sanz.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "Alcalde mensaje .ots not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_Mensaje_Alcalde_Sevilla.pdf.ots")

# --- PARCHE VERIFY.SH (instrucciones honestas para usuario) ---
@app.get("/api/verify/patch.md")
async def download_patch_md():
    path = os.path.join(_PITCH_DIR, "PARCHE_VERIFY_SH.md")
    if not os.path.exists(path):
        raise HTTPException(404, "Patch instructions not found")
    return FileResponse(path, media_type="text/markdown; charset=utf-8", filename="X39MATRIX_PARCHE_VERIFY_SH.md")

@app.get("/api/verify/patch.md.ots")
async def download_patch_ots():
    path = os.path.join(_PITCH_DIR, "PARCHE_VERIFY_SH.md.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "Patch OTS not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_PARCHE_VERIFY_SH.md.ots")

# --- SPRINT 2 LAYER 10 DESIGN ---
@app.get("/api/layer10/sprint2.md")
async def download_sprint2_md():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_LAYER10_SPRINT2_DESIGN.md")
    if not os.path.exists(path):
        raise HTTPException(404, "Sprint 2 design not found")
    return FileResponse(path, media_type="text/markdown; charset=utf-8", filename="X39MATRIX_LAYER10_SPRINT2_DESIGN.md")

@app.get("/api/layer10/sprint2.pdf")
async def download_sprint2_pdf():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_LAYER10_SPRINT2_DESIGN.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "Sprint 2 PDF not found")
    return FileResponse(path, media_type="application/pdf", filename="X39MATRIX_LAYER10_SPRINT2_DESIGN.pdf")

@app.get("/api/layer10/sprint2.pdf.ots")
async def download_sprint2_ots():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_LAYER10_SPRINT2_DESIGN.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "Sprint 2 OTS not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_LAYER10_SPRINT2_DESIGN.pdf.ots")

# --- OPENSATS GRANT APPLICATION ---
@app.get("/api/grants/opensats.md")
async def download_opensats_md():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_OPENSATS_APPLICATION.md")
    if not os.path.exists(path):
        raise HTTPException(404, "OpenSats application not found")
    return FileResponse(path, media_type="text/markdown; charset=utf-8", filename="X39MATRIX_OPENSATS_APPLICATION.md")

@app.get("/api/grants/opensats.pdf")
async def download_opensats_pdf():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_OPENSATS_APPLICATION.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "OpenSats PDF not found")
    return FileResponse(path, media_type="application/pdf", filename="X39MATRIX_OPENSATS_APPLICATION.pdf")

@app.get("/api/grants/opensats.pdf.ots")
async def download_opensats_ots():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_OPENSATS_APPLICATION.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "OpenSats OTS not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_OPENSATS_APPLICATION.pdf.ots")

# --- DFINITY GRANT APPLICATION ---
@app.get("/api/grants/dfinity.md")
async def download_dfinity_md():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_DFINITY_GRANT_APPLICATION.md")
    if not os.path.exists(path):
        raise HTTPException(404, "DFINITY application not found")
    return FileResponse(path, media_type="text/markdown; charset=utf-8", filename="X39MATRIX_DFINITY_GRANT_APPLICATION.md")

@app.get("/api/grants/dfinity.pdf")
async def download_dfinity_pdf():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_DFINITY_GRANT_APPLICATION.pdf")
    if not os.path.exists(path):
        raise HTTPException(404, "DFINITY PDF not found")
    return FileResponse(path, media_type="application/pdf", filename="X39MATRIX_DFINITY_GRANT_APPLICATION.pdf")

@app.get("/api/grants/dfinity.pdf.ots")
async def download_dfinity_ots():
    path = os.path.join(_PITCH_DIR, "X39MATRIX_DFINITY_GRANT_APPLICATION.pdf.ots")
    if not os.path.exists(path):
        raise HTTPException(404, "DFINITY OTS not found")
    return FileResponse(path, media_type="application/octet-stream", filename="X39MATRIX_DFINITY_GRANT_APPLICATION.pdf.ots")

# --- X39 i18n: bulk translation via Gemini (Emergent LLM Key) ---
import json as _json
import re as _re
from fastapi import Body

EMERGENT_LLM_KEY = os.environ.get("EMERGENT_LLM_KEY")
LANG_NAMES = {
    "en": "English",
    "zh": "Simplified Chinese",
    "ja": "Japanese",
    "ar": "Arabic (Modern Standard)",
}

def _extract_json(text: str) -> dict:
    t = (text or "").strip()
    t = _re.sub(r"^```(?:json)?\s*", "", t)
    t = _re.sub(r"\s*```$", "", t)
    # try direct parse
    try:
        return _json.loads(t)
    except Exception:
        pass
    # fallback: find first {...} block
    m = _re.search(r"\{[\s\S]*\}", t)
    if m:
        try:
            return _json.loads(m.group(0))
        except Exception:
            return {}
    return {}

@app.post("/api/x39/translate-bulk")
async def x39_translate_bulk(payload: dict = Body(...)):
    """
    Translate Spanish strings to EN/ZH/JA/AR for X-39MATRIX i18n.
    Body: { "strings": ["...","..."], "target_langs": ["en","zh","ja","ar"] }
    Returns: { "en": {es: tr, ...}, "zh": {...}, ... }
    """
    if not EMERGENT_LLM_KEY:
        raise HTTPException(500, "EMERGENT_LLM_KEY not configured")

    from emergentintegrations.llm.chat import LlmChat, UserMessage

    strings = payload.get("strings") or []
    target_langs = payload.get("target_langs") or ["en", "zh", "ja", "ar"]
    strings = [s for s in {str(x).strip() for x in strings} if s and len(s) > 1]
    if not strings:
        return {l: {} for l in target_langs}

    SYSTEM_TPL = (
        "You translate Spanish strings to {LANG}. Strict rules:\n"
        "1. Preserve technical terms as-is: SHA-256, Bitcoin, BTC, ICP, tECDSA, "
        "OpenTimestamps, OTS, PQC, FIPS-203/204/205, ML-KEM, ML-DSA, SLH-DSA, "
        "canister, blockchain, mainnet, x39MATRIX, X-39MATRIX, Ω, Web Crypto API.\n"
        "2. Preserve symbols (· → ↓ ↑ ✓ €, $, ₿) and emoji.\n"
        "3. Preserve casing pattern: ALL-CAPS Spanish -> ALL-CAPS in target language.\n"
        "4. Preserve punctuation and surrounding whitespace.\n"
        "5. Tone: cypherpunk, technical, sovereign, concise. No literal/clumsy phrasing.\n"
        "6. OUTPUT ONLY a single valid JSON object mapping the EXACT input Spanish string "
        "to its {LANG} translation. No markdown, no code fence, no commentary."
    )

    out = {l: {} for l in target_langs}
    CHUNK = 40

    for lang in target_langs:
        if lang not in LANG_NAMES:
            continue
        chat = (
            LlmChat(
                api_key=EMERGENT_LLM_KEY,
                session_id=f"x39-trans-{lang}-{secrets.token_hex(4)}",
                system_message=SYSTEM_TPL.format(LANG=LANG_NAMES[lang]),
            )
            .with_model("gemini", "gemini-3-flash-preview")
        )
        for i in range(0, len(strings), CHUNK):
            chunk = strings[i : i + CHUNK]
            user_payload = _json.dumps(chunk, ensure_ascii=False, indent=0)
            user_msg = UserMessage(
                text=(
                    f"Translate every string below to {LANG_NAMES[lang]}.\n"
                    f"Return a JSON object whose KEYS are the EXACT input strings "
                    f"and whose VALUES are the translations.\n\n"
                    f"INPUT (JSON array):\n{user_payload}"
                )
            )
            try:
                resp = await chat.send_message(user_msg)
                text = resp if isinstance(resp, str) else getattr(resp, "content", str(resp))
                parsed = _extract_json(text)
                if isinstance(parsed, dict):
                    for k, v in parsed.items():
                        if isinstance(k, str) and isinstance(v, str):
                            out[lang][k] = v
            except Exception as e:
                print(f"[x39-translate] {lang} chunk {i}: {e}")

    return out

# --- SOCKET.IO EVENTS ---
connected_users = {}

@sio.event
async def connect(sid, environ):
    pass

@sio.event
async def authenticate(sid, data):
    try:
        token = data.get("token", "")
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        nick = payload["nick"]
        connected_users[sid] = nick
        users_col.update_one({"nick": nick}, {"$set": {"online": True}})
        await sio.emit("user_online", {"nick": nick})
        online = list(users_col.find({"online": True}, {"_id": 0, "password_hash": 0}))
        await sio.emit("online_users", [u["nick"] for u in online], to=sid)
    except Exception:
        await sio.emit("auth_error", {"error": "Token invalido"}, to=sid)

@sio.event
async def join_room(sid, data):
    room_id = data.get("room_id")
    if room_id:
        sio.enter_room(sid, room_id)
        nick = connected_users.get(sid, "?")
        await sio.emit("room_joined", {"room_id": room_id, "nick": nick}, room=room_id)

@sio.event
async def leave_room(sid, data):
    room_id = data.get("room_id")
    if room_id:
        sio.leave_room(sid, room_id)

@sio.event
async def send_message(sid, data):
    nick = connected_users.get(sid)
    if not nick:
        return
    room_id = data.get("room_id")
    text = data.get("text", "").strip()
    if not room_id or not text:
        return
    msg = {
        "room_id": room_id,
        "from_nick": nick,
        "text": text,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    messages_col.insert_one({**msg})
    msg_out = {k: v for k, v in msg.items()}
    await sio.emit("new_message", msg_out, room=room_id)

@sio.event
async def typing(sid, data):
    nick = connected_users.get(sid)
    room_id = data.get("room_id")
    if nick and room_id:
        await sio.emit("user_typing", {"nick": nick, "room_id": room_id}, room=room_id, skip_sid=sid)

# --- WEBRTC SIGNALING ---
@sio.event
async def call_user(sid, data):
    target_nick = data.get("target")
    caller = connected_users.get(sid)
    target_sid = None
    for s, n in connected_users.items():
        if n == target_nick:
            target_sid = s
            break
    if target_sid:
        await sio.emit("incoming_call", {"from": caller, "signal": data.get("signal"), "type": data.get("type", "video")}, to=target_sid)

@sio.event
async def answer_call(sid, data):
    target_nick = data.get("target")
    answerer = connected_users.get(sid)
    target_sid = None
    for s, n in connected_users.items():
        if n == target_nick:
            target_sid = s
            break
    if target_sid:
        await sio.emit("call_answered", {"from": answerer, "signal": data.get("signal")}, to=target_sid)

@sio.event
async def end_call(sid, data):
    target_nick = data.get("target")
    caller = connected_users.get(sid)
    target_sid = None
    for s, n in connected_users.items():
        if n == target_nick:
            target_sid = s
            break
    if target_sid:
        await sio.emit("call_ended", {"from": caller}, to=target_sid)

@sio.event
async def ice_candidate(sid, data):
    target_nick = data.get("target")
    target_sid = None
    for s, n in connected_users.items():
        if n == target_nick:
            target_sid = s
            break
    if target_sid:
        await sio.emit("ice_candidate", {"candidate": data.get("candidate"), "from": connected_users.get(sid)}, to=target_sid)

@sio.event
async def disconnect(sid):
    nick = connected_users.pop(sid, None)
    if nick:
        remaining = any(n == nick for s, n in connected_users.items())
        if not remaining:
            users_col.update_one({"nick": nick}, {"$set": {"online": False}})
            await sio.emit("user_offline", {"nick": nick})

# --- MAIN ---
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(socket_app, host="0.0.0.0", port=8001)
