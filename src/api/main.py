#!/usr/bin/env python3

import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s -- %(message)s')
logger = logging.getLogger("aaaas-demo-api")

import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer
from pyfiglet import figlet_format
from arrpc import Client as RPCClient
from urllib.parse import parse_qs, urlparse
import sys


class AAaasServer(BaseHTTPRequestHandler):
    def do_GET(self):
        key = self.path.lstrip('/')
        msg = self.db_get(key)
        if msg is not None:
            return self.respond(msg.decode())
        else:
            return self.respond_404("Key \"{}\" not found!\n".format(key))

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(content_length)
        url_parsed = urlparse(self.path)
        query_parsed = parse_qs(url_parsed.query)
        key = url_parsed.path.lstrip('/')
        if 'style' in query_parsed:
            try:
                style = query_parsed['style'][0]
                data = stylise(data.decode(), style)
            except KeyError:
                self.respond_500("Unknown style: \"{}\"\n".format(style))
                return
        else:
            data = stylise(data.decode(), None)
        self.db_set(key, data)
        self.respond(data)

    def respond(self, data):
        content = self.handle_http(200, 'text/html', data)
        self.wfile.write(content)

    def respond_500(self,error_msg):
        content = self.handle_http(500, 'text/html', error_msg)
        self.wfile.write(content)

    def respond_404(self,error_msg):
        content = self.handle_http(404, 'text/html', error_msg)
        self.wfile.write(content)

    def handle_http(self, status, content_type, data):
        self.send_response(status)
        self.send_header('Content-type', content_type)
        self.end_headers()
        return bytes(data, 'UTF-8')

    def db_get(self, key):
        return self.db_client.send({'get': {'key': key}})

    def db_set(self, key, value):
        return self.db_client.send({'set': {'key':key, 'value': value}})


def style_title(value):
    return value.title(), {}

def style_upper(value):
    return value.upper(), {}

def style_starwars(value):
    return value, {'font': 'starwars'}

STYLE_FUNCS = {
    'title': style_title,
    'upper': style_upper,
    'starwars': style_starwars,
}

STYLE_ENABLED = {}

def style_parse_flags():
    for arg in sys.argv[1:]:
        if arg.startswith("--style-"):
            style = arg[8:]
            if style in STYLE_FUNCS:
                STYLE_ENABLED[style] = STYLE_FUNCS[style]
                logger.info("Enabled style: %s", style)
            else:
                raise Exception("Invalid style flag or style not available")

def stylise(value, style):
    stylised = value
    kwargs = {}
    try:
        if style is None:
            return figlet_format(stylised, font="standard")
        func = STYLE_ENABLED[style]
        stylised, kwargs = func(value)
        return figlet_format(stylised, **kwargs)
    except KeyError:
        raise


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ascii Art as a Service')
    parser.add_argument('--bind-host', action="store", default="")
    parser.add_argument('--bind-port', action="store", default=8080, type=int)
    parser.add_argument('--dbrpc-host', action="store", required=True)
    parser.add_argument('--dbrpc-port', action="store", type=int, required=True)
    parser.add_argument('--dbrpc-secret', action="store")
    parser.add_argument('--style-title', action="store_true", default=False)
    parser.add_argument('--style-upper', action="store_true", default=False)
    parser.add_argument('--style-starwars', action="store_true", default=False)
    args = parser.parse_args(sys.argv[1:])
    style_parse_flags()

    db_client_kwargs = {}
    if args.dbrpc_secret:
        db_client_kwargs = {"auth_secret": args.dbrpc_secret}

    db_client = RPCClient(args.dbrpc_host, args.dbrpc_port, **db_client_kwargs)
    AAaasServer.db_client = db_client
    aaaas_server = HTTPServer((args.bind_host, args.bind_port), AAaasServer)
    logger.info("Starting aaaas API with flags: %s", args)
    try:
        aaaas_server.serve_forever()
    except KeyboardInterrupt:
        aaaas_server.server_close()
