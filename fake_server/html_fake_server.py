import os
import http.server
import socketserver
import sys

port = sys.argv[1]
print ("Port: {}".format(port))

ip = '0.0.0.0' # Or '127.0.0.1' instead of 'localhost'.
# port = '8001' # Or '8081' or '8082' instead of '8080'.
Handler = http.server.SimpleHTTPRequestHandler
httpd = socketserver.TCPServer((ip, int(port)), Handler)
httpd.serve_forever()
