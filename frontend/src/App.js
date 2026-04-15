import React, { useState, useEffect, useRef, useCallback } from 'react';
import { io } from 'socket.io-client';
import './App.css';

const API = process.env.REACT_APP_BACKEND_URL;
const SOCKET_URL = process.env.REACT_APP_BACKEND_URL;

// ICE servers for WebRTC
const ICE_SERVERS = { iceServers: [{ urls: 'stun:stun.l.google.com:19302' }, { urls: 'stun:stun1.l.google.com:19302' }] };

function App() {
  const [token, setToken] = useState(localStorage.getItem('x39_token'));
  const [nick, setNick] = useState(localStorage.getItem('x39_nick'));

  const handleAuth = (t, n) => {
    localStorage.setItem('x39_token', t);
    localStorage.setItem('x39_nick', n);
    setToken(t);
    setNick(n);
  };

  const handleLogout = () => {
    localStorage.removeItem('x39_token');
    localStorage.removeItem('x39_nick');
    setToken(null);
    setNick(null);
  };

  if (!token) return <LoginPage onAuth={handleAuth} />;
  return <MainApp token={token} nick={nick} onLogout={handleLogout} />;
}

// =================== LOGIN PAGE ===================
function LoginPage({ onAuth }) {
  const [isRegister, setIsRegister] = useState(false);
  const [nickInput, setNickInput] = useState('');
  const [passInput, setPassInput] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    const endpoint = isRegister ? '/api/auth/register' : '/api/auth/login';
    try {
      const res = await fetch(`${API}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nick: nickInput, password: passInput }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.detail || 'Error');
      onAuth(data.token, data.nick);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="login-page" data-testid="login-page">
      <div className="login-bg" />
      <form className="login-box" onSubmit={handleSubmit}>
        <div className="login-title">X-39MATRIX</div>
        <div className="login-sub">KEPLER'S VISION</div>
        <input className="login-input" data-testid="login-nick" placeholder="Nick" value={nickInput} onChange={e => setNickInput(e.target.value)} autoFocus />
        <input className="login-input" data-testid="login-password" type="password" placeholder="Password" value={passInput} onChange={e => setPassInput(e.target.value)} />
        <button className="login-btn" data-testid="login-submit" type="submit">{isRegister ? 'REGISTRAR' : 'ENTRAR'}</button>
        <button className="login-btn secondary" type="button" onClick={() => { setIsRegister(!isRegister); setError(''); }}>
          {isRegister ? 'YA TENGO CUENTA' : 'CREAR CUENTA'}
        </button>
        {error && <div className="login-error" data-testid="login-error">{error}</div>}
      </form>
    </div>
  );
}

// =================== MAIN APP ===================
function MainApp({ token, nick, onLogout }) {
  const [view, setView] = useState('chat');
  const [socket, setSocket] = useState(null);
  const [onlineUsers, setOnlineUsers] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [activeRoom, setActiveRoom] = useState(null);
  const [messages, setMessages] = useState([]);
  const [incomingCall, setIncomingCall] = useState(null);
  const [callState, setCallState] = useState(null);

  // Socket connection
  useEffect(() => {
    const s = io(SOCKET_URL, { transports: ['websocket', 'polling'], path: '/api/socket.io' });
    s.on('connect', () => s.emit('authenticate', { token }));
    s.on('online_users', (users) => setOnlineUsers(users));
    s.on('user_online', ({ nick: n }) => setOnlineUsers(prev => prev.includes(n) ? prev : [...prev, n]));
    s.on('user_offline', ({ nick: n }) => setOnlineUsers(prev => prev.filter(u => u !== n)));
    s.on('new_message', (msg) => setMessages(prev => [...prev, msg]));
    s.on('incoming_call', (data) => setIncomingCall(data));
    s.on('call_answered', (data) => setCallState(prev => prev ? { ...prev, answered: true, signal: data.signal } : prev));
    s.on('call_ended', () => { setCallState(null); });
    setSocket(s);
    return () => s.disconnect();
  }, [token]);

  // Load users
  useEffect(() => {
    fetch(`${API}/api/users`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json()).then(setAllUsers).catch(() => {});
  }, [token]);

  // Load rooms
  useEffect(() => {
    fetch(`${API}/api/rooms`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json()).then(setRooms).catch(() => {});
  }, [token]);

  // Load messages when room changes
  useEffect(() => {
    if (!activeRoom) return;
    fetch(`${API}/api/rooms/${activeRoom.room_id}/messages`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json()).then(setMessages).catch(() => {});
    if (socket) {
      socket.emit('join_room', { room_id: activeRoom.room_id });
    }
  }, [activeRoom, token, socket]);

  const startDirectChat = async (targetNick) => {
    const existingRoom = rooms.find(r => r.type === 'direct' && r.members.includes(targetNick) && r.members.includes(nick));
    if (existingRoom) {
      setActiveRoom(existingRoom);
      return;
    }
    const res = await fetch(`${API}/api/rooms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({ name: `${nick}-${targetNick}`, members: [nick, targetNick], type: 'direct' }),
    });
    const room = await res.json();
    const newRoom = { ...room, members: [nick, targetNick], type: 'direct' };
    setRooms(prev => [...prev, newRoom]);
    setActiveRoom(newRoom);
  };

  const sendMessage = (text) => {
    if (!socket || !activeRoom || !text.trim()) return;
    socket.emit('send_message', { room_id: activeRoom.room_id, text });
  };

  const startCall = (targetNick) => {
    setCallState({ target: targetNick, initiator: true, answered: false });
    setView('video');
  };

  const answerCall = () => {
    if (!incomingCall) return;
    setCallState({ target: incomingCall.from, initiator: false, signal: incomingCall.signal });
    setIncomingCall(null);
    setView('video');
  };

  const rejectCall = () => setIncomingCall(null);

  const endCall = () => {
    if (callState && socket) {
      socket.emit('end_call', { target: callState.target });
    }
    setCallState(null);
    setView('chat');
  };

  const otherUsers = allUsers.filter(u => u.nick !== nick);

  return (
    <div className="app-layout" data-testid="main-app">
      {/* INCOMING CALL MODAL */}
      {incomingCall && (
        <div className="incoming-call-modal" data-testid="incoming-call">
          <div className="caller">{incomingCall.from}</div>
          <div className="call-type">VIDEOLLAMADA ENTRANTE</div>
          <div className="call-actions">
            <button className="accept" data-testid="accept-call" onClick={answerCall}>ACEPTAR</button>
            <button className="reject" data-testid="reject-call" onClick={rejectCall}>RECHAZAR</button>
          </div>
        </div>
      )}

      {/* SIDEBAR NAV */}
      <nav className="sidebar-nav" data-testid="sidebar-nav">
        <div className="nav-logo">X39</div>
        <button className={`nav-btn ${view === 'chat' ? 'active' : ''}`} data-testid="nav-chat" onClick={() => setView('chat')} title="Chat">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </button>
        <button className={`nav-btn ${view === 'video' ? 'active' : ''}`} data-testid="nav-video" onClick={() => setView('video')} title="Video">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
        </button>
        <button className={`nav-btn ${view === 'security' ? 'active' : ''}`} data-testid="nav-security" onClick={() => setView('security')} title="Seguridad">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </button>
        <button className={`nav-btn ${view === 'manual' ? 'active' : ''}`} data-testid="nav-manual" onClick={() => setView('manual')} title="Manual">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
        </button>
        <button className={`nav-btn ${view === 'protect' ? 'active' : ''}`} data-testid="nav-protect" onClick={() => setView('protect')} title="Proteger">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
        </button>
        <button className={`nav-btn ${view === 'support' ? 'active' : ''}`} data-testid="nav-support" onClick={() => setView('support')} title="Soporte">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        </button>
        <div className="nav-spacer" />
        <button className="nav-btn logout" data-testid="logout-btn" onClick={onLogout} title="Salir">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
        </button>
      </nav>

      {/* LEFT PANEL */}
      <div className="left-panel">
        {(view === 'chat' || view === 'video') && (
          <>
            <div className="panel-title">
              USUARIOS
              <span style={{ color: 'var(--red)', fontSize: '10px' }}>{nick}</span>
            </div>
            <div className="user-list">
              {otherUsers.map(u => (
                <div key={u.nick} className={`user-item ${activeRoom?.members?.includes(u.nick) ? 'active' : ''}`}
                  onClick={() => startDirectChat(u.nick)}>
                  <div className={`user-avatar ${onlineUsers.includes(u.nick) ? 'online' : ''}`}>
                    {u.nick[0].toUpperCase()}
                  </div>
                  <div>
                    <div className="user-name">{u.nick}</div>
                    <div className="user-status">{onlineUsers.includes(u.nick) ? 'En linea' : 'Desconectado'}</div>
                  </div>
                  {onlineUsers.includes(u.nick) && <div className="online-dot" />}
                </div>
              ))}
              {otherUsers.length === 0 && (
                <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-dim)', fontSize: '11px' }}>
                  No hay otros usuarios registrados
                </div>
              )}
            </div>
          </>
        )}
        {view === 'security' && <SecurityLeftPanel token={token} />}
        {view === 'manual' && <ManualLeftPanel token={token} />}
        {view === 'protect' && <ProtectLeftPanel />}
        {view === 'support' && <SupportLeftPanel />}
      </div>

      {/* MAIN CONTENT */}
      <div className="main-content">
        {view === 'chat' && <ChatView activeRoom={activeRoom} messages={messages} nick={nick} onSend={sendMessage} onCall={startCall} />}
        {view === 'video' && <VideoView callState={callState} socket={socket} nick={nick} onEnd={endCall} />}
        {view === 'security' && <SecurityView token={token} />}
        {view === 'manual' && <ManualView token={token} />}
        {view === 'protect' && <ProtectView />}
        {view === 'support' && <SupportView nick={nick} />}
      </div>
    </div>
  );
}

