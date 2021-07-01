# Specify OS
FROM ubuntu:18.04
SHELL ["/bin/bash", "-c"]

# Update package manager
RUN apt-get update && apt-get clean 

# Install basic linux packages
RUN apt-get install -y build-essential

# Install CMake
RUN apt-get install -y cmake

# Download G4 source code
RUN apt-get install -y wget
RUN wget http://cern.ch/geant4-data/releases/geant4.10.07.p02.tar.gz
RUN tar -xf geant4.10.07.p02.tar.gz

# Install NVIDIA drivers
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
RUN apt-get install -y ubuntu-drivers-common
RUN ubuntu-drivers autoinstall

# Install X11
RUN apt-get install -y libx11-dev 
RUN apt-get install -y libxmu-dev

# Install Qt5
#RUN apt-get install -y qt5-default

# Install OpenGL
RUN apt-get install -y libgl1-mesa-glx freeglut3-dev mesa-common-dev
RUN apt-get install -y libqt5opengl5

# Installing Expat
RUN apt-get install -y expat

# Building and Installing G4
RUN mkdir geant4.10.07.p02-build && mkdir geant4.10.07.p02-install
WORKDIR ./geant4.10.07.p02-build
RUN cmake -DGEANT4_INSTALL_DATA=ON \
          -DGEANT4_USE_SYSTEM_EXPAT=OFF \
          #-DGEANT4_USE_QT=ON \
          -DGEANT4_USE_OPENGL_X11=ON \
          -DCMAKE_INSTALL_PREFIX=../geant4.10.07.p02-install \
          ../geant4.10.07.p02
RUN make -j4
RUN make install -j4

# Set G4 environment variables
RUN source /geant4.10.07.p02-build/geant4make.sh
WORKDIR ../
RUN source /geant4.10.07.p02-install/bin/geant4.sh

# Set data environment variables
ENV G4ABLADATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4ABLA3.1
ENV G4ENSDFSTATEDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4ENSDFSTATE2.3
ENV G4INCLDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4INCL1.0
ENV G4LEDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4EMLOW7.13
ENV G4LEVELGAMMADATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/PhotonEvaporation5.7
ENV G4NEUTRONHPDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4NDL4.6
ENV G4PARTICLEXSDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4PARTICLEXS3.1.1
ENV G4PIIDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4PII1.3
ENV G4RADIOACTIVEDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/RadioactiveDecay5.6
ENV G4REALSURFACEDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/RealSurface2.2
ENV G4SAIDXSDATA=/geant4.10.07.p02-install/share/Geant4-10.7.2/data/G4SAIDDATA2.0

# Copy source files from local directory
COPY . ./source
WORKDIR source

# Build source project
RUN mkdir build
WORKDIR build
RUN cmake ..
RUN make -j4

# Set runtime environment variables
#ENV G4UI_QT_USE=ON
ENV LIBGL_ALWAYS_INDIRECT=1

# Run the project
CMD ["./exampleB1"]