local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local main_compose = if params.platform == "compose"
then {
  "compose.api": {
    version: "3",
    services: {
      api: {
        image: params.api.image,
        ports: [ "%(bind_port)d:%(bind_port)d" % params.api, ],
        command: [ "%s" % c for c in params.api.args ], //cast all to string
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

