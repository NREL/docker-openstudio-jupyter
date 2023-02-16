## Jupyter Notebooks with OpenStudio SDK use examples in a Docker container.

This repo contains a Docker container with IRuby Jupyter notebooks with examples using various functionality of the OpenStudio SDK.
The examples include  
#### URBANopt
1. Creating an URBANopt workflow
2. Creating an URBANopt OpenStudio Analysis (OSA) workflow for optimization
3. Submitting an URBANopt job to a cloud based Server  
#### Creating OpenStudio Workflow (OSW) and OpenStudio Analysis (OSA) jsons  
1. Creating an OSW json to run several Measures on an example OpenStudio Model (OSM)  
2. Adding a Calibration Measure to the OSW
3. Turning the OSW into an OSA to use Algorithms such as Sensitivity Analysis and Optimization.  

The notebooks have several dependencies which are pre-installed in a Docker container.
The intent is to make that part of the process easier for newer users.
The notebooks can be used outside of the containers, provided the dependencies are installed locally.
The user needs to install Docker and then either build the container locally or pull the container from dockerhub.
Instructions to do that follow:

#### Installing Docker  
1. Go to the official Docker website and download the appropriate installer for your platform: [www.docker.com](https://www.docker.com/get-started)  
2. Once the download is complete, run the installer and follow the on-screen instructions.  
3. After the installation is complete, open a terminal or command prompt and verify that Docker is installed by typing the following command:  
`docker --version`  
This should display the version of Docker installed on your system.  

4. If you plan to use Docker as a non-root user, add your user to the "docker" group with the following command:  
`sudo usermod -aG docker your-user`  
Replace "your-user" with your actual username.  

5. Finally, start the Docker service with the following command:
`sudo systemctl start docker`  
On some systems, you may need to use a different command to start the Docker service.  

#### Building the container locally
Git Clone this repo locally, open a terminal or command prompt and build the container with the following command:   
`docker build . -t "os-jupyter"`  
This builds the container with the name `os-jupyter`.   
Once the container is built, to run the container without the full Server stack execute:  
`docker run -p 127.0.0.1:8888:8888 os-jupyter`  
This will start the `os-jupyter` container, using the localhost IP of 127.0.0.1, on port 8888.  
In some instances a different IP or port maybe needed.

#### Starting a Full Stack OpenStudio-Server and Notebook
To stand up a full stack of the OpenStudio-Server with one worker to submit jobs to, open a terminal or command prompt in the root of the repo and use the following commands:  

`docker swarm init`  
`docker stack deploy osserver --compose-file=docker-compose.yml`  

This will start the docker swarm and should print out an IP address to the screen.  This is the same IP address from `docker info` and looking for the **Node Address**.  Note the port is not needed, just the IP address.  In some instances the full file path to the docker-compose.yml file will be needed.  You can verify that the stack has started by using the command:  

`docker service ls`  

and looking for 1/1 and not 0/1 for all the services. If you have enough base computing resources allocated to Docker on your computer, you can start more worker services by  

`docker service scale osserver_worker=X`  where **X** is the integer number of workers you want.  

Verify that the Server Stack has started by opening [localhost:8080](http://localhost:8080/) in a web browser.  You should see the server main GUI page.  

The notebooks can be accessed by opening [localhost:8888](http://localhost:8888/) in a web browser.
 

Please submit issues or enhancement requests on the project's [Github](https://github.com/NREL/docker-openstudio-jupyter/issues) page. 
