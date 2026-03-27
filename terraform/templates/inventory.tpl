[jumpbox]
${vms["jumpbox"].ip} ansible_user=root hostname=${vms["jumpbox"].hostname}

[control_plane]
${vms["server"].ip} ansible_user=root hostname=${vms["server"].hostname}

[workers]
%{ for name, vm in vms ~}
%{ if name != "jumpbox" && name != "server" ~}
${vm.ip} ansible_user=root hostname=${vm.hostname}
%{ endif ~}
%{ endfor ~}

[k8s_cluster:children]
control_plane
workers