// =================== CHAT VIEW ===================
function ChatView({ activeRoom, messages, nick, onSend, onCall }) {
  const [input, setInput] = useState('');
  const messagesEnd = useRef(null);

  useEffect(() => { messagesEnd.current?.scrollIntoView({ behavior: 'smooth' }); }, [messages]);

  const handleSend = () => {
    if (!input.trim()) return;
    onSend(input);
    setInput('');
  };

  if (!activeRoom) return (
    <div className="empty-state" data-testid="chat-empty">
      <div className="icon">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
      </div>
      <div className="text">SELECCIONA UN USUARIO PARA CHATEAR</div>
    </div>
  );

  const otherMember = activeRoom.members?.find(m => m !== nick) || activeRoom.name;

  return (
    <>
      <div className="chat-header" data-testid="chat-header">
        <div>
          <div className="chat-header-name">{otherMember}</div>
          <div className="chat-header-status">Chat directo</div>
        </div>
        <div className="chat-header-actions">
          <button data-testid="video-call-btn" onClick={() => onCall(otherMember)} title="Videollamada">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>
          </button>
        </div>
      </div>
      <div className="chat-messages" data-testid="chat-messages">
        {messages.map((m, i) => (
          <div key={i} className={`msg-item ${m.from_nick === nick ? 'mine' : ''}`}>
            <div className="msg-bubble">
              {m.from_nick !== nick && <div className="msg-nick">{m.from_nick}</div>}
              {m.text}
              <div className="msg-time">{new Date(m.timestamp).toLocaleTimeString()}</div>
            </div>
          </div>
        ))}
        <div ref={messagesEnd} />
      </div>
      <div className="chat-input-area" data-testid="chat-input-area">
        <input className="chat-input" data-testid="chat-input" placeholder="Escribe un mensaje..." value={input}
          onChange={e => setInput(e.target.value)} onKeyDown={e => e.key === 'Enter' && handleSend()} />
        <button className="chat-send" data-testid="chat-send" onClick={handleSend}>ENVIAR</button>
      </div>
    </>
  );
}

