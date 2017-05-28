"""This is a Wow build invoke module"""
import yaml
from invoke import task

CONFIG_FILES = ["pkgmeta.yaml", "testconfig.yaml"]


@task
def build(ctx):
    """Build addon files in destination folders"""
    print(ctx)


@task
def clear(ctx):
    """Clear destination folders"""
    return


@task
def watch(ctx):
    """Watch events on project files and trigger some actions when something occure"""
    return


ezaad
