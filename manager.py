# boto
import boto
from boto.ec2.connection import EC2Connection

# fabric
from fabric.api import *
from fabric.colors import *
from fabric.operations import prompt

from yaml import load, safe_dump

@task
def add_ip(zone, server_type, port, ip, requester_name):
	"""
	Opens port for a particular IP. Saves the name of the requester.

	:param zone: Environments; prod, stage, dev.
	:param server_type: Server type under consideration.
	:param requester_name: Whose IP is being added.

	"""


@task
def remove_ip(zone, server_type, port, ip, requester_name):
	pass

@task
def build_group_db(zone):
	pass




