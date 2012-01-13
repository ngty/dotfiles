#!/bin/bash
ME=`basename ${BASH_SOURCE[0]}`
for s in `ls */$ME`; do ./$s; end

# __END__
