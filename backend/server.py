from fastapi import FastAPI, APIRouter
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
import hashlib
import random
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
import uuid
from datetime import datetime, timezone

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

app = FastAPI()
api_router = APIRouter(prefix="/api")

class SimulationRun(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    started_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    status: str = "completed"
    attack_detected: bool = True
    detection_time_ms: int = Field(default_factory=lambda: random.randint(800, 1800))
    blocks_legitimate: int = 5
    blocks_attacker: int = 6
    tx_reverted: bool = True

class LayerStatus(BaseModel):
    layer: str
    name: str
    status: str
    canister_id: str
    technology: str
    blocks: int = 5

LAYERS = [
    LayerStatus(layer="L1", name="Infrastructure", status="RUNNING", canister_id="b4dy7-eyaaa-aaaao-baxra-cai", technology="Motoko", blocks=5),
    LayerStatus(layer="L2", name="Identity & Assets", status="RUNNING", canister_id="b3c6l-jaaaa-aaaao-baxrq-cai", technology="Motoko", blocks=5),
    LayerStatus(layer="L3", name="Execution Flow", status="RUNNING", canister_id="akiau-riaaa-aaaao-baxua-cai", technology="Motoko", blocks=6),
    LayerStatus(layer="L4", name="Consensus & Crypto", status="RUNNING", canister_id="anjga-4qaaa-aaaao-baxuq-cai", technology="Motoko", blocks=6),
    LayerStatus(layer="L5", name="Scalability", status="RUNNING", canister_id="aekn4-kyaaa-aaaao-baxva-cai", technology="Motoko", blocks=6),
    LayerStatus(layer="L6", name="Omnichain", status="RUNNING", canister_id="adlli-haaaa-aaaao-baxvq-cai", technology="Motoko", blocks=6),
    LayerStatus(layer="L7", name="AI Governance", status="RUNNING", canister_id="awm2f-giaaa-aaaao-baxwa-cai", technology="Motoko", blocks=5),
    LayerStatus(layer="L8", name="Core Orchestrator", status="RUNNING", canister_id="bsbvx-7iaaa-aaaao-baxqa-cai", technology="Motoko", blocks=3),
    LayerStatus(layer="L9", name="Rust DAG Engine", status="RUNNING", canister_id="arn4r-lqaaa-aaaao-baxwq-cai", technology="Rust/PTU-47", blocks=3),
    LayerStatus(layer="L10", name="Frontend", status="RUNNING", canister_id="bvatd-sqaaa-aaaao-baxqq-cai", technology="Assets", blocks=0),
]

def generate_block_hash():
    return "0x" + hashlib.sha256(str(random.random()).encode()).hexdigest()[:16]

def generate_tx_hash():
    return "0x" + hashlib.sha256(str(random.random()).encode()).hexdigest()[:24]

@api_router.get("/")
async def root():
    return {"message": "x39Matrix — 51% Attack Detection Lab"}

@api_router.get("/layers")
async def get_layers():
    return [l.model_dump() for l in LAYERS]

@api_router.get("/simulation/blocks")
async def generate_blocks():
    legit_blocks = []
    for i in range(5):
        legit_blocks.append({
            "height": i + 1,
            "hash": generate_block_hash(),
            "miner": "legit_miner_" + str(random.randint(1, 99)),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "tx_count": random.randint(150, 2500),
            "size_kb": random.randint(800, 1200),
        })
    attacker_blocks = []
    for i in range(6):
        attacker_blocks.append({
            "height": i + 1,
            "hash": generate_block_hash(),
            "miner": "ATTACKER_NODE",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "tx_count": random.randint(1, 10),
            "size_kb": random.randint(200, 400),
        })
    tx = {
        "txid": generate_tx_hash(),
        "amount": round(random.uniform(0.001, 0.1), 4),
        "from": "bc1q" + hashlib.sha256(str(random.random()).encode()).hexdigest()[:20],
        "to": "x39matrix_vault",
        "confirmations": 5,
    }
    return {
        "legitimate_chain": legit_blocks,
        "attacker_chain": attacker_blocks,
        "transaction": tx,
    }

@api_router.post("/simulation/run")
async def save_simulation_run():
    run = SimulationRun()
    doc = run.model_dump()
    await db.simulation_runs.insert_one(doc)
    doc.pop("_id", None)
    return doc

@api_router.get("/simulation/history")
async def get_simulation_history():
    runs = await db.simulation_runs.find({}, {"_id": 0}).sort("started_at", -1).to_list(50)
    return runs

app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
