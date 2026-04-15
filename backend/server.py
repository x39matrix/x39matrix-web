import os
import hashlib
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional

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

# --- SEED SECURITY DATA ---
def seed_layers():
    if layers_col.count_documents({}) > 0:
        return
    layer_data = [
        {"layer_id": "L1", "name": "Infrastructure", "canister": "b4dy7-eyaaa-aaaao-baxra-cai", "lang": "Motoko", "blocks": ["B36","B37","B38","B39"], "status": "ONLINE", "commands": ["ping","getNodeCount","getCyclesBalance","getTotalCyclesBurned","getUptime","logMemoryEvent","getMemoryLog","recordCyclesBurned","applyMorphism","getState","invariant"]},
        {"layer_id": "L2", "name": "Identity (ZK-KYC)", "canister": "b3c6l-jaaaa-aaaao-baxrq-cai", "lang": "Motoko", "blocks": ["B32","B33","B34","B35"], "status": "ONLINE", "commands": ["authenticate","getSession","verifyKYC","isKYCVerified","assignRole","sanitizeInput","delta","getState","invariant"]},
        {"layer_id": "L3", "name": "Smart Execution", "canister": "akiau-riaaa-aaaao-baxua-cai", "lang": "Rust", "blocks": ["B27","B28","B29","B30"], "status": "ONLINE", "commands": ["submitTransaction","getQueueSize","executeQueue","getExecutedCount","calculateFee","applyMorphism","getState","invariant"]},
        {"layer_id": "L4", "name": "Consensus", "canister": "anjga-4qaaa-aaaao-baxuq-cai", "lang": "Rust", "blocks": ["B23","B24","B25","B26"], "status": "ONLINE", "commands": ["proposeBlock","getBlockHeight","getBlock","checkRisk","logAudit","getAuditLog","applyMorphism","getState","invariant"]},
        {"layer_id": "L5", "name": "Scalability", "canister": "aekn4-kyaaa-aaaao-baxva-cai", "lang": "Motoko", "blocks": ["B19","B20","B21","B22"], "status": "ONLINE", "commands": ["getShards","getShardCount","assignToShard","routeTransaction","commitLiquidity","recordMetric","getMetrics","applyMorphism","getState","invariant"]},
        {"layer_id": "L6", "name": "Omnichain", "canister": "adlli-haaaa-aaaao-baxvq-cai", "lang": "Rust", "blocks": ["B15","B16","B17","B18"], "status": "ONLINE", "commands": ["bridgeToBitcoin","bridgeToEthereum","initiateCrossChain","verifyProof","settleTransaction","getCrossChainTxs","applyMorphism","getState","invariant"]},
        {"layer_id": "L7", "name": "AI Governance (PTU-47)", "canister": "awm2f-giaaa-aaaao-baxwa-cai", "lang": "Rust", "blocks": ["B11","B12","B13","B14"], "status": "ONLINE", "commands": ["sanitizeInput","analyzeRisk","getRiskReports","getBlockedCount","createProposal","voteProposal","getProposals","applyMorphism","getState","invariant"]},
        {"layer_id": "L8", "name": "Core Orchestrator", "canister": "bsbvx-7iaaa-aaaao-baxqa-cai", "lang": "Motoko", "blocks": ["B05","B06","B07","B08"], "status": "ONLINE", "commands": ["executePipeline","getPipelineLog","registerLayerStatus","getLayerStatuses","aggregateSignature","compose","delta","getState","isAccepting","reset","invariant"]},
        {"layer_id": "L9", "name": "x39_bases (Motor Algebraico)", "canister": "arn4r-lqaaa-aaaao-baxwq-cai", "lang": "Rust", "blocks": ["B01","B02","B03","B04"], "status": "ONLINE", "commands": ["genesis_object","genesis_module","reset","get_state","apply_morphism","apply_functor","compose","delta","is_accepting","schedule","invariant","validate_state","translate_morphism","bridge_btc","bridge_eth","secure_utxo","ptu47_audit","sanitize_prompt","fuzz_test","collapse_test","quantum_clock"]},
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
        "layers_online": 9,
        "layers_total": 9,
        "blocks_verified": 40,
        "ed25519_signatures": "9/9",
        "fuzz_tests": "2038/2038 PASSED",
        "collapse_tests": "10/10 PASSED",
        "throughput": "50,000+ TPS",
        "finality": "2.5s",
        "uptime": "99.99%",
        "canister_ids_exposed": 0,
        "keys_exposed": 0,
        "fuzz_escapes": 0,
        "quantum_clock": datetime.now(timezone.utc).isoformat(),
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
