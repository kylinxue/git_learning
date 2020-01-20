# 向集群中各个节点发送相同的命令
export NODE_IPS=(192.168.100.101 192.168.100.102 192.168.100.103)
for node_ip in ${NODE_IPS[@]}
  do
    echo ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p /etc/kubernetes/cert"
    scp ca*.pem ca-config.json root@${node_ip}:/etc/kubernetes/cert
  done
