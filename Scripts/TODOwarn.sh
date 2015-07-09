#!/bin/sh

#  TODOwarn.sh
#  oOps
#
#  Created by Alexandr Goncharov on 21/09/14.
#  Copyright (c) 2014 BeKitzur. All rights reserved.

KEYWORDS="TODO:|VERIFY:|FIXME:|\?\?\?:|\!\!\!:"
find "${SRCROOT}" -name "*.h" -or -name "*.m" -or -name "*.swift" -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ warning: \$1/"
