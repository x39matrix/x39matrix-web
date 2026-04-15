import React, { useState, useCallback, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Shield, AlertTriangle, Activity, Cpu, Server, Link2, Brain, Layers, Box, Zap, Play, RotateCcw, Building2, Landmark, Globe, Lock, Wifi, WifiOff, Eye, ShieldAlert, ShieldCheck, Database, FileWarning, Skull, Ban } from "lucide-react";

const API = `${process.env.REACT_APP_BACKEND_URL}/api`;

const SCENARIOS = {
  CNSS: {
    id: "CNSS",
    name: "Hackeo CNSS",
    icon: Database,
    target: "CNSS — Seguridad Social",
    description: "Exfiltración de datos de 2M ciudadanos",
    attackType: "Data Exfiltration + Zero-Day",
    realDamage: "54,000 archivos robados, 2M ciudadanos expuestos",
    layers: ["L1", "L2", "L3", "L7", "L8", "DB"],
  },
  MINISTRY: {
    id: "MINISTRY",
    name: "Defacement Ministerios",
    icon: Building2,
    target: "Ministerio de Empleo",
    description: "Modificación de sitio web gubernamental",
    attackType: "Web Defacement + SQLi",
    realDamage: "5 ministerios hackeados, 3,000+ nóminas expuestas",
    layers: ["L1", "L2", "L4", "L7", "L8"],
  },
  DDOS: {
    id: "DDOS",
    name: "DDoS Masivo",
    icon: WifiOff,
    target: "Servicios Gubernamentales",
    description: "75,000+ ataques DDoS simultáneos",
    attackType: "Volumetric DDoS + Application Layer",
    realDamage: "Servicios inaccesibles durante horas",
    layers: ["L1", "L5", "L7", "L8"],
  },
  SWIFT: {
    id: "SWIFT",
    name: "Fraude SWIFT Bancario",
    icon: Landmark,
    target: "Bank Al-Maghrib",
    description: "Transferencia fraudulenta tipo Bangladesh",
    attackType: "SWIFT Manipulation + Insider Threat",
    realDamage: "Referencia: $81M robados a Bangladesh Bank",
    layers: ["L2", "L3", "L4", "L6", "L7", "L8", "DB"],
  },
  SCADA: {
    id: "SCADA",
    name: "Ataque SCADA Energía",
    icon: Zap,
    target: "ONE/ONEE — Red Eléctrica",
    description: "Ataque tipo Stuxnet a centrales",
    attackType: "SCADA Exploitation + Malware",
    realDamage: "Potencial blackout nacional durante el Mundial",
    layers: ["L1", "L3", "L5", "L7", "L8", "DB"],
  },
  RANSOMWARE: {
    id: "RANSOMWARE",
    name: "Ransomware Hospitales",
    icon: FileWarning,
    target: "Hospital Universitario",
    description: "Cifrado de expedientes médicos",
    attackType: "Ransomware + Lateral Movement",
    realDamage: "500+ aparatos médicos expuestos, datos de pacientes",
    layers: ["L1", "L3", "L7", "L8", "DB"],
  },
};

const LAYER_DATA = {
  L1: { name: "Infrastructure", icon: Server, color: "#CC0000" },
  L2: { name: "Identity", icon: Lock, color: "#CC0000" },
  L3: { name: "Execution", icon: Zap, color: "#CC0000" },
  L4: { name: "Consensus", icon: Activity, color: "#CC0000" },
  L5: { name: "Scalability", icon: Layers, color: "#CC0000" },
  L6: { name: "OmniChain", icon: Link2, color: "#CC0000" },
  L7: { name: "AI Sentinel", icon: Brain, color: "#00FFFF" },
  L8: { name: "Orchestrator", icon: Cpu, color: "#CC0000" },
  DB: { name: "x39 Bases", icon: Database, color: "#CC0000" },
};

const PHASES = {
  IDLE: "IDLE",
  RECON: "RECON",
  ATTACK: "ATTACK",
  DETECTED: "DETECTED",
  BLOCKED: "BLOCKED",
  FORENSIC: "FORENSIC",
};

const PHASE_LABELS = {
  IDLE: "SELECCIONE ESCENARIO",
  RECON: "ATACANTE: RECONOCIMIENTO",
  ATTACK: "ATACANTE: EJECUTANDO ATAQUE",
  DETECTED: "X-39MATRIX: ATAQUE DETECTADO",
  BLOCKED: "X-39MATRIX: ATAQUE NEUTRALIZADO",
  FORENSIC: "X-39MATRIX: EVIDENCIA REGISTRADA",
};

