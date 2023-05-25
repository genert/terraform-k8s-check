import subprocess
import sys
import json

name = sys.argv[1]
namespace = sys.argv[2]

result = {}
try:
    helm_output = subprocess.check_output(["helm", "status", name, "-n", namespace])
    status = "deployed"
except subprocess.CalledProcessError:
    status = "not deployed"
except OSError:
    status = "Helm is not installed"
except Exception:
    status = "error"

result = {
    "release_name": name,
    "status": status,
}

print(json.dumps(result))