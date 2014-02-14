# boto
import boto
from boto.ec2.connection import EC2Connection

# fabric
from fabric.api import *
from fabric.colors import *
from fabric.operations import prompt

from yaml import load, safe_dump

@task
def add_ip(zone, server_type, port, ip, user):
	pass

@task
def remove_ip(zone, server_type, port, ip, user):
	pass



