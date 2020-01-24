local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local main_compose = if params.platform == "compose"
then {
  "redis": {
    version: "3",
    services: {
      redis: {
        image: params.redis.image,
        ports: [ "%(bind_port)d:%(bind_port)d" % params.redis, ],
        command: [ "%s" % c for c in params.redis.args ], //cast all to string
      },
    }
  }
}
else {};

main_compose
