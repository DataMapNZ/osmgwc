#!/bin/bash

# geoserver-import uses the Geoserver REST API to automate loading the styles and publishing the layers in Geoserver

# Get needed variables
if [ -z GS_HOST ]; then
    read -p 'Geoserver URL: ' GS_HOST
fi
if [ -z GS_USER ]; then
    read -p 'Geoserver Username: ' GS_USER
fi
if [ -z GS_PASS ]; then
    read -sp 'Geoserver Password: ' GS_PASS
fi