// =================== VIDEO VIEW ===================
function VideoView({ callState, socket, nick, onEnd }) {
  const localVideoRef = useRef(null);
  const remoteVideoRef = useRef(null);
  const peerRef = useRef(null);
  const localStreamRef = useRef(null);
  const [videoEnabled, setVideoEnabled] = useState(true);
  const [audioEnabled, setAudioEnabled] = useState(true);

  const startMedia = useCallback(async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
      localStreamRef.current = stream;
      if (localVideoRef.current) localVideoRef.current.srcObject = stream;
      return stream;
    } catch (err) {
      console.error('Media error:', err);
      return null;
    }
  }, []);

  const createPeer = useCallback((stream, initiator) => {
    const peer = new RTCPeerConnection(ICE_SERVERS);
    stream.getTracks().forEach(track => peer.addTrack(track, stream));

    peer.ontrack = (event) => {
      if (remoteVideoRef.current) remoteVideoRef.current.srcObject = event.streams[0];
    };

    peer.onicecandidate = (event) => {
      if (event.candidate && socket && callState) {
        socket.emit('ice_candidate', { target: callState.target, candidate: event.candidate });
      }
    };

    return peer;
  }, [socket, callState]);

  useEffect(() => {
    if (!callState || !socket) return;

    const setup = async () => {
      const stream = await startMedia();
      if (!stream) return;

      const peer = createPeer(stream, callState.initiator);
      peerRef.current = peer;

      if (callState.initiator) {
        const offer = await peer.createOffer();
        await peer.setLocalDescription(offer);
        socket.emit('call_user', { target: callState.target, signal: offer, type: 'video' });
      } else if (callState.signal) {
        await peer.setRemoteDescription(new RTCSessionDescription(callState.signal));
        const answer = await peer.createAnswer();
        await peer.setLocalDescription(answer);
        socket.emit('answer_call', { target: callState.target, signal: answer });
      }
    };

    const handleAnswer = (data) => {
      if (peerRef.current && data.signal) {
        peerRef.current.setRemoteDescription(new RTCSessionDescription(data.signal));
      }
    };

    const handleIce = (data) => {
      if (peerRef.current && data.candidate) {
        peerRef.current.addIceCandidate(new RTCIceCandidate(data.candidate));
      }
    };

    socket.on('call_answered', handleAnswer);
    socket.on('ice_candidate', handleIce);
    setup();

    return () => {
      socket.off('call_answered', handleAnswer);
      socket.off('ice_candidate', handleIce);
      if (peerRef.current) { peerRef.current.close(); peerRef.current = null; }
      if (localStreamRef.current) { localStreamRef.current.getTracks().forEach(t => t.stop()); }
    };
  }, [callState, socket, startMedia, createPeer]);

  const toggleVideo = () => {
    if (localStreamRef.current) {
      localStreamRef.current.getVideoTracks().forEach(t => { t.enabled = !t.enabled; });
      setVideoEnabled(!videoEnabled);
    }
  };

  const toggleAudio = () => {
    if (localStreamRef.current) {
      localStreamRef.current.getAudioTracks().forEach(t => { t.enabled = !t.enabled; });
      setAudioEnabled(!audioEnabled);
    }
  };

  if (!callState) return (
    <div className="empty-state" data-testid="video-empty">
      <div className="icon">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>
      </div>
      <div className="text">SELECCIONA UN USUARIO Y PULSA EL ICONO DE VIDEO</div>
    </div>
  );

  return (
    <div className="video-container" data-testid="video-container">
      <video ref={remoteVideoRef} className="video-remote" autoPlay playsInline />
      <video ref={localVideoRef} className="video-local" autoPlay playsInline muted />
      <div className="video-controls">
        <button className={`toggle-btn ${!audioEnabled ? 'off' : ''}`} onClick={toggleAudio} data-testid="toggle-audio">
          {audioEnabled ? '🎤' : '🔇'}
        </button>
        <button className={`toggle-btn ${!videoEnabled ? 'off' : ''}`} onClick={toggleVideo} data-testid="toggle-video">
          {videoEnabled ? '📹' : '📵'}
        </button>
        <button className="end-call" onClick={onEnd} data-testid="end-call">✕</button>
      </div>
      {callState.initiator && !callState.answered && (
        <div className="calling-overlay">
          <div className="pulse-ring">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg>
          </div>
          <div className="calling-name">{callState.target}</div>
          <div className="calling-text">LLAMANDO...</div>
          <button className="end-call" onClick={onEnd} style={{ width: 48, height: 48, borderRadius: '50%', background: 'var(--red)', color: '#fff', border: 'none', cursor: 'pointer', fontSize: 18 }}>✕</button>
        </div>
      )}
    </div>
  );
}

