"""
X-39MATRIX Messenger API Tests
Tests for authentication, security layers, alerts, and stats endpoints
"""
import pytest
import requests
import os
import time

BASE_URL = os.environ.get('REACT_APP_BACKEND_URL', '').rstrip('/')

class TestHealthEndpoint:
    """Health check endpoint tests"""
    
    def test_health_returns_ok(self):
        """Test /api/health returns status ok"""
        response = requests.get(f"{BASE_URL}/api/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert data["service"] == "X-39MATRIX Messenger"


class TestAuthEndpoints:
    """Authentication endpoint tests"""
    
    def test_register_new_user(self):
        """Test /api/auth/register creates new user"""
        unique_nick = f"TEST_user_{int(time.time())}"
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "nick": unique_nick,
            "password": "testpass123"
        })
        assert response.status_code == 200
        data = response.json()
        assert "token" in data
        assert data["nick"] == unique_nick
        assert len(data["token"]) > 0
    
    def test_register_short_nick_fails(self):
        """Test registration with short nick fails"""
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "nick": "a",
            "password": "testpass123"
        })
        assert response.status_code == 400
    
    def test_register_short_password_fails(self):
        """Test registration with short password fails"""
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "nick": "validnick",
            "password": "abc"
        })
        assert response.status_code == 400
    
    def test_register_duplicate_nick_fails(self):
        """Test registration with existing nick fails"""
        response = requests.post(f"{BASE_URL}/api/auth/register", json={
            "nick": "jose",
            "password": "anypassword"
        })
        assert response.status_code == 409
    
    def test_login_valid_credentials(self):
        """Test /api/auth/login with valid credentials"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "nick": "jose",
            "password": "x39matrix"
        })
        assert response.status_code == 200
        data = response.json()
        assert "token" in data
        assert data["nick"] == "jose"
        assert len(data["token"]) > 0
    
    def test_login_invalid_credentials(self):
        """Test /api/auth/login with invalid credentials"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "nick": "jose",
            "password": "wrongpassword"
        })
        assert response.status_code == 401
    
    def test_login_nonexistent_user(self):
        """Test /api/auth/login with nonexistent user"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "nick": "nonexistentuser12345",
            "password": "anypassword"
        })
        assert response.status_code == 401


class TestAuthenticatedEndpoints:
    """Tests for endpoints requiring authentication"""
    
    @pytest.fixture(autouse=True)
    def setup_auth(self):
        """Get auth token before each test"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "nick": "jose",
            "password": "x39matrix"
        })
        if response.status_code == 200:
            self.token = response.json()["token"]
            self.headers = {"Authorization": f"Bearer {self.token}"}
        else:
            pytest.skip("Authentication failed")
    
    def test_get_me(self):
        """Test /api/auth/me returns current user"""
        response = requests.get(f"{BASE_URL}/api/auth/me", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert data["nick"] == "jose"
        assert "password_hash" not in data
    
    def test_get_users(self):
        """Test /api/users returns user list"""
        response = requests.get(f"{BASE_URL}/api/users", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0
        # Verify no password hashes exposed
        for user in data:
            assert "password_hash" not in user
    
    def test_get_rooms(self):
        """Test /api/rooms returns room list"""
        response = requests.get(f"{BASE_URL}/api/rooms", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)


class TestSecurityEndpoints:
    """Security dashboard endpoint tests"""
    
    @pytest.fixture(autouse=True)
    def setup_auth(self):
        """Get auth token before each test"""
        response = requests.post(f"{BASE_URL}/api/auth/login", json={
            "nick": "jose",
            "password": "x39matrix"
        })
        if response.status_code == 200:
            self.token = response.json()["token"]
            self.headers = {"Authorization": f"Bearer {self.token}"}
        else:
            pytest.skip("Authentication failed")
    
    def test_get_security_layers(self):
        """Test /api/security/layers returns 9 layers"""
        response = requests.get(f"{BASE_URL}/api/security/layers", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 9
        
        # Verify layer structure
        for layer in data:
            assert "layer_id" in layer
            assert "name" in layer
            assert "canister" in layer
            assert "lang" in layer
            assert "blocks" in layer
            assert "status" in layer
            assert "commands" in layer
            assert layer["status"] == "ONLINE"
        
        # Verify all 9 layers present
        layer_ids = [l["layer_id"] for l in data]
        expected_ids = ["L1", "L2", "L3", "L4", "L5", "L6", "L7", "L8", "L9"]
        assert sorted(layer_ids) == sorted(expected_ids)
    
    def test_get_security_alerts(self):
        """Test /api/security/alerts returns alerts"""
        response = requests.get(f"{BASE_URL}/api/security/alerts", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) > 0
        
        # Verify alert structure
        for alert in data:
            assert "type" in alert
            assert "severity" in alert
            assert "layer" in alert
            assert "description" in alert
            assert "timestamp" in alert
            assert "resolved" in alert
            assert "action" in alert
    
    def test_get_security_stats(self):
        """Test /api/security/stats returns protocol stats"""
        response = requests.get(f"{BASE_URL}/api/security/stats", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        
        # Verify stats structure
        assert data["layers_online"] == 9
        assert data["layers_total"] == 9
        assert data["blocks_verified"] == 40
        assert data["ed25519_signatures"] == "9/9"
        assert "fuzz_tests" in data
        assert "collapse_tests" in data
        assert "throughput" in data
        assert "finality" in data
        assert "uptime" in data
        assert data["canister_ids_exposed"] == 0
        assert data["keys_exposed"] == 0
        assert data["fuzz_escapes"] == 0
    
    def test_get_manual_layers(self):
        """Test /api/manual/layers returns layers with commands"""
        response = requests.get(f"{BASE_URL}/api/manual/layers", headers=self.headers)
        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)
        assert len(data) == 9
        
        # Count total commands
        total_commands = sum(len(layer["commands"]) for layer in data)
        assert total_commands > 90  # Should have 90+ commands


class TestUnauthorizedAccess:
    """Tests for unauthorized access to protected endpoints"""
    
    def test_security_layers_without_token(self):
        """Test /api/security/layers requires auth"""
        response = requests.get(f"{BASE_URL}/api/security/layers")
        assert response.status_code == 401
    
    def test_security_alerts_without_token(self):
        """Test /api/security/alerts requires auth"""
        response = requests.get(f"{BASE_URL}/api/security/alerts")
        assert response.status_code == 401
    
    def test_security_stats_without_token(self):
        """Test /api/security/stats requires auth"""
        response = requests.get(f"{BASE_URL}/api/security/stats")
        assert response.status_code == 401
    
    def test_users_without_token(self):
        """Test /api/users requires auth"""
        response = requests.get(f"{BASE_URL}/api/users")
        assert response.status_code == 401
    
    def test_invalid_token(self):
        """Test invalid token is rejected"""
        response = requests.get(f"{BASE_URL}/api/security/layers", 
                               headers={"Authorization": "Bearer invalid_token"})
        assert response.status_code == 401


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
