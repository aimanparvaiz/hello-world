import os
import sys
import thread

# boto
import boto
import sqlite3
from boto.ec2.connection import EC2Connection

# fabric
from fabric.api import *
from fabric.colors import *
from fabric.operations import prompt

from yaml import load, safe_dump

db_path = '/mnt/sec_grp.db'

class AppError(Exception):
	pass

def get_config():
	with open(config.yaml) as f:
		return load(f)

def get_ec2(region):
	return boto.ec2.connect_to_region(region)

def get_db_conn():
	return sqlite3.connect(db_path)

@task
def db_initializer():
	conn = get_db_conn()
	c = conn.cursor()
	c.execute('''CREATE TABLE sec_grp_info(region text, security_group text, port real, ip text, requester_name text)''')

@task
def open_port(sec_grp, ip_protocol, port, cidr_ip):
	# If API call is successful then in returns True
	if not sec_grp.authorize(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=cidr_ip):
		ex = AppError( "AWS API failed" )
		raise ex

# TODO Make this threaded for multi simultaneous executions
@task
def add_ip(region, group, port, ip, requester_name):
	"""
	Opens port for a particular IP. Saves the name of the requester.

	:param zone: Environments; prod, stage, dev.
	:param group: Security Group under consideration.
	:param requester_name: Whose IP is being added.

	"""
	cidr_ip = ip+'/32'
	#Zone is the key to get vpc-id from config. Zone will also give
	#all the sec grps. From these sec grps get the one containing the word
	#server_type and then perform the action on this grp

	# TODO: IP range
	conn = get_ec2(region)

	sec_grps = conn.get_all_security_groups()

	for count in sec_grps:
		#import ipdb; ipdb.set_trace()
		if str(count) == 'SecurityGroup:'+group:
			sec_grp = count
	# This should be checked from the yaml
	if len(str(sec_grp)) == 0:
		print('sec grp not found')
		sys.exit(0)

	# Write a function which opens the security group and let it throw a exception.
	# Catch this exception and in the catch part undo the action.

	try:
		open_port(sec_grp, ip_protocol, port, cidr_ip)
	except AppError, ex
		print ex


	try:
		db_write()
	excpet AppError, ex
		print ex
		# Undo the actions

	if sec_grp.authorize(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=cidr_ip):
		try:
			os.path.exists('/mnt/sec_grp.db')
		except IOError:
			print('DB in not initialized, initializing it')
		# Call DB initializer()

		db_conn = get_db_conn()
		c = db_conn.cursor()
		try:
			c.execute("INSERT INTO sec_grp_info VALUES(region, security_group, port, ip, requester_name)")
		except IOError:
			print('Operation failed')
			sys.exit(0)
	else:
		print ('Security Grp call failed')




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




