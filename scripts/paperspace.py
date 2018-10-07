#!/usr/bin/env python3

import argparse
import json
import os
from os import path
import re
import subprocess
import sys

KEYNAME = 'paperspace-termux-cli'
VMNAME = 'ps-game'

## todo: generalize to include azure, bokken :D


def fatal_paperspace(error):
    sys.exit(f"fatal (paperspace): {error}")


def run_paperspace(args):
    result = subprocess.run(['paperspace'] + args, stdout=subprocess.PIPE)
    parsed = json.loads(result.stdout)[0]
    error = parsed['error']
    if error:
        fatal_paperspace(error)
    return parsed

def init_paperspace():
    for line in open(path.expanduser('~/dotfiles/private/api/keys')):
        m = re.search(f'{KEYNAME}\s+(\w+)\s*=\s*(\S+)', line)
        if m:
            os.environ[m.group(1)] = m.group(2)
            return
    fatal_paperspace('Unable to find API key')

def get_paperspace_vm_from_name(name=VMNAME):
    for item in run_paperspace(['machines', 'list']):
        if item['name'] == name:
            return item

def get_paperspace_vm_id_from_name(name=VMNAME):
    return get_paperspace_vm_from_name(name)['id']

def waitfor_paperspace_status(machineId, status):
    #paperspace machines waitfor --machineId $VMID --state ready
    pass

def start_cmd(args):
    init_paperspace()
    vmid = get_paperspace_vm_id_from_name()
    #paperspace machines start --machineId $VMID
    waitfor_paperspace_status(vmid, 'ready')
    print("start!")

def stop_cmd(args):
    init_paperspace()
    vmid = get_paperspace_vm_id_from_name()
    #paperspace machines stop --machineId $VMID
    waitfor_paperspace_status(vmid, 'off')
    print("stop!")

def status_cmd(args):
    init_paperspace()
    vm = get_paperspace_vm_from_name()
    print(vm.state)

parser = argparse.ArgumentParser(description='Simple helpers to mess with my VMs')
subparsers = parser.add_subparsers()
start_parser = subparsers.add_parser('start')
start_parser.set_defaults(func=start_cmd)
stop_parser = subparsers.add_parser('stop')
stop_parser.set_defaults(func=stop_cmd)
status_parser = subparsers.add_parser('status', aliases=['st'])
status_parser.set_defaults(func=status_cmd)
args = parser.parse_args()
args.func(args)