// =================== SECURITY VIEW ===================
function SecurityLeftPanel({ token }) {
  const [alerts, setAlerts] = useState([]);
  useEffect(() => {
    fetch(`${API}/api/security/alerts`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json()).then(setAlerts).catch(() => {});
  }, [token]);

  return (
    <>
      <div className="panel-title">ALERTAS</div>
      <div className="room-list">
        {alerts.map((a, i) => (
          <div key={i} className={`alert-item ${a.severity}`} style={{ margin: '4px 0', padding: '8px 10px' }}>
            <div style={{ fontSize: '10px', fontWeight: 700, color: a.severity === 'alta' ? 'var(--red)' : '#FFA500' }}>{a.type}</div>
            <div style={{ fontSize: '9px', color: 'var(--text-dim)' }}>{a.layer}</div>
          </div>
        ))}
      </div>
    </>
  );
}

function SecurityView({ token }) {
  const [stats, setStats] = useState(null);
  const [layers, setLayers] = useState([]);
  const [alerts, setAlerts] = useState([]);

  useEffect(() => {
    const headers = { Authorization: `Bearer ${token}` };
    Promise.all([
      fetch(`${API}/api/security/stats`, { headers }).then(r => r.json()),
      fetch(`${API}/api/security/layers`, { headers }).then(r => r.json()),
      fetch(`${API}/api/security/alerts`, { headers }).then(r => r.json()),
    ]).then(([s, l, a]) => { setStats(s); setLayers(l); setAlerts(a); }).catch(() => {});
  }, [token]);

  return (
    <div className="security-page" data-testid="security-page">
      <div className="security-header">
        <div className="security-title">INFORME DE SEGURIDAD</div>
        <div style={{ fontSize: '10px', color: 'var(--cyan)' }}>divzb-xiaaa-aaaam-aivwa-cai</div>
      </div>

      {stats && (
        <div className="stats-grid">
          <div className="stat-card"><div className="stat-value">{stats.layers_online}/{stats.layers_total}</div><div className="stat-label">CAPAS ONLINE</div></div>
          <div className="stat-card"><div className="stat-value">{stats.blocks_verified}</div><div className="stat-label">BLOQUES VERIFICADOS</div></div>
          <div className="stat-card"><div className="stat-value">{stats.ed25519_signatures}</div><div className="stat-label">FIRMAS Ed25519</div></div>
          <div className="stat-card"><div className="stat-value">{stats.fuzz_tests}</div><div className="stat-label">FUZZ TESTS</div></div>
          <div className="stat-card"><div className="stat-value">{stats.throughput}</div><div className="stat-label">THROUGHPUT</div></div>
          <div className="stat-card"><div className="stat-value">{stats.uptime}</div><div className="stat-label">UPTIME</div></div>
        </div>
      )}

      <div className="section-title">9 CAPAS DEL PROTOCOLO</div>
      <div className="layers-grid">
        {layers.map(l => (
          <div key={l.layer_id} className="layer-card">
            <div className="layer-header">
              <div className="layer-id">{l.layer_id}</div>
              <div className={`layer-status ${l.status.toLowerCase()}`}>{l.status}</div>
            </div>
            <div className="layer-name">{l.name}</div>
            <div className="layer-canister">{l.canister}</div>
            <div className="layer-lang">{l.lang}</div>
            <div className="layer-blocks">Bloques: <span>{l.blocks.join(', ')}</span></div>
            <div className="layer-cmds">Comandos: <span>{l.commands.length}</span></div>
          </div>
        ))}
      </div>

      <div className="section-title">ACTIVIDAD SOSPECHOSA DETECTADA</div>
      {alerts.map((a, i) => (
        <div key={i} className={`alert-item ${a.severity}`}>
          <div className="alert-header">
            <div className="alert-type">{a.type}</div>
            <div className="alert-severity">{a.severity.toUpperCase()}</div>
          </div>
          <div className="alert-desc">{a.description}</div>
          <div className="alert-action">{a.action}</div>
          <div className="alert-meta">
            <span>{a.layer}</span>
            <span>{a.resolved ? 'RESUELTO' : 'ACTIVO'}</span>
          </div>
        </div>
      ))}
    </div>
  );
}

