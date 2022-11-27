@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_USERNAME%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

docker build ^
	--pull ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
	--build-arg ONEC_VERSION=%ONEC_VERSION% ^
	--build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
	-t %DOCKER_USERNAME%/onec-client:%ONEC_VERSION% ^
	-f client/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_USERNAME%/onec-client:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--pull ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
	--build-arg ONEC_VERSION=%ONEC_VERSION% ^
	--build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
	-t %DOCKER_USERNAME%/onec-client-vnc:%ONEC_VERSION% ^
	-f client-vnc/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_USERNAME%/onec-client-vnc:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=onec-client-vnc ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    -t %DOCKER_USERNAME%/onec-client-vnc-oscript:%ONEC_VERSION% ^
    -f oscript/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=onec-client-vnc-oscript ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    -t %DOCKER_USERNAME%/onec-client-vnc-oscript-jdk:%ONEC_VERSION% ^
    -f jdk/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdk ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    -t %DOCKER_USERNAME%/onec-client-vnc-oscript-jdk-testutils:%ONEC_VERSION% ^
    -f test-utils/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=onec-client-vnc-oscript-jdk-testutils ^
    --build-arg BASE_TAG=%ONEC_VERSION% ^
    -t %DOCKER_USERNAME%/base-jenkins-agent:%ONEC_VERSION% ^
    -f jenkins-agent/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_USERNAME%/base-jenkins-agent:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.