function timestamp() {
  return new Date().toLocaleTimeString("en-US", { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" });
}

function generateHash() {
  return "0x" + Array.from({ length: 16 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
}

const StatusBadge = ({ phase }) => {
  const colors = {
    IDLE: "bg-zinc-700 text-zinc-300",
    RECON: "bg-orange-900/50 text-orange-400 border border-orange-500/30",
    ATTACK: "bg-red-900/50 text-red-400 border border-red-500/50 animate-pulse",
    DETECTED: "bg-cyan-900/50 text-cyan-400 border border-cyan-500/50",
    BLOCKED: "bg-red-900/30 text-red-400 border border-red-500/30",
    FORENSIC: "bg-red-900/20 text-red-300 border border-red-400/20",
  };
  return (
    <div data-testid="status-badge" className={`px-4 py-2 text-xs font-mono tracking-[3px] ${colors[phase]}`}>
      {PHASE_LABELS[phase]}
    </div>
  );
};

const ScenarioCard = ({ scenario, isSelected, onClick }) => {
  const Icon = scenario.icon;
  return (
    <motion.button
      data-testid={`scenario-${scenario.id}`}
      onClick={onClick}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className={`text-left p-4 border transition-all ${
        isSelected
          ? "border-[#CC0000] bg-[#CC0000]/10"
          : "border-zinc-800 bg-zinc-900/50 hover:border-zinc-600"
      }`}
    >
      <div className="flex items-center gap-3 mb-2">
        <Icon size={18} className={isSelected ? "text-[#CC0000]" : "text-zinc-500"} />
        <span className={`text-xs font-mono tracking-wider ${isSelected ? "text-[#CC0000]" : "text-zinc-400"}`}>
          {scenario.name}
        </span>
      </div>
      <div className="text-[10px] font-mono text-zinc-600">{scenario.target}</div>
    </motion.button>
  );
};

const LayerStatus = ({ layerId, isActive, isAlerted }) => {
  const layer = LAYER_DATA[layerId];
  const Icon = layer.icon;
  return (
    <motion.div
      data-testid={`layer-status-${layerId}`}
      initial={false}
      animate={{
        borderColor: isAlerted ? "#00FFFF" : isActive ? "#CC0000" : "#27272a",
        backgroundColor: isAlerted ? "rgba(0,255,255,0.05)" : isActive ? "rgba(204,0,0,0.05)" : "transparent",
      }}
      className="flex items-center gap-2 px-3 py-2 border transition-all"
    >
      <span className={`inline-block w-1.5 h-1.5 rounded-full ${isAlerted ? "bg-cyan-400 animate-pulse" : isActive ? "bg-[#CC0000] animate-pulse" : "bg-zinc-700"}`} />
      <Icon size={12} className={isAlerted ? "text-cyan-400" : isActive ? "text-[#CC0000]" : "text-zinc-600"} />
      <span className="text-[10px] font-mono text-zinc-500 w-5">{layerId}</span>
      <span className={`text-[10px] font-mono flex-1 ${isAlerted ? "text-cyan-400" : isActive ? "text-zinc-300" : "text-zinc-600"}`}>
        {layer.name}
      </span>
      <span className={`text-[8px] font-mono ${isAlerted ? "text-cyan-400" : isActive ? "text-[#CC0000]" : "text-zinc-700"}`}>
        {isAlerted ? "ALERT" : isActive ? "ACTIVE" : "STBY"}
      </span>
    </motion.div>
  );
};

const EventLog = ({ events }) => {
  const ref = useRef(null);
  useEffect(() => {
    if (ref.current) ref.current.scrollTop = ref.current.scrollHeight;
  }, [events]);

  return (
    <div
      ref={ref}
      data-testid="event-log"
      className="h-[300px] overflow-y-auto bg-black/60 border border-zinc-800 p-3 font-mono text-[11px] space-y-1"
      style={{ scrollBehavior: "smooth" }}
    >
      {events.map((e, i) => (
        <div key={i} className={`${
          e.type === "danger" ? "text-red-500" :
          e.type === "warning" ? "text-orange-400" :
          e.type === "success" ? "text-[#CC0000]" :
          e.type === "info" ? "text-cyan-400" :
          "text-zinc-500"
        }`}>
          <span className="text-zinc-600">[{e.time}]</span> {e.msg}
        </div>
      ))}
      {events.length === 0 && <div className="text-zinc-700">Esperando inicio de simulación...</div>}
    </div>
  );
};

const AttackVisual = ({ phase, scenario }) => {
  if (!scenario) return null;
  const Icon = scenario.icon;
  
  return (
    <div data-testid="attack-visual" className="relative h-[120px] flex items-center justify-between px-8 border border-zinc-800 bg-black/40 overflow-hidden">
      {/* Attacker */}
      <div className="flex flex-col items-center gap-1 z-10">
        <Skull size={28} className={phase === "IDLE" ? "text-zinc-700" : "text-orange-500"} />
        <span className="text-[9px] font-mono text-zinc-500">ATACANTE</span>
      </div>

      {/* Attack line */}
      <div className="flex-1 mx-6 relative h-1">
        {(phase === "RECON" || phase === "ATTACK") && (
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: "100%" }}
            transition={{ duration: 2 }}
            className={`absolute h-full ${phase === "ATTACK" ? "bg-red-600" : "bg-orange-500/50"}`}
          />
        )}
        {(phase === "DETECTED" || phase === "BLOCKED" || phase === "FORENSIC") && (
          <div className="absolute inset-0 flex items-center justify-center">
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="flex items-center gap-2"
            >
              <Ban size={20} className="text-[#CC0000]" />
              <span className="text-[10px] font-mono text-[#CC0000] tracking-wider">BLOQUEADO</span>
            </motion.div>
          </div>
        )}
      </div>

      {/* Target */}
      <div className="flex flex-col items-center gap-1 z-10">
        <div className={`p-2 border ${
          phase === "BLOCKED" || phase === "FORENSIC" ? "border-[#CC0000] bg-[#CC0000]/10" :
          phase === "DETECTED" ? "border-cyan-500 bg-cyan-500/10" :
          phase === "ATTACK" ? "border-red-500 bg-red-500/10 animate-pulse" :
          "border-zinc-700"
        }`}>
          <Icon size={24} className={
            phase === "BLOCKED" || phase === "FORENSIC" ? "text-[#CC0000]" :
            phase === "DETECTED" ? "text-cyan-400" :
            phase === "ATTACK" ? "text-red-500" :
            "text-zinc-500"
          } />
        </div>
        <span className="text-[9px] font-mono text-zinc-500">{scenario.target}</span>
      </div>

      {/* Shield overlay when protected */}
      {(phase === "BLOCKED" || phase === "FORENSIC") && (
        <motion.div
          initial={{ opacity: 0, scale: 0.5 }}
          animate={{ opacity: 1, scale: 1 }}
          className="absolute right-16 top-2"
        >
          <ShieldCheck size={32} className="text-[#CC0000]" />
        </motion.div>
      )}

      {/* Scan line */}
      <div className="absolute top-0 left-0 right-0 h-[1px] bg-gradient-to-r from-transparent via-[#CC0000]/20 to-transparent" 
           style={{ animation: "scan 3s linear infinite" }} />
    </div>
  );
};

const MetricCard = ({ label, value, danger }) => (
  <div className={`border p-3 text-center ${danger ? "border-red-800 bg-red-900/10" : "border-zinc-800 bg-zinc-900/30"}`}>
    <div className={`text-lg font-mono font-bold ${danger ? "text-red-500" : "text-[#CC0000]"}`}>{value}</div>
    <div className="text-[8px] font-mono text-zinc-600 tracking-wider uppercase">{label}</div>
  </div>
);

export default function GovBankDemo() {
  const [selectedScenario, setSelectedScenario] = useState(null);
  const [phase, setPhase] = useState(PHASES.IDLE);
  const [events, setEvents] = useState([]);
  const [activeLayers, setActiveLayers] = useState([]);
  const [alertedLayers, setAlertedLayers] = useState([]);
  const [metrics, setMetrics] = useState({ detected: 0, blocked: 0, time: "—", forensic: 0 });
  const [isRunning, setIsRunning] = useState(false);
  const timeoutRefs = useRef([]);

  const addEvent = useCallback((msg, type = "default") => {
    setEvents(prev => [...prev, { time: timestamp(), msg, type }]);
  }, []);

  const clearTimeouts = () => {
    timeoutRefs.current.forEach(t => clearTimeout(t));
    timeoutRefs.current = [];
  };

  const scheduleTimeout = (fn, ms) => {
    const t = setTimeout(fn, ms);
    timeoutRefs.current.push(t);
    return t;
  };

  const reset = useCallback(() => {
    clearTimeouts();
    setPhase(PHASES.IDLE);
    setEvents([]);
    setActiveLayers([]);
    setAlertedLayers([]);
    setMetrics({ detected: 0, blocked: 0, time: "—", forensic: 0 });
    setIsRunning(false);
  }, []);

  const runScenario = useCallback((scenario) => {
    if (isRunning) return;
    setIsRunning(true);
    setEvents([]);
    setActiveLayers([]);
    setAlertedLayers([]);

    const attackMessages = {
      CNSS: {
        recon: [
          "[RECON] Escaneando puertos CNSS... 443, 8080, 3306 abiertos",
          "[RECON] Versión Oracle detectada: vulnerable a CVE-2025-XXXX",
          "[RECON] Sin MFA detectado. Sin monitorización en tiempo real.",
        ],
        attack: [
          "[ATTACK] Explotando zero-day Oracle... acceso obtenido",
          "[ATTACK] Escalada de privilegios... root en servidor BD",
          "[ATTACK] Extrayendo tabla empleados... 1,996,026 registros",
          "[ATTACK] Exfiltrando 54,000 PDFs con nóminas y DNIs...",
        ],
        detect: [
          "[L1] Tráfico anómalo detectado: 847MB salientes en 30seg",
          "[L3] ALERTA: Consulta masiva a BD — 2M registros en 1 query",
          "[L2] ZK-KYC activo: datos cifrados con prueba zero-knowledge",
          "[L7] PTU-47: Patrón exfiltración — 97.2% coincidencia",
        ],
        block: [
          "[L8] Pipeline activado: aislamiento inmediato del servidor",
          "[L2] Datos exfiltrados INUTILIZABLES — solo hashes ZK on-chain",
          "[L7] Atacante bloqueado. IP registrada. Sesión terminada.",
        ],
        forensic: [
          "[DB] Evidencia forense registrada en x39 Bases — inmutable",
          "[DB] Hash: " + generateHash(),
          "[L8] Triple firma aplicada. Prueba admisible en tribunal.",
          "[DB] Tiempo detección: 2.8 segundos. 0 datos reales expuestos.",
        ],
      },
      MINISTRY: {
        recon: [
          "[RECON] Escaneando web ministerio... WordPress detectado",
          "[RECON] Plugin vulnerable encontrado: SQLi en formulario",
          "[RECON] Sin WAF. Sin RBAC. Credenciales por defecto.",
        ],
        attack: [
          "[ATTACK] Inyección SQL ejecutada... acceso a BD",
          "[ATTACK] Modificando index.html... defacement activo",
          "[ATTACK] Extrayendo 3,000 fichas de nóminas...",
          "[ATTACK] Subiendo mensaje político en portada...",
        ],
        detect: [
          "[L1] Modificación no autorizada detectada en frontend",
          "[L2] RBAC: Ningún rol autorizado para esta modificación",
          "[L7] PTU-47: Patrón defacement — 99.1% coincidencia",
          "[L4] Consenso: modificación rechazada — sin triple firma",
        ],
        block: [
          "[L8] Rollback automático al último estado verificado",
          "[L2] Sesión atacante revocada. Acceso bloqueado.",
          "[L7] Patrón SQLi añadido a base de conocimiento.",
        ],
        forensic: [
          "[DB] Ataque completo registrado en x39 Bases",
          "[DB] Hash: " + generateHash(),
          "[L8] Web restaurada en 0.4 segundos. 0 datos expuestos.",
        ],
      },
      DDOS: {
        recon: [
          "[RECON] Botnet activada: 75,000+ nodos zombi",
          "[RECON] Objetivo: servicios gubernamentales puerto 443",
          "[RECON] Tipo: Volumétrico + Application Layer",
        ],
        attack: [
          "[ATTACK] 75,000 conexiones simultáneas iniciadas",
          "[ATTACK] Tráfico: 450 Gbps dirigido a servidores gov.ma",
          "[ATTACK] Servicios comenzando a ralentizarse...",
          "[ATTACK] Timeout en portales de ministerios...",
        ],
        detect: [
          "[L1] Spike de tráfico detectado: +8,500% en 3 segundos",
          "[L5] Auto-scaling activado: distribuyendo carga",
          "[L7] PTU-47: Patrón DDoS volumétrico confirmado",
          "[L5] 4 canisters adicionales desplegados automáticamente",
        ],
        block: [
          "[L5] Carga distribuida entre 7 canisters ICP",
          "[L8] IPs maliciosas filtradas: 74,891 bloqueadas",
          "[L5] Servicios 100% operativos. 0 downtime.",
        ],
        forensic: [
          "[DB] 75,000+ IPs registradas inmutablemente",
          "[DB] Hash: " + generateHash(),
          "[L8] Disponibilidad mantenida: 99.99%. Ataque absorbido.",
        ],
      },
      SWIFT: {
        recon: [
          "[RECON] Insider comprometido en departamento SWIFT",
          "[RECON] Credenciales de operador SWIFT obtenidas",
          "[RECON] Ventana de transferencia nocturna identificada",
        ],
        attack: [
          "[ATTACK] Orden SWIFT falsificada: $81M a cuenta externa",
          "[ATTACK] Modificando campo beneficiario...",
          "[ATTACK] Intentando bypass de verificación...",
          "[ATTACK] Segunda orden: $45M a cuenta en Filipinas...",
        ],
        detect: [
          "[L3] Transacción anómala: $81M fuera de patrón habitual",
          "[L2] RBAC: Operador no tiene autorización para >$1M",
          "[L4] Consenso: Transferencia requiere triple firma — FALTA",
          "[L6] OmniChain: Cuenta destino en lista de riesgo cross-chain",
          "[L7] PTU-47: Patrón fraude SWIFT — 98.4% coincidencia",
        ],
        block: [
          "[L4] Transferencia RECHAZADA — consenso no alcanzado",
          "[L2] Cuenta operador CONGELADA inmediatamente",
          "[L6] Alerta cross-chain emitida a bancos corresponsales",
          "[L8] $126M SALVADOS. 0 fondos transferidos.",
        ],
        forensic: [
          "[DB] Cadena completa de evidencia registrada",
          "[DB] Hash: " + generateHash(),
          "[L8] Triple firma forense. Prueba para Bank Al-Maghrib.",
          "[DB] Tiempo detección: 1.2 segundos.",
        ],
      },
      SCADA: {
        recon: [
          "[RECON] Escaneando red industrial ONE/ONEE",
          "[RECON] PLC Siemens S7-1500 detectado sin segmentar",
          "[RECON] Protocolo Modbus sin autenticación",
        ],
        attack: [
          "[ATTACK] Malware tipo Stuxnet inyectado vía USB",
          "[ATTACK] Modificando parámetros de turbina: RPM +340%",
          "[ATTACK] Desactivando sistemas de seguridad física...",
          "[ATTACK] Potencial blackout en zona Casablanca...",
        ],
        detect: [
          "[L1] Comando SCADA anómalo: RPM fuera de rango seguro",
          "[L3] Patrón Stuxnet detectado en secuencia de comandos",
          "[L7] PTU-47: Ataque SCADA — 96.8% coincidencia",
          "[L5] Aislamiento automático del segmento afectado",
        ],
        block: [
          "[L8] Comando malicioso RECHAZADO y revertido",
          "[L5] Sistema aislado. Operación manual activada.",
          "[L7] Malware contenido. Propagación bloqueada.",
        ],
        forensic: [
          "[DB] Secuencia completa de comandos registrada",
          "[DB] Hash: " + generateHash(),
          "[L8] Blackout EVITADO. Red eléctrica estable.",
          "[DB] Evidencia para DGSSI disponible inmediatamente.",
        ],
      },
      RANSOMWARE: {
        recon: [
          "[RECON] Phishing enviado a 200 empleados del hospital",
          "[RECON] 3 clicks en enlace malicioso detectados",
          "[RECON] Descargando payload desde C2 server...",
        ],
        attack: [
          "[ATTACK] Ransomware ejecutándose en estación de trabajo",
          "[ATTACK] Movimiento lateral: 15 equipos infectados",
          "[ATTACK] Cifrando expedientes médicos: 50,000 archivos...",
          "[ATTACK] Nota de rescate: 500 BTC o datos destruidos",
        ],
        detect: [
          "[L1] Actividad de cifrado masivo detectada",
          "[L3] Patrón ransomware: cifrado AES secuencial anómalo",
          "[L7] PTU-47: Ransomware + lateral movement — 99.5%",
          "[L3] C2 server identificado y bloqueado",
        ],
        block: [
          "[L8] Equipos infectados AISLADOS de la red",
          "[L3] Proceso de cifrado TERMINADO a los 4.1 segundos",
          "[DB] Expedientes recuperables desde x39 Bases (inmutables)",
        ],
        forensic: [
          "[DB] Cadena de infección completa registrada",
          "[DB] Hash: " + generateHash(),
          "[L8] 49,847 archivos recuperados de backup inmutable.",
          "[DB] Tiempo respuesta: 4.1 seg. Rescate: $0.",
        ],
      },
    };

    const msgs = attackMessages[scenario.id];
    let delay = 0;

    // Phase: RECON
    scheduleTimeout(() => {
      setPhase(PHASES.RECON);
      addEvent(`━━━ ESCENARIO: ${scenario.name.toUpperCase()} ━━━`, "warning");
      addEvent(`Objetivo: ${scenario.target}`, "warning");
      addEvent(`Tipo: ${scenario.attackType}`, "warning");
      addEvent(`Daño real (sin X-39MATRIX): ${scenario.realDamage}`, "danger");
      addEvent("", "default");
    }, delay);
    delay += 1500;

    msgs.recon.forEach((msg) => {
      scheduleTimeout(() => addEvent(msg, "warning"), delay);
      delay += 1200;
    });

    // Phase: ATTACK
    scheduleTimeout(() => setPhase(PHASES.ATTACK), delay);
    delay += 500;
    msgs.attack.forEach((msg) => {
      scheduleTimeout(() => addEvent(msg, "danger"), delay);
      delay += 1500;
    });

    // Phase: DETECTED
    scheduleTimeout(() => {
      setPhase(PHASES.DETECTED);
      addEvent("", "default");
      addEvent("━━━ X-39MATRIX ACTIVADO ━━━", "info");
      setActiveLayers(scenario.layers);
    }, delay);
    delay += 1000;

    msgs.detect.forEach((msg, i) => {
      scheduleTimeout(() => {
        addEvent(msg, "info");
        if (msg.includes("PTU-47")) {
          setAlertedLayers(["L7"]);
          setMetrics(prev => ({ ...prev, detected: prev.detected + 1, time: (Math.random() * 3 + 1).toFixed(1) + "s" }));
        }
      }, delay);
      delay += 1200;
    });

    // Phase: BLOCKED
    scheduleTimeout(() => {
      setPhase(PHASES.BLOCKED);
      addEvent("", "default");
      addEvent("━━━ ATAQUE NEUTRALIZADO ━━━", "success");
    }, delay);
    delay += 800;

    msgs.block.forEach((msg) => {
      scheduleTimeout(() => {
        addEvent(msg, "success");
        setMetrics(prev => ({ ...prev, blocked: prev.blocked + 1 }));
      }, delay);
      delay += 1000;
    });

    // Phase: FORENSIC
    scheduleTimeout(() => {
      setPhase(PHASES.FORENSIC);
      addEvent("", "default");
      addEvent("━━━ REGISTRO FORENSE ━━━", "info");
    }, delay);
    delay += 800;

    msgs.forensic.forEach((msg) => {
      scheduleTimeout(() => {
        addEvent(msg, "info");
        setMetrics(prev => ({ ...prev, forensic: prev.forensic + 1 }));
      }, delay);
      delay += 1000;
    });

    scheduleTimeout(() => {
      addEvent("", "default");
      addEvent("━━━ SIMULACIÓN COMPLETA ━━━", "success");
      addEvent("Con X-39MATRIX: 0 daño. Sin X-39MATRIX: " + scenario.realDamage, "success");
      setIsRunning(false);
    }, delay + 500);

  }, [isRunning, addEvent]);

  return (
    <div data-testid="gov-bank-demo" className="min-h-screen bg-[#0a0a0a] text-white font-mono">
      {/* CRT scanline */}
      <div className="fixed inset-0 pointer-events-none z-50"
        style={{ background: "repeating-linear-gradient(0deg, rgba(0,0,0,0.03) 0px, rgba(0,0,0,0.03) 1px, transparent 1px, transparent 2px)" }} />

      {/* Header */}
      <div className="border-b border-zinc-800 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <ShieldAlert size={24} className="text-[#CC0000]" />
          <div>
            <h1 className="text-lg tracking-[4px] text-[#CC0000] font-bold">X-39MATRIX</h1>
            <p className="text-[10px] text-zinc-600 tracking-[3px]">SIMULADOR DE DEFENSA — GOBIERNO Y BANCA</p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <StatusBadge phase={phase} />
          <button
            data-testid="reset-btn"
            onClick={reset}
            className="flex items-center gap-2 px-4 py-2 border border-zinc-700 text-zinc-400 text-xs tracking-wider hover:border-[#CC0000] hover:text-[#CC0000] transition-all"
          >
            <RotateCcw size={12} /> RESET
          </button>
        </div>
      </div>

      <div className="flex">
        {/* Left sidebar - Scenarios */}
        <div className="w-[280px] border-r border-zinc-800 p-4 space-y-2">
          <div className="text-[10px] text-zinc-600 tracking-[3px] mb-3">ESCENARIOS DE ATAQUE</div>
          {Object.values(SCENARIOS).map((s) => (
            <ScenarioCard
              key={s.id}
              scenario={s}
              isSelected={selectedScenario?.id === s.id}
              onClick={() => {
                if (!isRunning) {
                  reset();
                  setSelectedScenario(s);
                }
              }}
            />
          ))}
          {selectedScenario && !isRunning && phase === PHASES.IDLE && (
            <motion.button
              data-testid="start-attack-btn"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              onClick={() => runScenario(selectedScenario)}
              className="w-full mt-4 py-3 bg-[#CC0000] text-white text-xs tracking-[3px] flex items-center justify-center gap-2 hover:bg-red-700 transition-all"
            >
              <Play size={14} /> INICIAR SIMULACIÓN
            </motion.button>
          )}
        </div>

        {/* Main content */}
        <div className="flex-1 p-4 space-y-4">
          {/* Attack visualization */}
          <AttackVisual phase={phase} scenario={selectedScenario} />

          {/* Metrics */}
          <div className="grid grid-cols-4 gap-3">
            <MetricCard label="Bloques Verificados" value="40" />
            <MetricCard label="Ataques Bloqueados" value={metrics.blocked} />
            <MetricCard label="Tiempo Detección" value={metrics.time} />
            <MetricCard label="Evidencias Forenses" value={metrics.forensic} />
          </div>

          {/* Event Log */}
          <div>
            <div className="text-[10px] text-zinc-600 tracking-[3px] mb-2">CONSOLA DE EVENTOS</div>
            <EventLog events={events} />
          </div>
        </div>

        {/* Right sidebar - Layers */}
        <div className="w-[220px] border-l border-zinc-800 p-4">
          <div className="text-[10px] text-zinc-600 tracking-[3px] mb-3">CAPAS X-39MATRIX</div>
          <div className="space-y-1">
            {Object.keys(LAYER_DATA).map((id) => (
              <LayerStatus
                key={id}
                layerId={id}
                isActive={activeLayers.includes(id)}
                isAlerted={alertedLayers.includes(id)}
              />
            ))}
          </div>

          {selectedScenario && (
            <div className="mt-6 border border-zinc-800 p-3">
              <div className="text-[10px] text-zinc-600 tracking-[2px] mb-2">ESCENARIO ACTIVO</div>
              <div className="text-xs text-[#CC0000] font-bold">{selectedScenario.name}</div>
              <div className="text-[10px] text-zinc-500 mt-1">{selectedScenario.description}</div>
              <div className="text-[10px] text-zinc-600 mt-2">Capas involucradas:</div>
              <div className="flex flex-wrap gap-1 mt-1">
                {selectedScenario.layers.map(l => (
                  <span key={l} className="text-[9px] px-2 py-0.5 border border-[#CC0000]/30 text-[#CC0000]">{l}</span>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="border-t border-zinc-800 px-6 py-3 flex items-center justify-between">
        <div className="text-[9px] text-zinc-700 tracking-[2px]">
          X-39MATRIX — 9 CAPAS SOBERANAS — ICP MAINNET
        </div>
        <div className="text-[9px] text-zinc-700">
          Jose Luis Olivares Esteban — x39matrix.org
        </div>
      </div>
    </div>
  );
}