// =================== MANUAL VIEW ===================
function ManualLeftPanel({ token }) {
  return (
    <>
      <div className="panel-title">CAPAS</div>
      <div className="room-list">
        {['L1','L2','L3','L4','L5','L6','L7','L8','L9'].map(l => (
          <div key={l} className="room-item">
            <div className="user-avatar" style={{ borderColor: 'var(--red)', color: 'var(--red)' }}>{l}</div>
            <div className="user-name">{l}</div>
          </div>
        ))}
      </div>
    </>
  );
}

function ManualView({ token }) {
  const [layers, setLayers] = useState([]);
  useEffect(() => {
    fetch(`${API}/api/manual/layers`, { headers: { Authorization: `Bearer ${token}` } })
      .then(r => r.json()).then(setLayers).catch(() => {});
  }, [token]);

  return (
    <div className="manual-page" data-testid="manual-page">
      <div className="security-header">
        <div className="security-title">VERIFICAR MANUAL</div>
        <div style={{ fontSize: '10px', color: 'var(--text-dim)' }}>200+ COMANDOS OPERATIVOS</div>
      </div>

      {layers.map(l => (
        <div key={l.layer_id} className="cmd-section">
          <div className="section-title" style={{ color: 'var(--red)' }}>{l.layer_id} — {l.name}</div>
          <div style={{ fontSize: '10px', color: 'var(--cyan)', marginBottom: '4px' }}>{l.canister} | {l.lang}</div>
          <div className="cmd-list">
            {l.commands.map((cmd, i) => (
              <div key={i} className="cmd-item">dfx canister call {l.layer_id === 'L9' ? 'x39_bases' : l.layer_id === 'L8' ? 'corebackend' : `layer${l.layer_id.slice(1)}${l.name.split(' ')[0].toLowerCase()}`} {cmd} --network ic</div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

// =================== PROTECT VIEW ===================
function ProtectLeftPanel() {
  return (
    <>
      <div className="panel-title">CATEGORIAS</div>
      <div className="room-list">
        {['Despliegue', 'Configuracion', 'Buenas Practicas', 'Algebra L9'].map((c, i) => (
          <div key={i} className="room-item">
            <div className="user-avatar" style={{ borderColor: 'var(--red)', color: 'var(--red)', fontSize: '10px' }}>{i + 1}</div>
            <div className="user-name" style={{ fontSize: '11px' }}>{c}</div>
          </div>
        ))}
      </div>
    </>
  );
}

function ProtectView() {
  const tips = [
    { title: 'Despliegue Recomendado por Tipo de Sistema', text: 'Gobierno: L1+L2+L3+L4+L7+L8+L9 (minimo 7 capas). Banca: TODAS las 9 capas con enfasis en L3 (ejecucion determinista) y L4 (consenso). Infraestructura critica: L1+L5+L6+L7+L8+L9 con L5 para absorcion DDoS. Identidad ciudadana: L2 (ZK-KYC) + L7 (AI) + L9 (algebra) obligatorios.' },
    { title: 'Configuracion Optima de Parametros', text: 'L7 analyzeRisk: umbral riskScore >= 70 para bloqueo automatico. L4 checkRisk: umbral >= 80 para transferencias SWIFT. L3 calculateFee: configurar fee anomala si operacion > 1000x normal. L8 aggregateSignature: requerir MINIMO 6/9 firmas para operaciones criticas. L1 logMemoryEvent: registrar TODO trafico > 100MB/min.' },
    { title: 'Buenas Practicas de Seguridad', text: 'Ejecutar dfx canister call x39_bases fuzz_test --network ic DIARIAMENTE. Verificar invariantes de TODAS las capas cada 6 horas. Mantener backup cifrado de la identidad dfx. NUNCA compartir el principal del controlador. Rotacion de claves cada 90 dias. Monitorizar cycles de cada canister — alerta si < 1T.' },
    { title: 'Algebra de la Capa L9 — Fundamento Matematico', text: 'L9 (x39_bases) es el CORAZON ALGEBRAICO del protocolo. Usa Algebra Abstracta: Teoria de Categorias (objetos, morfismos, functores, transformaciones naturales), Algebra de Automatas (estados, transiciones delta, aceptacion). Invariantes algebraicos: composicion asociativa (f∘g)∘h = f∘(g∘h), morfismo identidad id∘f = f, functor preserva composicion F(f∘g) = F(f)∘F(g). L9 es JUEZ DE ULTIMA INSTANCIA — puede vetar L8 si viola invariantes algebraicos.' },
  ];

  return (
    <div className="protect-page" data-testid="protect-page">
      <div className="security-header">
        <div className="security-title">PROTEGER SU SISTEMA</div>
      </div>
      {tips.map((t, i) => (
        <div key={i} className="tip-card">
          <div className="tip-title">{t.title}</div>
          <div className="tip-text">{t.text}</div>
        </div>
      ))}
    </div>
  );
}

// =================== SUPPORT VIEW ===================
function SupportLeftPanel() {
  return (
    <>
      <div className="panel-title">SOPORTE</div>
      <div className="room-list">
        {['Chat en Vivo', 'Enviar Evidencia', 'Base de Conocimiento'].map((c, i) => (
          <div key={i} className="room-item">
            <div className="user-avatar" style={{ borderColor: 'var(--cyan)', color: 'var(--cyan)', fontSize: '10px' }}>{i + 1}</div>
            <div className="user-name" style={{ fontSize: '11px' }}>{c}</div>
          </div>
        ))}
      </div>
    </>
  );
}

function SupportView({ nick }) {
  return (
    <div className="support-page" data-testid="support-page">
      <div className="security-header">
        <div className="security-title">CONTACTAR SOPORTE</div>
      </div>
      <div className="tip-card">
        <div className="tip-title">Chat en Vivo</div>
        <div className="tip-text">Para contactar con el equipo de soporte de X-39MATRIX, envia un mensaje a traves del chat de la aplicacion al usuario "soporte" o escribe a x39matrix.org.</div>
      </div>
      <div className="tip-card">
        <div className="tip-title">Enviar Evidencia Forense</div>
        <div className="tip-text">Para enviar evidencia forense para analisis, ejecuta el script de extraccion forense y comparte el archivo .tar.gz resultante con firma SHA256 y Ed25519 verificable.</div>
        <div className="cmd-list" style={{ marginTop: '8px' }}>
          <div className="cmd-item">dfx canister call x39_bases ptu47_audit --network ic</div>
          <div className="cmd-item">dfx canister call corebackend aggregateSignature '(vec {"{"}sig_L1"; ... "sig_L9"{"}"})' --network ic</div>
        </div>
      </div>
      <div className="tip-card">
        <div className="tip-title">Base de Conocimiento</div>
        <div className="tip-text">Accede a la documentacion completa en x39matrix.org. Manual de 200+ comandos, arquitectura de 9 capas con 40 bloques Ed25519, motor algebraico PTU-47 y Collapse Engine.</div>
      </div>
      <div className="tip-card">
        <div className="tip-title">Informacion de Contacto</div>
        <div className="tip-text">
          Creador: Jose Luis Olivares Esteban<br/>
          Protocolo: X-39MATRIX<br/>
          Canister: divzb-xiaaa-aaaam-aivwa-cai<br/>
          Web: x39matrix.org<br/>
          Red: ICP Mainnet
        </div>
      </div>
    </div>
  );
}

export default App;
