#!/bin/bash
C=/${0}
C=${C%/*}
exec "${C:-.}"/Explorer_ 2>>/tmp/explorer.log
