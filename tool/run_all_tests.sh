#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

dartanalyzer $ROOT_DIR/lib/*.dart \
&& dartanalyzer $ROOT_DIR/test/*.dart \
&& dartanalyzer $ROOT_DIR/example/*.dart \
&& dart $ROOT_DIR/test/pretty_test.dart --quiet
