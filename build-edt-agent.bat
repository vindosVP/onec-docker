@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_USERNAME%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

set edt_version=%EDT_VERSION%
set edt_escaped=%edt_version: =_%

docker build ^
	--pull ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
    --build-arg EDT_VERSION=%EDT_VERSION% ^
	-t %DOCKER_USERNAME%/onec-client:%edt_escaped% ^
	-f edt/Dockerfile ^
	%last_arg%

if %ERRORLEVEL% neq 0 goto end

docker build ^
    --build-arg DOCKER_USERNAME=%DOCKER_USERNAME% ^
    --build-arg BASE_IMAGE=edt ^
    --build-arg BASE_TAG=%edt_escaped% ^
    -t %DOCKER_USERNAME%/base-jenkins-agent:%edt_escaped% ^
    -f jenkins-agent/Dockerfile ^
    %last_arg%

if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_USERNAME%/base-jenkins-agent:%edt_escaped%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.
