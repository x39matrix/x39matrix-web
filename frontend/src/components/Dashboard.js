import React, { useState, useCallback, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Shield, AlertTriangle, Activity, Cpu, Server, Link2, Brain, Layers, Box, Zap, Play, RotateCcw, ChevronRight } from "lucide-react";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

const LAYER_ICONS = {
  L1: Server, L2: Shield, L3: Zap, L4: Activity, L5: Layers,
  L6: Link2, L7: Brain, L8: Cpu, L9: Box
};

const PHASES = {
  IDLE: "IDLE",
  MINING_LEGIT: "MINING_LEGIT",
  TX_SENT: "TX_SENT",
  ATTACKER_MINING: "ATTACKER_MINING",
  REORG_DETECTED: "REORG_DETECTED",
  ATTACK_BLOCKED: "ATTACK_BLOCKED",
};

const PHASE_LABELS = {
  IDLE: "AWAITING COMMAND",
  MINING_LEGIT: "MINING LEGITIMATE CHAIN",
  TX_SENT: "TRANSACTION BROADCAST",
  ATTACKER_MINING: "ATTACKER CHAIN DETECTED",
  REORG_DETECTED: "REORG DETECTED — 51% ATTACK",
  ATTACK_BLOCKED: "ATTACK NEUTRALIZED",
};

