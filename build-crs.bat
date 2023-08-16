@echo off

docker login -u %DOCKER_LOGIN% -p %DOCKER_PASSWORD% %DOCKER_REGISTRY_URL%

if %ERRORLEVEL% neq 0 goto end

if %DOCKER_SYSTEM_PRUNE%=="true" docker system prune -af

if %ERRORLEVEL% neq 0 goto end

if %NO_CACHE%=="true" (SET last_arg="--no-cache .") else (SET last_arg=".")

docker build ^
	--pull ^
	--build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
	--build-arg ONEC_USERNAME=%ONEC_USERNAME% ^
	--build-arg ONEC_PASSWORD=%ONEC_PASSWORD% ^
	--build-arg ONEC_VERSION=%ONEC_VERSION% ^
	-t %DOCKER_REGISTRY_URL%/crs:%ONEC_VERSION% ^
	-f crs/Dockerfile ^
	%last_arg%
	
if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/crs:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

docker build ^
	--pull ^
	--build-arg DOCKER_REGISTRY_URL=%DOCKER_REGISTRY_URL% ^
	--build-arg ONEC_VERSION=%ONEC_VERSION% ^
	-t %DOCKER_REGISTRY_URL%/crs-apache:%ONEC_VERSION% ^
	-f crs-apache/Dockerfile ^
	%last_arg%
	
if %ERRORLEVEL% neq 0 goto end

docker push %DOCKER_REGISTRY_URL%/crs-apache:%ONEC_VERSION%

if %ERRORLEVEL% neq 0 goto end

:end
echo End of program.