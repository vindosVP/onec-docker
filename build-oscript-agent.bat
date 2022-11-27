@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_USERNAME%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

docker build ^
	--pull ^
	--build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=onec-client-vnc ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    -t %DOCKER_USERNAME%/onec-client-vnc-oscript:%ONEC_VERSION% ^
    -f oscript/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=oscript-jdk ^
    --build-arg BASE_TAG=latest ^
    -t %DOCKER_USERNAME%/base-jenkins-agent:latest ^
    -f jenkins-agent/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_USERNAME%/base-jenkins-agent:latest

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.