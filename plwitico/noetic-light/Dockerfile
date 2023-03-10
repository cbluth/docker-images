FROM ssilenzi/noetic:light
LABEL org.opencontainers.image.title="Planning with tight contraints"
LABEL org.opencontainers.image.description="Python / C++ implementation of framework of manipulation planning with tight environment constraints."
LABEL org.opencontainers.image.source="https://github.com/CentroEPiaggio/planning-with-tight-constraints"
LABEL org.opencontainers.image.authors="Simone Silenzi <s.silenzi1@gmail.com>"

USER ubuntu
WORKDIR /workspaces

# Install project dependencies
ARG GITHUB_TOKEN
RUN wget -O gurobi.tar.gz https://packages.gurobi.com/9.5/gurobi9.5.0_linux64.tar.gz && \
  sudo mv gurobi.tar.gz /opt/ && \
  sudo chown root:root /opt/gurobi.tar.gz && \
  sudo tar -C /opt -xzvf /opt/gurobi.tar.gz && \
  sudo rm /opt/gurobi.tar.gz && \
  ( \
  echo ""; \
  echo "# gurobi"; \
  echo "export GUROBI_HOME=\"/opt/gurobi950/linux64\""; \
  echo "export PATH=\"\${PATH}:\${GUROBI_HOME}/bin\""; \
  echo "export LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" \
  ) >> ~/.bashrc && \
  wget -O mosek.tar.bz2 https://download.mosek.com/stable/9.3.11/mosektoolslinux64x86.tar.bz2 && \
  sudo mv mosek.tar.bz2 /opt/ && \
  sudo chown root:root /opt/mosek.tar.bz2 && \
  sudo tar -C /opt -xjvf /opt/mosek.tar.bz2 && \
  sudo rm /opt/mosek.tar.bz2 && \
  ( \  
  echo ""; \
  echo "# mosek"; \
  echo "export PATH=\"\${PATH}:/opt/mosek/9.3/tools/platform/linux64x86/bin\""; \
  ) >> ~/.bashrc && \
  git config --global url."https://${GITHUB_TOKEN}:@github.com/".insteadOf "https://github.com/" && \
  git clone --branch ${ROS_DISTRO}-devel --depth 1 --recurse-submodules \
  https://github.com/CentroEPiaggio/planning-with-tight-constraints.git && \
  git config --global --remove-section url."https://${GITHUB_TOKEN}:@github.com/" && \
  cd planning-with-tight-constraints/ && \
  sudo apt-get update && \
  rosdep update && \
  sudo apt-get dist-upgrade -y && \
  sudo apt-get install -y coinor-libipopt-dev gfortran graphviz graphviz-dev libglpk-dev libmetis-dev && \
  rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -r -y && \
  sudo apt-get clean && \
  sudo rm -Rf /var/lib/apt/lists/* && \
  mkdir ${HOME}/mosek/ && \
  sudo -H CVXOPT_BUILD_GLPK=1 pip3 install --ignore-installed cvxopt gurobipy==9.5.0 ipopt matplotlib mosek==9.3.11 osqp \
  pulp pyclean pygraphviz pyopt quadprog scipy testresources && \
  sudo rm -rf /root/.cache && \
  catkin --version && \
  rm -rf src/planning_with_tight_constraints/ && \
  catkin config --extend /opt/ros/${ROS_DISTRO} --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && \
  catkin build && \
  ccache -s && \
  cd .. && rm -Rf planning-with-tight-constraints/ && mkdir planning-with-tight-constraints/

# Insert the init script
COPY init-script.sh /usr/bin/
RUN sudo chmod +x /usr/bin/init-script.sh

# Start the container
WORKDIR /workspaces/planning-with-tight-constraints
ENTRYPOINT ["init-script.sh"]
CMD ["bash", "-i"]
