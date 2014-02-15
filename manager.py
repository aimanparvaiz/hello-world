# boto
import boto
from boto.ec2.connection import EC2Connection

# fabric
from fabric.api import *
from fabric.colors import *
from fabric.operations import prompt

from yaml import load, safe_dump


def get_config():
	with open(config.yaml) as f:
		return load(f)

def get_ec2(region):
	return boto.ec2.connect_to_region(region)

@task
def add_ip(region, group, port, ip, requester_name)
	"""
	Opens port for a particular IP. Saves the name of the requester.

	:param zone: Environments; prod, stage, dev.
	:param group: Security Group under consideration.
	:param requester_name: Whose IP is being added.

	"""

	#Zone is the key to get vpc-id from config. Zone will also give
	#all the sec grps. From these sec grps get the one containing the word
	#server_type and then perform the action on this grp

	# TODO: IP range
	conn = get_ec2(region)

	sec_grps = conn.get_all_security_groups()

	for count in sec_grps:
		if str(count) == 'SecurityGroup:'.group:
			sec_grp = count

	sec_grp.authorize(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=ip)

@task
def close()
	"""
	Opens port for a particular IP. Saves the name of the requester.

	:param zone: Environments; prod, stage, dev.
	:param group: Security Group under consideration.
	:param requester_name: Whose IP is being added.

	"""

	#Zone is the key to get vpc-id from config. Zone will also give
	#all the sec grps. From these sec grps get the one containing the word
	#server_type and then perform the action on this grp

	# TODO: IP range,
	conn = get_ec2(region)
	sec_gprs = conn.get_all_security_groups()
	sec_grp = sec_gprs[group]
	# May be make this and DB entry atomic
	sec_grp.authorize(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=ip)









@task
def remove_ip(zone, server_type, port, ip, requester_name):
	"""
	Removes a IP from a security group.

	:param zone: Environments; prod, stage, dev.
	:param server_type: Server type under consideration.
	:param requester_name: Whose IP is being added.

	"""
	pass

@task
def build_group_db(zone):
	##Zone will give VPC-ID, from VPC we fetch all the security grps
	pass




