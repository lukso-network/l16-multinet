#!/bin/bash

echo "Running lighthouse"

set -eu

export RUST_LOG=trace,libp2p=trace,multistream=trace,gossipsub=trace

# Read in variables
cd "$(dirname "$0")"
source vars.sh

MULTINET_POD_NAME=${MULTINET_POD_NAME:-lighthouse-0}
LH_DATADIR="/root/multinet/repo/deposits/$MULTINET_POD_NAME"

NBC_DATADIR="/root/multinet/repo/deposits/nimbus-0"
LH_VALIDATORS_DIR=$LH_DATADIR/keys
LH_SECRETS_DIR=$LH_DATADIR/secrets

SRCDIR=${LIGHTHOUSE_PATH:-"lighthouse"}

cd "$SRCDIR"

# fresh start!
rm -rf ~/.lighthouse
rm -rf $LH_DATADIR/beacon

# Wait nimbus (bootstrap node)
wait_enr "$NBC_DATADIR/beacon_node.enr"

sleep 2

BOOTNODES_ARG=""
if [[ -f $TESTNET_DIR/bootstrap_nodes.txt ]]; then
  BOOTNODES_ARG="--boot-nodes $(cat $TESTNET_DIR/bootstrap_nodes.txt | paste -s -d, -)"
fi

if [[ -f $LH_DATADIR/beacon/pubkey_cache.ssz ]]; then
  rm $LH_DATADIR/beacon/pubkey_cache.ssz
fi

if [[ -f $LH_DATADIR/beacon/network/enr.dat ]]; then
  rm $LH_DATADIR/beacon/network/enr.dat
fi

set -x # print commands

# beacon node
target/release/lighthouse \
  bn \
	--debug-level debug \
	--datadir $LH_DATADIR \
  --network mainnet \
  --dummy-eth1 \
  --http-address "0.0.0.0" \
  --http-port 5052 \
  --port 50001 \
  --enr-address $MULTINET_POD_NAME \
  --enr-udp-port 50001 \
  --http \
  $BOOTNODES_ARG