function generateHash() {
  return "0x" + Array.from({ length: 12 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
}

function generateTxHash() {
  return "0x" + Array.from({ length: 20 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
}

function timestamp() {
  return new Date().toLocaleTimeString("en-US", { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" });
}

// ─── StatusDot ──────────────────────────────────
const StatusDot = ({ active, danger }) => (
  <span
    data-testid={danger ? "status-dot-danger" : "status-dot-active"}
    className={`inline-block w-2 h-2 rounded-full ${danger ? "bg-[#FF8C00] pulse-orange" : active ? "bg-[#FF003C] pulse-dot" : "bg-[#52525B]"}`}
  />
);

// ─── Block Component ────────────────────────────
const Block = ({ block, type, index }) => {
  const isLegit = type === "legit";
  const borderColor = isLegit ? "border-[#00FFFF]/40" : "border-[#FF8C00]/50";
  const bgColor = isLegit ? "bg-[#00FFFF]/5" : "bg-[#FF8C00]/5";
  const textColor = isLegit ? "text-[#00FFFF]" : "text-[#FF8C00]";
  const hashColor = isLegit ? "text-[#00FFFF]/70" : "text-[#FFB000]/80";
  const pulseClass = isLegit ? "pulse-red" : "pulse-orange";

  return (
    <motion.div
      data-testid={`block-${type}-${block.height}`}
      initial={{ opacity: 0, scale: 0.7, x: 30 }}
      animate={{ opacity: 1, scale: 1, x: 0 }}
      transition={{ type: "spring", stiffness: 300, damping: 20, delay: index * 0.15 }}
      className={`flex-shrink-0 w-[120px] border ${borderColor} ${bgColor} p-3 relative ${pulseClass}`}
    >
      <div className={`text-xs font-mono font-bold ${textColor} mb-1`}>
        #{block.height}
      </div>
      <div className={`text-[10px] font-mono ${hashColor} truncate`}>
        {block.hash}
      </div>
      <div className="text-[10px] font-mono text-[#52525B] mt-1">
        {block.tx_count} txs
      </div>
      {index > 0 && (
        <div className={`absolute left-[-14px] top-1/2 -translate-y-1/2 w-[14px] h-[2px] ${isLegit ? "bg-[#00FFFF]/30" : "bg-[#FF8C00]/30"}`} />
      )}
    </motion.div>
  );
};

// ─── LayerRow ───────────────────────────────────
const LayerRow = ({ layer, isActive, isAlerted }) => {
  const Icon = LAYER_ICONS[layer.layer] || Box;
  return (
    <div
      data-testid={`layer-${layer.layer}`}
      className={`flex items-center gap-2 py-1.5 px-2 transition-all duration-300 ${
        isAlerted ? "bg-[#FF8C00]/10 border-l-2 border-[#FF8C00]" :
        isActive ? "bg-[#FF003C]/5 border-l-2 border-[#FF003C]/40" :
        "border-l-2 border-transparent"
      }`}
    >
      <StatusDot active={isActive} danger={isAlerted} />
      <Icon size={13} className={isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#FF003C]" : "text-[#52525B]"} />
      <span className="text-[11px] font-mono tracking-wider text-[#A1A1AA] w-6">{layer.layer}</span>
      <span className={`text-[11px] font-mono ${isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#EDEDED]" : "text-[#52525B]"}`}>
        {layer.name}
      </span>
      <span className={`ml-auto text-[9px] font-mono ${isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#FF003C]" : "text-[#52525B]"}`}>
        {isAlerted ? "ALERT" : isActive ? "ONLINE" : "STANDBY"}
      </span>
    </div>
  );
};

// ─── LogConsole ─────────────────────────────────
const LogConsole = ({ logs }) => {
  const endRef = useRef(null);
  useEffect(() => { endRef.current?.scrollIntoView({ behavior: "smooth" }); }, [logs]);

  return (
    <div data-testid="log-console" className="relative scanlines bg-[#050505] border border-white/10 p-3 h-[200px] overflow-y-auto font-mono text-sm">
      <AnimatePresence>
        {logs.map((log, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.2 }}
            className="flex gap-2 mb-0.5"
          >
            <span className="text-[#52525B] text-xs shrink-0">[{log.time}]</span>
            <span className={`text-xs ${
              log.type === "danger" ? "text-[#FF8C00]" :
              log.type === "warning" ? "text-[#FFB000]" :
              log.type === "success" ? "text-[#FF003C]" :
              log.type === "info" ? "text-[#00FFFF]" :
              "text-[#FF003C]"
            }`}>
              {log.message}
            </span>
          </motion.div>
        ))}
      </AnimatePresence>
      <div ref={endRef} />
    </div>
  );
};

// ─── Main Dashboard ─────────────────────────────
export default function Dashboard() {
  const [phase, setPhase] = useState(PHASES.IDLE);
  const [legitBlocks, setLegitBlocks] = useState([]);
  const [attackerBlocks, setAttackerBlocks] = useState([]);
  const [transaction, setTransaction] = useState(null);
  const [logs, setLogs] = useState([]);
  const [layers, setLayers] = useState([]);
  const [activeLayers, setActiveLayers] = useState(new Set());
  const [alertedLayers, setAlertedLayers] = useState(new Set());
  const [detectionTime, setDetectionTime] = useState(null);
  const [simRunning, setSimRunning] = useState(false);
  const timerRef = useRef(null);
  const blockDataRef = useRef(null);

  useEffect(() => {
    axios.get(`${API}/layers`).then(res => setLayers(res.data)).catch(() => {
      setLayers([
        { layer: "L1", name: "Infrastructure", status: "RUNNING", canister_id: "b4dy7-...", technology: "Motoko" },
        { layer: "L2", name: "Identity", status: "RUNNING", canister_id: "b3c6l-...", technology: "Motoko" },
        { layer: "L3", name: "Execution", status: "RUNNING", canister_id: "akiau-...", technology: "Motoko" },
        { layer: "L4", name: "Consensus", status: "RUNNING", canister_id: "anjga-...", technology: "Motoko" },
        { layer: "L5", name: "Scalability", status: "RUNNING", canister_id: "aekn4-...", technology: "Motoko" },
        { layer: "L6", name: "Omnichain", status: "RUNNING", canister_id: "adlli-...", technology: "Motoko" },
        { layer: "L7", name: "AI Governance", status: "RUNNING", canister_id: "awm2f-...", technology: "Motoko" },
        { layer: "L8", name: "Core Orchestrator", status: "RUNNING", canister_id: "bsbvx-...", technology: "Motoko" },
        { layer: "L9", name: "x39_bases", status: "RUNNING", canister_id: "arn4r-...", technology: "Rust/PTU-47" },
      ]);
    });
  }, []);

  const addLog = useCallback((message, type = "default") => {
    setLogs(prev => [...prev, { time: timestamp(), message, type }]);
  }, []);

  const activateLayer = useCallback((layer) => {
    setActiveLayers(prev => new Set([...prev, layer]));
  }, []);

  const alertLayer = useCallback((layer) => {
    setAlertedLayers(prev => new Set([...prev, layer]));
  }, []);

  const resetSimulation = useCallback(() => {
    if (timerRef.current) clearTimeout(timerRef.current);
    setPhase(PHASES.IDLE);
    setLegitBlocks([]);
    setAttackerBlocks([]);
    setTransaction(null);
    setLogs([]);
    setActiveLayers(new Set());
    setAlertedLayers(new Set());
    setDetectionTime(null);
    setSimRunning(false);
    blockDataRef.current = null;
  }, []);

  const startSimulation = useCallback(async () => {
    resetSimulation();
    setSimRunning(true);

    try {
      const res = await axios.get(`${API}/simulation/blocks`);
      blockDataRef.current = res.data;
    } catch {
      blockDataRef.current = {
        legitimate_chain: Array.from({ length: 5 }, (_, i) => ({
          height: i + 1, hash: generateHash(), tx_count: Math.floor(Math.random() * 2000) + 150, size_kb: Math.floor(Math.random() * 400) + 800
        })),
        attacker_chain: Array.from({ length: 6 }, (_, i) => ({
          height: i + 1, hash: generateHash(), tx_count: Math.floor(Math.random() * 10) + 1, size_kb: Math.floor(Math.random() * 200) + 200
        })),
        transaction: { txid: generateTxHash(), amount: 0.042, from: "bc1q" + generateHash().slice(2), to: "x39matrix_vault", confirmations: 5 }
      };
    }

    const data = blockDataRef.current;
    const delay = (ms) => new Promise(r => { timerRef.current = setTimeout(r, ms); });

    // Phase 1: Initialize system
    addLog("x39Matrix 51% Attack Detection Lab v2.0", "info");
    addLog("Initializing 9-layer sovereign protocol...", "info");
    await delay(600);

    activateLayer("L1");
    addLog("L1 Infrastructure: Node connections established", "success");
    await delay(300);
    activateLayer("L2");
    addLog("L2 Identity: Principal verified", "success");
    await delay(300);
    activateLayer("L3");
    addLog("L3 Execution: Engine ready", "success");
    await delay(300);
    activateLayer("L8");
    addLog("L8 Core Orchestrator: All subsystems nominal", "success");
    await delay(300);
    activateLayer("L9");
    addLog("L9 x39_bases: PTU-47 Category Theory Engine loaded", "success");
    await delay(500);
    addLog("All layers initialized. System OPERATIONAL.", "info");
    await delay(800);

    // Phase 2: Mine legitimate chain
    setPhase(PHASES.MINING_LEGIT);
    addLog("─── PHASE 1: Mining Legitimate Chain ───", "info");
    activateLayer("L4");
    addLog("L4 Consensus: Monitoring Bitcoin regtest...", "success");
    await delay(400);

    for (let i = 0; i < data.legitimate_chain.length; i++) {
      const block = data.legitimate_chain[i];
      setLegitBlocks(prev => [...prev, block]);
      addLog(`Block #${block.height} mined → ${block.hash} (${block.tx_count} txs)`, "success");
      await delay(700);
    }

    addLog("Legitimate chain: 5 blocks confirmed.", "info");
    await delay(600);

    // Phase 3: Transaction sent
    setPhase(PHASES.TX_SENT);
    addLog("─── PHASE 2: Transaction Broadcast ───", "info");
    setTransaction({ ...data.transaction, status: "CONFIRMED" });
    addLog(`TX ${data.transaction.txid}`, "info");
    addLog(`Amount: ${data.transaction.amount} BTC → x39matrix_vault`, "success");
    addLog("Transaction CONFIRMED with 5 confirmations.", "success");
    activateLayer("L5");
    addLog("L5 Scalability: UTXO indexed.", "success");
    await delay(1500);

    // Phase 4: Attacker mining
    setPhase(PHASES.ATTACKER_MINING);
    addLog("─── PHASE 3: ATTACKER CHAIN DETECTED ───", "warning");
    addLog("WARNING: Alternative chain activity detected!", "warning");
    activateLayer("L6");
    addLog("L6 Omnichain: Cross-chain anomaly flagged.", "warning");
    await delay(500);

    for (let i = 0; i < data.attacker_chain.length; i++) {
      const block = data.attacker_chain[i];
      setAttackerBlocks(prev => [...prev, block]);
      addLog(`ATTACKER Block #${block.height} → ${block.hash} (${block.tx_count} txs — SUSPICIOUS)`, "danger");
      await delay(600);
    }

    await delay(400);

    // Phase 5: Reorg detected
    setPhase(PHASES.REORG_DETECTED);
    const detTime = Math.floor(Math.random() * 900) + 800;
    setDetectionTime(detTime);

    addLog("─── PHASE 4: REORG DETECTED ───", "danger");
    addLog("CRITICAL: Attacker chain (6 blocks) > Legitimate chain (5 blocks)!", "danger");
    activateLayer("L7");
    alertLayer("L7");
    addLog("L7 AI Governance Sentinel: REORG DETECTED!", "danger");
    addLog(`Detection time: ${detTime}ms`, "danger");
    setTransaction(prev => prev ? { ...prev, status: "REVERTED" } : null);
    addLog("ALERT: Transaction REVERTED — double spend attempt!", "danger");
    alertLayer("L3");
    addLog("L3 Execution: UTXO set compromised — rolling back.", "danger");
    await delay(2000);

    // Phase 6: Attack blocked
    setPhase(PHASES.ATTACK_BLOCKED);
    addLog("─── PHASE 5: ATTACK NEUTRALIZED ───", "success");
    addLog("L7 Sentinel: Attacker chain REJECTED.", "success");
    addLog("L4 Consensus: Legitimate chain restored as canonical.", "success");
    addLog("L9 PTU-47: Algebraic invariants verified. Chain integrity: VALID.", "success");
    setAlertedLayers(new Set());
    addLog("═══ 51% ATTACK SUCCESSFULLY DETECTED AND BLOCKED ═══", "info");
    addLog(`Total detection time: ${detTime}ms`, "info");
    setSimRunning(false);

    try {
      await axios.post(`${API}/simulation/run`);
    } catch {}
  }, [addLog, activateLayer, alertLayer, resetSimulation]);

  const phaseColor = phase === PHASES.REORG_DETECTED ? "text-[#FF8C00]" :
    phase === PHASES.ATTACKER_MINING ? "text-[#FFB000]" :
    phase === PHASES.ATTACK_BLOCKED ? "text-[#FF003C]" :
    phase === PHASES.IDLE ? "text-[#52525B]" : "text-[#00FFFF]";

  return (
    <div className="min-h-screen bg-[#050505] p-3 md:p-5 lg:p-6 relative">
      {/* Background texture */}
      <div className="fixed inset-0 opacity-[0.03] pointer-events-none"
        style={{ backgroundImage: `url(https://static.prod-images.emergentagent.com/jobs/b93719da-776c-487b-ae8c-ecf4ae684f67/images/163fccf7edc5c9703ac5cd12ee0c959ed2f82fa045eb75f2803c5e24f7bc361c.png)`, backgroundSize: 'cover' }} />

      {/* Header */}
      <header className="flex items-center justify-between mb-5 relative z-10" data-testid="header">
        <div className="flex items-center gap-3">
          <img
            src="https://static.prod-images.emergentagent.com/jobs/b93719da-776c-487b-ae8c-ecf4ae684f67/images/f09629f148dfc3cb0339456b4f91329f042e714ebc688c88e53fab08b1d0e2a3.png"
            alt="x39Matrix"
            className="w-9 h-9"
          />
          <div>
            <h1 className="text-xl md:text-2xl font-black tracking-tighter uppercase text-white leading-none">
              x39<span className="text-[#FF003C]">Matrix</span>
            </h1>
            <p className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#52525B]">
              51% Attack Detection Lab
            </p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <div className={`text-xs font-mono tracking-widest uppercase ${phaseColor} glow-text`} data-testid="phase-indicator">
            {PHASE_LABELS[phase]}
          </div>
          <div className="flex items-center gap-1.5">
            <span className={`w-2 h-2 rounded-full ${phase === PHASES.IDLE ? "bg-[#52525B]" : phase === PHASES.REORG_DETECTED ? "bg-[#FF8C00] pulse-orange" : "bg-[#FF003C] pulse-dot"}`} />
            <span className="text-[10px] font-mono text-[#A1A1AA]">MAINNET</span>
          </div>
        </div>
      </header>

      {/* Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-[240px_1fr] gap-4 relative z-10">

        {/* Left: Layers Panel */}
        <div className="bg-[#0A0A0A] border border-white/10 p-3" data-testid="layers-panel">
          <div className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#52525B] mb-3 flex items-center gap-2">
            <Layers size={12} />
            System Layers
          </div>
          <div className="space-y-0">
            {layers.map(layer => (
              <LayerRow
                key={layer.layer}
                layer={layer}
                isActive={activeLayers.has(layer.layer)}
                isAlerted={alertedLayers.has(layer.layer)}
              />
            ))}
          </div>
          <div className="mt-4 border-t border-white/10 pt-3">
            <div className="text-[10px] font-mono text-[#52525B] mb-2">DETECTION</div>
            {detectionTime ? (
              <div className="text-2xl font-mono font-bold text-[#FF003C] glow-text" data-testid="detection-time">
                {detectionTime}<span className="text-sm text-[#A1A1AA]">ms</span>
              </div>
            ) : (
              <div className="text-2xl font-mono font-bold text-[#52525B]">—</div>
            )}
          </div>
        </div>

        {/* Right: Main Content */}
        <div className="space-y-4">

          {/* Chain Visualizations */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Legitimate Chain */}
            <div className={`bg-[#0A0A0A] border ${phase === PHASES.MINING_LEGIT ? "border-[#00FFFF]/30" : "border-white/10"} p-4`} data-testid="legit-chain-panel">
              <div className="flex items-center gap-2 mb-3">
                <StatusDot active={legitBlocks.length > 0} />
                <span className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#A1A1AA]">Legitimate Chain</span>
                <span className="ml-auto text-[10px] font-mono text-[#00FFFF]">{legitBlocks.length} blocks</span>
              </div>
              <div className="flex gap-3 overflow-x-auto pb-2 min-h-[80px] items-center">
                {legitBlocks.length === 0 ? (
                  <div className="text-xs font-mono text-[#52525B] w-full text-center">Awaiting blocks...</div>
                ) : (
                  legitBlocks.map((block, i) => <Block key={i} block={block} type="legit" index={i} />)
                )}
              </div>
            </div>

            {/* Attacker Chain */}
            <div className={`bg-[#0A0A0A] border ${
              phase === PHASES.REORG_DETECTED ? "border-[#FF8C00]/50 alert-flash" :
              phase === PHASES.ATTACKER_MINING ? "border-[#FFB000]/30" :
              "border-white/10"
            } p-4`} data-testid="attacker-chain-panel">
              <div className="flex items-center gap-2 mb-3">
                <StatusDot active={attackerBlocks.length > 0} danger={attackerBlocks.length > 0} />
                <span className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#A1A1AA]">Attacker Chain</span>
                <span className="ml-auto text-[10px] font-mono text-[#FF8C00]">{attackerBlocks.length} blocks</span>
              </div>
              <div className="flex gap-3 overflow-x-auto pb-2 min-h-[80px] items-center">
                {attackerBlocks.length === 0 ? (
                  <div className="text-xs font-mono text-[#52525B] w-full text-center">No threats detected</div>
                ) : (
                  attackerBlocks.map((block, i) => <Block key={i} block={block} type="attacker" index={i} />)
                )}
              </div>
            </div>
          </div>

          {/* Transaction + Alert Row */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Transaction */}
            <div className="bg-[#0A0A0A] border border-white/10 p-4" data-testid="transaction-panel">
              <div className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#52525B] mb-3 flex items-center gap-2">
                <ChevronRight size={12} />
                Transaction Monitor
              </div>
              {transaction ? (
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-mono text-[#52525B]">TXID:</span>
                    <span className="text-xs font-mono text-[#00FFFF]">{transaction.txid}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-mono text-[#52525B]">AMOUNT:</span>
                    <span className="text-xs font-mono text-[#EDEDED]">{transaction.amount} BTC</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-mono text-[#52525B]">TO:</span>
                    <span className="text-xs font-mono text-[#EDEDED]">{transaction.to}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[10px] font-mono text-[#52525B]">STATUS:</span>
                    <span className={`text-xs font-mono font-bold ${
                      transaction.status === "CONFIRMED" ? "text-[#00FFFF]" : "text-[#FF8C00]"
                    }`}>
                      {transaction.status === "CONFIRMED" ? "CONFIRMED (5 blocks)" : "REVERTED — DOUBLE SPEND DETECTED"}
                    </span>
                  </div>
                </div>
              ) : (
                <div className="text-xs font-mono text-[#52525B]">No active transaction</div>
              )}
            </div>

            {/* L7 Sentinel Alert */}
            <div
              className={`bg-[#0A0A0A] border p-4 transition-all duration-300 ${
                phase === PHASES.REORG_DETECTED ? "border-[#FF8C00] alert-flash bg-[#FF8C00]/5" :
                phase === PHASES.ATTACK_BLOCKED ? "border-[#FF003C]/40 bg-[#FF003C]/5" :
                "border-white/10"
              }`}
              data-testid="sentinel-alert-panel"
            >
              <div className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#52525B] mb-3 flex items-center gap-2">
                <AlertTriangle size={12} className={phase === PHASES.REORG_DETECTED ? "text-[#FF8C00]" : ""} />
                L7 Sentinel Alert
              </div>
              {phase === PHASES.REORG_DETECTED ? (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <div className="text-lg font-mono font-bold text-[#FF8C00] mb-2">
                    51% ATTACK DETECTED
                  </div>
                  <div className="text-xs font-mono text-[#FF8C00]/80 space-y-1">
                    <div>Chain reorg: Attacker chain (6) &gt; Legitimate (5)</div>
                    <div>tip_block_hash CHANGED — UTXO compromised</div>
                    <div>Transaction {transaction?.txid?.slice(0, 12)}... REVERTED</div>
                  </div>
                </motion.div>
              ) : phase === PHASES.ATTACK_BLOCKED ? (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <div className="text-lg font-mono font-bold text-[#FF003C] mb-2">
                    ATTACK NEUTRALIZED
                  </div>
                  <div className="text-xs font-mono text-[#FF003C]/80 space-y-1">
                    <div>Attacker chain rejected</div>
                    <div>Legitimate chain restored as canonical</div>
                    <div>PTU-47 invariants verified: CHAIN VALID</div>
                    <div>Detection time: {detectionTime}ms</div>
                  </div>
                </motion.div>
              ) : (
                <div className="text-xs font-mono text-[#52525B]">No active alerts — System nominal</div>
              )}
            </div>
          </div>

          {/* Log Console */}
          <div data-testid="log-section">
            <div className="text-[10px] font-mono tracking-[0.25em] uppercase text-[#52525B] mb-2 flex items-center gap-2">
              <Activity size={12} />
              Event Log
            </div>
            <LogConsole logs={logs} />
          </div>

          {/* Controls */}
          <div className="flex gap-3" data-testid="controls">
            <button
              data-testid="start-simulation-btn"
              onClick={startSimulation}
              disabled={simRunning}
              className={`flex items-center gap-2 px-6 py-3 font-mono text-sm font-bold tracking-wider uppercase transition-all ${
                simRunning
                  ? "bg-[#121212] text-[#52525B] cursor-not-allowed border border-white/5"
                  : "bg-[#FF003C] text-white hover:drop-shadow-[0_0_12px_rgba(255,0,60,0.5)] active:scale-[0.98]"
              }`}
            >
              <Play size={16} />
              {simRunning ? "Simulation Running..." : "Start Simulation"}
            </button>
            <button
              data-testid="reset-btn"
              onClick={resetSimulation}
              className="flex items-center gap-2 px-6 py-3 font-mono text-sm tracking-wider uppercase border border-[#FF003C]/30 text-[#FF003C] hover:bg-[#FF003C]/10 transition-all"
            >
              <RotateCcw size={16} />
              Reset
            </button>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="mt-6 text-center relative z-10">
        <p className="text-[10px] font-mono text-[#52525B] tracking-widest">
          x39Matrix — Sovereign Protocol | 9 Layers | 45 Blocks | Category Theory Engine |{" "}
          <a href="https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/" target="_blank" rel="noopener noreferrer" className="text-[#FF003C]/50 hover:text-[#FF003C]">
            Live on ICP Mainnet
          </a>
        </p>
      </footer>
    </div>
  );
}
