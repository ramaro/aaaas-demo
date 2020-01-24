local kap = import "lib/kapitan.libjsonnet";
local inv = kap.inventory();
local params = inv.parameters;

local n = {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
        labels: {
            name: params.target,
        },
        name: params.target,
        namespace: params.target,
    },
};

{
    "00_namespace": n,
}
