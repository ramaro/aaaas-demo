local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local main_compose = if params.platform == "compose"
then {
  "compose.dbrpc": {
    version: "3",
    services: {
      dbrpc: {
        image: params.dbrpc.image,
        ports: [ "%(bind_port)d:%(bind_port)d" % params.dbrpc, ],
        command: [ "%s" % c for c in params.dbrpc.args ], //cast all to string
      }
    }
  }
}
else {};

local main_kubernetes = if params.platform == "kubernetes"
then {
}
else {};

main_compose + main_kubernetes

