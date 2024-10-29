ARG BASE_IMAGE
ARG BASE_TAG
ARG DOCKER_REGISTRY_URL

FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}

RUN edt_path=$(ring edt locations list) \
    && echo $edt_path \
    && ring edt platform-versions \
    && sed -i -e s/4096m/12288m/g $edt_path/1cedt.ini \
    && rm -f $edt_path/configuration/*.log \
    && rm -rf $edt_path/configuration/org.eclipse.core.runtime \
    && rm -rf $edt_path/configuration/org.eclipse.osgi \
    && rm -rf $edt_path/plugin-development \
    && rm -f $edt_path/plugins/com._1c.g5.v8.dt.platform.doc_*.jar \
    && rm -f $edt_path/plugins/com._1c.g5.v8.dt.product.doc_*.jar \
    && rm -f $edt_path/plugins/com.eclipse.egit.doc_*.jar \
    && rm -f $edt_path/plugins/org.eclipse.platform.doc_*.jar \
    && rm -rf /tmp/*