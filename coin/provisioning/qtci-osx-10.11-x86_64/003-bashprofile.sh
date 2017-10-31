#!/bin/sh

# Read .bashrc if exist
printf -- "# Get the aliases and functions\nif [ -f ~/.bashrc ]; then\n        . ~/.bashrc\nfi\n" >> ~/.bash_profile

