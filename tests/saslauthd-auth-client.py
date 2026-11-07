#!/usr/bin/env python3
"""Minimal saslauthd mux client; stdlib only, for CI integration testing."""
import socket
import struct
import sys

if len(sys.argv) != 6:
    sys.exit('usage: saslauthd-auth-client.py SOCKET USER PASSWORD SERVICE REALM')
path, user, password, service, realm = sys.argv[1:]
fields = [user, password, service, realm]
request = b''.join(struct.pack('!H', len(x.encode())) + x.encode() for x in fields)
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
    sock.settimeout(5)
    sock.connect(path)
    sock.sendall(request)
    def read_exact(count):
        data = b''
        while len(data) < count:
            part = sock.recv(count - len(data))
            if not part:
                raise RuntimeError('Unexpected EOF from saslauthd')
            data += part
        return data
    length = struct.unpack('!H', read_exact(2))[0]
    result = read_exact(length).decode('ascii', 'replace')
print(result)
sys.exit(0 if result.startswith('OK') else 1)
