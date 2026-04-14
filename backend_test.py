import requests
import sys
from datetime import datetime
import json

class X39MatrixAPITester:
    def __init__(self, base_url="https://estado-protocolo.preview.emergentagent.com"):
        self.base_url = base_url
        self.api_url = f"{base_url}/api"
        self.tests_run = 0
        self.tests_passed = 0
        self.failed_tests = []

    def run_test(self, name, method, endpoint, expected_status, data=None):
        """Run a single API test"""
        url = f"{self.api_url}/{endpoint}" if endpoint else f"{self.api_url}/"
        headers = {'Content-Type': 'application/json'}

        self.tests_run += 1
        print(f"\n🔍 Testing {name}...")
        print(f"   URL: {url}")
        
        try:
            if method == 'GET':
                response = requests.get(url, headers=headers, timeout=10)
            elif method == 'POST':
                response = requests.post(url, json=data, headers=headers, timeout=10)

            success = response.status_code == expected_status
            if success:
                self.tests_passed += 1
                print(f"✅ Passed - Status: {response.status_code}")
                try:
                    response_data = response.json()
                    print(f"   Response: {json.dumps(response_data, indent=2)[:200]}...")
                    return True, response_data
                except:
                    return True, response.text
            else:
                print(f"❌ Failed - Expected {expected_status}, got {response.status_code}")
                print(f"   Response: {response.text[:200]}...")
                self.failed_tests.append({
                    "test": name,
                    "endpoint": endpoint,
                    "expected": expected_status,
                    "actual": response.status_code,
                    "response": response.text[:200]
                })
                return False, {}

        except Exception as e:
            print(f"❌ Failed - Error: {str(e)}")
            self.failed_tests.append({
                "test": name,
                "endpoint": endpoint,
                "error": str(e)
            })
            return False, {}

    def test_health_check(self):
        """Test GET /api/ health check"""
        success, response = self.run_test(
            "Health Check",
            "GET",
            "",
            200
        )
        if success and isinstance(response, dict) and "message" in response:
            expected_message = "x39Matrix — 51% Attack Detection Lab"
            if response["message"] == expected_message:
                print(f"   ✅ Correct message: {response['message']}")
                return True
            else:
                print(f"   ⚠️  Message mismatch. Expected: {expected_message}, Got: {response['message']}")
        return success

    def test_layers_endpoint(self):
        """Test GET /api/layers - should return 9 layers"""
        success, response = self.run_test(
            "Layers Endpoint",
            "GET",
            "layers",
            200
        )
        if success and isinstance(response, list):
            if len(response) == 9:
                print(f"   ✅ Correct number of layers: {len(response)}")
                # Check if all layers L1-L9 are present
                layer_names = [layer.get('layer') for layer in response]
                expected_layers = [f"L{i}" for i in range(1, 10)]
                missing_layers = [l for l in expected_layers if l not in layer_names]
                if not missing_layers:
                    print(f"   ✅ All layers L1-L9 present")
                    # Check layer structure
                    first_layer = response[0]
                    required_fields = ['layer', 'name', 'status', 'canister_id', 'technology']
                    if all(field in first_layer for field in required_fields):
                        print(f"   ✅ Layer structure correct")
                        return True
                    else:
                        print(f"   ⚠️  Missing required fields in layer structure")
                else:
                    print(f"   ⚠️  Missing layers: {missing_layers}")
            else:
                print(f"   ⚠️  Expected 9 layers, got {len(response)}")
        return success

    def test_simulation_blocks(self):
        """Test GET /api/simulation/blocks"""
        success, response = self.run_test(
            "Simulation Blocks",
            "GET",
            "simulation/blocks",
            200
        )
        if success and isinstance(response, dict):
            required_keys = ['legitimate_chain', 'attacker_chain', 'transaction']
            if all(key in response for key in required_keys):
                print(f"   ✅ All required keys present: {required_keys}")
                
                # Check legitimate chain
                legit_chain = response['legitimate_chain']
                if isinstance(legit_chain, list) and len(legit_chain) == 5:
                    print(f"   ✅ Legitimate chain has 5 blocks")
                else:
                    print(f"   ⚠️  Legitimate chain should have 5 blocks, got {len(legit_chain) if isinstance(legit_chain, list) else 'not a list'}")
                
                # Check attacker chain
                attacker_chain = response['attacker_chain']
                if isinstance(attacker_chain, list) and len(attacker_chain) == 6:
                    print(f"   ✅ Attacker chain has 6 blocks")
                else:
                    print(f"   ⚠️  Attacker chain should have 6 blocks, got {len(attacker_chain) if isinstance(attacker_chain, list) else 'not a list'}")
                
                # Check transaction structure
                transaction = response['transaction']
                if isinstance(transaction, dict) and 'txid' in transaction:
                    print(f"   ✅ Transaction structure correct")
                    return True
                else:
                    print(f"   ⚠️  Transaction structure incorrect")
            else:
                missing_keys = [key for key in required_keys if key not in response]
                print(f"   ⚠️  Missing keys: {missing_keys}")
        return success

    def test_simulation_run(self):
        """Test POST /api/simulation/run"""
        success, response = self.run_test(
            "Simulation Run",
            "POST",
            "simulation/run",
            200
        )
        if success and isinstance(response, dict):
            required_fields = ['id', 'started_at', 'status', 'attack_detected', 'detection_time_ms']
            if all(field in response for field in required_fields):
                print(f"   ✅ All required fields present: {required_fields}")
                if response['status'] == 'completed' and response['attack_detected'] == True:
                    print(f"   ✅ Simulation run data correct")
                    return True
                else:
                    print(f"   ⚠️  Unexpected simulation run values")
            else:
                missing_fields = [field for field in required_fields if field not in response]
                print(f"   ⚠️  Missing fields: {missing_fields}")
        return success

    def test_simulation_history(self):
        """Test GET /api/simulation/history"""
        success, response = self.run_test(
            "Simulation History",
            "GET",
            "simulation/history",
            200
        )
        if success and isinstance(response, list):
            print(f"   ✅ History endpoint returns list with {len(response)} entries")
            return True
        return success

def main():
    print("🚀 Starting x39Matrix API Testing...")
    print("=" * 60)
    
    # Setup
    tester = X39MatrixAPITester()
    
    # Run all tests
    tests = [
        tester.test_health_check,
        tester.test_layers_endpoint,
        tester.test_simulation_blocks,
        tester.test_simulation_run,
        tester.test_simulation_history
    ]
    
    for test in tests:
        test()
    
    # Print results
    print("\n" + "=" * 60)
    print(f"📊 Test Results: {tester.tests_passed}/{tester.tests_run} passed")
    
    if tester.failed_tests:
        print("\n❌ Failed Tests:")
        for failed in tester.failed_tests:
            error_msg = failed.get('error', f"Status {failed.get('actual')} != {failed.get('expected')}")
            print(f"   - {failed['test']}: {error_msg}")
    
    success_rate = (tester.tests_passed / tester.tests_run) * 100 if tester.tests_run > 0 else 0
    print(f"\n🎯 Success Rate: {success_rate:.1f}%")
    
    return 0 if tester.tests_passed == tester.tests_run else 1

if __name__ == "__main__":
    sys.exit(main())