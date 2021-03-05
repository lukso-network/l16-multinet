#!/bin/bash

echo "Running prysm beacon-node";

mkdir /root/multinet/repo/data/common;

if [ "$MULTINET_POD_NAME" == "prysm-0" ]; then
  EXTERNAL_IP=34.91.111.241;
  rm /root/multinet/repo/data/common/genesis.ssz
  bazel run //tools/genesis-state-gen -- --num-validators=400 \
  --output-ssz=/root/multinet/repo/data/common/genesis.ssz \
  --mainnet-config
fi

if [ "$MULTINET_POD_NAME" == "prysm-1" ]; then
  EXTERNAL_IP=34.91.186.254;
fi

if [ "$MULTINET_POD_NAME" == "prysm-2" ]; then
  EXTERNAL_IP=34.90.76.16;
fi

if [ "$MULTINET_POD_NAME" == "prysm-3" ]; then
  EXTERNAL_IP=35.204.181.122;
fi


while  [ ! -f /root/multinet/repo/data/common/genesis.ssz ]; do
  sleep 5;
done

./prysm.sh beacon-chain --datadir /tmp/chaindata \
  --force-clear-db \
  --interop-genesis-state /root/multinet/repo/data/common/genesis.ssz \
  --interop-eth1data-votes \
  --monitoring-host=0.0.0.0 \
  --verbosity=debug \
  --min-sync-peers=0 \
  --p2p-max-peers=10 \
  --p2p-host-ip=$EXTERNAL_IP \
  --bootstrap-node=enr:-Ku4QFuEmIcEMoNAox0fh1PdJMeYdzruWFI1rNXi0Xk-Bk9pPpetCQSu27X9vUjYj7rS67L6tJaWWgaB-aNx16-0InkBh2F0dG5ldHOIAAAAAAAAAACEZXRoMpD1pf1CAAAAAP__________gmlkgnY0gmlwhAoAAUaJc2VjcDI1NmsxoQKWfbT1atCho149MGMvpgBWUymiOv9QyXYhgYEBZvPBW4N1ZHCCD6A \
  --accept-terms-of-use




