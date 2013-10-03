#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

dartanalyzer --no-hints $ROOT_DIR/lib/*.dart \
&& dartanalyzer --no-hints $ROOT_DIR/test/*.dart \
&& dartanalyzer --no-hints $ROOT_DIR/example/*.dart \
&& dart $ROOT_DIR/test/pretty_test.dart --quiet
