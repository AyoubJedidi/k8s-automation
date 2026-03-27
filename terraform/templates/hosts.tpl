127.0.0.1   localhost
%{ for name, vm in vms ~}
${vm.ip}   ${vm.hostname}
%{ endfor ~}
