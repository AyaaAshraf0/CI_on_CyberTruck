#!/bin/bash
set -e

source /opt/ros/humble/setup.bash

# install/setup.bash only exists after colcon build has run.
# In CI we build outside the container, so this may not be present at entrypoint time.
if [ -f /app/cyber_truck/install/setup.bash ]; then
    source /app/cyber_truck/install/setup.bash
fi

exec "$@"