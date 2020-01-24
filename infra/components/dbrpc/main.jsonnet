local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local main_compose = if params.platform == "compose"
then {
  "dbrpc": {
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
  local containers = [
    {
      name: "dbrpc",
      image: params.dbrpc.image,
      ports: [{containerPort: params.dbrpc.bind_port}],
      args: ["%s" % arg for arg in params.dbrpc.args ], // TODO remove and hardcode args/styles for demo
    },
  ],

  local deployment = {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
        name: "dbrpc",
        namespace: inv.parameters.target,
    },
    spec: {
        replicas: 1,
        selector: {
            matchLabels: { app: "dbrpc" },
        },
        template: {
            metadata: {
                labels: { app: "dbrpc" },
            },
            spec: {
                containers: containers,
            },
        },
    },
  },

  local service = {
      apiVersion: "v1",
      kind: "Service",
      spec: {
          ports: [
              {
                name: "http",
                port: 8079,
                targetPort: params.dbrpc.bind_port
              },
          ],
          selector: { app: "dbrpc" },
          type: "ClusterIP",
      },

      metadata: {
          name: "dbrpc",
          namespace: inv.parameters.target,
          labels: { name: "dbrpc" },
      },
  },

  "dbrpc-deployment": deployment,
  "dbrpc-service": service,

}
else {};

main_compose + main_kubernetes

