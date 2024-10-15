#!/bin/bash

version="1.0.6"
pip install flit
git clone https://github.com/microsoft/confidential-aci-testing.git
(cd confidential-aci-testing && git checkout $version && flit install)