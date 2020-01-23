#!/usr/bin/env python3
from arrpc import Server
from redis import Redis
import argparse
import sys

def db_get(client, key):
    return client.get(key)

def db_set(client, key, value):
    return client.set(key, value)

def handler(client, msg):
    if 'get' in msg:
        key = msg['get']['key']
        return db_get(client, key)

    if 'set' in msg:
        key = msg['set']['key']
        value = msg['set']['value']
        return db_set(client, key, value)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Database RPC adapter')
    parser.add_argument('--bind-host', action="store", required=True)
    parser.add_argument('--bind-port', action="store", type=int, required=True)
    parser.add_argument('--db-host', action="store", required=True)
    parser.add_argument('--db-port', action="store", type=int, required=True)
    parser.add_argument('--secret', action="store")
    args = parser.parse_args(sys.argv[1:])

    server_kwargs = {}
    if args.secret:
        server_kwargs = {"auth_secret": args.secret}

    redis_client = Redis(host=args.db_host, port=args.db_port)
    rpc_server = Server(args.bind_host, args.bind_port,
                        lambda msg: handler(redis_client, msg),
                        **server_kwargs)
    rpc_server.start()
