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
	# Do exception handling may be
	c.execute('''CREATE TABLE sec_grp_info(region text, security_group text, port real, ip text, requester_name text)''')

def db_write():
	db_conn = get_db_conn()
	c = db_conn.cursor()

	try:
		os.path.exists(db_path)
	except IOError:
		print('DB in not initialized, initializing it')
		# Call DB initializer()
		db_initializer()

	if not c.execute("INSERT INTO sec_grp_info VALUES(region, security_group, port, ip, requester_name)"):
		ex = AppError('DB insert failed')
		raise ex

@task
def open_port(sec_grp, ip_protocol, port, cidr_ip):
	# If API call is successful then in returns True
	if not sec_grp.authorize(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=cidr_ip):
		ex = AppError( "Adding security group rule failed" )
		raise ex
@task
def remove_rule(sec_grp, ip_protocol, port, cidr_ip):
	if not sec_grp.revoke(ip_protocol='tcp', from_port=port, to_port=port, cidr_ip=cidr_ip)
		ex = AppError("Removing security group rule failed")
		raise ex

@task
def add_ip(region, group, port, ip, requester_name):
	"""
	Opens port for a particular IP. Saves the name of the requester.

	:param zone: Environments; prod, stage, dev.
	:param group: Security Group under consideration.
	:param requester_name: Whose IP is being added.

	"""
	cidr_ip = ip+'/32'
	sec_grp_string = 'SecurityGroup:'+group

	# TODO: IP range
	conn = get_ec2(region)

	sec_grps = conn.get_all_security_groups()

	for count in sec_grps:
		if str(count) == sec_grp_string:
			sec_grp = count
	# This should be checked from the yaml
	if len(str(sec_grp)) == 0:
		print('sec grp not found')
		sys.exit(0)

	try:
		open_port(sec_grp, ip_protocol, port, cidr_ip)
	except AppError, ex
		print ex
		sys.exit(0)
		# Exit gracefully

	try:
		db_write()
	except AppError, ex
		print ex
		# Undo the actions
		try:
			remove_rule(sec_grp, ip_protocol, port, cidr_ip)
		except AppError, ex
			print ex
			print ('Remove rule manually')




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




