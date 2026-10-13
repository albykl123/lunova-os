#!/usr/bin/env python3
import socket
import json
import sys
import time

def qmp_command(port, command, args=None, timeout=10.0):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(timeout)
        s.connect(('127.0.0.1', int(port)))
        
        # Read greeting
        data = b''
        while b'\n' not in data:
            chunk = s.recv(1024)
            if not chunk:
                break
            data += chunk

        # Negotiate QMP capabilities
        s.sendall(b'{"execute": "qmp_capabilities"}\n')
        data = b''
        while b'\n' not in data:
            chunk = s.recv(1024)
            if not chunk:
                break
            data += chunk

        # Send target command
        payload = {"execute": command}
        if args:
            payload["arguments"] = args
        s.sendall(json.dumps(payload).encode() + b'\n')
        data = b''
        while b'\n' not in data:
            chunk = s.recv(1024)
            if not chunk:
                break
            data += chunk

        s.close()
        print(f"[QMP] Command '{command}' on port {port}: {data.decode(errors='replace').strip()}")
        return True
    except Exception as e:
        print(f"[QMP] Error executing '{command}' on port {port}: {e}", file=sys.stderr)
        return False

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: qmp_control.py <port> <command> [json_args]", file=sys.stderr)
        sys.exit(1)
        
    port = int(sys.argv[1])
    cmd = sys.argv[2]
    args = json.loads(sys.argv[3]) if len(sys.argv) > 3 else None
    success = qmp_command(port, cmd, args)
    sys.exit(0 if success else 1)
